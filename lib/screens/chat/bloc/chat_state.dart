part of 'chat_bloc.dart';

@immutable
class ChatState {
  bool showEmoji;
  bool isUploadImage;
  bool isTyping;
  bool isRecording;
  bool isPlayRecord;
  ChatState({required this.showEmoji,required this.isUploadImage,required this.isTyping,required this.isRecording,required this.isPlayRecord});
}

class ChatInitial extends ChatState {
  ChatInitial():super(showEmoji: false, isUploadImage: false,isTyping:false,isRecording: false,isPlayRecord:false);
}
