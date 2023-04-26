part of 'home_bloc.dart';

@immutable
class HomeState {
  bool isSearching;
  bool showEmoji;
  List<ChatUser> searchList;
  HomeState({required this.searchList,required this.isSearching,required this.showEmoji});
}

class HomeInitial extends HomeState {
  HomeInitial():super(isSearching: false,searchList: [],showEmoji: false);
}
