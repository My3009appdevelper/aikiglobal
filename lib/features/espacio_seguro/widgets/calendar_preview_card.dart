import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../data/mock_safe_space_data.dart';

class CalendarPreviewCard extends StatelessWidget {
  const CalendarPreviewCard({super.key});

  static const _days = [
    _CalendarDay('LUN', '12'),
    _CalendarDay('MAR', '13'),
    _CalendarDay('MIÉ', '14'),
    _CalendarDay('JUE', '15', selected: true),
    _CalendarDay('VIE', '16'),
    _CalendarDay('SÁB', '17'),
    _CalendarDay('DOM', '18'),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surface = brightness == Brightness.dark
        ? AppColors.darkSurface
        : AppColors.white;
    final stroke = brightness == Brightness.dark
        ? AppColors.darkStroke
        : AppColors.stroke;
    final accent = Theme.of(context).colorScheme.primary;

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Próximos\ncursos',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right_rounded),
                label: const Text('Ver agenda'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final day in _days) Expanded(child: _DayChip(day: day)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: stroke, height: 1),
          const SizedBox(height: 12),
          for (final event in MockSafeSpaceData.events) ...[
            _CalendarEventTile(event: event),
            if (event != MockSafeSpaceData.events.last)
              Divider(color: stroke, height: 18),
          ],
        ],
      ),
    );
  }
}

class _CalendarDay {
  const _CalendarDay(this.label, this.number, {this.selected = false});

  final String label;
  final String number;
  final bool selected;
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day});

  final _CalendarDay day;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final selectedColor = Theme.of(context).colorScheme.primary;
    final selectedForeground = Theme.of(context).colorScheme.onPrimary;
    final textColor = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Column(
      children: [
        Text(
          day.label,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: day.selected ? selectedColor : AppColors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            day.number,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: day.selected ? selectedForeground : textColor,
              fontWeight: day.selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final chipColor = brightness == Brightness.dark
        ? AppColors.darkSurfaceSoft
        : AppColors.sandLight;
    final accent = Theme.of(context).colorScheme.primary;
    final muted = brightness == Brightness.dark
        ? AppColors.darkTextMuted
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            event.imageAsset,
            width: 66,
            height: 74,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(width: 66, height: 74, color: AppColors.sand);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    event.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                event.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(height: 1.08),
              ),
              const SizedBox(height: 4),
              Text(
                event.when,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: muted, height: 1.12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Icon(Icons.chevron_right_rounded, color: muted, size: 24),
        ),
      ],
    );
  }
}
