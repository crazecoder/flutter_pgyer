class AppBean {
  String versionName;
  String downloadURL;
  String versionCode;
  String releaseNote;
  bool shouldForceToUpdate;

  AppBean.fromJson(Map<String, dynamic> json)
      : versionName = json['versionName'],
        downloadURL = json['downloadURL'],
        versionCode = json['versionCode'],
        releaseNote = json['releaseNote'],
        shouldForceToUpdate = json['shouldForceToUpdate'];
}
