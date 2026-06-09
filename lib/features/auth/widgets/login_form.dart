import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_router.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../shared/widgets/app_interactive.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _remember = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isLoadingDialogOpen = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty || _isSubmitting) {
      if (!_isSubmitting && (email.isEmpty || password.isEmpty)) {
        setState(() {
          _errorMessage = 'Completa correo y contraseña para continuar.';
        });
      }
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
      await profileController.signIn(
        email: email,
        password: password,
        rememberMe: _remember,
      );
      try {
        await contentController.pullFromRemote();
        if (contentController.hasRemote) {
          await contentController.loadPublished();
        }
      } catch (error) {
        if (!mounted) return;
        _errorMessage = _userFriendlySyncError(error);
        if (_errorMessage != null) {
          setState(() {});
        }
      }
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.home, (route) => false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _userFriendlyAuthError(error);
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
    if (_isLoadingDialogOpen || !mounted) {
      return;
    }

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
                      'Iniciando sesión...',
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
    if (!_isLoadingDialogOpen || !mounted) {
      return;
    }

    _isLoadingDialogOpen = false;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String _userFriendlyAuthError(Object error) {
    final rawError = error.toString().toLowerCase();

    if (error is AuthApiException) {
      final code = error.statusCode?.toLowerCase() ?? '';
      final message = error.message.toLowerCase();

      if (code == 'invalid_credentials' ||
          message.contains('invalid login credentials') ||
          rawError.contains('invalid login credentials')) {
        return 'Correo o contraseña incorrectos. Revisa tus datos e inténtalo de nuevo.';
      }

      if (code == 'email_not_confirmed' ||
          message.contains('email not confirmed')) {
        return 'Tu correo aún no está confirmado. Revisa tu bandeja de entrada.';
      }

      if (code == 'over_email_send_rate_limit' ||
          message.contains('too many requests')) {
        return 'Has realizado demasiados intentos. Intenta de nuevo en unos minutos.';
      }

      if (code == 'invalid_grant' || message.contains('signup is disabled')) {
        return 'No se pudo iniciar sesión en este momento. Inténtalo de nuevo más tarde.';
      }

      if (code == 'user_banned' ||
          message.contains('is inactive') ||
          message.contains('disabled')) {
        return 'Tu cuenta está inactiva. Contacta al soporte.';
      }

      if (message.contains('not found')) {
        return 'No existe una cuenta con este correo. Verifica tus datos o crea una nueva cuenta.';
      }

      if (message.contains('invalid claim') ||
          message.contains('jwt') ||
          message.contains('token')) {
        return 'La sesión no es válida en este momento. Inicia sesión nuevamente.';
      }

      return 'No se pudo iniciar sesión. Inténtalo de nuevo.';
    }

    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid') && message.contains('credentials')) {
        return 'Correo o contraseña incorrectos. Revisa tus datos e inténtalo de nuevo.';
      }

      if (message.contains('email') && message.contains('not confirmed')) {
        return 'Tu correo aún no está confirmado. Revisa tu bandeja de entrada.';
      }

      return 'No se pudo iniciar sesión. Revisa tus credenciales e intenta nuevamente.';
    }

    if (rawError.contains('socketexception') ||
        rawError.contains('timeoutexception') ||
        rawError.contains('timeout')) {
      return 'No pudimos conectarnos al servidor. Verifica tu conexión a internet.';
    }

    if (rawError.contains('invalid login credentials') ||
        rawError.contains('invalid_credentials') ||
        rawError.contains('wrong password') ||
        rawError.contains('invalid password')) {
      return 'Correo o contraseña incorrectos. Revisa tus datos e inténtalo de nuevo.';
    }

    if (rawError.contains('user not found') ||
        rawError.contains('user not exist') ||
        rawError.contains('no user')) {
      return 'No existe una cuenta con este correo. Verifica tus datos o crea una nueva cuenta.';
    }

    if (rawError.contains('service_unavailable') ||
        rawError.contains('too many requests') ||
        rawError.contains('rate limit')) {
      return 'El servicio está temporalmente ocupado. Inténtalo de nuevo en unos minutos.';
    }

    return 'No se pudo iniciar sesión. Inténtalo nuevamente.';
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
      return 'La capa de contenido no respondió correctamente. Revisa configuración de tabla o permisos.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final uncheckedColor = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final borderColor = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          hintText: 'Correo electrónico',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 14),
        AppTextField(
          hintText: 'Contraseña',
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
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
        const SizedBox(height: 16),
        AppInteractive(
          tooltip: _remember ? 'No recordar sesión' : 'Recordar sesión',
          borderRadius: AppRadius.full,
          hoverScale: 1.02,
          onTap: () => setState(() => _remember = !_remember),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _remember ? scheme.primary : uncheckedColor,
                  border: Border.all(color: borderColor),
                ),
                child: _remember
                    ? Icon(
                        Icons.check_rounded,
                        color: scheme.onPrimary,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                'Recordarme',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              '¿Olvidaste tu contraseña?',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
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
          label: _isSubmitting ? 'Entrando...' : 'Iniciar sesión',
          onPressed: _isSubmitting ? null : _login,
        ),
        const SizedBox(height: 18),
        AppSecondaryButton(
          label: 'Continuar con Google',
          onPressed: () {},
          leading: Text(
            'G',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: scheme.primary),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.stroke.withValues(alpha: 0.9)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('o', style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              child: Divider(color: AppColors.stroke.withValues(alpha: 0.9)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                '¿No tienes cuenta?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
