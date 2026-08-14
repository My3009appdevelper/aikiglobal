import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_subscription.dart';
import '../remote/services/subscription_remote_service.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController({SubscriptionRemoteService? remoteService})
    : _remoteService = remoteService;

  final SubscriptionRemoteService? _remoteService;

  List<AppSubscriptionProduct> _availableProducts = const [];
  AppUserSubscription? _currentSubscription;
  String? _activeProfileUuid;
  bool _isLoading = false;
  Object? _error;
  int _requestGeneration = 0;

  List<AppSubscriptionProduct> get availableProducts => _availableProducts;
  AppUserSubscription? get currentSubscription => _currentSubscription;
  String? get activeProfileUuid => _activeProfileUuid;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  bool get hasPremiumAccess => _currentSubscription?.hasPremiumAccess ?? false;

  AppSubscriptionProduct? get currentProduct {
    final subscription = _currentSubscription;
    if (subscription == null) {
      return null;
    }

    for (final product in _availableProducts) {
      if (product.uuidSubscriptionProduct ==
          subscription.uuidSubscriptionProduct) {
        return product;
      }
    }

    return null;
  }

  bool get hasDownloadAccess =>
      hasPremiumAccess && currentProduct?.incluyeDescargas == true;

  void watchForProfile(String uuidProfile, {bool loadRemote = true}) {
    final cleanProfile = uuidProfile.trim();
    if (cleanProfile.isEmpty) {
      clear();
      return;
    }

    if (_activeProfileUuid == cleanProfile && _currentSubscription != null) {
      return;
    }

    final profileChanged = _activeProfileUuid != cleanProfile;
    _activeProfileUuid = cleanProfile;
    if (profileChanged) {
      _currentSubscription = null;
      _availableProducts = const [];
      _error = null;
      notifyListeners();
    }
    if (loadRemote) {
      unawaited(loadCurrentSubscription());
    }
  }

  Future<void> loadCurrentSubscription() async {
    final profileUuid = _activeProfileUuid;
    final service = _remoteService;
    if (profileUuid == null || profileUuid.isEmpty || service == null) {
      return;
    }

    final requestGeneration = ++_requestGeneration;

    _setLoading(true);
    _error = null;

    try {
      final results = await Future.wait([
        service.getAvailableProductsOnline(),
        service.getCurrentForProfileOnline(profileUuid),
      ]);
      if (!_isCurrentRequest(requestGeneration, profileUuid)) {
        return;
      }

      _availableProducts = List<AppSubscriptionProduct>.unmodifiable(
        results[0] as List<AppSubscriptionProduct>,
      );
      _currentSubscription = results[1] as AppUserSubscription?;
    } catch (error) {
      if (!_isCurrentRequest(requestGeneration, profileUuid)) {
        return;
      }
      _error = error;
    } finally {
      if (_isCurrentRequest(requestGeneration, profileUuid)) {
        _setLoading(false);
      }
    }
  }

  Future<void> refresh() => loadCurrentSubscription();

  Future<void> syncWithRemote() => loadCurrentSubscription();

  void clear() {
    _requestGeneration++;
    _activeProfileUuid = null;
    _availableProducts = const [];
    _currentSubscription = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  bool _isCurrentRequest(int requestGeneration, String profileUuid) {
    return requestGeneration == _requestGeneration &&
        _activeProfileUuid == profileUuid;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
