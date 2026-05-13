import 'package:equatable/equatable.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserAuthChanged extends UserEvent {
  final UserModel? authUser;
  const UserAuthChanged(this.authUser);

  @override
  List<Object?> get props => [authUser];
}

class LoadGuestProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final UserModel updatedUser;
  const UpdateUserProfile(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}
