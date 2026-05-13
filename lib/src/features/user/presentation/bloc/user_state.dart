import 'package:equatable/equatable.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();
  
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  final bool isGuest;

  const UserLoaded({required this.user, required this.isGuest});

  @override
  List<Object?> get props => [user, isGuest];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
