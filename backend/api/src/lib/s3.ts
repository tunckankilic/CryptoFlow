import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  ListObjectsV2Command,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { config } from '../config';

export const s3 = new S3Client({ region: config.region });

export async function putObject(
  key: string,
  body: Buffer | Uint8Array | string,
  contentType: string,
): Promise<void> {
  await s3.send(
    new PutObjectCommand({
      Bucket: config.reportsBucket,
      Key: key,
      Body: body,
      ContentType: contentType,
      ServerSideEncryption: 'AES256',
    }),
  );
}

export async function getDownloadUrl(key: string, expiresInSeconds = 3600): Promise<string> {
  const cmd = new GetObjectCommand({
    Bucket: config.reportsBucket,
    Key: key,
  });
  return getSignedUrl(s3, cmd, { expiresIn: expiresInSeconds });
}

export async function listObjectsByPrefix(prefix: string): Promise<
  Array<{ key: string; size: number; lastModified?: Date }>
> {
  const out = await s3.send(
    new ListObjectsV2Command({
      Bucket: config.reportsBucket,
      Prefix: prefix,
    }),
  );
  return (out.Contents ?? []).map((o) => ({
    key: o.Key!,
    size: o.Size ?? 0,
    lastModified: o.LastModified,
  }));
}
