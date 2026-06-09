import '../../../core/constants/app_assets.dart';
import '../models/content_item.dart';

class MockExploreData {
  const MockExploreData._();

  static const courses = [
    ContentItem(
      title: 'Sanación desde el cuerpo',
      type: 'Curso',
      lessons: 8,
      duration: '1h 24m',
      imageAsset: AppAssets.curso4,
      isNew: true,
      description:
          'Reconecta con tu cuerpo a través de respiración, tacto consciente y prácticas somáticas suaves.',
    ),
    ContentItem(
      title: 'Conecta con la tierra',
      type: 'Curso',
      lessons: 8,
      duration: '2h 15m',
      imageAsset: AppAssets.curso2,
      description:
          'Una práctica para volver al presente, liberar tensión y sentirte enraizado en la naturaleza.',
    ),
    ContentItem(
      title: 'Energía y equilibrio',
      type: 'Curso',
      lessons: 10,
      duration: '1h 32m',
      imageAsset: AppAssets.curso6,
      isFavorite: true,
      description:
          'Secuencias de yoga y respiración para renovar vitalidad, postura y claridad mental.',
    ),
    ContentItem(
      title: 'Círculo de terapia consciente',
      type: 'Curso',
      lessons: 6,
      duration: '58m',
      imageAsset: AppAssets.curso1,
      description:
          'Aprende herramientas de escucha, presencia y acompañamiento emocional en un espacio seguro.',
    ),
    ContentItem(
      title: 'Semillas de intención',
      type: 'Curso',
      lessons: 5,
      duration: '44m',
      imageAsset: AppAssets.curso3,
      description:
          'Un proceso de crecimiento personal para sembrar hábitos, rituales y decisiones alineadas.',
    ),
    ContentItem(
      title: 'Acompañamiento interior',
      type: 'Curso',
      lessons: 7,
      duration: '1h 10m',
      imageAsset: AppAssets.curso5,
      description:
          'Prácticas guiadas para observar tus emociones, ordenar tu energía y pedir apoyo con claridad.',
    ),
    ContentItem(
      title: 'Terapia personalizada Aiki',
      type: 'Curso',
      lessons: 4,
      duration: '36m',
      imageAsset: AppAssets.curso7,
      description:
          'Una introducción a sesiones uno a uno, objetivos terapéuticos y cuidado integral.',
    ),
    ContentItem(
      title: 'Expansión al atardecer',
      type: 'Curso',
      lessons: 7,
      duration: '1h 18m',
      imageAsset: AppAssets.curso8,
      description:
          'Movimiento consciente para abrir el cuerpo, soltar rigidez y cerrar el día con presencia.',
    ),
  ];

  static const meditations = [
    ContentItem(
      title: 'Mindfulness esencial',
      type: 'Meditación',
      duration: '18 min',
      imageAsset: AppAssets.meditacion1,
      isNew: true,
      description:
          'Una guía luminosa para observar tu respiración y regresar a tu centro.',
    ),
    ContentItem(
      title: 'Respira y suelta',
      type: 'Meditación',
      duration: '18 min',
      imageAsset: AppAssets.meditacion2,
      description:
          'Respiración consciente para suavizar tensión y abrir espacio emocional.',
    ),
    ContentItem(
      title: 'Silencio en el santuario',
      type: 'Meditación',
      duration: '20 min',
      imageAsset: AppAssets.meditacion3,
      description:
          'Una pausa guiada para entrar en calma profunda desde un espacio sereno.',
    ),
    ContentItem(
      title: 'Presencia del corazón',
      type: 'Meditación',
      duration: '16 min',
      imageAsset: AppAssets.meditacion4,
      isFavorite: true,
      description:
          'Conecta con gratitud, compasión y estabilidad emocional desde el corazón.',
    ),
    ContentItem(
      title: 'Agua que purifica',
      type: 'Meditación',
      duration: '22 min',
      imageAsset: AppAssets.meditacion5,
      description:
          'Visualización con agua, respiración y conciencia para liberar cargas del día.',
    ),
    ContentItem(
      title: 'Claridad al amanecer',
      type: 'Meditación',
      duration: '14 min',
      imageAsset: AppAssets.meditacion6,
      description:
          'Una práctica breve para empezar el día con intención, suavidad y foco.',
    ),
    ContentItem(
      title: 'Templo de calma',
      type: 'Meditación',
      duration: '24 min',
      imageAsset: AppAssets.meditacion7,
      description:
          'Meditación espacial para sentir refugio, amplitud y seguridad interior.',
    ),
    ContentItem(
      title: 'Cascada interior',
      type: 'Meditación',
      duration: '19 min',
      imageAsset: AppAssets.meditacion8,
      description:
          'Un recorrido sensorial por agua y naturaleza para renovar tu energía.',
    ),
    ContentItem(
      title: 'Respiración del océano',
      type: 'Meditación',
      duration: '21 min',
      imageAsset: AppAssets.meditacion9,
      description:
          'Respira con el ritmo del mar y deja que la mente encuentre espacio.',
    ),
  ];

  static const events = [
    ContentItem(
      title: 'Jardín zen abierto',
      type: 'Evento',
      duration: 'Sábado 9:00 AM',
      imageAsset: AppAssets.evento1,
      isNew: true,
      description:
          'Recorrido contemplativo por jardines, respiración y ritual de bienvenida.',
    ),
    ContentItem(
      title: 'Círculo de comunidad',
      type: 'Evento',
      duration: 'Viernes 6:00 PM',
      imageAsset: AppAssets.evento2,
      description:
          'Encuentro íntimo para compartir, meditar y fortalecer comunidad.',
    ),
    ContentItem(
      title: 'Noche de lámparas zen',
      type: 'Evento',
      duration: 'Jueves 7:30 PM',
      imageAsset: AppAssets.evento3,
      description:
          'Una experiencia sensorial de silencio, luz cálida y contemplación.',
    ),
    ContentItem(
      title: 'Meditación grupal en jardín',
      type: 'Evento',
      duration: 'Domingo 10:00 AM',
      imageAsset: AppAssets.evento4,
      description:
          'Práctica colectiva para abrir la semana desde calma, presencia y unión.',
    ),
    ContentItem(
      title: 'Retiro de montaña',
      type: 'Evento',
      duration: 'Próximo mes',
      imageAsset: AppAssets.evento5,
      description:
          'Una jornada de pausa, respiración y caminata consciente en naturaleza.',
    ),
    ContentItem(
      title: 'Festival de bienestar Aiki',
      type: 'Evento',
      duration: '2h 30m',
      imageAsset: AppAssets.evento6,
      isFavorite: true,
      description:
          'Terapias, yoga, meditación y convivencia para celebrar tu bienestar.',
    ),
    ContentItem(
      title: 'Caminata consciente',
      type: 'Evento',
      duration: 'Miércoles 8:00 AM',
      imageAsset: AppAssets.evento7,
      description:
          'Un recorrido lento para despertar sentidos, cuerpo y gratitud.',
    ),
    ContentItem(
      title: 'Santuario de primavera',
      type: 'Evento',
      duration: '18 de junio',
      imageAsset: AppAssets.evento8,
      description:
          'Encuentro especial entre flores, jardines y prácticas restaurativas.',
    ),
  ];

  static const audios = [
    ContentItem(
      title: 'Relajación profunda',
      type: 'Audio',
      duration: '32 min',
      imageAsset: AppAssets.audio3,
      isFavorite: true,
      description:
          'Paisaje sonoro para descansar el sistema nervioso y soltar el cuerpo.',
    ),
    ContentItem(
      title: 'Cuencos tibetanos',
      type: 'Audio',
      duration: '28 min',
      imageAsset: AppAssets.audio2,
      description:
          'Vibración cálida para meditar, estudiar o preparar tu descanso.',
    ),
    ContentItem(
      title: 'Ritual de té consciente',
      type: 'Audio',
      duration: '15 min',
      imageAsset: AppAssets.audio1,
      description:
          'Una guía breve para pausar, beber lento y reconectar con tus sentidos.',
    ),
    ContentItem(
      title: 'Sonido de lluvia interior',
      type: 'Audio',
      duration: '40 min',
      imageAsset: AppAssets.audio5,
      description:
          'Ambiente suave para concentración, lectura o descanso nocturno.',
    ),
    ContentItem(
      title: 'Pausa con cacao y calma',
      type: 'Audio',
      duration: '17 min',
      imageAsset: AppAssets.audio4,
      description:
          'Una pausa guiada para volver al cuerpo desde aromas, temperatura y presencia.',
    ),
    ContentItem(
      title: 'Té, piedras y silencio',
      type: 'Audio',
      duration: '26 min',
      imageAsset: AppAssets.audio6,
      description:
          'Texturas sonoras tranquilas para bajar revoluciones y ordenar la mente.',
    ),
    ContentItem(
      title: 'Frecuencias cristalinas',
      type: 'Audio',
      duration: '33 min',
      imageAsset: AppAssets.audio10,
      isNew: true,
      description:
          'Cuencos de cristal y respiración lenta para crear un estado meditativo.',
    ),
    ContentItem(
      title: 'Fuego de descanso',
      type: 'Audio',
      duration: '45 min',
      imageAsset: AppAssets.audio9,
      description:
          'Sonido de chimenea, respiración y calidez para cerrar la noche.',
    ),
    ContentItem(
      title: 'Bosque de bambú',
      type: 'Audio',
      duration: '36 min',
      imageAsset: AppAssets.audio11,
      description:
          'Ambiente natural para caminar mentalmente entre hojas, viento y luz.',
    ),
    ContentItem(
      title: 'Arroyo y piedras',
      type: 'Audio',
      duration: '38 min',
      imageAsset: AppAssets.audio12,
      description:
          'Agua sobre piedra para entrar en foco tranquilo y respiración estable.',
    ),
    ContentItem(
      title: 'Campanas del porche',
      type: 'Audio',
      duration: '30 min',
      imageAsset: AppAssets.audio13,
      description:
          'Campanas suaves, jardín y viento para acompañar una pausa consciente.',
    ),
    ContentItem(
      title: 'Descanso lunar',
      type: 'Audio',
      duration: '42 min',
      imageAsset: AppAssets.audio14,
      description:
          'Una atmósfera nocturna para relajar pensamientos antes de dormir.',
    ),
    ContentItem(
      title: 'Café tranquilo',
      type: 'Audio',
      duration: '22 min',
      imageAsset: AppAssets.audio15,
      description:
          'Sonido cálido de interior, taza y silencio para una pausa personal.',
    ),
    ContentItem(
      title: 'Ritual de limpieza sonora',
      type: 'Audio',
      duration: '24 min',
      imageAsset: AppAssets.audio7,
      description:
          'Cuencos y frecuencias suaves para preparar meditación o terapia.',
    ),
    ContentItem(
      title: 'Velas para soltar',
      type: 'Audio',
      duration: '18 min',
      imageAsset: AppAssets.audio8,
      description:
          'Una guía de respiración con intención de descanso y autocuidado.',
    ),
  ];

  static const recommended = [
    ContentItem(
      title: 'Conecta con la tierra',
      type: 'Curso',
      lessons: 8,
      duration: '2h 15m',
      imageAsset: AppAssets.curso2,
      isFavorite: true,
      description:
          'Una práctica para volver al presente, liberar tensión y sentirte enraizado.',
    ),
    ContentItem(
      title: 'Frecuencias cristalinas',
      type: 'Audio',
      duration: '33 min',
      imageAsset: AppAssets.audio10,
      isNew: true,
      description:
          'Cuencos de cristal y respiración lenta para crear un estado meditativo.',
    ),
    ContentItem(
      title: 'Presencia del corazón',
      type: 'Meditación',
      duration: '16 min',
      imageAsset: AppAssets.meditacion4,
      isFavorite: true,
      description:
          'Conecta con gratitud, compasión y estabilidad emocional desde el corazón.',
    ),
    ContentItem(
      title: 'Festival de bienestar Aiki',
      type: 'Evento',
      duration: '2h 30m',
      imageAsset: AppAssets.evento6,
      description:
          'Terapias, yoga, meditación y convivencia para celebrar tu bienestar.',
    ),
    ContentItem(
      title: 'Sanación desde el cuerpo',
      type: 'Curso',
      lessons: 8,
      duration: '1h 24m',
      imageAsset: AppAssets.curso4,
      description:
          'Reconecta con tu cuerpo a través de respiración y prácticas somáticas suaves.',
    ),
    ContentItem(
      title: 'Respiración del océano',
      type: 'Meditación',
      duration: '21 min',
      imageAsset: AppAssets.meditacion9,
      description:
          'Respira con el ritmo del mar y deja que la mente encuentre espacio.',
    ),
  ];
}
