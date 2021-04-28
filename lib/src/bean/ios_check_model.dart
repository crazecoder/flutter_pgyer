import 'package:flutter_pgyer/src/bean/check_model_base.dart';

class IOSCheckModel extends CheckModelBase {
  String? build;
  String? appUrl;
  String? lastBuild;
  String? forceUpdateVersion;
  bool? needForceUpdate;
  bool? haveNewVersion;
  bool? updateDeny;
  String? version;
  String? forceUpdateVersionNo;
  String? releaseNote;
  String? downloadURL;

  IOSCheckModel.fromJson(json) {
    build = json['build'];
    forceUpdateVersion = json['forceUpdateVersion'];
    forceUpdateVersionNo = json['forceUpdateVersionNo'];
    needForceUpdate = json['needForceUpdate'];
    appUrl = json['appUrl'];
    downloadURL = json['downloadURL'];
    lastBuild = json['lastBuild'];
    releaseNote = json['releaseNote'];
    haveNewVersion = json['haveNewVersion'];
    version = json['version'];
    updateDeny = json['updateDeny'];
  }
}
