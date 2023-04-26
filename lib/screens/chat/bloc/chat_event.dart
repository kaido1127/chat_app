part of 'chat_bloc.dart';

@immutable
class ChatEvent {}

class NotShowEmoji extends ChatEvent{}
class NotUploadImage extends ChatEvent{}
class NotIsTyping extends ChatEvent{}
class IsTyping extends ChatEvent{}
class NotIsRecording extends ChatEvent{}
class IsRecording extends ChatEvent{}
class NotIsPlayRecord extends ChatEvent{}
class IsPlayRecord extends ChatEvent{}
