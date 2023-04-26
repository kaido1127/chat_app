import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<NotIsSearching>((event, emit) {
      emit(HomeState(searchList: state.searchList, isSearching: !state.isSearching, showEmoji: state.showEmoji));
    });
    on<NotShowEmoji>((event, emit) {
      emit(HomeState(searchList: state.searchList, isSearching: state.isSearching, showEmoji: !state.showEmoji));
    });
    on<ClearSearchList>((event, emit) {
      emit(HomeState(isSearching: state.isSearching, searchList: HomeInitial().searchList,showEmoji: state.showEmoji));
    });

    on<AddSearchList>((event, emit) {
      final List<ChatUser> newList = List.of(state.searchList)..add(event.user);
      emit(HomeState(isSearching: state.isSearching, searchList: newList,showEmoji: state.showEmoji));
    });
  }
}
