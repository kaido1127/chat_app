part of 'chat_home_bloc.dart';

@immutable
class ChatHomeState {
  bool isSearching;
  List<ChatUser> searchList;
  ChatHomeState({required this.isSearching,required this.searchList});
}

class ChatHomeInitial extends ChatHomeState {
  ChatHomeInitial():super(isSearching: false,searchList: []);
}
