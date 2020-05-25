var https = require('https');
var util = require('util');
var channel = "#alerts"
var url = "/services/TCHRTAZBJ/B013V88L6NS/01h8egzpkWuDQpT6XmikjxMM"
var date = new Date();
var hour = date.getHours();

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));
    console.log('From SNS:', event.Records[0].Sns.Message);

    var icon_emoji = ":thumbsup:"
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
            icon_emoji = ":thumbsdown:"
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
    
    var CronJob = require('cron').CronJob;
    new CronJob('* * 15 * * 1-5', function() {
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
            req.write(util.format("%j", postData));
            req.end();
            console.log('end of loop');
      }
    },null, true,'Europe/Dublin');
    console.log('outside loop');
    //job.start();
    //job.cancel();

    // if (hour > 12 && hour < 21) {
    //    if ("good" != severity) {
    //      var req = https.request(options, function(res) {
    //        res.setEncoding('utf8');
    //        res.on('data', function (chunk) {
    //        context.done(null);
    //      });
    //    });

    //    console.log('Before req.on error');
    //    req.on('error', function(e) {
    //      console.log('problem with request: ' + e.message);
    //    });

    //    req.write(util.format("%j", postData));
    //    req.end();
   // }
 // }
};
