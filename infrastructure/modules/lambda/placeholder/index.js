// Placeholder Lambda handler used by Terraform during Faz 0.
// Real code is deployed in Faz 2 via `aws lambda update-function-code`.
exports.handler = async () => ({
  statusCode: 200,
  body: JSON.stringify({ message: "cryptoflow lambda placeholder" }),
});
