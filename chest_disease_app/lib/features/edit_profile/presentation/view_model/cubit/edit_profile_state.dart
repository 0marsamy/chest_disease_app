part of 'edit_profile_cubit.dart';

sealed class EditProfileState extends Equatable {
  final bool isEditing;
  final File? profileImage;

  const EditProfileState({this.isEditing = false, this.profileImage});

  @override
  List<Object> get props => [isEditing, profileImage ?? ''];

  EditProfileState copyWith({
    bool? isEditing,
    File? profileImage,
  }) {
    if (this is EditProfileInitial) {
      return EditProfileInitial(isEditing: isEditing ?? this.isEditing);
    }
    if (this is EditProfileLoading) {
      return EditProfileLoading(isEditing: isEditing ?? this.isEditing);
    }
    if (this is EditProfileSuccess) {
      return EditProfileSuccess(isEditing: isEditing ?? this.isEditing);
    }
    if (this is EditProfileError) {
      return EditProfileError(isEditing: isEditing ?? this.isEditing);
    }
    if (this is EditProfileImagePicked) {
      return EditProfileImagePicked(
          isEditing: isEditing ?? this.isEditing,
          profileImage: profileImage ?? this.profileImage);
    }
    if (this is EditProfileToggled) {
      return EditProfileToggled(isEditing: isEditing ?? this.isEditing);
    }
    return EditProfileInitial(isEditing: isEditing ?? this.isEditing);
  }
}

final class EditProfileInitial extends EditProfileState {
  const EditProfileInitial({super.isEditing});
}

final class EditProfileLoading extends EditProfileState {
  const EditProfileLoading({super.isEditing});
}

final class EditProfileSuccess extends EditProfileState {
  const EditProfileSuccess({super.isEditing});
}

final class EditProfileError extends EditProfileState {
  const EditProfileError({super.isEditing});
}

final class EditProfileImagePicked extends EditProfileState {
  const EditProfileImagePicked({super.isEditing, super.profileImage});
}

final class EditProfileToggled extends EditProfileState {
  const EditProfileToggled({required super.isEditing});
}
