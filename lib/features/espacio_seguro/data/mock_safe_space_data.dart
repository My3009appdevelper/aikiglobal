import '../../../core/constants/app_assets.dart';

class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.when,
    required this.type,
    required this.imageAsset,
  });

  final String title;
  final String when;
  final String type;
  final String imageAsset;
}

class WellnessMetric {
  const WellnessMetric({
    required this.label,
    required this.value,
    required this.iconCodePoint,
  });

  final String label;
  final double value;
  final int iconCodePoint;
}

class MockSafeSpaceData {
  const MockSafeSpaceData._();

  static const events = [
    CalendarEvent(
      title: 'Yoga para reconectar con la tierra',
      when: 'Jueves 15 de mayo · 8:30 a.m.',
      type: 'Curso',
      imageAsset: AppAssets.curso2,
    ),
    CalendarEvent(
      title: 'Meditación: paciencia y tiempo divino',
      when: 'Jueves 15 de mayo · 10:00 a.m.',
      type: 'Meditación',
      imageAsset: AppAssets.meditacion2,
    ),
    CalendarEvent(
      title: 'Ritual de cuencos para descanso profundo',
      when: 'Jueves 15 de mayo · 7:00 p.m.',
      type: 'Audio',
      imageAsset: AppAssets.audio10,
    ),
  ];

  static const metrics = [
    WellnessMetric(label: 'Energía', value: 0.78, iconCodePoint: 0xe3e7),
    WellnessMetric(label: 'Calma', value: 0.86, iconCodePoint: 0xe1d1),
    WellnessMetric(label: 'Descanso', value: 0.66, iconCodePoint: 0xf060b),
    WellnessMetric(label: 'Conexión', value: 0.58, iconCodePoint: 0xe25b),
  ];
}
