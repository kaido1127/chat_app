part of 'profile_bloc.dart';

@immutable
class ProfileState {
  String image;
  ProfileState({required this.image});
}

class ProfileInitial extends ProfileState  {
  ProfileInitial():super(image:"");
}
