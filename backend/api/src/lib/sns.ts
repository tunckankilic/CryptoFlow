import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';
import { config } from '../config';

export const sns = new SNSClient({ region: config.region });

export interface PushPayload {
  userId: string;
  type: string;
  title?: string;
  body?: string;
  data?: Record<string, unknown>;
}

export async function publishNotification(payload: PushPayload): Promise<void> {
  await sns.send(
    new PublishCommand({
      TopicArn: config.snsTopicArn,
      Message: JSON.stringify(payload),
      MessageAttributes: {
        userId: { DataType: 'String', StringValue: payload.userId },
        type: { DataType: 'String', StringValue: payload.type },
      },
    }),
  );
}
