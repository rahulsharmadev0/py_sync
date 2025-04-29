import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/ui/screens/auth/auth_form_state.dart';

class AuthFormBloc extends Cubit<AuthFormState> {
  final AuthRepository authRepo;
  AuthFormBloc(this.authRepo) : super(AuthFormState());

  void loginEvent() async {
    if (!state.isValid()) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await authRepo.login(state.username, state.password);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void registerEvent() async {
    if (!state.isValid()) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await authRepo.register(state.username, state.password);
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void setFormStateEvent(FormStatus formStatus) {
    if (state.formStatus == formStatus || state.isLoading) return;
    emit(state.copyWith(formStatus: formStatus, errorMessage: null));
  }

  void onUsername(String username) {
    if (state.username == username || state.isLoading) return;
    emit(state.copyWith(username: username));
  }

  void onPassword(String password) {
    if (state.password == password || state.isLoading) return;
    emit(state.copyWith(password: password));
  }

  void clearError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(errorMessage: null));
  }
}
