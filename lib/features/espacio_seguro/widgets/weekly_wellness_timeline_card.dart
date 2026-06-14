import 'package:flutter/material.dart';

import '../../../core/data/models/app_wellness_daily_log.dart';
import '../../../core/data/providers/app_data_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_interactive.dart';

class WeeklyWellnessTimelineCard extends StatefulWidget {
  const WeeklyWellnessTimelineCard({super.key});

  @override
  State<WeeklyWellnessTimelineCard> createState() =>
      _WeeklyWellnessTimelineCardState();
}

class _WeeklyWellnessTimelineCardState
    extends State<WeeklyWellnessTimelineCard> {
  final ScrollController _timelineController = ScrollController();
  String _selectedDateKey = _dateKey(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_timelineController.hasClients) {
        return;
      }
      _timelineController.jumpTo(_timelineController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDataScope.wellnessDailyLogs(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final days = _buildDaysFromLogs(controller.logs);
        final selectedIndex = _selectedIndexFor(days);
        final selectedDay = days[selectedIndex];

        return _WeeklyWellnessTimelineContent(
          days: days,
          selectedIndex: selectedIndex,
          selectedDay: selectedDay,
          timelineController: _timelineController,
          onDaySelected: (day) {
            setState(() => _selectedDateKey = _dateKey(day.date));
          },
        );
      },
    );
  }

  int _selectedIndexFor(List<_WellnessDaySnapshot> days) {
    final index = days.indexWhere(
      (day) => _dateKey(day.date) == _selectedDateKey,
    );
    return index == -1 ? days.length - 1 : index;
  }
}

class _WeeklyWellnessTimelineContent extends StatelessWidget {
  const _WeeklyWellnessTimelineContent({
    required this.days,
    required this.selectedIndex,
    required this.selectedDay,
    required this.timelineController,
    required this.onDaySelected,
  });

  final List<_WellnessDaySnapshot> days;
  final int selectedIndex;
  final _WellnessDaySnapshot selectedDay;
  final ScrollController timelineController;
  final ValueChanged<_WellnessDaySnapshot> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: AppRadius.large,
        border: Border.all(color: stroke),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu energía interior de la semana',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 128,
            child: ListView.separated(
              controller: timelineController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final day = days[index];
                return _DayWellnessChip(
                  day: day,
                  selected: index == selectedIndex,
                  onTap: () => onDaySelected(day),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _SelectedDayDetails(
              key: ValueKey(selectedDay.date),
              day: selectedDay,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayWellnessChip extends StatelessWidget {
  const _DayWellnessChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final _WellnessDaySnapshot day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    final selectedForeground = Theme.of(context).colorScheme.onPrimary;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.textMuted;
    final baseSurface = isDark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final selectedSurface = isDark ? AppColors.sand : AppColors.primary;
    final textColor = selected
        ? selectedForeground
        : Theme.of(context).colorScheme.onSurface;
    final tooltip =
        '${_fullDateLabel(day.date)}\n'
        'Energía ${day.energia}/5 · Calma ${day.calma}/5\n'
        'Descanso ${day.descanso}/5 · Conexión ${day.conexion}/5\n'
        'Meditación ${day.meditacionCompletada ? 'completada' : 'pendiente'} · '
        '${day.minutosBienestar} min de bienestar';

    return AppInteractive(
      tooltip: tooltip,
      borderRadius: AppRadius.medium,
      onTap: onTap,
      hoverScale: 1.03,
      pressedScale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 78,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
        decoration: BoxDecoration(
          color: selected
              ? selectedSurface
              : baseSurface.withValues(alpha: 0.8),
          borderRadius: AppRadius.medium,
          border: Border.all(
            color: selected ? accent : AppColors.transparent,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  _weekdayShort(day.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? textColor : muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day.date.day.toString(),
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
            _MetricBars(day: day, selected: selected),
            if (day.isToday)
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: selected ? textColor : accent,
                  borderRadius: AppRadius.full,
                ),
              )
            else
              const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }
}

class _MetricBars extends StatelessWidget {
  const _MetricBars({required this.day, required this.selected});

  final _WellnessDaySnapshot day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final values = [day.energia, day.calma, day.descanso, day.conexion];
    final brightness = Theme.of(context).brightness;
    final baseColor = selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.primary;
    final emptyColor = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;

    return SizedBox(
      height: 34,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var index = 0; index < values.length; index++) ...[
            _MetricBar(
              value: values[index],
              selected: selected,
              baseColor: baseColor,
              emptyColor: emptyColor,
            ),
            if (index < values.length - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.value,
    required this.selected,
    required this.baseColor,
    required this.emptyColor,
  });

  final int value;
  final bool selected;
  final Color baseColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.clamp(0, 5);

    return SizedBox(
      width: 6,
      height: 34,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var level = 5; level >= 1; level--) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 6,
              height: 4.8,
              decoration: BoxDecoration(
                color: cleanValue >= level
                    ? baseColor.withValues(alpha: selected ? 0.92 : 0.78)
                    : emptyColor.withValues(alpha: selected ? 0.42 : 0.82),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (level > 1) const SizedBox(height: 2),
          ],
        ],
      ),
    );
  }
}

class _SelectedDayDetails extends StatelessWidget {
  const _SelectedDayDetails({super.key, required this.day});

  final _WellnessDaySnapshot day;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.82),
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.isToday ? 'Hoy' : _fullDateLabel(day.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            day.mood == null ? 'Aún no has registrado este día.' : day.mood!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: muted, height: 1.18),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.8,
            children: [
              _MetricTile(label: 'Energía', value: day.energia),
              _MetricTile(label: 'Calma', value: day.calma),
              _MetricTile(label: 'Descanso', value: day.descanso),
              _MetricTile(label: 'Conexión', value: day.conexion),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DayInfoTile(
                  icon: day.meditacionCompletada
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  label: 'Meditación',
                  value: day.meditacionCompletada ? 'Hecha' : 'Pendiente',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DayInfoTile(
                  icon: Icons.self_improvement_rounded,
                  label: 'Bienestar',
                  value: '${day.minutosBienestar} min',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white.withValues(alpha: 0.72);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color, borderRadius: AppRadius.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value/5',
            maxLines: 1,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayInfoTile extends StatelessWidget {
  const _DayInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;
    final fill = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(color: fill, borderRadius: AppRadius.medium),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WellnessDaySnapshot {
  const _WellnessDaySnapshot({
    required this.date,
    required this.energia,
    required this.calma,
    required this.descanso,
    required this.conexion,
    required this.meditacionCompletada,
    required this.minutosBienestar,
    this.mood,
  });

  final DateTime date;
  final int energia;
  final int calma;
  final int descanso;
  final int conexion;
  final bool meditacionCompletada;
  final int minutosBienestar;
  final String? mood;

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

List<_WellnessDaySnapshot> _buildDaysFromLogs(List<AppWellnessDailyLog> logs) {
  final today = DateTime.now();
  final logByDate = {
    for (final log in logs)
      if (log.deletedAt == null) log.fecha: log,
  };

  return [
    for (var index = 6; index >= 0; index--)
      _snapshotForDate(
        DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(Duration(days: index)),
        logByDate,
      ),
  ];
}

_WellnessDaySnapshot _snapshotForDate(
  DateTime date,
  Map<String, AppWellnessDailyLog> logByDate,
) {
  final log = logByDate[_dateKey(date)];

  return _WellnessDaySnapshot(
    date: date,
    energia: _metricValue(log?.energia ?? 0),
    calma: _metricValue(log?.calma ?? 0),
    descanso: _metricValue(log?.descanso ?? 0),
    conexion: _metricValue(log?.conexion ?? 0),
    meditacionCompletada: log?.meditacionCompletada ?? false,
    minutosBienestar: _positiveValue(log?.minutosBienestar ?? 0),
    mood: log?.mood,
  );
}

int _metricValue(int value) => value.clamp(0, 5).toInt();

int _positiveValue(int value) => value < 0 ? 0 : value;

String _dateKey(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');

  return '${local.year}-$month-$day';
}

String _weekdayShort(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'LUN',
    DateTime.tuesday => 'MAR',
    DateTime.wednesday => 'MIÉ',
    DateTime.thursday => 'JUE',
    DateTime.friday => 'VIE',
    DateTime.saturday => 'SÁB',
    DateTime.sunday => 'DOM',
    _ => '',
  };
}

String _weekdayName(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'Lunes',
    DateTime.tuesday => 'Martes',
    DateTime.wednesday => 'Miércoles',
    DateTime.thursday => 'Jueves',
    DateTime.friday => 'Viernes',
    DateTime.saturday => 'Sábado',
    DateTime.sunday => 'Domingo',
    _ => '',
  };
}

String _monthName(int month) {
  return switch (month) {
    1 => 'enero',
    2 => 'febrero',
    3 => 'marzo',
    4 => 'abril',
    5 => 'mayo',
    6 => 'junio',
    7 => 'julio',
    8 => 'agosto',
    9 => 'septiembre',
    10 => 'octubre',
    11 => 'noviembre',
    12 => 'diciembre',
    _ => '',
  };
}

String _fullDateLabel(DateTime date) {
  return '${_weekdayName(date)} ${date.day} de ${_monthName(date.month)}';
}
