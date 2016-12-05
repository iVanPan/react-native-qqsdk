var fs = require('fs');
var inquirer = require('inquirer');
var path = require("path");

var buildGradlePath =path.join(__dirname,'../','../','../','./android/build.gradle');
var buildGradleContents = fs.readFileSync(buildGradlePath, "utf8");
var appIDLink = "${QQ_APP_ID}";
if (~buildGradleContents.indexOf(appIDLink)) {
  inquirer.prompt([{
    type: "input",
    name: "AppID",
    message: "What is your Tencent SDK AppID for Android (hit <ENTER> to ignore)"
  }]).then(function(answer) {
    var key = answer.AppID || "app-id-here";
    buildGradleContents = buildGradleContents.replace(appIDLink,
      `${key}`);
    fs.writeFileSync(buildGradlePath, buildGradleContents);
  });
} else {
  console.log('请在react-native-qqsdk中手动设置Android App ID');
}