import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:path/path.dart' as path;

import '../../../../core/error/exceptions/server_exception.dart';
import '../../../../core/error/exceptions/user_exception.dart';
import '../../utils/enums.dart';
import 'models/remote_message_model.dart';

abstract class MessagesRemoteDataSource {
  const MessagesRemoteDataSource();

  Future<RemoteMessageModel> sendTextMessage(RemoteMessageModel message);

  Future<String> uploadFile(
    File file,
    void Function(int progress, int total) progressCallback,
  );

  Future<File> downloadFile(
    String url,
    void Function(int progress, int total) progressCallback,
  );

  Future<RemoteMessageModel> sendImageMessage(RemoteMessageModel message);
}

class MessagesRemoteDataSourceImpl extends MessagesRemoteDataSource {
  @override
  Future<RemoteMessageModel> sendTextMessage(RemoteMessageModel message) async {
    assert(message.textMessage != null);
    assert(message.receivedMessageType == MessageType.text.name);

    return _sendMessage(
      message,
      'Can not sent text message, connection exception',
    );
  }

  @override
  Future<RemoteMessageModel> sendImageMessage(RemoteMessageModel message) {
    assert(message.remoteFile != null && message.remoteFileURL != null);
    assert(message.receivedMessageType == MessageType.image.name);

    return _sendMessage(
      message,
      'Can not sent image message, connection exception',
    );
  }

  @override
  Future<String> uploadFile(
    File file,
    void Function(int progress, int total) progressCallback,
  ) async {
    final parseFile = ParseFile(file);

    final ParseResponse uploadFileResponse;
    try {
      uploadFileResponse = await parseFile.upload(
        progressCallback: progressCallback,
      );
    } catch (error) {
      throw InternetConnectionException(
        "Can't upload the file connection error \nError:$error",
      );
    }
    if (!uploadFileResponse.success) {
      throw ParseException.extractParseException(uploadFileResponse.error);
    }

    return parseFile.url!;
  }

  Future<RemoteMessageModel> _sendMessage(
    RemoteMessageModel message,
    String internetConnectionErrorMessage,
  ) async {
    final ParseResponse sendMessageResponse;

    try {
      sendMessageResponse = await message.create();
    } catch (error) {
      throw InternetConnectionException(
        '$internetConnectionErrorMessage\nError:$error',
      );
    }
    if (sendMessageResponse.success &&
        sendMessageResponse.results != null &&
        sendMessageResponse.count != 0) {
      return sendMessageResponse.results!.first as RemoteMessageModel;
    } else {
      throw ParseException.extractParseException(sendMessageResponse.error);
    }
  }

  @override
  Future<File> downloadFile(
    String url,
    void Function(int progress, int total) progressCallback,
  ) async {
    var parseFile = ParseFile(
      null,
      url: url,
      name: path.basename(url),
    );

    try {
      parseFile = await parseFile.download(
        progressCallback: progressCallback,
      );

      return parseFile.file!;
    } catch (error) {
      throw InternetConnectionException(
        "Can't download the file connection error \nError:$error",
      );
    }
  }
}
