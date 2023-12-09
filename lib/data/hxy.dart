import 'package:flutter/foundation.dart';
import 'package:awesome_help/controller/settings.dart';
import 'package:awesome_help/repository/conversation.dart';
import 'package:awesome_help/utils/bingSearch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class LLM {
  getResponse(List<Message> messages, ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback, ValueChanged<Message> onSuccess);
}

class HXYGpt extends LLM {
  @override
  getResponse(
      List<Message> messages,
      ValueChanged<Message> onResponse,
      ValueChanged<Message> errorCallback,
      ValueChanged<Message> onSuccess) async {
    //messages = messages.reversed.toList();
    int size = messages.length;
    Message requestMessage = messages[size - 1];
    // 将messages里面的每条消息的内容取出来拼接在一起
    String content = "";
    String currentModel = SettingsController.to.gptModel.value;
    int maxTokenLength = 1800;
    switch (currentModel) {
      case "gpt-3.5-turbo":
        maxTokenLength = 1800;
        break;
      case "gpt-3.5-turbo-16k":
        maxTokenLength = 10000;
        break;
      default:
        maxTokenLength = 1800;
        break;
    }
    bool useWebSearch = SettingsController.to.useWebSearch.value;
    if (useWebSearch) {
      requestMessage.text = await fetchAndParse(messages.first.text);
    }

    var message = Message(
        conversationId: messages.first.conversationId,
        text: "",
        role: Role.assistant);

    var userUUID = "test-uuid";

    if (SettingsController.to.useStream.value) {
      //TODO stream
    } else {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String azureAPI = SettingsController.to.azureAPI.value;
        String token = prefs.getString('user_token').toString();
        final response = await http.post(
          Uri.parse(
              //hxyall.eastus.cloudapp.azure.com
              "$azureAPI/api/v1/pri/chat/gptmessage?chatUUID=${requestMessage.conversationId}&userUUID=$userUUID&gptVersion=$currentModel"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'token': token
          },
          body: jsonEncode(<String, String>{
            'promptMessage': requestMessage.text,
          }),
        );

        if (response.statusCode == 200) {
          Utf8Decoder utf8decoder = Utf8Decoder();
          String responseString = utf8decoder.convert(response.bodyBytes);
          Map<String, dynamic> jsonData = jsonDecode(responseString);
          if (jsonData["code"] == 0) {
            onSuccess(Message(
                conversationId: requestMessage.conversationId,
                text: jsonData["data"],
                role: Role.assistant));
          } else {
            onResponse(Message(
                conversationId: requestMessage.conversationId,
                text: "${jsonData["msg"]}",
                role: Role.assistant));
          }
        } else {
          onResponse(Message(
              conversationId: requestMessage.conversationId,
              text: "${response.statusCode}",
              role: Role.assistant));
        }
      } catch (e) {
        message.text = e.toString();
        errorCallback(message);
      }
    }
  }
}
