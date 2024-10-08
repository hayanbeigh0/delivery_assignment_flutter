part of 'sign_up_form_bloc.dart';

@freezed
class SignUpFormEvent with _$SignUpFormEvent {
  const factory SignUpFormEvent.emailChanged(String emailStr) = EmailChanged;
  const factory SignUpFormEvent.passwordChanged(String passwordStr) =
      PasswordChanged;
  const factory SignUpFormEvent.nameChanged(String nameStr) = NameChanged;
  const factory SignUpFormEvent.photoUrlChanged(String photoUrlStr) =
      PhotoOrlChanged;
  const factory SignUpFormEvent.role(String role) =
      RoleChanged;
  const factory SignUpFormEvent.registerWithEmailAndPasswordPressed() =
      RegisterWithEmailAndPasswordPressed;
}
