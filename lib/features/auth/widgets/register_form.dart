import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_router.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static final RegExp _emailPattern = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    caseSensitive: false,
  );

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isLoadingDialogOpen = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _isSubmitting) {
      if (!_isSubmitting) {
        setState(() {
          _errorMessage = 'Completa todos los campos para continuar.';
        });
      }
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden.';
      });
      return;
    }

    if (!_emailPattern.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Ingresa un correo electrónico válido.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres.';
      });
      return;
    }

    final profileController = AppDataScope.currentProfile(context);
    final contentController = AppDataScope.contentItems(context);

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    _showLoadingDialog();

    try {
      final response = await profileController.signUp(
        email: email,
        password: password,
        nombre: fullName,
      );

      if (response.user == null) {
        throw StateError('No se pudo completar tu registro.');
      }

      await profileController.markOnboardingCompleted();

      try {
        await contentController.pullFromRemote();
        if (contentController.hasRemote) {
          await contentController.loadPublished();
        }
      } catch (error) {
        if (!mounted) return;
        final syncError = _userFriendlySyncError(error);
        if (syncError != null) {
          setState(() {
            _errorMessage = syncError;
          });
        }
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _userFriendlyAuthErrorFromObject(error);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _userFriendlyAuthErrorFromObject(error);
      });
    } finally {
      _hideLoadingDialog();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showLoadingDialog() {
    if (_isLoadingDialogOpen || !mounted) return;

    _isLoadingDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SizedBox(
            width: 240,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Creando cuenta...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (!_isLoadingDialogOpen || !mounted) return;

    _isLoadingDialogOpen = false;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String _userFriendlyAuthErrorFromObject(Object error) {
    final rawError = error.toString().toLowerCase();

    if (error is AuthApiException) {
      final code = error.statusCode?.toLowerCase() ?? '';
      final message = error.message.toLowerCase();
      final hasDbSignature =
          rawError.contains('database error') ||
          rawError.contains('db error') ||
          rawError.contains('postgresql');
      final hasPolicySignature =
          rawError.contains('policy') ||
          rawError.contains('rls') ||
          rawError.contains('row-level') ||
          rawError.contains('permission denied');

      if (code == 'user_already_exists' ||
          message.contains('user already registered') ||
          message.contains('already exists')) {
        return 'Ya existe una cuenta con este correo.';
      }

      if (code == 'weak_password' ||
          (message.contains('weak') && message.contains('password'))) {
        return 'La contraseña es muy débil. Usa una combinación más segura.';
      }

      if (code == 'email_address_invalid' ||
          message.contains('email address is invalid')) {
        return 'El correo ingresado no es válido.';
      }

      if (hasDbSignature || hasPolicySignature) {
        return 'No se pudo crear la cuenta por un error al guardar tu perfil. '
            'Revisa la configuración del trigger o permisos de "profiles" en Supabase.';
      }
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      final hasDbSignature =
          rawError.contains('database error') ||
          rawError.contains('db error') ||
          rawError.contains('postgresql');
      final hasPolicySignature =
          rawError.contains('policy') ||
          rawError.contains('rls') ||
          rawError.contains('row-level') ||
          rawError.contains('permission denied');

      if (message.contains('user already registered') ||
          message.contains('already exists')) {
        return 'Ya existe una cuenta con este correo.';
      }

      if (message.contains('weak') && message.contains('password')) {
        return 'La contraseña es muy débil. Usa una combinación más segura.';
      }

      if (message.contains('invalid') && message.contains('email')) {
        return 'El correo ingresado no es válido.';
      }

      if (hasDbSignature || hasPolicySignature) {
        return 'No se pudo crear la cuenta por un error al guardar tu perfil. '
            'Revisa la configuración del trigger o permisos de "profiles" en Supabase.';
      }

      return 'No se pudo crear la cuenta. Revisa tus datos e intenta nuevamente.';
    }

    if (rawError.contains('socketexception') ||
        rawError.contains('timeoutexception') ||
        rawError.contains('timeout')) {
      return 'No pudimos conectarnos al servidor. Verifica tu conexión.';
    }

    if (rawError.contains('database error') ||
        rawError.contains('postgresql') ||
        rawError.contains('policy') ||
        rawError.contains('rls') ||
        rawError.contains('permission denied')) {
      return 'No se pudo crear la cuenta por un error de configuración del servidor.';
    }

    return 'No se pudo crear la cuenta. Inténtalo nuevamente.';
  }

  String? _userFriendlySyncError(Object error) {
    final rawError = error.toString().toLowerCase();

    if (rawError.contains('socketexception') ||
        rawError.contains('timeoutexception') ||
        rawError.contains('timeout')) {
      return 'No pudimos sincronizar contenido en este momento. Revisa tu conexión.';
    }

    if (rawError.contains('403') ||
        rawError.contains('forbidden') ||
        rawError.contains('rls')) {
      return 'No se pudo sincronizar contenido porque no tienes permisos configurados.';
    }

    if (rawError.contains('postgresql') || rawError.contains('db error')) {
      return 'La capa de contenido no respondió correctamente.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          hintText: 'Nombre completo',
          controller: _fullNameController,
          focusNode: _fullNameFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_emailFocusNode),
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Correo electrónico',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_passwordFocusNode),
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Contraseña',
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Confirmar contraseña',
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _register(),
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            tooltip: _obscureConfirmPassword
                ? 'Mostrar contraseña'
                : 'Ocultar contraseña',
            onPressed: () {
              setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              );
            },
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
        AppPrimaryButton(
          label: _isSubmitting ? 'Creando cuenta...' : 'Crear cuenta',
          onPressed: _isSubmitting ? null : _register,
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                '¿Ya tienes cuenta?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRouter.login);
                },
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


