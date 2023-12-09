import 'dart:async';

import 'package:awesome_help/repository/conversation.dart';
import 'package:awesome_help/repository/message.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final messageList = <Message>[].obs;

  void loadAllMessages(String conversationUUid) async {
    messageList.value = await ConversationRepository()
        .getMessagesByConversationUUid(conversationUUid);
  }

  void addMessage(Message message, Function? callback) async {
    await ConversationRepository().addMessage(message);
    final messages = await ConversationRepository()
        .getMessagesByConversationUUid(message.conversationId);
    messageList.value = messages;
    // wait for all the  state emit
    final completer = Completer();
    try {
      MessageRepository().postMessage(message, (Message message) {
        //onresponse
        messageList.value = [...messages, message];
        callback?.call();
      }, (Message message) {
        //onerror
        messageList.value = [...messages, message];
        callback?.call();
      }, (Message message) async {
        //onsuccess
        ConversationRepository().addMessage(message);
        final messages = await ConversationRepository()
            .getMessagesByConversationUUid(message.conversationId);
        messageList.value = messages;
        callback?.call();
        completer.complete();
      });
    } catch (e) {
      messageList.value = [
        ...messages,
        Message(
            conversationId: message.conversationId,
            text: e.toString(),
            role: Role.assistant)
      ];
      callback?.call();
      completer.complete();
    }
    await completer.future;
  }
}
