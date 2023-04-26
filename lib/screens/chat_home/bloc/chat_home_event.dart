part of 'chat_home_bloc.dart';

@immutable
class ChatHomeEvent {}

class NotIsSearching extends ChatHomeEvent{}

class ClearSearchList extends ChatHomeEvent{}

class AddSearchList extends ChatHomeEvent{
  final ChatUser user;
  AddSearchList({required this.user});
  List<Object?> get props=>[user];
}
