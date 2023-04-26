part of 'profile_bloc.dart';

@immutable
class ProfileEvent {}

class NewImageFromGallery extends ProfileEvent{
  final String imagePath;
  NewImageFromGallery(this.imagePath);
  List<Object?> get props=>[imagePath];
}
class NewImageFromCamera extends ProfileEvent{
  final String imagePath;
  NewImageFromCamera(this.imagePath);
  List<Object?> get props=>[imagePath];
}
