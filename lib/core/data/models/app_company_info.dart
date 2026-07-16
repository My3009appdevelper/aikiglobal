import '../local/app_database.dart';

class AppCompanyInfo {
  static const fallbackUuid = 'local-fallback-company-info';

  const AppCompanyInfo({
    required this.uuidCompanyInfo,
    required this.slug,
    required this.heroTitulo,
    required this.heroSubtitulo,
    this.heroImagePath,
    required this.textoEntrada,
    required this.quienesSomos,
    required this.significadoAiki,
    required this.mision,
    required this.vision,
    required this.filosofia,
    required this.mensajeFundadoresTitulo,
    required this.mensajeFundadoresTexto,
    this.mensajeFundadoresImagePath1,
    this.mensajeFundadoresImagePath2,
    this.mensajeFundadoresImagePath3,
    this.mensajeFundadoresImagePath4,
    this.mensajeFundadoresImagePath5,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });

  factory AppCompanyInfo.fromLocal(LocalCompanyInfo info) {
    return AppCompanyInfo(
      uuidCompanyInfo: info.uuidCompanyInfo,
      slug: info.slug,
      heroTitulo: info.heroTitulo,
      heroSubtitulo: info.heroSubtitulo,
      heroImagePath: info.heroImagePath,
      textoEntrada: info.textoEntrada,
      quienesSomos: info.quienesSomos,
      significadoAiki: info.significadoAiki,
      mision: info.mision,
      vision: info.vision,
      filosofia: info.filosofia,
      mensajeFundadoresTitulo: info.mensajeFundadoresTitulo,
      mensajeFundadoresTexto: info.mensajeFundadoresTexto,
      mensajeFundadoresImagePath1: info.mensajeFundadoresImagePath1,
      mensajeFundadoresImagePath2: info.mensajeFundadoresImagePath2,
      mensajeFundadoresImagePath3: info.mensajeFundadoresImagePath3,
      mensajeFundadoresImagePath4: info.mensajeFundadoresImagePath4,
      mensajeFundadoresImagePath5: info.mensajeFundadoresImagePath5,
      createdAt: info.createdAt,
      updatedAt: info.updatedAt,
      deletedAt: info.deletedAt,
      syncedAt: info.syncedAt,
    );
  }

  static AppCompanyInfo fallback() {
    final now = DateTime.utc(2026);
    return AppCompanyInfo(
      uuidCompanyInfo: fallbackUuid,
      slug: 'main',
      heroTitulo: 'Bienvenido a tu espacio de paz interior',
      heroSubtitulo: 'Explora, aprende y conecta contigo.',
      heroImagePath: null,
      textoEntrada:
          'Bienvenidos a Aiki Wellness Center®, un refugio donde el cuerpo, la mente y el espíritu encuentran su equilibrio perfecto.',
      quienesSomos:
          'Aiki es un espacio creado para acompañarte en tu bienestar, con prácticas, meditaciones y recursos pensados para volver a ti.',
      significadoAiki:
          'Aiki representa armonía, energía y presencia consciente.',
      mision:
          'Acompañar a cada persona en su proceso de calma, presencia y conexión interior.',
      vision:
          'Ser una comunidad de bienestar accesible, cálida y consciente para quienes buscan vivir con mayor equilibrio.',
      filosofia:
          'Creemos en la pausa, la respiración y el cuidado cotidiano como caminos simples para habitar la vida con más presencia.',
      mensajeFundadoresTitulo: '',
      mensajeFundadoresTexto: '',
      createdAt: now,
      updatedAt: now,
      syncedAt: now,
    );
  }

  final String uuidCompanyInfo;
  final String slug;
  final String heroTitulo;
  final String heroSubtitulo;
  final String? heroImagePath;
  final String textoEntrada;
  final String quienesSomos;
  final String significadoAiki;
  final String mision;
  final String vision;
  final String filosofia;
  final String mensajeFundadoresTitulo;
  final String mensajeFundadoresTexto;
  final String? mensajeFundadoresImagePath1;
  final String? mensajeFundadoresImagePath2;
  final String? mensajeFundadoresImagePath3;
  final String? mensajeFundadoresImagePath4;
  final String? mensajeFundadoresImagePath5;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;

  bool get isDeleted => deletedAt != null;
  bool get hasPendingSync => syncedAt == null || syncedAt!.isBefore(updatedAt);

  List<String> get mensajeFundadoresImagePaths {
    return [
      mensajeFundadoresImagePath1,
      mensajeFundadoresImagePath2,
      mensajeFundadoresImagePath3,
      mensajeFundadoresImagePath4,
      mensajeFundadoresImagePath5,
    ].whereType<String>().map((path) => path.trim()).where((path) {
      return path.isNotEmpty;
    }).toList(growable: false);
  }

  bool get hasMensajeFundadores {
    return mensajeFundadoresTitulo.trim().isNotEmpty ||
        mensajeFundadoresTexto.trim().isNotEmpty ||
        mensajeFundadoresImagePaths.isNotEmpty;
  }
}
