part of 'home_bloc.dart';

@immutable
class HomeEvent {}

class NotIsSearching extends HomeEvent{}
class NotShowEmoji extends HomeEvent{}
class ClearSearchList extends HomeEvent{}

class AddSearchList extends HomeEvent{
  final ChatUser user;
  AddSearchList({required this.user});
  List<Object?> get props=>[user];
}
