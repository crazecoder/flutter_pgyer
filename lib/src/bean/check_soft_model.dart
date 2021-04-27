import 'dart:convert';

import 'package:flutter_pgyer/src/bean/check_model_base.dart';

class CheckSoftModel extends CheckModelBase{
   int buildBuildVersion;
   String forceUpdateVersion;
   String forceUpdateVersionNo;
   bool needForceUpdate;
   bool buildHaveNewVersion;
   String downloadURL;
   String buildVersionNo;
   String buildVersion;
   String buildShortcutUrl;
   String buildUpdateDescription;

   CheckSoftModel.fromJson(String jsonStr){
      Map resultMap = json.decode(jsonStr);
      buildBuildVersion = resultMap['buildBuildVersion'];
      forceUpdateVersion = resultMap['forceUpdateVersion'];
      forceUpdateVersionNo = resultMap['forceUpdateVersionNo'];
      needForceUpdate = resultMap['needForceUpdate'];
      buildHaveNewVersion = resultMap['buildHaveNewVersion'];
      downloadURL = resultMap['downloadURL'];
      buildVersionNo = resultMap['buildVersionNo'];
      buildShortcutUrl = resultMap['buildShortcutUrl'];
      buildUpdateDescription = resultMap['buildUpdateDescription'];
      buildVersion = resultMap['buildVersion'];
   }
}