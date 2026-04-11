export type ReportType = 'portfolio' | 'tax' | 'performance';

export interface ReportMetadata {
  reportId: string;
  type: ReportType;
  key: string;
  size: number;
  createdAt: string;
  downloadUrl?: string;
}
