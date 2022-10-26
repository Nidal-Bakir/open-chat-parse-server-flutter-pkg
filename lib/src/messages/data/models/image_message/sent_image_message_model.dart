import 'dart:io';

import 'package:parse_server_sdk_flutter/parse_server_sdk.dart' show ParseFile;

import '../../../domain/entities/image_message/image.dart';
import '../../../domain/entities/image_message/sent_image_message.dart';
import '../../../domain/entities/sent_message_base.dart';
import '../../datasources/local/models/messages_collection_model.dart';
import '../../datasources/remote/models/remote_message_model.dart';
import '../../utils/enums.dart';
import '../model_converter.dart';

class SentImageMessageModel extends SentImageMessage
    with SentMessageModelConverterMixin {
  const SentImageMessageModel({
    required super.localMessageId,
    required super.remoteMessageId,
    required super.userId,
    required super.localSentDate,
    required super.remoteCreationDate,
    required super.messageDeliveryState,
    required super.sentImage,
  });

  factory SentImageMessageModel.fromEntity(SentImageMessage entityObject) {
    return SentImageMessageModel(
      localMessageId: entityObject.localMessageId,
      localSentDate: entityObject.localSentDate,
      messageDeliveryState: entityObject.messageDeliveryState,
      remoteCreationDate: entityObject.remoteCreationDate,
      userId: entityObject.userId,
      remoteMessageId: entityObject.remoteMessageId,
      sentImage: entityObject.sentImage,
    );
  }

  @override
  MessagesCollectionModel toLocalDBModel() {
    final localImageMessage = ImageMessage()
      ..imageFilePath = sentImage.imageFile?.path
      ..thumbnailFilePath = sentImage.thumbnailFile?.path
      ..hight = sentImage.imageMetaData.hight
      ..width = sentImage.imageMetaData.width
      ..size = sentImage.imageMetaData.size;

    return super.toLocalDBModel()
      ..messageType = MessageType.image.name
      ..imageMessage = localImageMessage;
  }

  @override
  RemoteMessageModel toRemoteModel() {
    return super.toRemoteModel()
      ..messageType = MessageType.image
      ..remoteFile = ParseFile(sentImage.imageFile, url: sentImage.imageURL)
      ..metaData = sentImage.imageMetaData.toJson();
  }

  factory SentImageMessageModel.fromRemoteModel(
    RemoteMessageModel remoteModel,
  ) {
    final image = Image(
      imageMetaData: const ImageMetaData().fromJson(remoteModel.metaData),
      imageURL: remoteModel.remoteFile!.url,
      thumbnailURL: remoteModel.thumbnail!.url,
    );

    return SentImageMessageModel(
      localMessageId: remoteModel.sentDate.microsecondsSinceEpoch,
      remoteMessageId: remoteModel.remoteMessageId,
      userId: remoteModel.receiver.userId,
      messageDeliveryState: SentMessageDeliveryState.values.byName(
        remoteModel.messageDeliveryState,
      ),
      localSentDate: remoteModel.sentDate,
      remoteCreationDate: remoteModel.remoteCreationDate,
      sentImage: image,
    );
  }

  factory SentImageMessageModel.fromLocalDBModel(
    MessagesCollectionModel localModel,
  ) {
    final localImgMsg = localModel.imageMessage;
    final imagePath = localImgMsg?.imageFilePath;
    final thumbnailPath = localImgMsg?.thumbnailFilePath;

    final image = Image(
      imageMetaData: ImageMetaData(
        hight: localImgMsg?.hight,
        size: localImgMsg?.size,
        width: localImgMsg?.width,
      ),
      imageURL: localImgMsg?.imageURL,
      thumbnailURL: localImgMsg?.thumbnailURL,
      imageFile: imagePath != null ? File(imagePath) : null,
      thumbnailFile: thumbnailPath != null ? File(thumbnailPath) : null,
    );

    return SentImageMessageModel(
      localMessageId: localModel.localMessageId,
      remoteMessageId: localModel.remoteMessageId,
      userId: localModel.userId,
      remoteCreationDate: localModel.remoteCreationDate,
      messageDeliveryState:
          localModel.sentMessageProperties!.sentMessageDeliveryState,
      localSentDate: localModel.localSentDate,
      sentImage: image,
    );
  }
}
