import PDFDocument from 'pdfkit';
import { ulid } from 'ulid';
import { putObject, getDownloadUrl, listObjectsByPrefix } from '../lib/s3';
import { listHoldings, listTransactions } from './portfolio.service';
import { ValidationError } from '../errors';
import type { ReportMetadata, ReportType } from '../models/report';

export interface GenerateReportInput {
  type: ReportType;
}

export async function generateReport(
  userId: string,
  input: GenerateReportInput,
): Promise<ReportMetadata> {
  if (!input.type) throw new ValidationError('type is required');

  const reportId = ulid();
  const key = `${userId}/${reportId}.pdf`;
  const buffer = await renderPdf(userId, input.type);
  await putObject(key, buffer, 'application/pdf');
  const downloadUrl = await getDownloadUrl(key, 3600);

  return {
    reportId,
    type: input.type,
    key,
    size: buffer.length,
    createdAt: new Date().toISOString(),
    downloadUrl,
  };
}

export async function listReports(userId: string): Promise<ReportMetadata[]> {
  const objects = await listObjectsByPrefix(`${userId}/`);
  return objects.map((o) => ({
    reportId: o.key.split('/').pop()?.replace('.pdf', '') ?? o.key,
    type: 'portfolio' as ReportType,
    key: o.key,
    size: o.size,
    createdAt: o.lastModified?.toISOString() ?? new Date().toISOString(),
  }));
}

async function renderPdf(userId: string, type: ReportType): Promise<Buffer> {
  const [holdings, transactions] = await Promise.all([
    listHoldings(userId),
    listTransactions(userId),
  ]);

  return new Promise<Buffer>((resolve, reject) => {
    const doc = new PDFDocument({ size: 'A4', margin: 50 });
    const chunks: Buffer[] = [];
    doc.on('data', (c) => chunks.push(c as Buffer));
    doc.on('end', () => resolve(Buffer.concat(chunks)));
    doc.on('error', reject);

    doc.fontSize(20).text('CryptoFlow Report', { align: 'center' });
    doc.moveDown();
    doc.fontSize(12).text(`Type: ${type}`);
    doc.text(`Generated: ${new Date().toISOString()}`);
    doc.moveDown();

    doc.fontSize(14).text('Holdings', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(10);
    if (holdings.length === 0) {
      doc.text('(no holdings)');
    } else {
      for (const h of holdings) {
        doc.text(
          `${h.symbol}  qty=${h.quantity}  avgBuy=${h.avgBuyPrice}  cost=${(
            h.quantity * h.avgBuyPrice
          ).toFixed(2)}`,
        );
      }
    }
    doc.moveDown();
    doc.fontSize(14).text('Transactions', { underline: true });
    doc.moveDown(0.5);
    doc.fontSize(10);
    if (transactions.length === 0) {
      doc.text('(no transactions)');
    } else {
      for (const t of transactions) {
        doc.text(
          `${t.timestamp}  ${t.type.toUpperCase()}  ${t.symbol}  qty=${t.quantity}  price=${t.price}  fee=${t.fee} ${t.feeAsset}`,
        );
      }
    }

    doc.end();
  });
}
