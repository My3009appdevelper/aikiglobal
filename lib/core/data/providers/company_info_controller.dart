import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../local/daos/company_info_dao.dart';
import '../models/app_company_info.dart';
import '../models/pending_company_info_image_upload.dart';
import '../remote/services/company_info_remote_service.dart';
import '../remote/services/company_info_storage_service.dart';
import '../sync/company_info_sync_service.dart';
import '../sync/sync_mappers.dart';

class CompanyInfoController extends ChangeNotifier {
  CompanyInfoController({
    required CompanyInfoDao? companyInfoDao,
    CompanyInfoRemoteService? companyInfoRemoteService,
    CompanyInfoStorageService? companyInfoStorageService,
    CompanyInfoSyncService? syncService,
  }) : _companyInfoDao = companyInfoDao,
       _companyInfoRemoteService = companyInfoRemoteService,
       _companyInfoStorageService = companyInfoStorageService,
       _syncService = syncService;

  final CompanyInfoDao? _companyInfoDao;
  final CompanyInfoRemoteService? _companyInfoRemoteService;
  final CompanyInfoStorageService? _companyInfoStorageService;
  final CompanyInfoSyncService? _syncService;

  StreamSubscription<LocalCompanyInfo?>? _subscription;
  AppCompanyInfo? _info;
  bool _isLoading = false;
  bool _isSyncing = false;
  Object? _error;

  AppCompanyInfo get item => _info ?? AppCompanyInfo.fallback();
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  Object? get error => _error;
  bool get hasRemote => _companyInfoRemoteService != null;

  Future<String?> resolveInfoImageUrl(String imagePath) {
    return _companyInfoStorageService?.createSignedUrl(imagePath) ??
        Future.value(null);
  }

  void watch() {
    final dao = _companyInfoDao;
    if (dao == null) {
      unawaited(load());
      return;
    }

    _subscription?.cancel();
    _subscription = dao.watchMain().listen(
      (localInfo) {
        _info = localInfo == null ? null : AppCompanyInfo.fromLocal(localInfo);
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        notifyListeners();
      },
    );
  }

  Future<void> load() async {
    _setLoading(true);
    _error = null;

    try {
      final dao = _companyInfoDao;
      if (dao != null) {
        final localInfo = await dao.getMain();
        if (localInfo != null) {
          _info = AppCompanyInfo.fromLocal(localInfo);
          return;
        }
      }

      final remoteService = _companyInfoRemoteService;
      if (remoteService == null) {
        return;
      }

      final remoteInfo = await remoteService.getMainOnline();
      if (remoteInfo == null) {
        return;
      }

      if (dao != null) {
        await dao.upsertCompanyInfo(companyInfoRemoteToCompanion(remoteInfo));
      }
      _info = companyInfoRemoteToApp(remoteInfo);
    } catch (error) {
      _error = error;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pullFromRemote() async {
    final dao = _companyInfoDao;
    final syncService = _syncService;
    if (dao == null || syncService == null) {
      await load();
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.pull();
      final localInfo = await dao.getMain();
      if (localInfo != null) {
        _info = AppCompanyInfo.fromLocal(localInfo);
      }
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> syncWithRemote() async {
    final dao = _companyInfoDao;
    final syncService = _syncService;
    if (dao == null || syncService == null) {
      await load();
      return;
    }

    _setSyncing(true);
    _error = null;

    try {
      await syncService.sync();
      final localInfo = await dao.getMain();
      if (localInfo != null) {
        _info = AppCompanyInfo.fromLocal(localInfo);
      }
    } catch (error) {
      _error = error;
    } finally {
      _setSyncing(false);
    }
  }

  Future<void> saveInfo({
    required String heroTitulo,
    required String heroSubtitulo,
    String? heroImagePath,
    PendingCompanyInfoImageUpload? heroImageUpload,
    required String textoEntrada,
    required String quienesSomos,
    required String significadoAiki,
    required String mision,
    required String vision,
    required String filosofia,
    required String mensajeFundadoresTitulo,
    required String mensajeFundadoresTexto,
    String? mensajeFundadoresImagePath1,
    PendingCompanyInfoImageUpload? mensajeFundadoresImageUpload1,
    String? mensajeFundadoresImagePath2,
    PendingCompanyInfoImageUpload? mensajeFundadoresImageUpload2,
    String? mensajeFundadoresImagePath3,
    PendingCompanyInfoImageUpload? mensajeFundadoresImageUpload3,
    String? mensajeFundadoresImagePath4,
    PendingCompanyInfoImageUpload? mensajeFundadoresImageUpload4,
    String? mensajeFundadoresImagePath5,
    PendingCompanyInfoImageUpload? mensajeFundadoresImageUpload5,
    bool syncAfterSave = false,
  }) async {
    final cleanHeroTitulo = heroTitulo.trim();
    final cleanHeroSubtitulo = heroSubtitulo.trim();
    final cleanHeroImagePathInput = _cleanNullableText(heroImagePath);
    final cleanTextoEntrada = textoEntrada.trim();
    final cleanQuienesSomos = quienesSomos.trim();
    final cleanSignificadoAiki = significadoAiki.trim();
    final cleanMision = mision.trim();
    final cleanVision = vision.trim();
    final cleanFilosofia = filosofia.trim();
    final cleanMensajeFundadoresTitulo = mensajeFundadoresTitulo.trim();
    final cleanMensajeFundadoresTexto = mensajeFundadoresTexto.trim();
    final cleanMensajeFundadoresImagePathInput1 = _cleanNullableText(
      mensajeFundadoresImagePath1,
    );
    final cleanMensajeFundadoresImagePathInput2 = _cleanNullableText(
      mensajeFundadoresImagePath2,
    );
    final cleanMensajeFundadoresImagePathInput3 = _cleanNullableText(
      mensajeFundadoresImagePath3,
    );
    final cleanMensajeFundadoresImagePathInput4 = _cleanNullableText(
      mensajeFundadoresImagePath4,
    );
    final cleanMensajeFundadoresImagePathInput5 = _cleanNullableText(
      mensajeFundadoresImagePath5,
    );

    if (cleanHeroTitulo.isEmpty ||
        cleanHeroSubtitulo.isEmpty ||
        cleanTextoEntrada.isEmpty ||
        cleanQuienesSomos.isEmpty ||
        cleanSignificadoAiki.isEmpty ||
        cleanMision.isEmpty ||
        cleanVision.isEmpty ||
        cleanFilosofia.isEmpty) {
      throw ArgumentError(
        'Completa todos los campos de información de la empresa.',
      );
    }

    final uploadedHeroImagePath = await _uploadImageIfNeeded(
      slot: companyInfoHeroImageSlot,
      upload: heroImageUpload,
    );
    final uploadedFundadoresImagePath1 = await _uploadImageIfNeeded(
      slot: companyInfoFounderImageSlot(1),
      upload: mensajeFundadoresImageUpload1,
    );
    final uploadedFundadoresImagePath2 = await _uploadImageIfNeeded(
      slot: companyInfoFounderImageSlot(2),
      upload: mensajeFundadoresImageUpload2,
    );
    final uploadedFundadoresImagePath3 = await _uploadImageIfNeeded(
      slot: companyInfoFounderImageSlot(3),
      upload: mensajeFundadoresImageUpload3,
    );
    final uploadedFundadoresImagePath4 = await _uploadImageIfNeeded(
      slot: companyInfoFounderImageSlot(4),
      upload: mensajeFundadoresImageUpload4,
    );
    final uploadedFundadoresImagePath5 = await _uploadImageIfNeeded(
      slot: companyInfoFounderImageSlot(5),
      upload: mensajeFundadoresImageUpload5,
    );
    final cleanHeroImagePath = uploadedHeroImagePath ?? cleanHeroImagePathInput;
    final cleanMensajeFundadoresImagePath1 =
        uploadedFundadoresImagePath1 ?? cleanMensajeFundadoresImagePathInput1;
    final cleanMensajeFundadoresImagePath2 =
        uploadedFundadoresImagePath2 ?? cleanMensajeFundadoresImagePathInput2;
    final cleanMensajeFundadoresImagePath3 =
        uploadedFundadoresImagePath3 ?? cleanMensajeFundadoresImagePathInput3;
    final cleanMensajeFundadoresImagePath4 =
        uploadedFundadoresImagePath4 ?? cleanMensajeFundadoresImagePathInput4;
    final cleanMensajeFundadoresImagePath5 =
        uploadedFundadoresImagePath5 ?? cleanMensajeFundadoresImagePathInput5;

    final now = DateTime.now().toUtc();
    final current = _info;
    final hasPersistedInfo =
        current != null &&
        current.uuidCompanyInfo != AppCompanyInfo.fallbackUuid;
    final uuidCompanyInfo = hasPersistedInfo
        ? current.uuidCompanyInfo
        : _generateUuidV4();
    final createdAt = hasPersistedInfo ? current.createdAt : now;
    final dao = _companyInfoDao;
    final remoteService = _companyInfoRemoteService;

    final nextInfo = AppCompanyInfo(
      uuidCompanyInfo: uuidCompanyInfo,
      slug: CompanyInfoDao.mainSlug,
      heroTitulo: cleanHeroTitulo,
      heroSubtitulo: cleanHeroSubtitulo,
      heroImagePath: cleanHeroImagePath,
      textoEntrada: cleanTextoEntrada,
      quienesSomos: cleanQuienesSomos,
      significadoAiki: cleanSignificadoAiki,
      mision: cleanMision,
      vision: cleanVision,
      filosofia: cleanFilosofia,
      mensajeFundadoresTitulo: cleanMensajeFundadoresTitulo,
      mensajeFundadoresTexto: cleanMensajeFundadoresTexto,
      mensajeFundadoresImagePath1: cleanMensajeFundadoresImagePath1,
      mensajeFundadoresImagePath2: cleanMensajeFundadoresImagePath2,
      mensajeFundadoresImagePath3: cleanMensajeFundadoresImagePath3,
      mensajeFundadoresImagePath4: cleanMensajeFundadoresImagePath4,
      mensajeFundadoresImagePath5: cleanMensajeFundadoresImagePath5,
      createdAt: createdAt,
      updatedAt: now,
      syncedAt: null,
    );

    if (dao != null) {
      await dao.upsertCompanyInfo(
        CompanyInfoTableCompanion.insert(
          uuidCompanyInfo: uuidCompanyInfo,
          slug: const Value(CompanyInfoDao.mainSlug),
          heroTitulo: Value(cleanHeroTitulo),
          heroSubtitulo: Value(cleanHeroSubtitulo),
          heroImagePath: Value(cleanHeroImagePath),
          textoEntrada: Value(cleanTextoEntrada),
          quienesSomos: cleanQuienesSomos,
          significadoAiki: Value(cleanSignificadoAiki),
          mision: cleanMision,
          vision: cleanVision,
          filosofia: cleanFilosofia,
          mensajeFundadoresTitulo: Value(cleanMensajeFundadoresTitulo),
          mensajeFundadoresTexto: Value(cleanMensajeFundadoresTexto),
          mensajeFundadoresImagePath1: Value(cleanMensajeFundadoresImagePath1),
          mensajeFundadoresImagePath2: Value(cleanMensajeFundadoresImagePath2),
          mensajeFundadoresImagePath3: Value(cleanMensajeFundadoresImagePath3),
          mensajeFundadoresImagePath4: Value(cleanMensajeFundadoresImagePath4),
          mensajeFundadoresImagePath5: Value(cleanMensajeFundadoresImagePath5),
          createdAt: Value(createdAt),
          updatedAt: Value(now),
          deletedAt: const Value(null),
          syncedAt: const Value(null),
        ),
      );
      _info = nextInfo;
      notifyListeners();
    } else if (remoteService != null) {
      await remoteService.upsertOnline({
        'uuid_company_info': uuidCompanyInfo,
        'slug': CompanyInfoDao.mainSlug,
        'hero_titulo': cleanHeroTitulo,
        'hero_subtitulo': cleanHeroSubtitulo,
        'hero_image_path': cleanHeroImagePath,
        'texto_entrada': cleanTextoEntrada,
        'quienes_somos': cleanQuienesSomos,
        'significado_aiki': cleanSignificadoAiki,
        'mision': cleanMision,
        'vision': cleanVision,
        'filosofia': cleanFilosofia,
        'mensaje_fundadores_titulo': cleanMensajeFundadoresTitulo,
        'mensaje_fundadores_texto': cleanMensajeFundadoresTexto,
        'mensaje_fundadores_image_path1': cleanMensajeFundadoresImagePath1,
        'mensaje_fundadores_image_path2': cleanMensajeFundadoresImagePath2,
        'mensaje_fundadores_image_path3': cleanMensajeFundadoresImagePath3,
        'mensaje_fundadores_image_path4': cleanMensajeFundadoresImagePath4,
        'mensaje_fundadores_image_path5': cleanMensajeFundadoresImagePath5,
        'created_at': remoteService.isoUtc(createdAt),
        'updated_at': remoteService.isoUtc(now),
        'deleted_at': null,
        'synced_at': remoteService.isoUtc(now),
      });
      _info = AppCompanyInfo(
        uuidCompanyInfo: uuidCompanyInfo,
        slug: CompanyInfoDao.mainSlug,
        heroTitulo: cleanHeroTitulo,
        heroSubtitulo: cleanHeroSubtitulo,
        heroImagePath: cleanHeroImagePath,
        textoEntrada: cleanTextoEntrada,
        quienesSomos: cleanQuienesSomos,
        significadoAiki: cleanSignificadoAiki,
        mision: cleanMision,
        vision: cleanVision,
        filosofia: cleanFilosofia,
        mensajeFundadoresTitulo: cleanMensajeFundadoresTitulo,
        mensajeFundadoresTexto: cleanMensajeFundadoresTexto,
        mensajeFundadoresImagePath1: cleanMensajeFundadoresImagePath1,
        mensajeFundadoresImagePath2: cleanMensajeFundadoresImagePath2,
        mensajeFundadoresImagePath3: cleanMensajeFundadoresImagePath3,
        mensajeFundadoresImagePath4: cleanMensajeFundadoresImagePath4,
        mensajeFundadoresImagePath5: cleanMensajeFundadoresImagePath5,
        createdAt: createdAt,
        updatedAt: now,
        syncedAt: now,
      );
      notifyListeners();
    }

    if (syncAfterSave) {
      await syncWithRemote();
      final syncError = _error;
      if (syncError != null) {
        throw syncError;
      }
      _deleteReplacedImages(
        previous: current,
        nextHeroImagePath: cleanHeroImagePath,
        nextFounderImagePath1: cleanMensajeFundadoresImagePath1,
        nextFounderImagePath2: cleanMensajeFundadoresImagePath2,
        nextFounderImagePath3: cleanMensajeFundadoresImagePath3,
        nextFounderImagePath4: cleanMensajeFundadoresImagePath4,
        nextFounderImagePath5: cleanMensajeFundadoresImagePath5,
      );
    }
  }

  Future<String?> _uploadImageIfNeeded({
    required String slot,
    required PendingCompanyInfoImageUpload? upload,
  }) async {
    if (upload == null) {
      return null;
    }

    final storageService = _companyInfoStorageService;
    if (storageService == null) {
      throw StateError('No hay servicio de Storage para subir la imagen.');
    }

    return storageService.uploadImage(
      slot: slot,
      bytes: upload.bytes,
      fileName: upload.fileName,
      contentType: upload.contentType,
    );
  }

  void _deleteReplacedImages({
    required AppCompanyInfo? previous,
    required String? nextHeroImagePath,
    required String? nextFounderImagePath1,
    required String? nextFounderImagePath2,
    required String? nextFounderImagePath3,
    required String? nextFounderImagePath4,
    required String? nextFounderImagePath5,
  }) {
    if (previous == null) {
      return;
    }

    _deleteReplacedImageIfNeeded(previous.heroImagePath, nextHeroImagePath);
    _deleteReplacedImageIfNeeded(
      previous.mensajeFundadoresImagePath1,
      nextFounderImagePath1,
    );
    _deleteReplacedImageIfNeeded(
      previous.mensajeFundadoresImagePath2,
      nextFounderImagePath2,
    );
    _deleteReplacedImageIfNeeded(
      previous.mensajeFundadoresImagePath3,
      nextFounderImagePath3,
    );
    _deleteReplacedImageIfNeeded(
      previous.mensajeFundadoresImagePath4,
      nextFounderImagePath4,
    );
    _deleteReplacedImageIfNeeded(
      previous.mensajeFundadoresImagePath5,
      nextFounderImagePath5,
    );
  }

  void _deleteReplacedImageIfNeeded(String? previousPath, String? nextPath) {
    final cleanPreviousPath = _cleanNullableText(previousPath);
    if (cleanPreviousPath == null || cleanPreviousPath == nextPath) {
      return;
    }

    final storageService = _companyInfoStorageService;
    if (storageService == null) {
      return;
    }

    unawaited(storageService.deleteImage(cleanPreviousPath).catchError((_) {}));
  }

  String? _cleanNullableText(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _setSyncing(bool value) {
    if (_isSyncing == value) {
      return;
    }
    _isSyncing = value;
    notifyListeners();
  }

  String _generateUuidV4() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String byteToHex(int value) => value.toRadixString(16).padLeft(2, '0');
    final hex = bytes.map(byteToHex).join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20),
    ].join('-');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
