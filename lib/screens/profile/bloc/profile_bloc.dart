import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/profile/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<NewImageFromGallery>((event, emit) {
      emit(ProfileState(image: event.imagePath));
    });
    on<NewImageFromCamera>((event, emit) {
      emit(ProfileState(image: event.imagePath));
    });
  }

}

