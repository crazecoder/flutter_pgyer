import 'package:flutter_pgyer/src/bean/check_model_base.dart';

class CheckResult {
  final CheckModelBase? model;
  final CheckEnum? checkEnum;

  CheckResult({this.model, this.checkEnum});
  // CheckResult.fromJson(Map<String, dynamic> json) {
  //   model = CheckSoftModel.fromJson(json["model"]);
  //   checkEnum = CheckEnum.values[json["enum"]];
  // }
}

enum CheckEnum { SUCCESS, FAIL, NO_VERSION }
