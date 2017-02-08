var fs = require('fs');
var glob = require("glob");
var inquirer = require('inquirer');
var xcode = require('xcode');
var path = require('path');
var plist = require('plist');
var _ = require('lodash');
var pbxFile = require('xcode/lib/pbxFile');
var package = require('../../../../package.json');

var ignoreNodeModules = { ignore: "node_modules/**" };
var appDelegatePaths = glob.sync("**/AppDelegate.m", ignoreNodeModules);


// Fix for https://github.com/Microsoft/react-native-code-push/issues/477
// Typical location of AppDelegate.m for newer RN versions: $PROJECT_ROOT/ios/<project_name>/AppDelegate.m
// Let's try to find that path by filtering the whole array for any path containing <project_name>
// If we can't find it there, play dumb and pray it is the first path we find.
var appDelegatePath = findFileByAppName(appDelegatePaths, package ? package.name : null) || appDelegatePaths[0];
var plistPath = glob.sync(path.join(path.dirname(appDelegatePath), "*Info.plist").replace(/\\/g, "/"), ignoreNodeModules)[0];
var appDelegateContents = fs.readFileSync(appDelegatePath, "utf8");
var plistContents = fs.readFileSync(plistPath, "utf8");
var skipAddAppId = false;
var addTypes = false;
var qqSchemes = ['mqqapi','mqq','mqqOpensdkSSoLogin','mqqconnect','mqqopensdkdataline',
  'mqqopensdkgrouptribeshare', 'mqqopensdkfriend','mqqopensdkapi','mqqopensdkapiV2',
  'mqqopensdkapiV3','mqzoneopensdk','wtloginmqq','wtloginmqq2', 'mqqwpa','mqzone',
  'mqzonev2','mqzoneshare','wtloginqzone','mqzonewx','mqzoneopensdkapiV2',
  'mqzoneopensdkapi19','mqzoneopensdkapi', 'mqzoneopensdk','mqqopensdkapiv4'];


addRCTLinkManagerHeader();
addLinkFunction();
addFrameworkAndSearchPath()
addAppID();
addQueriesSchemes();


function addRCTLinkManagerHeader() {
  var linkHeaderImportStatement = `#import <React/RCTLinkingManager.h>`;
  if (~appDelegateContents.indexOf(linkHeaderImportStatement)) {
      console.log(`"RCTLinkingManager.h" header already imported.`);
  } else {
      var appDelegateHeaderImportStatement = `#import "AppDelegate.h"`;
      appDelegateContents = appDelegateContents.replace(appDelegateHeaderImportStatement,
          `${appDelegateHeaderImportStatement}\n${linkHeaderImportStatement}`);
  }
  fs.writeFileSync(appDelegatePath, appDelegateContents);
}

function addLinkFunction() {
  var linkFunctionName =  `- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation`.replace(/(\r\n|\n|\r)/gm,"").replace(/\s/g,'').trim();
  var linkFunction = `- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
  {
    return [RCTLinkingManager application:application openURL:url
                        sourceApplication:sourceApplication annotation:annotation];
  }`;
  if (~appDelegateContents.replace(/(\r\n|\n|\r)/gm,"").replace(/\s/g,'').trim().indexOf(linkFunctionName)) {
      console.log(`link function already imported.`);
  } else {
      var appDelegateEndStatement = `@end`;
      appDelegateContents = appDelegateContents.replace(appDelegateEndStatement,
          `${linkFunction}\n${appDelegateEndStatement}`);
  }
  fs.writeFileSync(appDelegatePath, appDelegateContents);
}

function addAppID() {
  var parsedInfoPlist = plist.parse(plistContents);
  var types = parsedInfoPlist.CFBundleURLTypes;
  types ? (skipAddAppId = findAppID(types) === -1? false : true):addTypes = true;
  addURLTypesForTencentSDK();
}

function findAppID(types) {
  return _.findIndex(types, function(schemes) {
    return -1 !== _.findIndex(schemes.CFBundleURLSchemes,function (scheme) {
        return scheme.startsWith('tencent');
      })
  });
}

function addURLTypesForTencentSDK() {
  if (skipAddAppId) {
    console.log("发现已经存在AppID");
  } else {
    inquirer.prompt([{
      type: "input",
      name: "AppID",
      message: "What is your Tencent SDK AppID for iOS (hit <ENTER> to ignore)"
    }]).then(function(answer) {
      var key = ('tencent' + answer.AppID) || "app-id-here";
      var qqAppId = {
        CFBundleURLName: 'qqAppId',
        CFBundleTypeRole: 'Editor',
        CFBundleURLSchemes: [key]
      };
      var parsedInfoPlist = plist.parse(plistContents);
      if (addTypes){
        parsedInfoPlist.CFBundleURLTypes = [];
      }
      parsedInfoPlist.CFBundleURLTypes.push(qqAppId);
      plistContents = plist.build(parsedInfoPlist);
      fs.writeFileSync(plistPath, plistContents);
    }).then(function(){
      addAppIdToGradle()
    });
  }
}

function addQueriesSchemes() {
  var parsedInfoPlist = plist.parse(plistContents);
  var schemes = parsedInfoPlist.LSApplicationQueriesSchemes;
  parsedInfoPlist.LSApplicationQueriesSchemes = schemes? _.union(schemes,qqSchemes):qqSchemes;
  plistContents = plist.build(parsedInfoPlist);
  fs.writeFileSync(plistPath, plistContents);
}
// Helper that filters an array with AppDelegate.m paths for a path with the app name inside it
// Should cover nearly all cases
function findFileByAppName(array, appName) {
    if (array.length === 0 || !appName) return null;
    for (var i = 0; i < array.length; i++) {
        var path = array[i];
        if (path && path.indexOf(appName) !== -1) {
            return path;
        }
    }
    return null;
}
function addAppIdToGradle() {
  var buildGradlePath =path.join(__dirname,'../','../','./android/build.gradle');
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
    console.log('App ID 可能已存在，如果要进行修改请在react-native-qqsdk的Gradle文件中手动修改Android App ID');
  }
}

function addFrameworkAndSearchPath() {
  var projectPath = glob.sync("**/project.pbxproj", ignoreNodeModules)[0];
  var project = xcode.project(projectPath);
  var frameworkPath = path.join(__dirname,'../node_modules/react-native-qqsdk/ios/RCTQQSDK/TencentOpenAPI.framework');
  var project_dir = path.join(__dirname);
  var project_relative = path.relative(project_dir, frameworkPath);
    project.parse(function (error) {
      if (error) {
        console.log('xcode project error is', error);
      } else {
        var target = project.getFirstTarget().uuid;        
        var file = new pbxFile(project_relative,{customFramework: true, target:target});
        file.uuid = project.generateUuid();
        file.fileRef = project.generateUuid();
        file.target = target;
        if (project.hasFile(file.path)) return false;
         project.addToPbxBuildFileSection(file);        // PBXBuildFile
         project.addToPbxFileReferenceSection(file);    // PBXFileReference
         project.addToFrameworksPbxGroup(file);         // PBXGroup
         project.addToPbxFrameworksBuildPhase(file);    // PBXFrameworksBuildPhase
         //project.addToFrameworkSearchPaths(file);
        addSearchPaths(project,'"$(SRCROOT)/../node_modules/react-native-qqsdk/ios/RCTQQSDK/**"');
        fs.writeFileSync(projectPath, project.writeSync());
      }
    });
}

function addSearchPaths(project, frameworkSearchPath) {
  const config = project.pbxXCBuildConfigurationSection();
  const INHERITED = '"$(inherited)"';
  Object
    .keys(config)
    .filter(ref => ref.indexOf('_comment') === -1)
    .forEach(ref => {
      const buildSettings = config[ref].buildSettings;
      const shouldVisitBuildSettings = (
        buildSettings['PRODUCT_NAME'] === package.name);
    if (shouldVisitBuildSettings) {
      if (!buildSettings['FRAMEWORK_SEARCH_PATHS']
        || buildSettings['FRAMEWORK_SEARCH_PATHS'] === INHERITED) {
        buildSettings['FRAMEWORK_SEARCH_PATHS'] = [INHERITED];
      }
      var framworkIndex = _.findIndex(buildSettings['FRAMEWORK_SEARCH_PATHS'], function(path) { return path == frameworkSearchPath; });
      if (framworkIndex === -1) {
        buildSettings['FRAMEWORK_SEARCH_PATHS'].push(frameworkSearchPath);
      }
    }
  });
};

