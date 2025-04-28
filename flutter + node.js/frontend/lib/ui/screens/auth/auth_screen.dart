import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:py_sync/logic/repositories/auth_repository.dart';
import 'package:py_sync/ui/screens/auth/auth_bloc.dart';
import 'package:py_sync/ui/screens/auth/auth_form_state.dart';

/// Screen for handling user authentication (login and registration)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 800;

    return BlocProvider(
      create: (context) => AuthFormBloc(context.read<AuthRepository>()),
      child: BlocListener<AuthFormBloc, AuthFormState>(
        listenWhen: (previous, current) => previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Unknown error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: isSmallScreen ? _buildMobileLayout(size) : _buildDesktopLayout(size),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        // Left side - Brand section
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/brand.png',
                    height: size.height * 0.3,
                    colorBlendMode: BlendMode.srcIn,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PiSync',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right side - Authentication form
        Expanded(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: AuthForm(tabController: _tabController),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top section - Brand
          Container(
            color: Colors.black,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/brand.png',
                  height: size.height * 0.15,
                  colorBlendMode: BlendMode.srcIn,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'PiSync Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Bottom section - Auth form
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: AuthForm(tabController: _tabController),
          ),
        ],
      ),
    );
  }
}

class AuthForm extends StatelessWidget {
  const AuthForm({super.key, required TabController tabController})
    : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
    var outlineInputBorder2 = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 2),
    );

    var read = context.read<AuthFormBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tab bar for switching between login and register
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'LOGIN'), Tab(text: 'REGISTER')],
        ),
        const SizedBox(height: 32),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: read.onUsername,
              decoration: InputDecoration(
                labelText: 'Username',
                border: outlineInputBorder,
                focusedBorder: outlineInputBorder2,
              ),
              autofillHints: const [AutofillHints.username],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your username';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: context.read<AuthFormBloc>().onPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: outlineInputBorder,
                focusedBorder: outlineInputBorder2,
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            LoginButton(tabController: _tabController),
          ],
        ),
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required TabController tabController})
    : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthFormBloc, AuthFormState, (bool, bool)>(
      selector: (state) => (state.isValid(), state.isLoading),
      builder: (context, data) {
        return SizedBox(
          height: kToolbarHeight,
          child: ElevatedButton(
            onPressed: !data.$1 ? null : context.read<AuthFormBloc>().loginEvent,
            child:
                data.$2
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      _tabController.index == 0 ? 'LOGIN' : 'REGISTER',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
          ),
        );
      },
    );
  }
}
