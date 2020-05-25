const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const limit = 8;
exports.handler = (event, context, cb) => {
  const date = new Date().toISOString().slice(0, 10); // yyyy-mm-dd
  const id = `iteration1:${event.user}:${date}`;
  dynamodb.updateItem({
    TableName: `ratelimit`,
    Key: {
      id: {S: id},
    },
    UpdateExpression: 'ADD calls :one',  // increase attribute calls by one, if the calls attribute not exists, a value of 0 is assumed
    ExpressionAttributeValues: {
      ':one': {N: '1'}
    },
    ReturnValues: 'ALL_NEW'
  }, function(err, data) {
    if (err) {
      cb(err);
    } else {
      const calls = parseInt(data.Attributes.calls.N, 10);
      cb(null, {limited: calls > limit});
    }
  });
};
