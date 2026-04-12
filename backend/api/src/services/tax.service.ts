import PDFDocument from 'pdfkit';
import { ulid } from 'ulid';
import { putObject, getDownloadUrl, listObjectsByPrefix } from '../lib/s3';
import { listTransactions } from './portfolio.service';
import { ValidationError } from '../errors';
import type { ReportMetadata } from '../models/report';

// ── Types ────────────────────────────────────────────────────────────────────

export type CostBasisMethod = 'FIFO' | 'LIFO' | 'HIFO';

export interface TaxReportInput {
  year: number;
  costBasisMethod: CostBasisMethod;
  jurisdiction?: string;
}

export interface TaxLot {
  date: string;
  quantity: number;
  costBasis: number;
  remaining: number;
}

export interface CapitalGainEntry {
  symbol: string;
  acquiredDate: string;
  soldDate: string;
  quantity: number;
  costBasis: number;
  proceeds: number;
  gainLoss: number;
  isLongTerm: boolean;
}

export interface TaxSummary {
  year: number;
  method: CostBasisMethod;
  jurisdiction: string;
  totalShortTermGains: number;
  totalLongTermGains: number;
  totalShortTermLosses: number;
  totalLongTermLosses: number;
  netGainLoss: number;
  entries: CapitalGainEntry[];
}

// ── Cost Basis Calculation ───────────────────────────────────────────────────

function selectLot(lots: TaxLot[], method: CostBasisMethod): number {
  if (lots.length === 0) return -1;
  const available = lots.map((l, i) => ({ ...l, idx: i })).filter((l) => l.remaining > 0);
  if (available.length === 0) return -1;

  switch (method) {
    case 'FIFO':
      return available[0].idx;
    case 'LIFO':
      return available[available.length - 1].idx;
    case 'HIFO':
      return available.reduce((max, l) => (l.costBasis > available[max.idx === undefined ? 0 : max.idx].costBasis ? l : max), available[0]).idx;
    default:
      return available[0].idx;
  }
}

function calculateCapitalGains(
  transactions: Array<{ symbol: string; type: string; quantity: number; price: number; fee: number; timestamp: string }>,
  year: number,
  method: CostBasisMethod,
): CapitalGainEntry[] {
  // Group by symbol
  const bySymbol = new Map<string, typeof transactions>();
  for (const tx of transactions) {
    const list = bySymbol.get(tx.symbol) ?? [];
    list.push(tx);
    bySymbol.set(tx.symbol, list);
  }

  const entries: CapitalGainEntry[] = [];
  const longTermMs = 365 * 24 * 60 * 60 * 1000;

  for (const [symbol, txs] of bySymbol) {
    const sorted = [...txs].sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());
    const lots: TaxLot[] = [];

    for (const tx of sorted) {
      if (tx.type === 'buy') {
        lots.push({
          date: tx.timestamp,
          quantity: tx.quantity,
          costBasis: tx.price + tx.fee / tx.quantity,
          remaining: tx.quantity,
        });
      } else if (tx.type === 'sell') {
        const sellDate = new Date(tx.timestamp);
        // Only include sales from the target year
        if (sellDate.getFullYear() !== year) continue;

        let remainingToSell = tx.quantity;
        const proceeds = tx.price - tx.fee / tx.quantity;

        while (remainingToSell > 0) {
          const lotIdx = selectLot(lots, method);
          if (lotIdx < 0) break;

          const lot = lots[lotIdx];
          const qty = Math.min(remainingToSell, lot.remaining);
          const costBasis = lot.costBasis * qty;
          const saleProceeds = proceeds * qty;
          const acquireDate = new Date(lot.date);
          const holdingPeriod = sellDate.getTime() - acquireDate.getTime();

          entries.push({
            symbol,
            acquiredDate: lot.date,
            soldDate: tx.timestamp,
            quantity: Math.round(qty * 1e8) / 1e8,
            costBasis: Math.round(costBasis * 100) / 100,
            proceeds: Math.round(saleProceeds * 100) / 100,
            gainLoss: Math.round((saleProceeds - costBasis) * 100) / 100,
            isLongTerm: holdingPeriod >= longTermMs,
          });

          lot.remaining -= qty;
          remainingToSell -= qty;
        }
      }
    }
  }

  return entries;
}

// ── PDF Generation ───────────────────────────────────────────────────────────

async function renderTaxPdf(summary: TaxSummary): Promise<Buffer> {
  return new Promise<Buffer>((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const chunks: Buffer[] = [];
    doc.on('data', (c) => chunks.push(c as Buffer));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    // Title
    doc.fontSize(20).text('CryptoFlow Tax Report', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12).text(`Tax Year: ${summary.year}`);
    doc.text(`Cost Basis Method: ${summary.method}`);
    doc.text(`Jurisdiction: ${summary.jurisdiction}`);
    doc.text(`Generated: ${new Date().toISOString()}`);
    doc.moveDown();

    // Summary
    doc.fontSize(14).text('Summary', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(10);
    doc.text(`Short-Term Gains: $${summary.totalShortTermGains.toFixed(2)}`);
    doc.text(`Short-Term Losses: $${summary.totalShortTermLosses.toFixed(2)}`);
    doc.text(`Long-Term Gains: $${summary.totalLongTermGains.toFixed(2)}`);
    doc.text(`Long-Term Losses: $${summary.totalLongTermLosses.toFixed(2)}`);
    doc.text(`Net Gain/Loss: $${summary.netGainLoss.toFixed(2)}`, {
      continued: false,
    });
    doc.moveDown();

    // Detailed entries
    doc.fontSize(14).text('Capital Gains & Losses', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(8);

    for (const entry of summary.entries) {
      const term = entry.isLongTerm ? 'LT' : 'ST';
      doc.text(
        `[${term}] ${entry.symbol}  qty=${entry.quantity}  ` +
          `acquired=${entry.acquiredDate.slice(0, 10)}  sold=${entry.soldDate.slice(0, 10)}  ` +
          `cost=$${entry.costBasis.toFixed(2)}  proceeds=$${entry.proceeds.toFixed(2)}  ` +
          `gain/loss=$${entry.gainLoss.toFixed(2)}`,
      );
    }

    doc.end();
  });
}

// ── Public API ───────────────────────────────────────────────────────────────

export async function generateTaxReport(
  userId: string,
  input: TaxReportInput,
): Promise<ReportMetadata> {
  if (!input.year) throw new ValidationError('year is required');
  if (!input.costBasisMethod) throw new ValidationError('costBasisMethod is required');
  if (!['FIFO', 'LIFO', 'HIFO'].includes(input.costBasisMethod)) {
    throw new ValidationError('costBasisMethod must be FIFO, LIFO, or HIFO');
  }

  const transactions = await listTransactions(userId);
  const entries = calculateCapitalGains(transactions, input.year, input.costBasisMethod);

  const summary: TaxSummary = {
    year: input.year,
    method: input.costBasisMethod,
    jurisdiction: input.jurisdiction ?? 'US',
    totalShortTermGains: entries.filter((e) => !e.isLongTerm && e.gainLoss > 0).reduce((s, e) => s + e.gainLoss, 0),
    totalLongTermGains: entries.filter((e) => e.isLongTerm && e.gainLoss > 0).reduce((s, e) => s + e.gainLoss, 0),
    totalShortTermLosses: entries.filter((e) => !e.isLongTerm && e.gainLoss < 0).reduce((s, e) => s + Math.abs(e.gainLoss), 0),
    totalLongTermLosses: entries.filter((e) => e.isLongTerm && e.gainLoss < 0).reduce((s, e) => s + Math.abs(e.gainLoss), 0),
    netGainLoss: entries.reduce((s, e) => s + e.gainLoss, 0),
    entries,
  };

  const reportId = ulid();
  const key = `${userId}/tax/${reportId}.pdf`;
  const buffer = await renderTaxPdf(summary);
  await putObject(key, buffer, 'application/pdf');
  const downloadUrl = await getDownloadUrl(key, 86400); // 24 hours

  return {
    reportId,
    type: 'tax',
    key,
    size: buffer.length,
    createdAt: new Date().toISOString(),
    downloadUrl,
  };
}

export async function listTaxReports(userId: string): Promise<ReportMetadata[]> {
  const objects = await listObjectsByPrefix(`${userId}/tax/`);
  return objects.map((o) => ({
    reportId: o.key.split('/').pop()?.replace('.pdf', '') ?? o.key,
    type: 'tax' as const,
    key: o.key,
    size: o.size,
    createdAt: o.lastModified?.toISOString() ?? new Date().toISOString(),
  }));
}
