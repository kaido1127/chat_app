import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<NotShowEmoji>((event, emit) {
     emit(ChatState(showEmoji: !state.showEmoji, isUploadImage: state.isUploadImage,isTyping:state.isTyping,isRecording: state.isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<NotUploadImage>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: !state.isUploadImage,isTyping:state.isTyping,isRecording: state.isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<NotIsTyping>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:ChatInitial().isTyping,isRecording: state.isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<NotIsRecording>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:ChatInitial().isTyping,isRecording: ChatInitial().isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<IsRecording>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:ChatInitial().isTyping,isRecording: !ChatInitial().isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<IsTyping>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:!ChatInitial().isTyping,isRecording: state.isRecording,isPlayRecord: state.isPlayRecord));
    });
    on<NotIsPlayRecord>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:state.isTyping,isRecording: state.isRecording,isPlayRecord: ChatInitial().isPlayRecord));
    });
    on<IsPlayRecord>((event, emit) {
      emit(ChatState(showEmoji: state.showEmoji, isUploadImage: state.isUploadImage,isTyping:state.isTyping,isRecording: state.isRecording,isPlayRecord: !ChatInitial().isPlayRecord));
    });
  }
}
