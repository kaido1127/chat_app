import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/chat/bloc/chat_bloc.dart';
import 'package:meta/meta.dart';

part 'chat_home_event.dart';
part 'chat_home_state.dart';

class ChatHomeBloc extends Bloc<ChatHomeEvent, ChatHomeState> {
  ChatHomeBloc() : super(ChatHomeInitial()) {
    on<NotIsSearching>((event, emit) {
      emit(ChatHomeState(isSearching: !state.isSearching, searchList: state.searchList));
    });

    on<ClearSearchList>((event, emit) {
      emit(ChatHomeState(isSearching: state.isSearching, searchList: ChatHomeInitial().searchList));
    });

    on<AddSearchList>((event, emit) {
      final List<ChatUser> newList = List.of(state.searchList)..add(event.user);
      emit(ChatHomeState(isSearching: state.isSearching, searchList: newList));
    });
  }
}

