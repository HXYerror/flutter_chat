import 'package:flutter/foundation.dart';
import 'package:awesome_help/controller/settings.dart';
import 'package:awesome_help/repository/conversation.dart';
import 'package:awesome_help/utils/bingSearch.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GetHttpResponse {
  getTokenResponse(String userName, String password,
      ValueChanged<String> onError, ValueChanged<String> onSuccess) async {
    try {
      String azureAPI = SettingsController.to.azureAPI.value;
      final response = await http.post(
        Uri.parse(
            //hxyall.eastus.cloudapp.azure.com
            "$azureAPI/api/v1/pri/user/login"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userName': userName,
          'userPwd': password,
        }),
      );

      if (response.statusCode == 200) {
        Utf8Decoder utf8decoder = Utf8Decoder();
        String responseString = utf8decoder.convert(response.bodyBytes);
        Map<String, dynamic> jsonData = jsonDecode(responseString);
        print(jsonData);
        if (jsonData["code"] == 0) {
          onSuccess(jsonData["data"]);
        } else {
          onError(jsonData["msg"]);
        }
      } else {
        onError(response.statusCode.toString());
      }
    } catch (e) {
      var text = e.toString();
      onError(text);
    }
  }
}
