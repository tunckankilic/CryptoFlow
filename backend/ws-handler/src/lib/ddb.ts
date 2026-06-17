import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';
import { config } from '../config';

export const ddb = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: config.region }),
  {
    marshallOptions: { removeUndefinedValues: true },
  },
);
