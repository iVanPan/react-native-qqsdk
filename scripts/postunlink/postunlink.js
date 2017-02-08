var fs = require('fs');
var glob = require('glob');
var inquirer = require('inquirer');
var path = require('path');
var plist = require('plist');
var xcode = require('xcode');
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

removeRCTLinkManagerHeader();
removeLinkFunction();
removeAppID();
removeQueriesSchemes();
removeFrameworkAndSearchPath();


function removeRCTLinkManagerHeader() {
  var linkHeaderImportStatement = `#import <React/RCTLinkingManager.h>`;
  if (~appDelegateContents.indexOf(linkHeaderImportStatement)) {
      console.log(`"RCTLinkingManager.h" header delete.`);
      appDelegateContents = appDelegateContents.replace(linkHeaderImportStatement,'');
  } 
  fs.writeFileSync(appDelegatePath, appDelegateContents);
}

function removeLinkFunction() {
  var linkFunctionName =  `- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation`.replace(/(\r\n|\n|\r)/gm,"").replace(/\s/g,'').trim();
  var linkFunction = `- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
  {
    return [RCTLinkingManager application:application openURL:url
                        sourceApplication:sourceApplication annotation:annotation];
  }`;
  if (~appDelegateContents.replace(/(\r\n|\n|\r)/gm,"").replace(/\s/g,'').trim().indexOf(linkFunctionName)) {
      console.log(`如果没有使用RCTLinking的功能，你所使用第三方库也没有依赖RCTLinkingManager，你可以删除在AppDelegate.m中RCTLinkingManager相关方法`);
      console.log('相关内容你可以查看 react native 文档:http://facebook.github.io/react-native/docs/linking.html');
  }
}

function removeAppID() {
  var parsedInfoPlist = plist.parse(plistContents);
  var types = parsedInfoPlist.CFBundleURLTypes;
  if (types) {
      var index = findAppID(types);
    if( index === -1) {
      return;
    } else {
      parsedInfoPlist.CFBundleURLTypes = _.dropWhile(types,types[index]);
      plistContents = plist.build(parsedInfoPlist);
      fs.writeFileSync(plistPath, plistContents);
    }
  }
}

function findAppID(types) {
  return _.findIndex(types, function(schemes) {
    return -1 !== _.findIndex(schemes.CFBundleURLSchemes,function (scheme) {
        return scheme.startsWith('tencent');
      })
  });
}


function removeQueriesSchemes() {
  var parsedInfoPlist = plist.parse(plistContents);
  var schemes = parsedInfoPlist.LSApplicationQueriesSchemes;
  parsedInfoPlist.LSApplicationQueriesSchemes = _.difference(schemes,qqSchemes);
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

function removeFrameworkAndSearchPath() {
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
      file.target = target;
      project.removeFromPbxBuildFileSection(file);          // PBXBuildFile
      project.removeFromPbxFileReferenceSection(file);      // PBXFileReference
      project.removeFromFrameworksPbxGroup(file);           // PBXGroup
      project.removeFromPbxFrameworksBuildPhase(file);      // PBXFrameworksBuildPhase
      //project.removeFromFrameworkSearchPaths(file);
      removeSearchPaths(project,'"$(SRCROOT)/../node_modules/react-native-qqsdk/ios/RCTQQSDK/**"');
      fs.writeFileSync(projectPath, project.writeSync());
    }
  });
}

function removeSearchPaths(project, frameworkSearchPath) {
  const config = project.pbxXCBuildConfigurationSection();
  Object
    .keys(config)
    .filter(ref => ref.indexOf('_comment') === -1)
.forEach(ref => {
      const buildSettings = config[ref].buildSettings;
    const shouldVisitBuildSettings = (
        buildSettings['PRODUCT_NAME'] === package.name);
    if (shouldVisitBuildSettings) {
      if (buildSettings['FRAMEWORK_SEARCH_PATHS']) {
        const paths = _.remove(buildSettings['FRAMEWORK_SEARCH_PATHS'], function(path) {
          return path !== frameworkSearchPath;
        });
         buildSettings['FRAMEWORK_SEARCH_PATHS'] = paths;
      }
    }
  });
}
