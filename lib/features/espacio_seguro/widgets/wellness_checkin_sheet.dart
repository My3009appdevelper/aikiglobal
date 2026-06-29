import 'package:flutter/material.dart';

import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import 'wellness_metric_selector.dart';

class WellnessCheckInSheet extends StatefulWidget {
  const WellnessCheckInSheet({
    super.key,
    required this.uuidProfile,
    required this.date,
    this.initialMood,
    this.initialEnergia = 0,
    this.initialCalma = 0,
    this.initialDescanso = 0,
    this.initialConexion = 0,
  });

  final String uuidProfile;
  final DateTime date;
  final String? initialMood;
  final int initialEnergia;
  final int initialCalma;
  final int initialDescanso;
  final int initialConexion;

  @override
  State<WellnessCheckInSheet> createState() => _WellnessCheckInSheetState();
}

class _WellnessCheckInSheetState extends State<WellnessCheckInSheet> {
  late final TextEditingController _moodController;
  late int _energia;
  late int _calma;
  late int _descanso;
  late int _conexion;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isComplete {
    return _energia > 0 && _calma > 0 && _descanso > 0 && _conexion > 0;
  }

  @override
  void initState() {
    super.initState();
    _moodController = TextEditingController(text: widget.initialMood ?? '');
    _energia = _cleanMetric(widget.initialEnergia);
    _calma = _cleanMetric(widget.initialCalma);
    _descanso = _cleanMetric(widget.initialDescanso);
    _conexion = _cleanMetric(widget.initialConexion);
  }

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: muted.withValues(alpha: 0.34),
                      borderRadius: AppRadius.full,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    '¿Cómo te sientes hoy?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Registra tu energía interior para acompañar tu bienestar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                WellnessMetricSelector(
                  label: 'Energía',
                  icon: Icons.bolt_rounded,
                  value: _energia,
                  onChanged: (value) => setState(() => _energia = value),
                ),
                const SizedBox(height: AppSpacing.md),
                WellnessMetricSelector(
                  label: 'Calma',
                  icon: Icons.spa_rounded,
                  value: _calma,
                  onChanged: (value) => setState(() => _calma = value),
                ),
                const SizedBox(height: AppSpacing.md),
                WellnessMetricSelector(
                  label: 'Descanso',
                  icon: Icons.nights_stay_rounded,
                  value: _descanso,
                  onChanged: (value) => setState(() => _descanso = value),
                ),
                const SizedBox(height: AppSpacing.md),
                WellnessMetricSelector(
                  label: 'Conexión',
                  icon: Icons.self_improvement_rounded,
                  value: _conexion,
                  onChanged: (value) => setState(() => _conexion = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 104,
                  child: TextField(
                    controller: _moodController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.center,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Escribe cómo te sientes hoy...',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Elige un nivel del 1 al 5 en cada área. El mood es opcional.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: muted),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: _isSaving ? 'Guardando...' : 'Guardar registro',
                  icon: Icons.check_rounded,
                  height: 54,
                  onPressed: _isComplete && !_isSaving ? _save : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: 'Cancelar',
                  icon: Icons.close_rounded,
                  height: 52,
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final streakEvent = await AppDataScope.wellnessDailyLogs(context)
          .saveCheckIn(
            uuidProfile: widget.uuidProfile,
            date: widget.date,
            mood: _moodController.text,
            energia: _energia,
            calma: _calma,
            descanso: _descanso,
            conexion: _conexion,
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(streakEvent);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _errorMessage = 'No se pudo guardar tu registro. Inténtalo nuevamente.';
      });
    }
  }
}

int _cleanMetric(int value) => value.clamp(0, 5).toInt();
