var https = require('https');
var util = require('util');
var channel = "#alerts"
var url = "/services/TCHRTAZBJ/B013V88L6NS/01h8egzpkWuDQpT6XmikjxMM"
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var time = new Date();

exports.handler = function(event, context, cb) {
    console.log(JSON.stringify(event, null, 2));
    console.log('From SNS:', event.Records[0].Sns.Message);
    const date = new Date(event.Records[0].Sns.Timestamp).toISOString().slice(0, 10);
    const id = `iteration2:${date}`;
    var hour =   time.getHours();
    var day = time.getDay();

    var params = {
        'TableName': "ratelimit",
        'Key': { "id": {S: id} },
        'UpdateExpression': "ADD MessageIds :MessageIds",
        'ConditionExpression': 'not contains (MessageIds, :MessageId)',
        'ExpressionAttributeValues': {
            ':MessageId': {S: event.Records[0].Sns.MessageId},
            ':MessageIds': {'SS': [event.Records[0].Sns.MessageId]}
    },
    //ReturnValues: 'UPDATED_NEW'
  };

    var icon_emoji = ":thumbsup:";
    var postData = {
        "channel": channel,
        "username": "CloudwatchAlarm-Sns-Lambda-Slack",
        "text": "*" + event.Records[0].Sns.Subject + "*",
        "icon_emoji": ":aws:"
    };

    var message = event.Records[0].Sns.Message;
    var severity = "good";

    var dangerMessages = [
        "This alarm triggers when",
        "HealthyHostCount"
        ];

    var warningMessages = [
        ];

    for(var dangerMessagesItem in dangerMessages) {
        if (message.indexOf(dangerMessages[dangerMessagesItem]) != -1) {
            severity = "danger";
            icon_emoji = ":thumbsdown:";
            break;
        }
    }

    // Only check for warning messages if necessary
    if (severity == "good") {
        for(var warningMessagesItem in warningMessages) {
            if (message.indexOf(warningMessages[warningMessagesItem]) != -1) {
                severity = "warning";
                break;
            }
        }
    }

    postData.attachments = [
        {
            "color": severity,
            "text": message
        }
    ];

    var options = {
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: url
    };

    if(day >= 1 && day <= 5){
        if(hour >= 8 && hour <= 20){
                console.log("inside");
                console.log('You will see this message every second');
                if ("good" != severity) {
                  var req = https.request(options, function(res) {
                    res.setEncoding('utf8');
                    res.on('data', function (chunk) {
                      context.done(null);
                    });
                  });
                  console.log('Before req.on error');
                  req.on('error', function(e) {
                    console.log('problem with request: ' + e.message);
                  });

                  dynamodb.updateItem(params, function(err) {
    		              if (err) {
      			               console.log("error " + err);
      			               if (err.code === 'ConditionalCheckFailedException') { // $limit requests in set and current request is not in set
        			                  cb(null, {limited: true});
        			                  console.log("conditional error the messageid already exists");
      			               } else {
        			                  console.log("ok");
      			               }
    		              } else {
      			               console.log("error " + err);
      			               req.write(util.format("%j", postData));
            	               cb(null, {limited: false});
    		              }
    		              req.end();
  	              });

                }
        } else {
            console.log("outside time")
        }
    } else {
        console.log("outside day")
    }
    console.log('outside loop');
};
