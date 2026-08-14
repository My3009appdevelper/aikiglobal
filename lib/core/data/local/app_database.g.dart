// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTableTable extends ProfilesTable
    with TableInfo<$ProfilesTableTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authUserIdMeta = const VerificationMeta(
    'authUserId',
  );
  @override
  late final GeneratedColumn<String> authUserId = GeneratedColumn<String>(
    'auth_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoPathSupabaseMeta = const VerificationMeta(
    'fotoPathSupabase',
  );
  @override
  late final GeneratedColumn<String> fotoPathSupabase = GeneratedColumn<String>(
    'foto_path_supabase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoPathLocalMeta = const VerificationMeta(
    'fotoPathLocal',
  );
  @override
  late final GeneratedColumn<String> fotoPathLocal = GeneratedColumn<String>(
    'foto_path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    check: () => role.isIn(profileRoles),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingCompletadoMeta =
      const VerificationMeta('onboardingCompletado');
  @override
  late final GeneratedColumn<bool> onboardingCompletado = GeneratedColumn<bool>(
    'onboarding_completado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidProfile,
    authUserId,
    nombre,
    email,
    fotoPathSupabase,
    fotoPathLocal,
    role,
    activo,
    onboardingCompletado,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('auth_user_id')) {
      context.handle(
        _authUserIdMeta,
        authUserId.isAcceptableOrUnknown(
          data['auth_user_id']!,
          _authUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authUserIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('foto_path_supabase')) {
      context.handle(
        _fotoPathSupabaseMeta,
        fotoPathSupabase.isAcceptableOrUnknown(
          data['foto_path_supabase']!,
          _fotoPathSupabaseMeta,
        ),
      );
    }
    if (data.containsKey('foto_path_local')) {
      context.handle(
        _fotoPathLocalMeta,
        fotoPathLocal.isAcceptableOrUnknown(
          data['foto_path_local']!,
          _fotoPathLocalMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('onboarding_completado')) {
      context.handle(
        _onboardingCompletadoMeta,
        onboardingCompletado.isAcceptableOrUnknown(
          data['onboarding_completado']!,
          _onboardingCompletadoMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidProfile};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      authUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_user_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      fotoPathSupabase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path_supabase'],
      ),
      fotoPathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path_local'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      onboardingCompletado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completado'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ProfilesTableTable createAlias(String alias) {
    return $ProfilesTableTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String uuidProfile;
  final String authUserId;
  final String? nombre;
  final String email;
  final String? fotoPathSupabase;
  final String? fotoPathLocal;
  final String role;
  final bool activo;
  final bool onboardingCompletado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalProfile({
    required this.uuidProfile,
    required this.authUserId,
    this.nombre,
    required this.email,
    this.fotoPathSupabase,
    this.fotoPathLocal,
    required this.role,
    required this.activo,
    required this.onboardingCompletado,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['auth_user_id'] = Variable<String>(authUserId);
    if (!nullToAbsent || nombre != null) {
      map['nombre'] = Variable<String>(nombre);
    }
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || fotoPathSupabase != null) {
      map['foto_path_supabase'] = Variable<String>(fotoPathSupabase);
    }
    if (!nullToAbsent || fotoPathLocal != null) {
      map['foto_path_local'] = Variable<String>(fotoPathLocal);
    }
    map['role'] = Variable<String>(role);
    map['activo'] = Variable<bool>(activo);
    map['onboarding_completado'] = Variable<bool>(onboardingCompletado);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return ProfilesTableCompanion(
      uuidProfile: Value(uuidProfile),
      authUserId: Value(authUserId),
      nombre: nombre == null && nullToAbsent
          ? const Value.absent()
          : Value(nombre),
      email: Value(email),
      fotoPathSupabase: fotoPathSupabase == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPathSupabase),
      fotoPathLocal: fotoPathLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPathLocal),
      role: Value(role),
      activo: Value(activo),
      onboardingCompletado: Value(onboardingCompletado),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      authUserId: serializer.fromJson<String>(json['authUserId']),
      nombre: serializer.fromJson<String?>(json['nombre']),
      email: serializer.fromJson<String>(json['email']),
      fotoPathSupabase: serializer.fromJson<String?>(json['fotoPathSupabase']),
      fotoPathLocal: serializer.fromJson<String?>(json['fotoPathLocal']),
      role: serializer.fromJson<String>(json['role']),
      activo: serializer.fromJson<bool>(json['activo']),
      onboardingCompletado: serializer.fromJson<bool>(
        json['onboardingCompletado'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'authUserId': serializer.toJson<String>(authUserId),
      'nombre': serializer.toJson<String?>(nombre),
      'email': serializer.toJson<String>(email),
      'fotoPathSupabase': serializer.toJson<String?>(fotoPathSupabase),
      'fotoPathLocal': serializer.toJson<String?>(fotoPathLocal),
      'role': serializer.toJson<String>(role),
      'activo': serializer.toJson<bool>(activo),
      'onboardingCompletado': serializer.toJson<bool>(onboardingCompletado),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalProfile copyWith({
    String? uuidProfile,
    String? authUserId,
    Value<String?> nombre = const Value.absent(),
    String? email,
    Value<String?> fotoPathSupabase = const Value.absent(),
    Value<String?> fotoPathLocal = const Value.absent(),
    String? role,
    bool? activo,
    bool? onboardingCompletado,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalProfile(
    uuidProfile: uuidProfile ?? this.uuidProfile,
    authUserId: authUserId ?? this.authUserId,
    nombre: nombre.present ? nombre.value : this.nombre,
    email: email ?? this.email,
    fotoPathSupabase: fotoPathSupabase.present
        ? fotoPathSupabase.value
        : this.fotoPathSupabase,
    fotoPathLocal: fotoPathLocal.present
        ? fotoPathLocal.value
        : this.fotoPathLocal,
    role: role ?? this.role,
    activo: activo ?? this.activo,
    onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalProfile copyWithCompanion(ProfilesTableCompanion data) {
    return LocalProfile(
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      authUserId: data.authUserId.present
          ? data.authUserId.value
          : this.authUserId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      email: data.email.present ? data.email.value : this.email,
      fotoPathSupabase: data.fotoPathSupabase.present
          ? data.fotoPathSupabase.value
          : this.fotoPathSupabase,
      fotoPathLocal: data.fotoPathLocal.present
          ? data.fotoPathLocal.value
          : this.fotoPathLocal,
      role: data.role.present ? data.role.value : this.role,
      activo: data.activo.present ? data.activo.value : this.activo,
      onboardingCompletado: data.onboardingCompletado.present
          ? data.onboardingCompletado.value
          : this.onboardingCompletado,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('authUserId: $authUserId, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('fotoPathSupabase: $fotoPathSupabase, ')
          ..write('fotoPathLocal: $fotoPathLocal, ')
          ..write('role: $role, ')
          ..write('activo: $activo, ')
          ..write('onboardingCompletado: $onboardingCompletado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidProfile,
    authUserId,
    nombre,
    email,
    fotoPathSupabase,
    fotoPathLocal,
    role,
    activo,
    onboardingCompletado,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.uuidProfile == this.uuidProfile &&
          other.authUserId == this.authUserId &&
          other.nombre == this.nombre &&
          other.email == this.email &&
          other.fotoPathSupabase == this.fotoPathSupabase &&
          other.fotoPathLocal == this.fotoPathLocal &&
          other.role == this.role &&
          other.activo == this.activo &&
          other.onboardingCompletado == this.onboardingCompletado &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class ProfilesTableCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> uuidProfile;
  final Value<String> authUserId;
  final Value<String?> nombre;
  final Value<String> email;
  final Value<String?> fotoPathSupabase;
  final Value<String?> fotoPathLocal;
  final Value<String> role;
  final Value<bool> activo;
  final Value<bool> onboardingCompletado;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ProfilesTableCompanion({
    this.uuidProfile = const Value.absent(),
    this.authUserId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.email = const Value.absent(),
    this.fotoPathSupabase = const Value.absent(),
    this.fotoPathLocal = const Value.absent(),
    this.role = const Value.absent(),
    this.activo = const Value.absent(),
    this.onboardingCompletado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesTableCompanion.insert({
    required String uuidProfile,
    required String authUserId,
    this.nombre = const Value.absent(),
    required String email,
    this.fotoPathSupabase = const Value.absent(),
    this.fotoPathLocal = const Value.absent(),
    this.role = const Value.absent(),
    this.activo = const Value.absent(),
    this.onboardingCompletado = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidProfile = Value(uuidProfile),
       authUserId = Value(authUserId),
       email = Value(email);
  static Insertable<LocalProfile> custom({
    Expression<String>? uuidProfile,
    Expression<String>? authUserId,
    Expression<String>? nombre,
    Expression<String>? email,
    Expression<String>? fotoPathSupabase,
    Expression<String>? fotoPathLocal,
    Expression<String>? role,
    Expression<bool>? activo,
    Expression<bool>? onboardingCompletado,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (authUserId != null) 'auth_user_id': authUserId,
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (fotoPathSupabase != null) 'foto_path_supabase': fotoPathSupabase,
      if (fotoPathLocal != null) 'foto_path_local': fotoPathLocal,
      if (role != null) 'role': role,
      if (activo != null) 'activo': activo,
      if (onboardingCompletado != null)
        'onboarding_completado': onboardingCompletado,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesTableCompanion copyWith({
    Value<String>? uuidProfile,
    Value<String>? authUserId,
    Value<String?>? nombre,
    Value<String>? email,
    Value<String?>? fotoPathSupabase,
    Value<String?>? fotoPathLocal,
    Value<String>? role,
    Value<bool>? activo,
    Value<bool>? onboardingCompletado,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ProfilesTableCompanion(
      uuidProfile: uuidProfile ?? this.uuidProfile,
      authUserId: authUserId ?? this.authUserId,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoPathSupabase: fotoPathSupabase ?? this.fotoPathSupabase,
      fotoPathLocal: fotoPathLocal ?? this.fotoPathLocal,
      role: role ?? this.role,
      activo: activo ?? this.activo,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (authUserId.present) {
      map['auth_user_id'] = Variable<String>(authUserId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fotoPathSupabase.present) {
      map['foto_path_supabase'] = Variable<String>(fotoPathSupabase.value);
    }
    if (fotoPathLocal.present) {
      map['foto_path_local'] = Variable<String>(fotoPathLocal.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (onboardingCompletado.present) {
      map['onboarding_completado'] = Variable<bool>(onboardingCompletado.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableCompanion(')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('authUserId: $authUserId, ')
          ..write('nombre: $nombre, ')
          ..write('email: $email, ')
          ..write('fotoPathSupabase: $fotoPathSupabase, ')
          ..write('fotoPathLocal: $fotoPathLocal, ')
          ..write('role: $role, ')
          ..write('activo: $activo, ')
          ..write('onboardingCompletado: $onboardingCompletado, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompanyInfoTableTable extends CompanyInfoTable
    with TableInfo<$CompanyInfoTableTable, LocalCompanyInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompanyInfoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidCompanyInfoMeta = const VerificationMeta(
    'uuidCompanyInfo',
  );
  @override
  late final GeneratedColumn<String> uuidCompanyInfo = GeneratedColumn<String>(
    'uuid_company_info',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    defaultValue: const Constant('main'),
  );
  static const VerificationMeta _heroTituloMeta = const VerificationMeta(
    'heroTitulo',
  );
  @override
  late final GeneratedColumn<String> heroTitulo = GeneratedColumn<String>(
    'hero_titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _heroSubtituloMeta = const VerificationMeta(
    'heroSubtitulo',
  );
  @override
  late final GeneratedColumn<String> heroSubtitulo = GeneratedColumn<String>(
    'hero_subtitulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _heroImagePathMeta = const VerificationMeta(
    'heroImagePath',
  );
  @override
  late final GeneratedColumn<String> heroImagePath = GeneratedColumn<String>(
    'hero_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textoEntradaMeta = const VerificationMeta(
    'textoEntrada',
  );
  @override
  late final GeneratedColumn<String> textoEntrada = GeneratedColumn<String>(
    'texto_entrada',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _quienesSomosMeta = const VerificationMeta(
    'quienesSomos',
  );
  @override
  late final GeneratedColumn<String> quienesSomos = GeneratedColumn<String>(
    'quienes_somos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _significadoAikiMeta = const VerificationMeta(
    'significadoAiki',
  );
  @override
  late final GeneratedColumn<String> significadoAiki = GeneratedColumn<String>(
    'significado_aiki',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _misionMeta = const VerificationMeta('mision');
  @override
  late final GeneratedColumn<String> mision = GeneratedColumn<String>(
    'mision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visionMeta = const VerificationMeta('vision');
  @override
  late final GeneratedColumn<String> vision = GeneratedColumn<String>(
    'vision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filosofiaMeta = const VerificationMeta(
    'filosofia',
  );
  @override
  late final GeneratedColumn<String> filosofia = GeneratedColumn<String>(
    'filosofia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mensajeFundadoresTituloMeta =
      const VerificationMeta('mensajeFundadoresTitulo');
  @override
  late final GeneratedColumn<String> mensajeFundadoresTitulo =
      GeneratedColumn<String>(
        'mensaje_fundadores_titulo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _mensajeFundadoresTextoMeta =
      const VerificationMeta('mensajeFundadoresTexto');
  @override
  late final GeneratedColumn<String> mensajeFundadoresTexto =
      GeneratedColumn<String>(
        'mensaje_fundadores_texto',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _mensajeFundadoresImagePath1Meta =
      const VerificationMeta('mensajeFundadoresImagePath1');
  @override
  late final GeneratedColumn<String> mensajeFundadoresImagePath1 =
      GeneratedColumn<String>(
        'mensaje_fundadores_image_path1',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mensajeFundadoresImagePath2Meta =
      const VerificationMeta('mensajeFundadoresImagePath2');
  @override
  late final GeneratedColumn<String> mensajeFundadoresImagePath2 =
      GeneratedColumn<String>(
        'mensaje_fundadores_image_path2',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mensajeFundadoresImagePath3Meta =
      const VerificationMeta('mensajeFundadoresImagePath3');
  @override
  late final GeneratedColumn<String> mensajeFundadoresImagePath3 =
      GeneratedColumn<String>(
        'mensaje_fundadores_image_path3',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mensajeFundadoresImagePath4Meta =
      const VerificationMeta('mensajeFundadoresImagePath4');
  @override
  late final GeneratedColumn<String> mensajeFundadoresImagePath4 =
      GeneratedColumn<String>(
        'mensaje_fundadores_image_path4',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mensajeFundadoresImagePath5Meta =
      const VerificationMeta('mensajeFundadoresImagePath5');
  @override
  late final GeneratedColumn<String> mensajeFundadoresImagePath5 =
      GeneratedColumn<String>(
        'mensaje_fundadores_image_path5',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidCompanyInfo,
    slug,
    heroTitulo,
    heroSubtitulo,
    heroImagePath,
    textoEntrada,
    quienesSomos,
    significadoAiki,
    mision,
    vision,
    filosofia,
    mensajeFundadoresTitulo,
    mensajeFundadoresTexto,
    mensajeFundadoresImagePath1,
    mensajeFundadoresImagePath2,
    mensajeFundadoresImagePath3,
    mensajeFundadoresImagePath4,
    mensajeFundadoresImagePath5,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_company_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCompanyInfo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_company_info')) {
      context.handle(
        _uuidCompanyInfoMeta,
        uuidCompanyInfo.isAcceptableOrUnknown(
          data['uuid_company_info']!,
          _uuidCompanyInfoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidCompanyInfoMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    }
    if (data.containsKey('hero_titulo')) {
      context.handle(
        _heroTituloMeta,
        heroTitulo.isAcceptableOrUnknown(data['hero_titulo']!, _heroTituloMeta),
      );
    }
    if (data.containsKey('hero_subtitulo')) {
      context.handle(
        _heroSubtituloMeta,
        heroSubtitulo.isAcceptableOrUnknown(
          data['hero_subtitulo']!,
          _heroSubtituloMeta,
        ),
      );
    }
    if (data.containsKey('hero_image_path')) {
      context.handle(
        _heroImagePathMeta,
        heroImagePath.isAcceptableOrUnknown(
          data['hero_image_path']!,
          _heroImagePathMeta,
        ),
      );
    }
    if (data.containsKey('texto_entrada')) {
      context.handle(
        _textoEntradaMeta,
        textoEntrada.isAcceptableOrUnknown(
          data['texto_entrada']!,
          _textoEntradaMeta,
        ),
      );
    }
    if (data.containsKey('quienes_somos')) {
      context.handle(
        _quienesSomosMeta,
        quienesSomos.isAcceptableOrUnknown(
          data['quienes_somos']!,
          _quienesSomosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quienesSomosMeta);
    }
    if (data.containsKey('significado_aiki')) {
      context.handle(
        _significadoAikiMeta,
        significadoAiki.isAcceptableOrUnknown(
          data['significado_aiki']!,
          _significadoAikiMeta,
        ),
      );
    }
    if (data.containsKey('mision')) {
      context.handle(
        _misionMeta,
        mision.isAcceptableOrUnknown(data['mision']!, _misionMeta),
      );
    } else if (isInserting) {
      context.missing(_misionMeta);
    }
    if (data.containsKey('vision')) {
      context.handle(
        _visionMeta,
        vision.isAcceptableOrUnknown(data['vision']!, _visionMeta),
      );
    } else if (isInserting) {
      context.missing(_visionMeta);
    }
    if (data.containsKey('filosofia')) {
      context.handle(
        _filosofiaMeta,
        filosofia.isAcceptableOrUnknown(data['filosofia']!, _filosofiaMeta),
      );
    } else if (isInserting) {
      context.missing(_filosofiaMeta);
    }
    if (data.containsKey('mensaje_fundadores_titulo')) {
      context.handle(
        _mensajeFundadoresTituloMeta,
        mensajeFundadoresTitulo.isAcceptableOrUnknown(
          data['mensaje_fundadores_titulo']!,
          _mensajeFundadoresTituloMeta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_texto')) {
      context.handle(
        _mensajeFundadoresTextoMeta,
        mensajeFundadoresTexto.isAcceptableOrUnknown(
          data['mensaje_fundadores_texto']!,
          _mensajeFundadoresTextoMeta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_image_path1')) {
      context.handle(
        _mensajeFundadoresImagePath1Meta,
        mensajeFundadoresImagePath1.isAcceptableOrUnknown(
          data['mensaje_fundadores_image_path1']!,
          _mensajeFundadoresImagePath1Meta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_image_path2')) {
      context.handle(
        _mensajeFundadoresImagePath2Meta,
        mensajeFundadoresImagePath2.isAcceptableOrUnknown(
          data['mensaje_fundadores_image_path2']!,
          _mensajeFundadoresImagePath2Meta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_image_path3')) {
      context.handle(
        _mensajeFundadoresImagePath3Meta,
        mensajeFundadoresImagePath3.isAcceptableOrUnknown(
          data['mensaje_fundadores_image_path3']!,
          _mensajeFundadoresImagePath3Meta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_image_path4')) {
      context.handle(
        _mensajeFundadoresImagePath4Meta,
        mensajeFundadoresImagePath4.isAcceptableOrUnknown(
          data['mensaje_fundadores_image_path4']!,
          _mensajeFundadoresImagePath4Meta,
        ),
      );
    }
    if (data.containsKey('mensaje_fundadores_image_path5')) {
      context.handle(
        _mensajeFundadoresImagePath5Meta,
        mensajeFundadoresImagePath5.isAcceptableOrUnknown(
          data['mensaje_fundadores_image_path5']!,
          _mensajeFundadoresImagePath5Meta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidCompanyInfo};
  @override
  LocalCompanyInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCompanyInfo(
      uuidCompanyInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_company_info'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      heroTitulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_titulo'],
      )!,
      heroSubtitulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_subtitulo'],
      )!,
      heroImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_image_path'],
      ),
      textoEntrada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto_entrada'],
      )!,
      quienesSomos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quienes_somos'],
      )!,
      significadoAiki: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}significado_aiki'],
      )!,
      mision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mision'],
      )!,
      vision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vision'],
      )!,
      filosofia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filosofia'],
      )!,
      mensajeFundadoresTitulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_titulo'],
      )!,
      mensajeFundadoresTexto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_texto'],
      )!,
      mensajeFundadoresImagePath1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_image_path1'],
      ),
      mensajeFundadoresImagePath2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_image_path2'],
      ),
      mensajeFundadoresImagePath3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_image_path3'],
      ),
      mensajeFundadoresImagePath4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_image_path4'],
      ),
      mensajeFundadoresImagePath5: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mensaje_fundadores_image_path5'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $CompanyInfoTableTable createAlias(String alias) {
    return $CompanyInfoTableTable(attachedDatabase, alias);
  }
}

class LocalCompanyInfo extends DataClass
    implements Insertable<LocalCompanyInfo> {
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
  const LocalCompanyInfo({
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_company_info'] = Variable<String>(uuidCompanyInfo);
    map['slug'] = Variable<String>(slug);
    map['hero_titulo'] = Variable<String>(heroTitulo);
    map['hero_subtitulo'] = Variable<String>(heroSubtitulo);
    if (!nullToAbsent || heroImagePath != null) {
      map['hero_image_path'] = Variable<String>(heroImagePath);
    }
    map['texto_entrada'] = Variable<String>(textoEntrada);
    map['quienes_somos'] = Variable<String>(quienesSomos);
    map['significado_aiki'] = Variable<String>(significadoAiki);
    map['mision'] = Variable<String>(mision);
    map['vision'] = Variable<String>(vision);
    map['filosofia'] = Variable<String>(filosofia);
    map['mensaje_fundadores_titulo'] = Variable<String>(
      mensajeFundadoresTitulo,
    );
    map['mensaje_fundadores_texto'] = Variable<String>(mensajeFundadoresTexto);
    if (!nullToAbsent || mensajeFundadoresImagePath1 != null) {
      map['mensaje_fundadores_image_path1'] = Variable<String>(
        mensajeFundadoresImagePath1,
      );
    }
    if (!nullToAbsent || mensajeFundadoresImagePath2 != null) {
      map['mensaje_fundadores_image_path2'] = Variable<String>(
        mensajeFundadoresImagePath2,
      );
    }
    if (!nullToAbsent || mensajeFundadoresImagePath3 != null) {
      map['mensaje_fundadores_image_path3'] = Variable<String>(
        mensajeFundadoresImagePath3,
      );
    }
    if (!nullToAbsent || mensajeFundadoresImagePath4 != null) {
      map['mensaje_fundadores_image_path4'] = Variable<String>(
        mensajeFundadoresImagePath4,
      );
    }
    if (!nullToAbsent || mensajeFundadoresImagePath5 != null) {
      map['mensaje_fundadores_image_path5'] = Variable<String>(
        mensajeFundadoresImagePath5,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  CompanyInfoTableCompanion toCompanion(bool nullToAbsent) {
    return CompanyInfoTableCompanion(
      uuidCompanyInfo: Value(uuidCompanyInfo),
      slug: Value(slug),
      heroTitulo: Value(heroTitulo),
      heroSubtitulo: Value(heroSubtitulo),
      heroImagePath: heroImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(heroImagePath),
      textoEntrada: Value(textoEntrada),
      quienesSomos: Value(quienesSomos),
      significadoAiki: Value(significadoAiki),
      mision: Value(mision),
      vision: Value(vision),
      filosofia: Value(filosofia),
      mensajeFundadoresTitulo: Value(mensajeFundadoresTitulo),
      mensajeFundadoresTexto: Value(mensajeFundadoresTexto),
      mensajeFundadoresImagePath1:
          mensajeFundadoresImagePath1 == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeFundadoresImagePath1),
      mensajeFundadoresImagePath2:
          mensajeFundadoresImagePath2 == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeFundadoresImagePath2),
      mensajeFundadoresImagePath3:
          mensajeFundadoresImagePath3 == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeFundadoresImagePath3),
      mensajeFundadoresImagePath4:
          mensajeFundadoresImagePath4 == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeFundadoresImagePath4),
      mensajeFundadoresImagePath5:
          mensajeFundadoresImagePath5 == null && nullToAbsent
          ? const Value.absent()
          : Value(mensajeFundadoresImagePath5),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalCompanyInfo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCompanyInfo(
      uuidCompanyInfo: serializer.fromJson<String>(json['uuidCompanyInfo']),
      slug: serializer.fromJson<String>(json['slug']),
      heroTitulo: serializer.fromJson<String>(json['heroTitulo']),
      heroSubtitulo: serializer.fromJson<String>(json['heroSubtitulo']),
      heroImagePath: serializer.fromJson<String?>(json['heroImagePath']),
      textoEntrada: serializer.fromJson<String>(json['textoEntrada']),
      quienesSomos: serializer.fromJson<String>(json['quienesSomos']),
      significadoAiki: serializer.fromJson<String>(json['significadoAiki']),
      mision: serializer.fromJson<String>(json['mision']),
      vision: serializer.fromJson<String>(json['vision']),
      filosofia: serializer.fromJson<String>(json['filosofia']),
      mensajeFundadoresTitulo: serializer.fromJson<String>(
        json['mensajeFundadoresTitulo'],
      ),
      mensajeFundadoresTexto: serializer.fromJson<String>(
        json['mensajeFundadoresTexto'],
      ),
      mensajeFundadoresImagePath1: serializer.fromJson<String?>(
        json['mensajeFundadoresImagePath1'],
      ),
      mensajeFundadoresImagePath2: serializer.fromJson<String?>(
        json['mensajeFundadoresImagePath2'],
      ),
      mensajeFundadoresImagePath3: serializer.fromJson<String?>(
        json['mensajeFundadoresImagePath3'],
      ),
      mensajeFundadoresImagePath4: serializer.fromJson<String?>(
        json['mensajeFundadoresImagePath4'],
      ),
      mensajeFundadoresImagePath5: serializer.fromJson<String?>(
        json['mensajeFundadoresImagePath5'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidCompanyInfo': serializer.toJson<String>(uuidCompanyInfo),
      'slug': serializer.toJson<String>(slug),
      'heroTitulo': serializer.toJson<String>(heroTitulo),
      'heroSubtitulo': serializer.toJson<String>(heroSubtitulo),
      'heroImagePath': serializer.toJson<String?>(heroImagePath),
      'textoEntrada': serializer.toJson<String>(textoEntrada),
      'quienesSomos': serializer.toJson<String>(quienesSomos),
      'significadoAiki': serializer.toJson<String>(significadoAiki),
      'mision': serializer.toJson<String>(mision),
      'vision': serializer.toJson<String>(vision),
      'filosofia': serializer.toJson<String>(filosofia),
      'mensajeFundadoresTitulo': serializer.toJson<String>(
        mensajeFundadoresTitulo,
      ),
      'mensajeFundadoresTexto': serializer.toJson<String>(
        mensajeFundadoresTexto,
      ),
      'mensajeFundadoresImagePath1': serializer.toJson<String?>(
        mensajeFundadoresImagePath1,
      ),
      'mensajeFundadoresImagePath2': serializer.toJson<String?>(
        mensajeFundadoresImagePath2,
      ),
      'mensajeFundadoresImagePath3': serializer.toJson<String?>(
        mensajeFundadoresImagePath3,
      ),
      'mensajeFundadoresImagePath4': serializer.toJson<String?>(
        mensajeFundadoresImagePath4,
      ),
      'mensajeFundadoresImagePath5': serializer.toJson<String?>(
        mensajeFundadoresImagePath5,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalCompanyInfo copyWith({
    String? uuidCompanyInfo,
    String? slug,
    String? heroTitulo,
    String? heroSubtitulo,
    Value<String?> heroImagePath = const Value.absent(),
    String? textoEntrada,
    String? quienesSomos,
    String? significadoAiki,
    String? mision,
    String? vision,
    String? filosofia,
    String? mensajeFundadoresTitulo,
    String? mensajeFundadoresTexto,
    Value<String?> mensajeFundadoresImagePath1 = const Value.absent(),
    Value<String?> mensajeFundadoresImagePath2 = const Value.absent(),
    Value<String?> mensajeFundadoresImagePath3 = const Value.absent(),
    Value<String?> mensajeFundadoresImagePath4 = const Value.absent(),
    Value<String?> mensajeFundadoresImagePath5 = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalCompanyInfo(
    uuidCompanyInfo: uuidCompanyInfo ?? this.uuidCompanyInfo,
    slug: slug ?? this.slug,
    heroTitulo: heroTitulo ?? this.heroTitulo,
    heroSubtitulo: heroSubtitulo ?? this.heroSubtitulo,
    heroImagePath: heroImagePath.present
        ? heroImagePath.value
        : this.heroImagePath,
    textoEntrada: textoEntrada ?? this.textoEntrada,
    quienesSomos: quienesSomos ?? this.quienesSomos,
    significadoAiki: significadoAiki ?? this.significadoAiki,
    mision: mision ?? this.mision,
    vision: vision ?? this.vision,
    filosofia: filosofia ?? this.filosofia,
    mensajeFundadoresTitulo:
        mensajeFundadoresTitulo ?? this.mensajeFundadoresTitulo,
    mensajeFundadoresTexto:
        mensajeFundadoresTexto ?? this.mensajeFundadoresTexto,
    mensajeFundadoresImagePath1: mensajeFundadoresImagePath1.present
        ? mensajeFundadoresImagePath1.value
        : this.mensajeFundadoresImagePath1,
    mensajeFundadoresImagePath2: mensajeFundadoresImagePath2.present
        ? mensajeFundadoresImagePath2.value
        : this.mensajeFundadoresImagePath2,
    mensajeFundadoresImagePath3: mensajeFundadoresImagePath3.present
        ? mensajeFundadoresImagePath3.value
        : this.mensajeFundadoresImagePath3,
    mensajeFundadoresImagePath4: mensajeFundadoresImagePath4.present
        ? mensajeFundadoresImagePath4.value
        : this.mensajeFundadoresImagePath4,
    mensajeFundadoresImagePath5: mensajeFundadoresImagePath5.present
        ? mensajeFundadoresImagePath5.value
        : this.mensajeFundadoresImagePath5,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalCompanyInfo copyWithCompanion(CompanyInfoTableCompanion data) {
    return LocalCompanyInfo(
      uuidCompanyInfo: data.uuidCompanyInfo.present
          ? data.uuidCompanyInfo.value
          : this.uuidCompanyInfo,
      slug: data.slug.present ? data.slug.value : this.slug,
      heroTitulo: data.heroTitulo.present
          ? data.heroTitulo.value
          : this.heroTitulo,
      heroSubtitulo: data.heroSubtitulo.present
          ? data.heroSubtitulo.value
          : this.heroSubtitulo,
      heroImagePath: data.heroImagePath.present
          ? data.heroImagePath.value
          : this.heroImagePath,
      textoEntrada: data.textoEntrada.present
          ? data.textoEntrada.value
          : this.textoEntrada,
      quienesSomos: data.quienesSomos.present
          ? data.quienesSomos.value
          : this.quienesSomos,
      significadoAiki: data.significadoAiki.present
          ? data.significadoAiki.value
          : this.significadoAiki,
      mision: data.mision.present ? data.mision.value : this.mision,
      vision: data.vision.present ? data.vision.value : this.vision,
      filosofia: data.filosofia.present ? data.filosofia.value : this.filosofia,
      mensajeFundadoresTitulo: data.mensajeFundadoresTitulo.present
          ? data.mensajeFundadoresTitulo.value
          : this.mensajeFundadoresTitulo,
      mensajeFundadoresTexto: data.mensajeFundadoresTexto.present
          ? data.mensajeFundadoresTexto.value
          : this.mensajeFundadoresTexto,
      mensajeFundadoresImagePath1: data.mensajeFundadoresImagePath1.present
          ? data.mensajeFundadoresImagePath1.value
          : this.mensajeFundadoresImagePath1,
      mensajeFundadoresImagePath2: data.mensajeFundadoresImagePath2.present
          ? data.mensajeFundadoresImagePath2.value
          : this.mensajeFundadoresImagePath2,
      mensajeFundadoresImagePath3: data.mensajeFundadoresImagePath3.present
          ? data.mensajeFundadoresImagePath3.value
          : this.mensajeFundadoresImagePath3,
      mensajeFundadoresImagePath4: data.mensajeFundadoresImagePath4.present
          ? data.mensajeFundadoresImagePath4.value
          : this.mensajeFundadoresImagePath4,
      mensajeFundadoresImagePath5: data.mensajeFundadoresImagePath5.present
          ? data.mensajeFundadoresImagePath5.value
          : this.mensajeFundadoresImagePath5,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCompanyInfo(')
          ..write('uuidCompanyInfo: $uuidCompanyInfo, ')
          ..write('slug: $slug, ')
          ..write('heroTitulo: $heroTitulo, ')
          ..write('heroSubtitulo: $heroSubtitulo, ')
          ..write('heroImagePath: $heroImagePath, ')
          ..write('textoEntrada: $textoEntrada, ')
          ..write('quienesSomos: $quienesSomos, ')
          ..write('significadoAiki: $significadoAiki, ')
          ..write('mision: $mision, ')
          ..write('vision: $vision, ')
          ..write('filosofia: $filosofia, ')
          ..write('mensajeFundadoresTitulo: $mensajeFundadoresTitulo, ')
          ..write('mensajeFundadoresTexto: $mensajeFundadoresTexto, ')
          ..write('mensajeFundadoresImagePath1: $mensajeFundadoresImagePath1, ')
          ..write('mensajeFundadoresImagePath2: $mensajeFundadoresImagePath2, ')
          ..write('mensajeFundadoresImagePath3: $mensajeFundadoresImagePath3, ')
          ..write('mensajeFundadoresImagePath4: $mensajeFundadoresImagePath4, ')
          ..write('mensajeFundadoresImagePath5: $mensajeFundadoresImagePath5, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    uuidCompanyInfo,
    slug,
    heroTitulo,
    heroSubtitulo,
    heroImagePath,
    textoEntrada,
    quienesSomos,
    significadoAiki,
    mision,
    vision,
    filosofia,
    mensajeFundadoresTitulo,
    mensajeFundadoresTexto,
    mensajeFundadoresImagePath1,
    mensajeFundadoresImagePath2,
    mensajeFundadoresImagePath3,
    mensajeFundadoresImagePath4,
    mensajeFundadoresImagePath5,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCompanyInfo &&
          other.uuidCompanyInfo == this.uuidCompanyInfo &&
          other.slug == this.slug &&
          other.heroTitulo == this.heroTitulo &&
          other.heroSubtitulo == this.heroSubtitulo &&
          other.heroImagePath == this.heroImagePath &&
          other.textoEntrada == this.textoEntrada &&
          other.quienesSomos == this.quienesSomos &&
          other.significadoAiki == this.significadoAiki &&
          other.mision == this.mision &&
          other.vision == this.vision &&
          other.filosofia == this.filosofia &&
          other.mensajeFundadoresTitulo == this.mensajeFundadoresTitulo &&
          other.mensajeFundadoresTexto == this.mensajeFundadoresTexto &&
          other.mensajeFundadoresImagePath1 ==
              this.mensajeFundadoresImagePath1 &&
          other.mensajeFundadoresImagePath2 ==
              this.mensajeFundadoresImagePath2 &&
          other.mensajeFundadoresImagePath3 ==
              this.mensajeFundadoresImagePath3 &&
          other.mensajeFundadoresImagePath4 ==
              this.mensajeFundadoresImagePath4 &&
          other.mensajeFundadoresImagePath5 ==
              this.mensajeFundadoresImagePath5 &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class CompanyInfoTableCompanion extends UpdateCompanion<LocalCompanyInfo> {
  final Value<String> uuidCompanyInfo;
  final Value<String> slug;
  final Value<String> heroTitulo;
  final Value<String> heroSubtitulo;
  final Value<String?> heroImagePath;
  final Value<String> textoEntrada;
  final Value<String> quienesSomos;
  final Value<String> significadoAiki;
  final Value<String> mision;
  final Value<String> vision;
  final Value<String> filosofia;
  final Value<String> mensajeFundadoresTitulo;
  final Value<String> mensajeFundadoresTexto;
  final Value<String?> mensajeFundadoresImagePath1;
  final Value<String?> mensajeFundadoresImagePath2;
  final Value<String?> mensajeFundadoresImagePath3;
  final Value<String?> mensajeFundadoresImagePath4;
  final Value<String?> mensajeFundadoresImagePath5;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const CompanyInfoTableCompanion({
    this.uuidCompanyInfo = const Value.absent(),
    this.slug = const Value.absent(),
    this.heroTitulo = const Value.absent(),
    this.heroSubtitulo = const Value.absent(),
    this.heroImagePath = const Value.absent(),
    this.textoEntrada = const Value.absent(),
    this.quienesSomos = const Value.absent(),
    this.significadoAiki = const Value.absent(),
    this.mision = const Value.absent(),
    this.vision = const Value.absent(),
    this.filosofia = const Value.absent(),
    this.mensajeFundadoresTitulo = const Value.absent(),
    this.mensajeFundadoresTexto = const Value.absent(),
    this.mensajeFundadoresImagePath1 = const Value.absent(),
    this.mensajeFundadoresImagePath2 = const Value.absent(),
    this.mensajeFundadoresImagePath3 = const Value.absent(),
    this.mensajeFundadoresImagePath4 = const Value.absent(),
    this.mensajeFundadoresImagePath5 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompanyInfoTableCompanion.insert({
    required String uuidCompanyInfo,
    this.slug = const Value.absent(),
    this.heroTitulo = const Value.absent(),
    this.heroSubtitulo = const Value.absent(),
    this.heroImagePath = const Value.absent(),
    this.textoEntrada = const Value.absent(),
    required String quienesSomos,
    this.significadoAiki = const Value.absent(),
    required String mision,
    required String vision,
    required String filosofia,
    this.mensajeFundadoresTitulo = const Value.absent(),
    this.mensajeFundadoresTexto = const Value.absent(),
    this.mensajeFundadoresImagePath1 = const Value.absent(),
    this.mensajeFundadoresImagePath2 = const Value.absent(),
    this.mensajeFundadoresImagePath3 = const Value.absent(),
    this.mensajeFundadoresImagePath4 = const Value.absent(),
    this.mensajeFundadoresImagePath5 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidCompanyInfo = Value(uuidCompanyInfo),
       quienesSomos = Value(quienesSomos),
       mision = Value(mision),
       vision = Value(vision),
       filosofia = Value(filosofia);
  static Insertable<LocalCompanyInfo> custom({
    Expression<String>? uuidCompanyInfo,
    Expression<String>? slug,
    Expression<String>? heroTitulo,
    Expression<String>? heroSubtitulo,
    Expression<String>? heroImagePath,
    Expression<String>? textoEntrada,
    Expression<String>? quienesSomos,
    Expression<String>? significadoAiki,
    Expression<String>? mision,
    Expression<String>? vision,
    Expression<String>? filosofia,
    Expression<String>? mensajeFundadoresTitulo,
    Expression<String>? mensajeFundadoresTexto,
    Expression<String>? mensajeFundadoresImagePath1,
    Expression<String>? mensajeFundadoresImagePath2,
    Expression<String>? mensajeFundadoresImagePath3,
    Expression<String>? mensajeFundadoresImagePath4,
    Expression<String>? mensajeFundadoresImagePath5,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidCompanyInfo != null) 'uuid_company_info': uuidCompanyInfo,
      if (slug != null) 'slug': slug,
      if (heroTitulo != null) 'hero_titulo': heroTitulo,
      if (heroSubtitulo != null) 'hero_subtitulo': heroSubtitulo,
      if (heroImagePath != null) 'hero_image_path': heroImagePath,
      if (textoEntrada != null) 'texto_entrada': textoEntrada,
      if (quienesSomos != null) 'quienes_somos': quienesSomos,
      if (significadoAiki != null) 'significado_aiki': significadoAiki,
      if (mision != null) 'mision': mision,
      if (vision != null) 'vision': vision,
      if (filosofia != null) 'filosofia': filosofia,
      if (mensajeFundadoresTitulo != null)
        'mensaje_fundadores_titulo': mensajeFundadoresTitulo,
      if (mensajeFundadoresTexto != null)
        'mensaje_fundadores_texto': mensajeFundadoresTexto,
      if (mensajeFundadoresImagePath1 != null)
        'mensaje_fundadores_image_path1': mensajeFundadoresImagePath1,
      if (mensajeFundadoresImagePath2 != null)
        'mensaje_fundadores_image_path2': mensajeFundadoresImagePath2,
      if (mensajeFundadoresImagePath3 != null)
        'mensaje_fundadores_image_path3': mensajeFundadoresImagePath3,
      if (mensajeFundadoresImagePath4 != null)
        'mensaje_fundadores_image_path4': mensajeFundadoresImagePath4,
      if (mensajeFundadoresImagePath5 != null)
        'mensaje_fundadores_image_path5': mensajeFundadoresImagePath5,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompanyInfoTableCompanion copyWith({
    Value<String>? uuidCompanyInfo,
    Value<String>? slug,
    Value<String>? heroTitulo,
    Value<String>? heroSubtitulo,
    Value<String?>? heroImagePath,
    Value<String>? textoEntrada,
    Value<String>? quienesSomos,
    Value<String>? significadoAiki,
    Value<String>? mision,
    Value<String>? vision,
    Value<String>? filosofia,
    Value<String>? mensajeFundadoresTitulo,
    Value<String>? mensajeFundadoresTexto,
    Value<String?>? mensajeFundadoresImagePath1,
    Value<String?>? mensajeFundadoresImagePath2,
    Value<String?>? mensajeFundadoresImagePath3,
    Value<String?>? mensajeFundadoresImagePath4,
    Value<String?>? mensajeFundadoresImagePath5,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return CompanyInfoTableCompanion(
      uuidCompanyInfo: uuidCompanyInfo ?? this.uuidCompanyInfo,
      slug: slug ?? this.slug,
      heroTitulo: heroTitulo ?? this.heroTitulo,
      heroSubtitulo: heroSubtitulo ?? this.heroSubtitulo,
      heroImagePath: heroImagePath ?? this.heroImagePath,
      textoEntrada: textoEntrada ?? this.textoEntrada,
      quienesSomos: quienesSomos ?? this.quienesSomos,
      significadoAiki: significadoAiki ?? this.significadoAiki,
      mision: mision ?? this.mision,
      vision: vision ?? this.vision,
      filosofia: filosofia ?? this.filosofia,
      mensajeFundadoresTitulo:
          mensajeFundadoresTitulo ?? this.mensajeFundadoresTitulo,
      mensajeFundadoresTexto:
          mensajeFundadoresTexto ?? this.mensajeFundadoresTexto,
      mensajeFundadoresImagePath1:
          mensajeFundadoresImagePath1 ?? this.mensajeFundadoresImagePath1,
      mensajeFundadoresImagePath2:
          mensajeFundadoresImagePath2 ?? this.mensajeFundadoresImagePath2,
      mensajeFundadoresImagePath3:
          mensajeFundadoresImagePath3 ?? this.mensajeFundadoresImagePath3,
      mensajeFundadoresImagePath4:
          mensajeFundadoresImagePath4 ?? this.mensajeFundadoresImagePath4,
      mensajeFundadoresImagePath5:
          mensajeFundadoresImagePath5 ?? this.mensajeFundadoresImagePath5,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidCompanyInfo.present) {
      map['uuid_company_info'] = Variable<String>(uuidCompanyInfo.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (heroTitulo.present) {
      map['hero_titulo'] = Variable<String>(heroTitulo.value);
    }
    if (heroSubtitulo.present) {
      map['hero_subtitulo'] = Variable<String>(heroSubtitulo.value);
    }
    if (heroImagePath.present) {
      map['hero_image_path'] = Variable<String>(heroImagePath.value);
    }
    if (textoEntrada.present) {
      map['texto_entrada'] = Variable<String>(textoEntrada.value);
    }
    if (quienesSomos.present) {
      map['quienes_somos'] = Variable<String>(quienesSomos.value);
    }
    if (significadoAiki.present) {
      map['significado_aiki'] = Variable<String>(significadoAiki.value);
    }
    if (mision.present) {
      map['mision'] = Variable<String>(mision.value);
    }
    if (vision.present) {
      map['vision'] = Variable<String>(vision.value);
    }
    if (filosofia.present) {
      map['filosofia'] = Variable<String>(filosofia.value);
    }
    if (mensajeFundadoresTitulo.present) {
      map['mensaje_fundadores_titulo'] = Variable<String>(
        mensajeFundadoresTitulo.value,
      );
    }
    if (mensajeFundadoresTexto.present) {
      map['mensaje_fundadores_texto'] = Variable<String>(
        mensajeFundadoresTexto.value,
      );
    }
    if (mensajeFundadoresImagePath1.present) {
      map['mensaje_fundadores_image_path1'] = Variable<String>(
        mensajeFundadoresImagePath1.value,
      );
    }
    if (mensajeFundadoresImagePath2.present) {
      map['mensaje_fundadores_image_path2'] = Variable<String>(
        mensajeFundadoresImagePath2.value,
      );
    }
    if (mensajeFundadoresImagePath3.present) {
      map['mensaje_fundadores_image_path3'] = Variable<String>(
        mensajeFundadoresImagePath3.value,
      );
    }
    if (mensajeFundadoresImagePath4.present) {
      map['mensaje_fundadores_image_path4'] = Variable<String>(
        mensajeFundadoresImagePath4.value,
      );
    }
    if (mensajeFundadoresImagePath5.present) {
      map['mensaje_fundadores_image_path5'] = Variable<String>(
        mensajeFundadoresImagePath5.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompanyInfoTableCompanion(')
          ..write('uuidCompanyInfo: $uuidCompanyInfo, ')
          ..write('slug: $slug, ')
          ..write('heroTitulo: $heroTitulo, ')
          ..write('heroSubtitulo: $heroSubtitulo, ')
          ..write('heroImagePath: $heroImagePath, ')
          ..write('textoEntrada: $textoEntrada, ')
          ..write('quienesSomos: $quienesSomos, ')
          ..write('significadoAiki: $significadoAiki, ')
          ..write('mision: $mision, ')
          ..write('vision: $vision, ')
          ..write('filosofia: $filosofia, ')
          ..write('mensajeFundadoresTitulo: $mensajeFundadoresTitulo, ')
          ..write('mensajeFundadoresTexto: $mensajeFundadoresTexto, ')
          ..write('mensajeFundadoresImagePath1: $mensajeFundadoresImagePath1, ')
          ..write('mensajeFundadoresImagePath2: $mensajeFundadoresImagePath2, ')
          ..write('mensajeFundadoresImagePath3: $mensajeFundadoresImagePath3, ')
          ..write('mensajeFundadoresImagePath4: $mensajeFundadoresImagePath4, ')
          ..write('mensajeFundadoresImagePath5: $mensajeFundadoresImagePath5, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentDownloadsTableTable extends ContentDownloadsTable
    with TableInfo<$ContentDownloadsTableTable, LocalContentDownload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentDownloadsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidContentDownloadMeta =
      const VerificationMeta('uuidContentDownload');
  @override
  late final GeneratedColumn<String> uuidContentDownload =
      GeneratedColumn<String>(
        'uuid_content_download',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidContentItemMeta = const VerificationMeta(
    'uuidContentItem',
  );
  @override
  late final GeneratedColumn<String> uuidContentItem = GeneratedColumn<String>(
    'uuid_content_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidContentMediaMeta = const VerificationMeta(
    'uuidContentMedia',
  );
  @override
  late final GeneratedColumn<String> uuidContentMedia = GeneratedColumn<String>(
    'uuid_content_media',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathSupabaseMeta =
      const VerificationMeta('storagePathSupabase');
  @override
  late final GeneratedColumn<String> storagePathSupabase =
      GeneratedColumn<String>(
        'storage_path_supabase',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _storagePathLocalMeta = const VerificationMeta(
    'storagePathLocal',
  );
  @override
  late final GeneratedColumn<String> storagePathLocal = GeneratedColumn<String>(
    'storage_path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _bytesDownloadedMeta = const VerificationMeta(
    'bytesDownloaded',
  );
  @override
  late final GeneratedColumn<int> bytesDownloaded = GeneratedColumn<int>(
    'bytes_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessExpiresAtMeta = const VerificationMeta(
    'accessExpiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> accessExpiresAt =
      GeneratedColumn<DateTime>(
        'access_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidContentDownload,
    uuidProfile,
    uuidContentItem,
    uuidContentMedia,
    storagePathSupabase,
    storagePathLocal,
    status,
    bytesDownloaded,
    totalBytes,
    downloadedAt,
    accessExpiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_content_downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalContentDownload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_content_download')) {
      context.handle(
        _uuidContentDownloadMeta,
        uuidContentDownload.isAcceptableOrUnknown(
          data['uuid_content_download']!,
          _uuidContentDownloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentDownloadMeta);
    }
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('uuid_content_item')) {
      context.handle(
        _uuidContentItemMeta,
        uuidContentItem.isAcceptableOrUnknown(
          data['uuid_content_item']!,
          _uuidContentItemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentItemMeta);
    }
    if (data.containsKey('uuid_content_media')) {
      context.handle(
        _uuidContentMediaMeta,
        uuidContentMedia.isAcceptableOrUnknown(
          data['uuid_content_media']!,
          _uuidContentMediaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentMediaMeta);
    }
    if (data.containsKey('storage_path_supabase')) {
      context.handle(
        _storagePathSupabaseMeta,
        storagePathSupabase.isAcceptableOrUnknown(
          data['storage_path_supabase']!,
          _storagePathSupabaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathSupabaseMeta);
    }
    if (data.containsKey('storage_path_local')) {
      context.handle(
        _storagePathLocalMeta,
        storagePathLocal.isAcceptableOrUnknown(
          data['storage_path_local']!,
          _storagePathLocalMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('bytes_downloaded')) {
      context.handle(
        _bytesDownloadedMeta,
        bytesDownloaded.isAcceptableOrUnknown(
          data['bytes_downloaded']!,
          _bytesDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('access_expires_at')) {
      context.handle(
        _accessExpiresAtMeta,
        accessExpiresAt.isAcceptableOrUnknown(
          data['access_expires_at']!,
          _accessExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidContentDownload};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uuidProfile, uuidContentMedia},
  ];
  @override
  LocalContentDownload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalContentDownload(
      uuidContentDownload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_download'],
      )!,
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      uuidContentItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_item'],
      )!,
      uuidContentMedia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_media'],
      )!,
      storagePathSupabase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path_supabase'],
      )!,
      storagePathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path_local'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bytesDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_downloaded'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      accessExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}access_expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ContentDownloadsTableTable createAlias(String alias) {
    return $ContentDownloadsTableTable(attachedDatabase, alias);
  }
}

class LocalContentDownload extends DataClass
    implements Insertable<LocalContentDownload> {
  final String uuidContentDownload;
  final String uuidProfile;
  final String uuidContentItem;
  final String uuidContentMedia;
  final String storagePathSupabase;
  final String? storagePathLocal;
  final String status;
  final int bytesDownloaded;
  final int totalBytes;
  final DateTime? downloadedAt;
  final DateTime? accessExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalContentDownload({
    required this.uuidContentDownload,
    required this.uuidProfile,
    required this.uuidContentItem,
    required this.uuidContentMedia,
    required this.storagePathSupabase,
    this.storagePathLocal,
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    this.downloadedAt,
    this.accessExpiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_content_download'] = Variable<String>(uuidContentDownload);
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['uuid_content_item'] = Variable<String>(uuidContentItem);
    map['uuid_content_media'] = Variable<String>(uuidContentMedia);
    map['storage_path_supabase'] = Variable<String>(storagePathSupabase);
    if (!nullToAbsent || storagePathLocal != null) {
      map['storage_path_local'] = Variable<String>(storagePathLocal);
    }
    map['status'] = Variable<String>(status);
    map['bytes_downloaded'] = Variable<int>(bytesDownloaded);
    map['total_bytes'] = Variable<int>(totalBytes);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    if (!nullToAbsent || accessExpiresAt != null) {
      map['access_expires_at'] = Variable<DateTime>(accessExpiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ContentDownloadsTableCompanion toCompanion(bool nullToAbsent) {
    return ContentDownloadsTableCompanion(
      uuidContentDownload: Value(uuidContentDownload),
      uuidProfile: Value(uuidProfile),
      uuidContentItem: Value(uuidContentItem),
      uuidContentMedia: Value(uuidContentMedia),
      storagePathSupabase: Value(storagePathSupabase),
      storagePathLocal: storagePathLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePathLocal),
      status: Value(status),
      bytesDownloaded: Value(bytesDownloaded),
      totalBytes: Value(totalBytes),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      accessExpiresAt: accessExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(accessExpiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalContentDownload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalContentDownload(
      uuidContentDownload: serializer.fromJson<String>(
        json['uuidContentDownload'],
      ),
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      uuidContentItem: serializer.fromJson<String>(json['uuidContentItem']),
      uuidContentMedia: serializer.fromJson<String>(json['uuidContentMedia']),
      storagePathSupabase: serializer.fromJson<String>(
        json['storagePathSupabase'],
      ),
      storagePathLocal: serializer.fromJson<String?>(json['storagePathLocal']),
      status: serializer.fromJson<String>(json['status']),
      bytesDownloaded: serializer.fromJson<int>(json['bytesDownloaded']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      accessExpiresAt: serializer.fromJson<DateTime?>(json['accessExpiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidContentDownload': serializer.toJson<String>(uuidContentDownload),
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'uuidContentItem': serializer.toJson<String>(uuidContentItem),
      'uuidContentMedia': serializer.toJson<String>(uuidContentMedia),
      'storagePathSupabase': serializer.toJson<String>(storagePathSupabase),
      'storagePathLocal': serializer.toJson<String?>(storagePathLocal),
      'status': serializer.toJson<String>(status),
      'bytesDownloaded': serializer.toJson<int>(bytesDownloaded),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'accessExpiresAt': serializer.toJson<DateTime?>(accessExpiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalContentDownload copyWith({
    String? uuidContentDownload,
    String? uuidProfile,
    String? uuidContentItem,
    String? uuidContentMedia,
    String? storagePathSupabase,
    Value<String?> storagePathLocal = const Value.absent(),
    String? status,
    int? bytesDownloaded,
    int? totalBytes,
    Value<DateTime?> downloadedAt = const Value.absent(),
    Value<DateTime?> accessExpiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocalContentDownload(
    uuidContentDownload: uuidContentDownload ?? this.uuidContentDownload,
    uuidProfile: uuidProfile ?? this.uuidProfile,
    uuidContentItem: uuidContentItem ?? this.uuidContentItem,
    uuidContentMedia: uuidContentMedia ?? this.uuidContentMedia,
    storagePathSupabase: storagePathSupabase ?? this.storagePathSupabase,
    storagePathLocal: storagePathLocal.present
        ? storagePathLocal.value
        : this.storagePathLocal,
    status: status ?? this.status,
    bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
    totalBytes: totalBytes ?? this.totalBytes,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    accessExpiresAt: accessExpiresAt.present
        ? accessExpiresAt.value
        : this.accessExpiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalContentDownload copyWithCompanion(ContentDownloadsTableCompanion data) {
    return LocalContentDownload(
      uuidContentDownload: data.uuidContentDownload.present
          ? data.uuidContentDownload.value
          : this.uuidContentDownload,
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      uuidContentItem: data.uuidContentItem.present
          ? data.uuidContentItem.value
          : this.uuidContentItem,
      uuidContentMedia: data.uuidContentMedia.present
          ? data.uuidContentMedia.value
          : this.uuidContentMedia,
      storagePathSupabase: data.storagePathSupabase.present
          ? data.storagePathSupabase.value
          : this.storagePathSupabase,
      storagePathLocal: data.storagePathLocal.present
          ? data.storagePathLocal.value
          : this.storagePathLocal,
      status: data.status.present ? data.status.value : this.status,
      bytesDownloaded: data.bytesDownloaded.present
          ? data.bytesDownloaded.value
          : this.bytesDownloaded,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      accessExpiresAt: data.accessExpiresAt.present
          ? data.accessExpiresAt.value
          : this.accessExpiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalContentDownload(')
          ..write('uuidContentDownload: $uuidContentDownload, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('uuidContentMedia: $uuidContentMedia, ')
          ..write('storagePathSupabase: $storagePathSupabase, ')
          ..write('storagePathLocal: $storagePathLocal, ')
          ..write('status: $status, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('accessExpiresAt: $accessExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidContentDownload,
    uuidProfile,
    uuidContentItem,
    uuidContentMedia,
    storagePathSupabase,
    storagePathLocal,
    status,
    bytesDownloaded,
    totalBytes,
    downloadedAt,
    accessExpiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalContentDownload &&
          other.uuidContentDownload == this.uuidContentDownload &&
          other.uuidProfile == this.uuidProfile &&
          other.uuidContentItem == this.uuidContentItem &&
          other.uuidContentMedia == this.uuidContentMedia &&
          other.storagePathSupabase == this.storagePathSupabase &&
          other.storagePathLocal == this.storagePathLocal &&
          other.status == this.status &&
          other.bytesDownloaded == this.bytesDownloaded &&
          other.totalBytes == this.totalBytes &&
          other.downloadedAt == this.downloadedAt &&
          other.accessExpiresAt == this.accessExpiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ContentDownloadsTableCompanion
    extends UpdateCompanion<LocalContentDownload> {
  final Value<String> uuidContentDownload;
  final Value<String> uuidProfile;
  final Value<String> uuidContentItem;
  final Value<String> uuidContentMedia;
  final Value<String> storagePathSupabase;
  final Value<String?> storagePathLocal;
  final Value<String> status;
  final Value<int> bytesDownloaded;
  final Value<int> totalBytes;
  final Value<DateTime?> downloadedAt;
  final Value<DateTime?> accessExpiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ContentDownloadsTableCompanion({
    this.uuidContentDownload = const Value.absent(),
    this.uuidProfile = const Value.absent(),
    this.uuidContentItem = const Value.absent(),
    this.uuidContentMedia = const Value.absent(),
    this.storagePathSupabase = const Value.absent(),
    this.storagePathLocal = const Value.absent(),
    this.status = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.accessExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentDownloadsTableCompanion.insert({
    required String uuidContentDownload,
    required String uuidProfile,
    required String uuidContentItem,
    required String uuidContentMedia,
    required String storagePathSupabase,
    this.storagePathLocal = const Value.absent(),
    this.status = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.accessExpiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidContentDownload = Value(uuidContentDownload),
       uuidProfile = Value(uuidProfile),
       uuidContentItem = Value(uuidContentItem),
       uuidContentMedia = Value(uuidContentMedia),
       storagePathSupabase = Value(storagePathSupabase);
  static Insertable<LocalContentDownload> custom({
    Expression<String>? uuidContentDownload,
    Expression<String>? uuidProfile,
    Expression<String>? uuidContentItem,
    Expression<String>? uuidContentMedia,
    Expression<String>? storagePathSupabase,
    Expression<String>? storagePathLocal,
    Expression<String>? status,
    Expression<int>? bytesDownloaded,
    Expression<int>? totalBytes,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? accessExpiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidContentDownload != null)
        'uuid_content_download': uuidContentDownload,
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (uuidContentItem != null) 'uuid_content_item': uuidContentItem,
      if (uuidContentMedia != null) 'uuid_content_media': uuidContentMedia,
      if (storagePathSupabase != null)
        'storage_path_supabase': storagePathSupabase,
      if (storagePathLocal != null) 'storage_path_local': storagePathLocal,
      if (status != null) 'status': status,
      if (bytesDownloaded != null) 'bytes_downloaded': bytesDownloaded,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (accessExpiresAt != null) 'access_expires_at': accessExpiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentDownloadsTableCompanion copyWith({
    Value<String>? uuidContentDownload,
    Value<String>? uuidProfile,
    Value<String>? uuidContentItem,
    Value<String>? uuidContentMedia,
    Value<String>? storagePathSupabase,
    Value<String?>? storagePathLocal,
    Value<String>? status,
    Value<int>? bytesDownloaded,
    Value<int>? totalBytes,
    Value<DateTime?>? downloadedAt,
    Value<DateTime?>? accessExpiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ContentDownloadsTableCompanion(
      uuidContentDownload: uuidContentDownload ?? this.uuidContentDownload,
      uuidProfile: uuidProfile ?? this.uuidProfile,
      uuidContentItem: uuidContentItem ?? this.uuidContentItem,
      uuidContentMedia: uuidContentMedia ?? this.uuidContentMedia,
      storagePathSupabase: storagePathSupabase ?? this.storagePathSupabase,
      storagePathLocal: storagePathLocal ?? this.storagePathLocal,
      status: status ?? this.status,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidContentDownload.present) {
      map['uuid_content_download'] = Variable<String>(
        uuidContentDownload.value,
      );
    }
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (uuidContentItem.present) {
      map['uuid_content_item'] = Variable<String>(uuidContentItem.value);
    }
    if (uuidContentMedia.present) {
      map['uuid_content_media'] = Variable<String>(uuidContentMedia.value);
    }
    if (storagePathSupabase.present) {
      map['storage_path_supabase'] = Variable<String>(
        storagePathSupabase.value,
      );
    }
    if (storagePathLocal.present) {
      map['storage_path_local'] = Variable<String>(storagePathLocal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bytesDownloaded.present) {
      map['bytes_downloaded'] = Variable<int>(bytesDownloaded.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (accessExpiresAt.present) {
      map['access_expires_at'] = Variable<DateTime>(accessExpiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentDownloadsTableCompanion(')
          ..write('uuidContentDownload: $uuidContentDownload, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('uuidContentMedia: $uuidContentMedia, ')
          ..write('storagePathSupabase: $storagePathSupabase, ')
          ..write('storagePathLocal: $storagePathLocal, ')
          ..write('status: $status, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('accessExpiresAt: $accessExpiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentItemsTableTable extends ContentItemsTable
    with TableInfo<$ContentItemsTableTable, LocalContentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidContentItemMeta = const VerificationMeta(
    'uuidContentItem',
  );
  @override
  late final GeneratedColumn<String> uuidContentItem = GeneratedColumn<String>(
    'uuid_content_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtituloMeta = const VerificationMeta(
    'subtitulo',
  );
  @override
  late final GeneratedColumn<String> subtitulo = GeneratedColumn<String>(
    'subtitulo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathSupabaseMeta = const VerificationMeta(
    'coverPathSupabase',
  );
  @override
  late final GeneratedColumn<String> coverPathSupabase =
      GeneratedColumn<String>(
        'cover_path_supabase',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _coverPathLocalMeta = const VerificationMeta(
    'coverPathLocal',
  );
  @override
  late final GeneratedColumn<String> coverPathLocal = GeneratedColumn<String>(
    'cover_path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _destacadoMeta = const VerificationMeta(
    'destacado',
  );
  @override
  late final GeneratedColumn<bool> destacado = GeneratedColumn<bool>(
    'destacado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("destacado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _descargableMeta = const VerificationMeta(
    'descargable',
  );
  @override
  late final GeneratedColumn<bool> descargable = GeneratedColumn<bool>(
    'descargable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("descargable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _duracionSegundosMeta = const VerificationMeta(
    'duracionSegundos',
  );
  @override
  late final GeneratedColumn<int> duracionSegundos = GeneratedColumn<int>(
    'duracion_segundos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidContentItem,
    tipo,
    titulo,
    subtitulo,
    descripcion,
    coverPathSupabase,
    coverPathLocal,
    status,
    destacado,
    descargable,
    duracionSegundos,
    orden,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_content_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalContentItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_content_item')) {
      context.handle(
        _uuidContentItemMeta,
        uuidContentItem.isAcceptableOrUnknown(
          data['uuid_content_item']!,
          _uuidContentItemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentItemMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('subtitulo')) {
      context.handle(
        _subtituloMeta,
        subtitulo.isAcceptableOrUnknown(data['subtitulo']!, _subtituloMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('cover_path_supabase')) {
      context.handle(
        _coverPathSupabaseMeta,
        coverPathSupabase.isAcceptableOrUnknown(
          data['cover_path_supabase']!,
          _coverPathSupabaseMeta,
        ),
      );
    }
    if (data.containsKey('cover_path_local')) {
      context.handle(
        _coverPathLocalMeta,
        coverPathLocal.isAcceptableOrUnknown(
          data['cover_path_local']!,
          _coverPathLocalMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('destacado')) {
      context.handle(
        _destacadoMeta,
        destacado.isAcceptableOrUnknown(data['destacado']!, _destacadoMeta),
      );
    }
    if (data.containsKey('descargable')) {
      context.handle(
        _descargableMeta,
        descargable.isAcceptableOrUnknown(
          data['descargable']!,
          _descargableMeta,
        ),
      );
    }
    if (data.containsKey('duracion_segundos')) {
      context.handle(
        _duracionSegundosMeta,
        duracionSegundos.isAcceptableOrUnknown(
          data['duracion_segundos']!,
          _duracionSegundosMeta,
        ),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidContentItem};
  @override
  LocalContentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalContentItem(
      uuidContentItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_item'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      subtitulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitulo'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      coverPathSupabase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path_supabase'],
      ),
      coverPathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path_local'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      destacado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}destacado'],
      )!,
      descargable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}descargable'],
      )!,
      duracionSegundos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duracion_segundos'],
      ),
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ContentItemsTableTable createAlias(String alias) {
    return $ContentItemsTableTable(attachedDatabase, alias);
  }
}

class LocalContentItem extends DataClass
    implements Insertable<LocalContentItem> {
  final String uuidContentItem;
  final String tipo;
  final String titulo;
  final String? subtitulo;
  final String? descripcion;
  final String? coverPathSupabase;
  final String? coverPathLocal;
  final String status;
  final bool destacado;
  final bool descargable;
  final int? duracionSegundos;
  final int orden;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalContentItem({
    required this.uuidContentItem,
    required this.tipo,
    required this.titulo,
    this.subtitulo,
    this.descripcion,
    this.coverPathSupabase,
    this.coverPathLocal,
    required this.status,
    required this.destacado,
    required this.descargable,
    this.duracionSegundos,
    required this.orden,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_content_item'] = Variable<String>(uuidContentItem);
    map['tipo'] = Variable<String>(tipo);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || subtitulo != null) {
      map['subtitulo'] = Variable<String>(subtitulo);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || coverPathSupabase != null) {
      map['cover_path_supabase'] = Variable<String>(coverPathSupabase);
    }
    if (!nullToAbsent || coverPathLocal != null) {
      map['cover_path_local'] = Variable<String>(coverPathLocal);
    }
    map['status'] = Variable<String>(status);
    map['destacado'] = Variable<bool>(destacado);
    map['descargable'] = Variable<bool>(descargable);
    if (!nullToAbsent || duracionSegundos != null) {
      map['duracion_segundos'] = Variable<int>(duracionSegundos);
    }
    map['orden'] = Variable<int>(orden);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ContentItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ContentItemsTableCompanion(
      uuidContentItem: Value(uuidContentItem),
      tipo: Value(tipo),
      titulo: Value(titulo),
      subtitulo: subtitulo == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitulo),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      coverPathSupabase: coverPathSupabase == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPathSupabase),
      coverPathLocal: coverPathLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPathLocal),
      status: Value(status),
      destacado: Value(destacado),
      descargable: Value(descargable),
      duracionSegundos: duracionSegundos == null && nullToAbsent
          ? const Value.absent()
          : Value(duracionSegundos),
      orden: Value(orden),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalContentItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalContentItem(
      uuidContentItem: serializer.fromJson<String>(json['uuidContentItem']),
      tipo: serializer.fromJson<String>(json['tipo']),
      titulo: serializer.fromJson<String>(json['titulo']),
      subtitulo: serializer.fromJson<String?>(json['subtitulo']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      coverPathSupabase: serializer.fromJson<String?>(
        json['coverPathSupabase'],
      ),
      coverPathLocal: serializer.fromJson<String?>(json['coverPathLocal']),
      status: serializer.fromJson<String>(json['status']),
      destacado: serializer.fromJson<bool>(json['destacado']),
      descargable: serializer.fromJson<bool>(json['descargable']),
      duracionSegundos: serializer.fromJson<int?>(json['duracionSegundos']),
      orden: serializer.fromJson<int>(json['orden']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidContentItem': serializer.toJson<String>(uuidContentItem),
      'tipo': serializer.toJson<String>(tipo),
      'titulo': serializer.toJson<String>(titulo),
      'subtitulo': serializer.toJson<String?>(subtitulo),
      'descripcion': serializer.toJson<String?>(descripcion),
      'coverPathSupabase': serializer.toJson<String?>(coverPathSupabase),
      'coverPathLocal': serializer.toJson<String?>(coverPathLocal),
      'status': serializer.toJson<String>(status),
      'destacado': serializer.toJson<bool>(destacado),
      'descargable': serializer.toJson<bool>(descargable),
      'duracionSegundos': serializer.toJson<int?>(duracionSegundos),
      'orden': serializer.toJson<int>(orden),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalContentItem copyWith({
    String? uuidContentItem,
    String? tipo,
    String? titulo,
    Value<String?> subtitulo = const Value.absent(),
    Value<String?> descripcion = const Value.absent(),
    Value<String?> coverPathSupabase = const Value.absent(),
    Value<String?> coverPathLocal = const Value.absent(),
    String? status,
    bool? destacado,
    bool? descargable,
    Value<int?> duracionSegundos = const Value.absent(),
    int? orden,
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalContentItem(
    uuidContentItem: uuidContentItem ?? this.uuidContentItem,
    tipo: tipo ?? this.tipo,
    titulo: titulo ?? this.titulo,
    subtitulo: subtitulo.present ? subtitulo.value : this.subtitulo,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    coverPathSupabase: coverPathSupabase.present
        ? coverPathSupabase.value
        : this.coverPathSupabase,
    coverPathLocal: coverPathLocal.present
        ? coverPathLocal.value
        : this.coverPathLocal,
    status: status ?? this.status,
    destacado: destacado ?? this.destacado,
    descargable: descargable ?? this.descargable,
    duracionSegundos: duracionSegundos.present
        ? duracionSegundos.value
        : this.duracionSegundos,
    orden: orden ?? this.orden,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalContentItem copyWithCompanion(ContentItemsTableCompanion data) {
    return LocalContentItem(
      uuidContentItem: data.uuidContentItem.present
          ? data.uuidContentItem.value
          : this.uuidContentItem,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      subtitulo: data.subtitulo.present ? data.subtitulo.value : this.subtitulo,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      coverPathSupabase: data.coverPathSupabase.present
          ? data.coverPathSupabase.value
          : this.coverPathSupabase,
      coverPathLocal: data.coverPathLocal.present
          ? data.coverPathLocal.value
          : this.coverPathLocal,
      status: data.status.present ? data.status.value : this.status,
      destacado: data.destacado.present ? data.destacado.value : this.destacado,
      descargable: data.descargable.present
          ? data.descargable.value
          : this.descargable,
      duracionSegundos: data.duracionSegundos.present
          ? data.duracionSegundos.value
          : this.duracionSegundos,
      orden: data.orden.present ? data.orden.value : this.orden,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalContentItem(')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('subtitulo: $subtitulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('coverPathSupabase: $coverPathSupabase, ')
          ..write('coverPathLocal: $coverPathLocal, ')
          ..write('status: $status, ')
          ..write('destacado: $destacado, ')
          ..write('descargable: $descargable, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('orden: $orden, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidContentItem,
    tipo,
    titulo,
    subtitulo,
    descripcion,
    coverPathSupabase,
    coverPathLocal,
    status,
    destacado,
    descargable,
    duracionSegundos,
    orden,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalContentItem &&
          other.uuidContentItem == this.uuidContentItem &&
          other.tipo == this.tipo &&
          other.titulo == this.titulo &&
          other.subtitulo == this.subtitulo &&
          other.descripcion == this.descripcion &&
          other.coverPathSupabase == this.coverPathSupabase &&
          other.coverPathLocal == this.coverPathLocal &&
          other.status == this.status &&
          other.destacado == this.destacado &&
          other.descargable == this.descargable &&
          other.duracionSegundos == this.duracionSegundos &&
          other.orden == this.orden &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class ContentItemsTableCompanion extends UpdateCompanion<LocalContentItem> {
  final Value<String> uuidContentItem;
  final Value<String> tipo;
  final Value<String> titulo;
  final Value<String?> subtitulo;
  final Value<String?> descripcion;
  final Value<String?> coverPathSupabase;
  final Value<String?> coverPathLocal;
  final Value<String> status;
  final Value<bool> destacado;
  final Value<bool> descargable;
  final Value<int?> duracionSegundos;
  final Value<int> orden;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ContentItemsTableCompanion({
    this.uuidContentItem = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.subtitulo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.coverPathSupabase = const Value.absent(),
    this.coverPathLocal = const Value.absent(),
    this.status = const Value.absent(),
    this.destacado = const Value.absent(),
    this.descargable = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.orden = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentItemsTableCompanion.insert({
    required String uuidContentItem,
    required String tipo,
    required String titulo,
    this.subtitulo = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.coverPathSupabase = const Value.absent(),
    this.coverPathLocal = const Value.absent(),
    this.status = const Value.absent(),
    this.destacado = const Value.absent(),
    this.descargable = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.orden = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidContentItem = Value(uuidContentItem),
       tipo = Value(tipo),
       titulo = Value(titulo);
  static Insertable<LocalContentItem> custom({
    Expression<String>? uuidContentItem,
    Expression<String>? tipo,
    Expression<String>? titulo,
    Expression<String>? subtitulo,
    Expression<String>? descripcion,
    Expression<String>? coverPathSupabase,
    Expression<String>? coverPathLocal,
    Expression<String>? status,
    Expression<bool>? destacado,
    Expression<bool>? descargable,
    Expression<int>? duracionSegundos,
    Expression<int>? orden,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidContentItem != null) 'uuid_content_item': uuidContentItem,
      if (tipo != null) 'tipo': tipo,
      if (titulo != null) 'titulo': titulo,
      if (subtitulo != null) 'subtitulo': subtitulo,
      if (descripcion != null) 'descripcion': descripcion,
      if (coverPathSupabase != null) 'cover_path_supabase': coverPathSupabase,
      if (coverPathLocal != null) 'cover_path_local': coverPathLocal,
      if (status != null) 'status': status,
      if (destacado != null) 'destacado': destacado,
      if (descargable != null) 'descargable': descargable,
      if (duracionSegundos != null) 'duracion_segundos': duracionSegundos,
      if (orden != null) 'orden': orden,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentItemsTableCompanion copyWith({
    Value<String>? uuidContentItem,
    Value<String>? tipo,
    Value<String>? titulo,
    Value<String?>? subtitulo,
    Value<String?>? descripcion,
    Value<String?>? coverPathSupabase,
    Value<String?>? coverPathLocal,
    Value<String>? status,
    Value<bool>? destacado,
    Value<bool>? descargable,
    Value<int?>? duracionSegundos,
    Value<int>? orden,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ContentItemsTableCompanion(
      uuidContentItem: uuidContentItem ?? this.uuidContentItem,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      descripcion: descripcion ?? this.descripcion,
      coverPathSupabase: coverPathSupabase ?? this.coverPathSupabase,
      coverPathLocal: coverPathLocal ?? this.coverPathLocal,
      status: status ?? this.status,
      destacado: destacado ?? this.destacado,
      descargable: descargable ?? this.descargable,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      orden: orden ?? this.orden,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidContentItem.present) {
      map['uuid_content_item'] = Variable<String>(uuidContentItem.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (subtitulo.present) {
      map['subtitulo'] = Variable<String>(subtitulo.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (coverPathSupabase.present) {
      map['cover_path_supabase'] = Variable<String>(coverPathSupabase.value);
    }
    if (coverPathLocal.present) {
      map['cover_path_local'] = Variable<String>(coverPathLocal.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (destacado.present) {
      map['destacado'] = Variable<bool>(destacado.value);
    }
    if (descargable.present) {
      map['descargable'] = Variable<bool>(descargable.value);
    }
    if (duracionSegundos.present) {
      map['duracion_segundos'] = Variable<int>(duracionSegundos.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentItemsTableCompanion(')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('subtitulo: $subtitulo, ')
          ..write('descripcion: $descripcion, ')
          ..write('coverPathSupabase: $coverPathSupabase, ')
          ..write('coverPathLocal: $coverPathLocal, ')
          ..write('status: $status, ')
          ..write('destacado: $destacado, ')
          ..write('descargable: $descargable, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('orden: $orden, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentMediaTableTable extends ContentMediaTable
    with TableInfo<$ContentMediaTableTable, LocalContentMedia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentMediaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidContentMediaMeta = const VerificationMeta(
    'uuidContentMedia',
  );
  @override
  late final GeneratedColumn<String> uuidContentMedia = GeneratedColumn<String>(
    'uuid_content_media',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidContentItemMeta = const VerificationMeta(
    'uuidContentItem',
  );
  @override
  late final GeneratedColumn<String> uuidContentItem = GeneratedColumn<String>(
    'uuid_content_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storagePathSupabaseMeta =
      const VerificationMeta('storagePathSupabase');
  @override
  late final GeneratedColumn<String> storagePathSupabase =
      GeneratedColumn<String>(
        'storage_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _storagePathLocalMeta = const VerificationMeta(
    'storagePathLocal',
  );
  @override
  late final GeneratedColumn<String> storagePathLocal = GeneratedColumn<String>(
    'storage_path_local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duracionSegundosMeta = const VerificationMeta(
    'duracionSegundos',
  );
  @override
  late final GeneratedColumn<int> duracionSegundos = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidContentMedia,
    uuidContentItem,
    tipo,
    titulo,
    storagePathSupabase,
    storagePathLocal,
    duracionSegundos,
    orden,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_content_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalContentMedia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_content_media')) {
      context.handle(
        _uuidContentMediaMeta,
        uuidContentMedia.isAcceptableOrUnknown(
          data['uuid_content_media']!,
          _uuidContentMediaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentMediaMeta);
    }
    if (data.containsKey('uuid_content_item')) {
      context.handle(
        _uuidContentItemMeta,
        uuidContentItem.isAcceptableOrUnknown(
          data['uuid_content_item']!,
          _uuidContentItemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentItemMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['type']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['title']!, _tituloMeta),
      );
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathSupabaseMeta,
        storagePathSupabase.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathSupabaseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathSupabaseMeta);
    }
    if (data.containsKey('storage_path_local')) {
      context.handle(
        _storagePathLocalMeta,
        storagePathLocal.isAcceptableOrUnknown(
          data['storage_path_local']!,
          _storagePathLocalMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _duracionSegundosMeta,
        duracionSegundos.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _duracionSegundosMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['sort_order']!, _ordenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidContentMedia};
  @override
  LocalContentMedia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalContentMedia(
      uuidContentMedia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_media'],
      )!,
      uuidContentItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_item'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      storagePathSupabase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      storagePathLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path_local'],
      ),
      duracionSegundos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $ContentMediaTableTable createAlias(String alias) {
    return $ContentMediaTableTable(attachedDatabase, alias);
  }
}

class LocalContentMedia extends DataClass
    implements Insertable<LocalContentMedia> {
  final String uuidContentMedia;
  final String uuidContentItem;
  final String tipo;
  final String? titulo;
  final String storagePathSupabase;
  final String? storagePathLocal;
  final int? duracionSegundos;
  final int orden;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalContentMedia({
    required this.uuidContentMedia,
    required this.uuidContentItem,
    required this.tipo,
    this.titulo,
    required this.storagePathSupabase,
    this.storagePathLocal,
    this.duracionSegundos,
    required this.orden,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_content_media'] = Variable<String>(uuidContentMedia);
    map['uuid_content_item'] = Variable<String>(uuidContentItem);
    map['type'] = Variable<String>(tipo);
    if (!nullToAbsent || titulo != null) {
      map['title'] = Variable<String>(titulo);
    }
    map['storage_path'] = Variable<String>(storagePathSupabase);
    if (!nullToAbsent || storagePathLocal != null) {
      map['storage_path_local'] = Variable<String>(storagePathLocal);
    }
    if (!nullToAbsent || duracionSegundos != null) {
      map['duration_seconds'] = Variable<int>(duracionSegundos);
    }
    map['sort_order'] = Variable<int>(orden);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  ContentMediaTableCompanion toCompanion(bool nullToAbsent) {
    return ContentMediaTableCompanion(
      uuidContentMedia: Value(uuidContentMedia),
      uuidContentItem: Value(uuidContentItem),
      tipo: Value(tipo),
      titulo: titulo == null && nullToAbsent
          ? const Value.absent()
          : Value(titulo),
      storagePathSupabase: Value(storagePathSupabase),
      storagePathLocal: storagePathLocal == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePathLocal),
      duracionSegundos: duracionSegundos == null && nullToAbsent
          ? const Value.absent()
          : Value(duracionSegundos),
      orden: Value(orden),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalContentMedia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalContentMedia(
      uuidContentMedia: serializer.fromJson<String>(json['uuidContentMedia']),
      uuidContentItem: serializer.fromJson<String>(json['uuidContentItem']),
      tipo: serializer.fromJson<String>(json['tipo']),
      titulo: serializer.fromJson<String?>(json['titulo']),
      storagePathSupabase: serializer.fromJson<String>(
        json['storagePathSupabase'],
      ),
      storagePathLocal: serializer.fromJson<String?>(json['storagePathLocal']),
      duracionSegundos: serializer.fromJson<int?>(json['duracionSegundos']),
      orden: serializer.fromJson<int>(json['orden']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidContentMedia': serializer.toJson<String>(uuidContentMedia),
      'uuidContentItem': serializer.toJson<String>(uuidContentItem),
      'tipo': serializer.toJson<String>(tipo),
      'titulo': serializer.toJson<String?>(titulo),
      'storagePathSupabase': serializer.toJson<String>(storagePathSupabase),
      'storagePathLocal': serializer.toJson<String?>(storagePathLocal),
      'duracionSegundos': serializer.toJson<int?>(duracionSegundos),
      'orden': serializer.toJson<int>(orden),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalContentMedia copyWith({
    String? uuidContentMedia,
    String? uuidContentItem,
    String? tipo,
    Value<String?> titulo = const Value.absent(),
    String? storagePathSupabase,
    Value<String?> storagePathLocal = const Value.absent(),
    Value<int?> duracionSegundos = const Value.absent(),
    int? orden,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalContentMedia(
    uuidContentMedia: uuidContentMedia ?? this.uuidContentMedia,
    uuidContentItem: uuidContentItem ?? this.uuidContentItem,
    tipo: tipo ?? this.tipo,
    titulo: titulo.present ? titulo.value : this.titulo,
    storagePathSupabase: storagePathSupabase ?? this.storagePathSupabase,
    storagePathLocal: storagePathLocal.present
        ? storagePathLocal.value
        : this.storagePathLocal,
    duracionSegundos: duracionSegundos.present
        ? duracionSegundos.value
        : this.duracionSegundos,
    orden: orden ?? this.orden,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalContentMedia copyWithCompanion(ContentMediaTableCompanion data) {
    return LocalContentMedia(
      uuidContentMedia: data.uuidContentMedia.present
          ? data.uuidContentMedia.value
          : this.uuidContentMedia,
      uuidContentItem: data.uuidContentItem.present
          ? data.uuidContentItem.value
          : this.uuidContentItem,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      storagePathSupabase: data.storagePathSupabase.present
          ? data.storagePathSupabase.value
          : this.storagePathSupabase,
      storagePathLocal: data.storagePathLocal.present
          ? data.storagePathLocal.value
          : this.storagePathLocal,
      duracionSegundos: data.duracionSegundos.present
          ? data.duracionSegundos.value
          : this.duracionSegundos,
      orden: data.orden.present ? data.orden.value : this.orden,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalContentMedia(')
          ..write('uuidContentMedia: $uuidContentMedia, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('storagePathSupabase: $storagePathSupabase, ')
          ..write('storagePathLocal: $storagePathLocal, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('orden: $orden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidContentMedia,
    uuidContentItem,
    tipo,
    titulo,
    storagePathSupabase,
    storagePathLocal,
    duracionSegundos,
    orden,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalContentMedia &&
          other.uuidContentMedia == this.uuidContentMedia &&
          other.uuidContentItem == this.uuidContentItem &&
          other.tipo == this.tipo &&
          other.titulo == this.titulo &&
          other.storagePathSupabase == this.storagePathSupabase &&
          other.storagePathLocal == this.storagePathLocal &&
          other.duracionSegundos == this.duracionSegundos &&
          other.orden == this.orden &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class ContentMediaTableCompanion extends UpdateCompanion<LocalContentMedia> {
  final Value<String> uuidContentMedia;
  final Value<String> uuidContentItem;
  final Value<String> tipo;
  final Value<String?> titulo;
  final Value<String> storagePathSupabase;
  final Value<String?> storagePathLocal;
  final Value<int?> duracionSegundos;
  final Value<int> orden;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const ContentMediaTableCompanion({
    this.uuidContentMedia = const Value.absent(),
    this.uuidContentItem = const Value.absent(),
    this.tipo = const Value.absent(),
    this.titulo = const Value.absent(),
    this.storagePathSupabase = const Value.absent(),
    this.storagePathLocal = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.orden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentMediaTableCompanion.insert({
    required String uuidContentMedia,
    required String uuidContentItem,
    required String tipo,
    this.titulo = const Value.absent(),
    required String storagePathSupabase,
    this.storagePathLocal = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.orden = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidContentMedia = Value(uuidContentMedia),
       uuidContentItem = Value(uuidContentItem),
       tipo = Value(tipo),
       storagePathSupabase = Value(storagePathSupabase);
  static Insertable<LocalContentMedia> custom({
    Expression<String>? uuidContentMedia,
    Expression<String>? uuidContentItem,
    Expression<String>? tipo,
    Expression<String>? titulo,
    Expression<String>? storagePathSupabase,
    Expression<String>? storagePathLocal,
    Expression<int>? duracionSegundos,
    Expression<int>? orden,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidContentMedia != null) 'uuid_content_media': uuidContentMedia,
      if (uuidContentItem != null) 'uuid_content_item': uuidContentItem,
      if (tipo != null) 'type': tipo,
      if (titulo != null) 'title': titulo,
      if (storagePathSupabase != null) 'storage_path': storagePathSupabase,
      if (storagePathLocal != null) 'storage_path_local': storagePathLocal,
      if (duracionSegundos != null) 'duration_seconds': duracionSegundos,
      if (orden != null) 'sort_order': orden,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentMediaTableCompanion copyWith({
    Value<String>? uuidContentMedia,
    Value<String>? uuidContentItem,
    Value<String>? tipo,
    Value<String?>? titulo,
    Value<String>? storagePathSupabase,
    Value<String?>? storagePathLocal,
    Value<int?>? duracionSegundos,
    Value<int>? orden,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ContentMediaTableCompanion(
      uuidContentMedia: uuidContentMedia ?? this.uuidContentMedia,
      uuidContentItem: uuidContentItem ?? this.uuidContentItem,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      storagePathSupabase: storagePathSupabase ?? this.storagePathSupabase,
      storagePathLocal: storagePathLocal ?? this.storagePathLocal,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      orden: orden ?? this.orden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidContentMedia.present) {
      map['uuid_content_media'] = Variable<String>(uuidContentMedia.value);
    }
    if (uuidContentItem.present) {
      map['uuid_content_item'] = Variable<String>(uuidContentItem.value);
    }
    if (tipo.present) {
      map['type'] = Variable<String>(tipo.value);
    }
    if (titulo.present) {
      map['title'] = Variable<String>(titulo.value);
    }
    if (storagePathSupabase.present) {
      map['storage_path'] = Variable<String>(storagePathSupabase.value);
    }
    if (storagePathLocal.present) {
      map['storage_path_local'] = Variable<String>(storagePathLocal.value);
    }
    if (duracionSegundos.present) {
      map['duration_seconds'] = Variable<int>(duracionSegundos.value);
    }
    if (orden.present) {
      map['sort_order'] = Variable<int>(orden.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentMediaTableCompanion(')
          ..write('uuidContentMedia: $uuidContentMedia, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('tipo: $tipo, ')
          ..write('titulo: $titulo, ')
          ..write('storagePathSupabase: $storagePathSupabase, ')
          ..write('storagePathLocal: $storagePathLocal, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('orden: $orden, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationDevicesTableTable extends NotificationDevicesTable
    with TableInfo<$NotificationDevicesTableTable, LocalNotificationDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationDevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidNotificationDeviceMeta =
      const VerificationMeta('uuidNotificationDevice');
  @override
  late final GeneratedColumn<String> uuidNotificationDevice =
      GeneratedColumn<String>(
        'uuid_notification_device',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installationIdMeta = const VerificationMeta(
    'installationId',
  );
  @override
  late final GeneratedColumn<String> installationId = GeneratedColumn<String>(
    'installation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fcmTokenMeta = const VerificationMeta(
    'fcmToken',
  );
  @override
  late final GeneratedColumn<String> fcmToken = GeneratedColumn<String>(
    'fcm_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    check: () => platform.isIn(notificationDevicePlatforms),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionStatusMeta = const VerificationMeta(
    'permissionStatus',
  );
  @override
  late final GeneratedColumn<String> permissionStatus = GeneratedColumn<String>(
    'permission_status',
    aliasedName,
    false,
    check: () => permissionStatus.isIn(notificationPermissionStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('not_determined'),
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _registrationRefreshedAtMeta =
      const VerificationMeta('registrationRefreshedAt');
  @override
  late final GeneratedColumn<DateTime> registrationRefreshedAt =
      GeneratedColumn<DateTime>(
        'registration_refreshed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidNotificationDevice,
    uuidProfile,
    installationId,
    fcmToken,
    platform,
    permissionStatus,
    appVersion,
    timeZone,
    isActive,
    registrationRefreshedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notification_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNotificationDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_notification_device')) {
      context.handle(
        _uuidNotificationDeviceMeta,
        uuidNotificationDevice.isAcceptableOrUnknown(
          data['uuid_notification_device']!,
          _uuidNotificationDeviceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationDeviceMeta);
    }
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('installation_id')) {
      context.handle(
        _installationIdMeta,
        installationId.isAcceptableOrUnknown(
          data['installation_id']!,
          _installationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installationIdMeta);
    }
    if (data.containsKey('fcm_token')) {
      context.handle(
        _fcmTokenMeta,
        fcmToken.isAcceptableOrUnknown(data['fcm_token']!, _fcmTokenMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('permission_status')) {
      context.handle(
        _permissionStatusMeta,
        permissionStatus.isAcceptableOrUnknown(
          data['permission_status']!,
          _permissionStatusMeta,
        ),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['timezone']!, _timeZoneMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('registration_refreshed_at')) {
      context.handle(
        _registrationRefreshedAtMeta,
        registrationRefreshedAt.isAcceptableOrUnknown(
          data['registration_refreshed_at']!,
          _registrationRefreshedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidNotificationDevice};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uuidProfile, installationId},
  ];
  @override
  LocalNotificationDevice map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotificationDevice(
      uuidNotificationDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_device'],
      )!,
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      installationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_id'],
      )!,
      fcmToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fcm_token'],
      ),
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      permissionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_status'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      registrationRefreshedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registration_refreshed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $NotificationDevicesTableTable createAlias(String alias) {
    return $NotificationDevicesTableTable(attachedDatabase, alias);
  }
}

class LocalNotificationDevice extends DataClass
    implements Insertable<LocalNotificationDevice> {
  final String uuidNotificationDevice;
  final String uuidProfile;
  final String installationId;
  final String? fcmToken;
  final String platform;
  final String permissionStatus;
  final String? appVersion;
  final String? timeZone;
  final bool isActive;
  final DateTime? registrationRefreshedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalNotificationDevice({
    required this.uuidNotificationDevice,
    required this.uuidProfile,
    required this.installationId,
    this.fcmToken,
    required this.platform,
    required this.permissionStatus,
    this.appVersion,
    this.timeZone,
    required this.isActive,
    this.registrationRefreshedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_notification_device'] = Variable<String>(uuidNotificationDevice);
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['installation_id'] = Variable<String>(installationId);
    if (!nullToAbsent || fcmToken != null) {
      map['fcm_token'] = Variable<String>(fcmToken);
    }
    map['platform'] = Variable<String>(platform);
    map['permission_status'] = Variable<String>(permissionStatus);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    if (!nullToAbsent || timeZone != null) {
      map['timezone'] = Variable<String>(timeZone);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || registrationRefreshedAt != null) {
      map['registration_refreshed_at'] = Variable<DateTime>(
        registrationRefreshedAt,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  NotificationDevicesTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationDevicesTableCompanion(
      uuidNotificationDevice: Value(uuidNotificationDevice),
      uuidProfile: Value(uuidProfile),
      installationId: Value(installationId),
      fcmToken: fcmToken == null && nullToAbsent
          ? const Value.absent()
          : Value(fcmToken),
      platform: Value(platform),
      permissionStatus: Value(permissionStatus),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      timeZone: timeZone == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZone),
      isActive: Value(isActive),
      registrationRefreshedAt: registrationRefreshedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationRefreshedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalNotificationDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotificationDevice(
      uuidNotificationDevice: serializer.fromJson<String>(
        json['uuidNotificationDevice'],
      ),
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      installationId: serializer.fromJson<String>(json['installationId']),
      fcmToken: serializer.fromJson<String?>(json['fcmToken']),
      platform: serializer.fromJson<String>(json['platform']),
      permissionStatus: serializer.fromJson<String>(json['permissionStatus']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      timeZone: serializer.fromJson<String?>(json['timeZone']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      registrationRefreshedAt: serializer.fromJson<DateTime?>(
        json['registrationRefreshedAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidNotificationDevice': serializer.toJson<String>(
        uuidNotificationDevice,
      ),
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'installationId': serializer.toJson<String>(installationId),
      'fcmToken': serializer.toJson<String?>(fcmToken),
      'platform': serializer.toJson<String>(platform),
      'permissionStatus': serializer.toJson<String>(permissionStatus),
      'appVersion': serializer.toJson<String?>(appVersion),
      'timeZone': serializer.toJson<String?>(timeZone),
      'isActive': serializer.toJson<bool>(isActive),
      'registrationRefreshedAt': serializer.toJson<DateTime?>(
        registrationRefreshedAt,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalNotificationDevice copyWith({
    String? uuidNotificationDevice,
    String? uuidProfile,
    String? installationId,
    Value<String?> fcmToken = const Value.absent(),
    String? platform,
    String? permissionStatus,
    Value<String?> appVersion = const Value.absent(),
    Value<String?> timeZone = const Value.absent(),
    bool? isActive,
    Value<DateTime?> registrationRefreshedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalNotificationDevice(
    uuidNotificationDevice:
        uuidNotificationDevice ?? this.uuidNotificationDevice,
    uuidProfile: uuidProfile ?? this.uuidProfile,
    installationId: installationId ?? this.installationId,
    fcmToken: fcmToken.present ? fcmToken.value : this.fcmToken,
    platform: platform ?? this.platform,
    permissionStatus: permissionStatus ?? this.permissionStatus,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    timeZone: timeZone.present ? timeZone.value : this.timeZone,
    isActive: isActive ?? this.isActive,
    registrationRefreshedAt: registrationRefreshedAt.present
        ? registrationRefreshedAt.value
        : this.registrationRefreshedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalNotificationDevice copyWithCompanion(
    NotificationDevicesTableCompanion data,
  ) {
    return LocalNotificationDevice(
      uuidNotificationDevice: data.uuidNotificationDevice.present
          ? data.uuidNotificationDevice.value
          : this.uuidNotificationDevice,
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      installationId: data.installationId.present
          ? data.installationId.value
          : this.installationId,
      fcmToken: data.fcmToken.present ? data.fcmToken.value : this.fcmToken,
      platform: data.platform.present ? data.platform.value : this.platform,
      permissionStatus: data.permissionStatus.present
          ? data.permissionStatus.value
          : this.permissionStatus,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      registrationRefreshedAt: data.registrationRefreshedAt.present
          ? data.registrationRefreshedAt.value
          : this.registrationRefreshedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationDevice(')
          ..write('uuidNotificationDevice: $uuidNotificationDevice, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('installationId: $installationId, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('permissionStatus: $permissionStatus, ')
          ..write('appVersion: $appVersion, ')
          ..write('timeZone: $timeZone, ')
          ..write('isActive: $isActive, ')
          ..write('registrationRefreshedAt: $registrationRefreshedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidNotificationDevice,
    uuidProfile,
    installationId,
    fcmToken,
    platform,
    permissionStatus,
    appVersion,
    timeZone,
    isActive,
    registrationRefreshedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotificationDevice &&
          other.uuidNotificationDevice == this.uuidNotificationDevice &&
          other.uuidProfile == this.uuidProfile &&
          other.installationId == this.installationId &&
          other.fcmToken == this.fcmToken &&
          other.platform == this.platform &&
          other.permissionStatus == this.permissionStatus &&
          other.appVersion == this.appVersion &&
          other.timeZone == this.timeZone &&
          other.isActive == this.isActive &&
          other.registrationRefreshedAt == this.registrationRefreshedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class NotificationDevicesTableCompanion
    extends UpdateCompanion<LocalNotificationDevice> {
  final Value<String> uuidNotificationDevice;
  final Value<String> uuidProfile;
  final Value<String> installationId;
  final Value<String?> fcmToken;
  final Value<String> platform;
  final Value<String> permissionStatus;
  final Value<String?> appVersion;
  final Value<String?> timeZone;
  final Value<bool> isActive;
  final Value<DateTime?> registrationRefreshedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const NotificationDevicesTableCompanion({
    this.uuidNotificationDevice = const Value.absent(),
    this.uuidProfile = const Value.absent(),
    this.installationId = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.platform = const Value.absent(),
    this.permissionStatus = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.registrationRefreshedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationDevicesTableCompanion.insert({
    required String uuidNotificationDevice,
    required String uuidProfile,
    required String installationId,
    this.fcmToken = const Value.absent(),
    required String platform,
    this.permissionStatus = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.isActive = const Value.absent(),
    this.registrationRefreshedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidNotificationDevice = Value(uuidNotificationDevice),
       uuidProfile = Value(uuidProfile),
       installationId = Value(installationId),
       platform = Value(platform);
  static Insertable<LocalNotificationDevice> custom({
    Expression<String>? uuidNotificationDevice,
    Expression<String>? uuidProfile,
    Expression<String>? installationId,
    Expression<String>? fcmToken,
    Expression<String>? platform,
    Expression<String>? permissionStatus,
    Expression<String>? appVersion,
    Expression<String>? timeZone,
    Expression<bool>? isActive,
    Expression<DateTime>? registrationRefreshedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidNotificationDevice != null)
        'uuid_notification_device': uuidNotificationDevice,
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (installationId != null) 'installation_id': installationId,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (platform != null) 'platform': platform,
      if (permissionStatus != null) 'permission_status': permissionStatus,
      if (appVersion != null) 'app_version': appVersion,
      if (timeZone != null) 'timezone': timeZone,
      if (isActive != null) 'is_active': isActive,
      if (registrationRefreshedAt != null)
        'registration_refreshed_at': registrationRefreshedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationDevicesTableCompanion copyWith({
    Value<String>? uuidNotificationDevice,
    Value<String>? uuidProfile,
    Value<String>? installationId,
    Value<String?>? fcmToken,
    Value<String>? platform,
    Value<String>? permissionStatus,
    Value<String?>? appVersion,
    Value<String?>? timeZone,
    Value<bool>? isActive,
    Value<DateTime?>? registrationRefreshedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return NotificationDevicesTableCompanion(
      uuidNotificationDevice:
          uuidNotificationDevice ?? this.uuidNotificationDevice,
      uuidProfile: uuidProfile ?? this.uuidProfile,
      installationId: installationId ?? this.installationId,
      fcmToken: fcmToken ?? this.fcmToken,
      platform: platform ?? this.platform,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      appVersion: appVersion ?? this.appVersion,
      timeZone: timeZone ?? this.timeZone,
      isActive: isActive ?? this.isActive,
      registrationRefreshedAt:
          registrationRefreshedAt ?? this.registrationRefreshedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidNotificationDevice.present) {
      map['uuid_notification_device'] = Variable<String>(
        uuidNotificationDevice.value,
      );
    }
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (installationId.present) {
      map['installation_id'] = Variable<String>(installationId.value);
    }
    if (fcmToken.present) {
      map['fcm_token'] = Variable<String>(fcmToken.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (permissionStatus.present) {
      map['permission_status'] = Variable<String>(permissionStatus.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (timeZone.present) {
      map['timezone'] = Variable<String>(timeZone.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (registrationRefreshedAt.present) {
      map['registration_refreshed_at'] = Variable<DateTime>(
        registrationRefreshedAt.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationDevicesTableCompanion(')
          ..write('uuidNotificationDevice: $uuidNotificationDevice, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('installationId: $installationId, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('platform: $platform, ')
          ..write('permissionStatus: $permissionStatus, ')
          ..write('appVersion: $appVersion, ')
          ..write('timeZone: $timeZone, ')
          ..write('isActive: $isActive, ')
          ..write('registrationRefreshedAt: $registrationRefreshedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationEventsTableTable extends NotificationEventsTable
    with TableInfo<$NotificationEventsTableTable, LocalNotificationEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidNotificationEventMeta =
      const VerificationMeta('uuidNotificationEvent');
  @override
  late final GeneratedColumn<String> uuidNotificationEvent =
      GeneratedColumn<String>(
        'uuid_notification_event',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    check: () => category.isIn(notificationCategories),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleTemplateMeta = const VerificationMeta(
    'titleTemplate',
  );
  @override
  late final GeneratedColumn<String> titleTemplate = GeneratedColumn<String>(
    'title_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyTemplateMeta = const VerificationMeta(
    'bodyTemplate',
  );
  @override
  late final GeneratedColumn<String> bodyTemplate = GeneratedColumn<String>(
    'body_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerTypeMeta = const VerificationMeta(
    'triggerType',
  );
  @override
  late final GeneratedColumn<String> triggerType = GeneratedColumn<String>(
    'trigger_type',
    aliasedName,
    false,
    check: () => triggerType.isIn(notificationEventTriggerTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerKeyMeta = const VerificationMeta(
    'triggerKey',
  );
  @override
  late final GeneratedColumn<String> triggerKey = GeneratedColumn<String>(
    'trigger_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _executionModeMeta = const VerificationMeta(
    'executionMode',
  );
  @override
  late final GeneratedColumn<String> executionMode = GeneratedColumn<String>(
    'execution_mode',
    aliasedName,
    false,
    check: () => executionMode.isIn(notificationEventExecutionModes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audienceTypeMeta = const VerificationMeta(
    'audienceType',
  );
  @override
  late final GeneratedColumn<String> audienceType = GeneratedColumn<String>(
    'audience_type',
    aliasedName,
    false,
    check: () => audienceType.isIn(notificationAudienceTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    check: () => actionType.isIn(notificationActionTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionPayloadTemplateJsonMeta =
      const VerificationMeta('actionPayloadTemplateJson');
  @override
  late final GeneratedColumn<String> actionPayloadTemplateJson =
      GeneratedColumn<String>(
        'action_payload_template',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _triggerConfigJsonMeta = const VerificationMeta(
    'triggerConfigJson',
  );
  @override
  late final GeneratedColumn<String> triggerConfigJson =
      GeneratedColumn<String>(
        'trigger_config',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(notificationEventStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _uuidCreatedByProfileMeta =
      const VerificationMeta('uuidCreatedByProfile');
  @override
  late final GeneratedColumn<String> uuidCreatedByProfile =
      GeneratedColumn<String>(
        'uuid_created_by_profile',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _uuidUpdatedByProfileMeta =
      const VerificationMeta('uuidUpdatedByProfile');
  @override
  late final GeneratedColumn<String> uuidUpdatedByProfile =
      GeneratedColumn<String>(
        'uuid_updated_by_profile',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidNotificationEvent,
    name,
    category,
    titleTemplate,
    bodyTemplate,
    triggerType,
    triggerKey,
    executionMode,
    audienceType,
    actionType,
    actionPayloadTemplateJson,
    triggerConfigJson,
    startsAt,
    endsAt,
    status,
    uuidCreatedByProfile,
    uuidUpdatedByProfile,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notification_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNotificationEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_notification_event')) {
      context.handle(
        _uuidNotificationEventMeta,
        uuidNotificationEvent.isAcceptableOrUnknown(
          data['uuid_notification_event']!,
          _uuidNotificationEventMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationEventMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title_template')) {
      context.handle(
        _titleTemplateMeta,
        titleTemplate.isAcceptableOrUnknown(
          data['title_template']!,
          _titleTemplateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleTemplateMeta);
    }
    if (data.containsKey('body_template')) {
      context.handle(
        _bodyTemplateMeta,
        bodyTemplate.isAcceptableOrUnknown(
          data['body_template']!,
          _bodyTemplateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyTemplateMeta);
    }
    if (data.containsKey('trigger_type')) {
      context.handle(
        _triggerTypeMeta,
        triggerType.isAcceptableOrUnknown(
          data['trigger_type']!,
          _triggerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTypeMeta);
    }
    if (data.containsKey('trigger_key')) {
      context.handle(
        _triggerKeyMeta,
        triggerKey.isAcceptableOrUnknown(data['trigger_key']!, _triggerKeyMeta),
      );
    }
    if (data.containsKey('execution_mode')) {
      context.handle(
        _executionModeMeta,
        executionMode.isAcceptableOrUnknown(
          data['execution_mode']!,
          _executionModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_executionModeMeta);
    }
    if (data.containsKey('audience_type')) {
      context.handle(
        _audienceTypeMeta,
        audienceType.isAcceptableOrUnknown(
          data['audience_type']!,
          _audienceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audienceTypeMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('action_payload_template')) {
      context.handle(
        _actionPayloadTemplateJsonMeta,
        actionPayloadTemplateJson.isAcceptableOrUnknown(
          data['action_payload_template']!,
          _actionPayloadTemplateJsonMeta,
        ),
      );
    }
    if (data.containsKey('trigger_config')) {
      context.handle(
        _triggerConfigJsonMeta,
        triggerConfigJson.isAcceptableOrUnknown(
          data['trigger_config']!,
          _triggerConfigJsonMeta,
        ),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('uuid_created_by_profile')) {
      context.handle(
        _uuidCreatedByProfileMeta,
        uuidCreatedByProfile.isAcceptableOrUnknown(
          data['uuid_created_by_profile']!,
          _uuidCreatedByProfileMeta,
        ),
      );
    }
    if (data.containsKey('uuid_updated_by_profile')) {
      context.handle(
        _uuidUpdatedByProfileMeta,
        uuidUpdatedByProfile.isAcceptableOrUnknown(
          data['uuid_updated_by_profile']!,
          _uuidUpdatedByProfileMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidNotificationEvent};
  @override
  LocalNotificationEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotificationEvent(
      uuidNotificationEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_event'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      titleTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_template'],
      )!,
      bodyTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_template'],
      )!,
      triggerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_type'],
      )!,
      triggerKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_key'],
      ),
      executionMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}execution_mode'],
      )!,
      audienceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience_type'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      actionPayloadTemplateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_payload_template'],
      )!,
      triggerConfigJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_config'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      uuidCreatedByProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_created_by_profile'],
      ),
      uuidUpdatedByProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_updated_by_profile'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $NotificationEventsTableTable createAlias(String alias) {
    return $NotificationEventsTableTable(attachedDatabase, alias);
  }
}

class LocalNotificationEvent extends DataClass
    implements Insertable<LocalNotificationEvent> {
  final String uuidNotificationEvent;
  final String name;
  final String category;
  final String titleTemplate;
  final String bodyTemplate;
  final String triggerType;
  final String? triggerKey;
  final String executionMode;
  final String audienceType;
  final String actionType;
  final String actionPayloadTemplateJson;
  final String triggerConfigJson;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String status;
  final String? uuidCreatedByProfile;
  final String? uuidUpdatedByProfile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalNotificationEvent({
    required this.uuidNotificationEvent,
    required this.name,
    required this.category,
    required this.titleTemplate,
    required this.bodyTemplate,
    required this.triggerType,
    this.triggerKey,
    required this.executionMode,
    required this.audienceType,
    required this.actionType,
    required this.actionPayloadTemplateJson,
    required this.triggerConfigJson,
    required this.startsAt,
    this.endsAt,
    required this.status,
    this.uuidCreatedByProfile,
    this.uuidUpdatedByProfile,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_notification_event'] = Variable<String>(uuidNotificationEvent);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['title_template'] = Variable<String>(titleTemplate);
    map['body_template'] = Variable<String>(bodyTemplate);
    map['trigger_type'] = Variable<String>(triggerType);
    if (!nullToAbsent || triggerKey != null) {
      map['trigger_key'] = Variable<String>(triggerKey);
    }
    map['execution_mode'] = Variable<String>(executionMode);
    map['audience_type'] = Variable<String>(audienceType);
    map['action_type'] = Variable<String>(actionType);
    map['action_payload_template'] = Variable<String>(
      actionPayloadTemplateJson,
    );
    map['trigger_config'] = Variable<String>(triggerConfigJson);
    map['starts_at'] = Variable<DateTime>(startsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || uuidCreatedByProfile != null) {
      map['uuid_created_by_profile'] = Variable<String>(uuidCreatedByProfile);
    }
    if (!nullToAbsent || uuidUpdatedByProfile != null) {
      map['uuid_updated_by_profile'] = Variable<String>(uuidUpdatedByProfile);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  NotificationEventsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationEventsTableCompanion(
      uuidNotificationEvent: Value(uuidNotificationEvent),
      name: Value(name),
      category: Value(category),
      titleTemplate: Value(titleTemplate),
      bodyTemplate: Value(bodyTemplate),
      triggerType: Value(triggerType),
      triggerKey: triggerKey == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerKey),
      executionMode: Value(executionMode),
      audienceType: Value(audienceType),
      actionType: Value(actionType),
      actionPayloadTemplateJson: Value(actionPayloadTemplateJson),
      triggerConfigJson: Value(triggerConfigJson),
      startsAt: Value(startsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      status: Value(status),
      uuidCreatedByProfile: uuidCreatedByProfile == null && nullToAbsent
          ? const Value.absent()
          : Value(uuidCreatedByProfile),
      uuidUpdatedByProfile: uuidUpdatedByProfile == null && nullToAbsent
          ? const Value.absent()
          : Value(uuidUpdatedByProfile),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalNotificationEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotificationEvent(
      uuidNotificationEvent: serializer.fromJson<String>(
        json['uuidNotificationEvent'],
      ),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      titleTemplate: serializer.fromJson<String>(json['titleTemplate']),
      bodyTemplate: serializer.fromJson<String>(json['bodyTemplate']),
      triggerType: serializer.fromJson<String>(json['triggerType']),
      triggerKey: serializer.fromJson<String?>(json['triggerKey']),
      executionMode: serializer.fromJson<String>(json['executionMode']),
      audienceType: serializer.fromJson<String>(json['audienceType']),
      actionType: serializer.fromJson<String>(json['actionType']),
      actionPayloadTemplateJson: serializer.fromJson<String>(
        json['actionPayloadTemplateJson'],
      ),
      triggerConfigJson: serializer.fromJson<String>(json['triggerConfigJson']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      status: serializer.fromJson<String>(json['status']),
      uuidCreatedByProfile: serializer.fromJson<String?>(
        json['uuidCreatedByProfile'],
      ),
      uuidUpdatedByProfile: serializer.fromJson<String?>(
        json['uuidUpdatedByProfile'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidNotificationEvent': serializer.toJson<String>(uuidNotificationEvent),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'titleTemplate': serializer.toJson<String>(titleTemplate),
      'bodyTemplate': serializer.toJson<String>(bodyTemplate),
      'triggerType': serializer.toJson<String>(triggerType),
      'triggerKey': serializer.toJson<String?>(triggerKey),
      'executionMode': serializer.toJson<String>(executionMode),
      'audienceType': serializer.toJson<String>(audienceType),
      'actionType': serializer.toJson<String>(actionType),
      'actionPayloadTemplateJson': serializer.toJson<String>(
        actionPayloadTemplateJson,
      ),
      'triggerConfigJson': serializer.toJson<String>(triggerConfigJson),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'status': serializer.toJson<String>(status),
      'uuidCreatedByProfile': serializer.toJson<String?>(uuidCreatedByProfile),
      'uuidUpdatedByProfile': serializer.toJson<String?>(uuidUpdatedByProfile),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalNotificationEvent copyWith({
    String? uuidNotificationEvent,
    String? name,
    String? category,
    String? titleTemplate,
    String? bodyTemplate,
    String? triggerType,
    Value<String?> triggerKey = const Value.absent(),
    String? executionMode,
    String? audienceType,
    String? actionType,
    String? actionPayloadTemplateJson,
    String? triggerConfigJson,
    DateTime? startsAt,
    Value<DateTime?> endsAt = const Value.absent(),
    String? status,
    Value<String?> uuidCreatedByProfile = const Value.absent(),
    Value<String?> uuidUpdatedByProfile = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalNotificationEvent(
    uuidNotificationEvent: uuidNotificationEvent ?? this.uuidNotificationEvent,
    name: name ?? this.name,
    category: category ?? this.category,
    titleTemplate: titleTemplate ?? this.titleTemplate,
    bodyTemplate: bodyTemplate ?? this.bodyTemplate,
    triggerType: triggerType ?? this.triggerType,
    triggerKey: triggerKey.present ? triggerKey.value : this.triggerKey,
    executionMode: executionMode ?? this.executionMode,
    audienceType: audienceType ?? this.audienceType,
    actionType: actionType ?? this.actionType,
    actionPayloadTemplateJson:
        actionPayloadTemplateJson ?? this.actionPayloadTemplateJson,
    triggerConfigJson: triggerConfigJson ?? this.triggerConfigJson,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    status: status ?? this.status,
    uuidCreatedByProfile: uuidCreatedByProfile.present
        ? uuidCreatedByProfile.value
        : this.uuidCreatedByProfile,
    uuidUpdatedByProfile: uuidUpdatedByProfile.present
        ? uuidUpdatedByProfile.value
        : this.uuidUpdatedByProfile,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalNotificationEvent copyWithCompanion(
    NotificationEventsTableCompanion data,
  ) {
    return LocalNotificationEvent(
      uuidNotificationEvent: data.uuidNotificationEvent.present
          ? data.uuidNotificationEvent.value
          : this.uuidNotificationEvent,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      titleTemplate: data.titleTemplate.present
          ? data.titleTemplate.value
          : this.titleTemplate,
      bodyTemplate: data.bodyTemplate.present
          ? data.bodyTemplate.value
          : this.bodyTemplate,
      triggerType: data.triggerType.present
          ? data.triggerType.value
          : this.triggerType,
      triggerKey: data.triggerKey.present
          ? data.triggerKey.value
          : this.triggerKey,
      executionMode: data.executionMode.present
          ? data.executionMode.value
          : this.executionMode,
      audienceType: data.audienceType.present
          ? data.audienceType.value
          : this.audienceType,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      actionPayloadTemplateJson: data.actionPayloadTemplateJson.present
          ? data.actionPayloadTemplateJson.value
          : this.actionPayloadTemplateJson,
      triggerConfigJson: data.triggerConfigJson.present
          ? data.triggerConfigJson.value
          : this.triggerConfigJson,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      status: data.status.present ? data.status.value : this.status,
      uuidCreatedByProfile: data.uuidCreatedByProfile.present
          ? data.uuidCreatedByProfile.value
          : this.uuidCreatedByProfile,
      uuidUpdatedByProfile: data.uuidUpdatedByProfile.present
          ? data.uuidUpdatedByProfile.value
          : this.uuidUpdatedByProfile,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationEvent(')
          ..write('uuidNotificationEvent: $uuidNotificationEvent, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('titleTemplate: $titleTemplate, ')
          ..write('bodyTemplate: $bodyTemplate, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerKey: $triggerKey, ')
          ..write('executionMode: $executionMode, ')
          ..write('audienceType: $audienceType, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadTemplateJson: $actionPayloadTemplateJson, ')
          ..write('triggerConfigJson: $triggerConfigJson, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('status: $status, ')
          ..write('uuidCreatedByProfile: $uuidCreatedByProfile, ')
          ..write('uuidUpdatedByProfile: $uuidUpdatedByProfile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    uuidNotificationEvent,
    name,
    category,
    titleTemplate,
    bodyTemplate,
    triggerType,
    triggerKey,
    executionMode,
    audienceType,
    actionType,
    actionPayloadTemplateJson,
    triggerConfigJson,
    startsAt,
    endsAt,
    status,
    uuidCreatedByProfile,
    uuidUpdatedByProfile,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotificationEvent &&
          other.uuidNotificationEvent == this.uuidNotificationEvent &&
          other.name == this.name &&
          other.category == this.category &&
          other.titleTemplate == this.titleTemplate &&
          other.bodyTemplate == this.bodyTemplate &&
          other.triggerType == this.triggerType &&
          other.triggerKey == this.triggerKey &&
          other.executionMode == this.executionMode &&
          other.audienceType == this.audienceType &&
          other.actionType == this.actionType &&
          other.actionPayloadTemplateJson == this.actionPayloadTemplateJson &&
          other.triggerConfigJson == this.triggerConfigJson &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt &&
          other.status == this.status &&
          other.uuidCreatedByProfile == this.uuidCreatedByProfile &&
          other.uuidUpdatedByProfile == this.uuidUpdatedByProfile &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class NotificationEventsTableCompanion
    extends UpdateCompanion<LocalNotificationEvent> {
  final Value<String> uuidNotificationEvent;
  final Value<String> name;
  final Value<String> category;
  final Value<String> titleTemplate;
  final Value<String> bodyTemplate;
  final Value<String> triggerType;
  final Value<String?> triggerKey;
  final Value<String> executionMode;
  final Value<String> audienceType;
  final Value<String> actionType;
  final Value<String> actionPayloadTemplateJson;
  final Value<String> triggerConfigJson;
  final Value<DateTime> startsAt;
  final Value<DateTime?> endsAt;
  final Value<String> status;
  final Value<String?> uuidCreatedByProfile;
  final Value<String?> uuidUpdatedByProfile;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const NotificationEventsTableCompanion({
    this.uuidNotificationEvent = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.titleTemplate = const Value.absent(),
    this.bodyTemplate = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerKey = const Value.absent(),
    this.executionMode = const Value.absent(),
    this.audienceType = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionPayloadTemplateJson = const Value.absent(),
    this.triggerConfigJson = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.status = const Value.absent(),
    this.uuidCreatedByProfile = const Value.absent(),
    this.uuidUpdatedByProfile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationEventsTableCompanion.insert({
    required String uuidNotificationEvent,
    required String name,
    required String category,
    required String titleTemplate,
    required String bodyTemplate,
    required String triggerType,
    this.triggerKey = const Value.absent(),
    required String executionMode,
    required String audienceType,
    required String actionType,
    this.actionPayloadTemplateJson = const Value.absent(),
    this.triggerConfigJson = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.status = const Value.absent(),
    this.uuidCreatedByProfile = const Value.absent(),
    this.uuidUpdatedByProfile = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidNotificationEvent = Value(uuidNotificationEvent),
       name = Value(name),
       category = Value(category),
       titleTemplate = Value(titleTemplate),
       bodyTemplate = Value(bodyTemplate),
       triggerType = Value(triggerType),
       executionMode = Value(executionMode),
       audienceType = Value(audienceType),
       actionType = Value(actionType);
  static Insertable<LocalNotificationEvent> custom({
    Expression<String>? uuidNotificationEvent,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? titleTemplate,
    Expression<String>? bodyTemplate,
    Expression<String>? triggerType,
    Expression<String>? triggerKey,
    Expression<String>? executionMode,
    Expression<String>? audienceType,
    Expression<String>? actionType,
    Expression<String>? actionPayloadTemplateJson,
    Expression<String>? triggerConfigJson,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<String>? status,
    Expression<String>? uuidCreatedByProfile,
    Expression<String>? uuidUpdatedByProfile,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidNotificationEvent != null)
        'uuid_notification_event': uuidNotificationEvent,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (titleTemplate != null) 'title_template': titleTemplate,
      if (bodyTemplate != null) 'body_template': bodyTemplate,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerKey != null) 'trigger_key': triggerKey,
      if (executionMode != null) 'execution_mode': executionMode,
      if (audienceType != null) 'audience_type': audienceType,
      if (actionType != null) 'action_type': actionType,
      if (actionPayloadTemplateJson != null)
        'action_payload_template': actionPayloadTemplateJson,
      if (triggerConfigJson != null) 'trigger_config': triggerConfigJson,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (status != null) 'status': status,
      if (uuidCreatedByProfile != null)
        'uuid_created_by_profile': uuidCreatedByProfile,
      if (uuidUpdatedByProfile != null)
        'uuid_updated_by_profile': uuidUpdatedByProfile,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationEventsTableCompanion copyWith({
    Value<String>? uuidNotificationEvent,
    Value<String>? name,
    Value<String>? category,
    Value<String>? titleTemplate,
    Value<String>? bodyTemplate,
    Value<String>? triggerType,
    Value<String?>? triggerKey,
    Value<String>? executionMode,
    Value<String>? audienceType,
    Value<String>? actionType,
    Value<String>? actionPayloadTemplateJson,
    Value<String>? triggerConfigJson,
    Value<DateTime>? startsAt,
    Value<DateTime?>? endsAt,
    Value<String>? status,
    Value<String?>? uuidCreatedByProfile,
    Value<String?>? uuidUpdatedByProfile,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return NotificationEventsTableCompanion(
      uuidNotificationEvent:
          uuidNotificationEvent ?? this.uuidNotificationEvent,
      name: name ?? this.name,
      category: category ?? this.category,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      triggerType: triggerType ?? this.triggerType,
      triggerKey: triggerKey ?? this.triggerKey,
      executionMode: executionMode ?? this.executionMode,
      audienceType: audienceType ?? this.audienceType,
      actionType: actionType ?? this.actionType,
      actionPayloadTemplateJson:
          actionPayloadTemplateJson ?? this.actionPayloadTemplateJson,
      triggerConfigJson: triggerConfigJson ?? this.triggerConfigJson,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      uuidCreatedByProfile: uuidCreatedByProfile ?? this.uuidCreatedByProfile,
      uuidUpdatedByProfile: uuidUpdatedByProfile ?? this.uuidUpdatedByProfile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidNotificationEvent.present) {
      map['uuid_notification_event'] = Variable<String>(
        uuidNotificationEvent.value,
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (titleTemplate.present) {
      map['title_template'] = Variable<String>(titleTemplate.value);
    }
    if (bodyTemplate.present) {
      map['body_template'] = Variable<String>(bodyTemplate.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>(triggerType.value);
    }
    if (triggerKey.present) {
      map['trigger_key'] = Variable<String>(triggerKey.value);
    }
    if (executionMode.present) {
      map['execution_mode'] = Variable<String>(executionMode.value);
    }
    if (audienceType.present) {
      map['audience_type'] = Variable<String>(audienceType.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionPayloadTemplateJson.present) {
      map['action_payload_template'] = Variable<String>(
        actionPayloadTemplateJson.value,
      );
    }
    if (triggerConfigJson.present) {
      map['trigger_config'] = Variable<String>(triggerConfigJson.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (uuidCreatedByProfile.present) {
      map['uuid_created_by_profile'] = Variable<String>(
        uuidCreatedByProfile.value,
      );
    }
    if (uuidUpdatedByProfile.present) {
      map['uuid_updated_by_profile'] = Variable<String>(
        uuidUpdatedByProfile.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationEventsTableCompanion(')
          ..write('uuidNotificationEvent: $uuidNotificationEvent, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('titleTemplate: $titleTemplate, ')
          ..write('bodyTemplate: $bodyTemplate, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerKey: $triggerKey, ')
          ..write('executionMode: $executionMode, ')
          ..write('audienceType: $audienceType, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadTemplateJson: $actionPayloadTemplateJson, ')
          ..write('triggerConfigJson: $triggerConfigJson, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('status: $status, ')
          ..write('uuidCreatedByProfile: $uuidCreatedByProfile, ')
          ..write('uuidUpdatedByProfile: $uuidUpdatedByProfile, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationDispatchesTableTable extends NotificationDispatchesTable
    with
        TableInfo<
          $NotificationDispatchesTableTable,
          LocalNotificationDispatch
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationDispatchesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidNotificationDispatchMeta =
      const VerificationMeta('uuidNotificationDispatch');
  @override
  late final GeneratedColumn<String> uuidNotificationDispatch =
      GeneratedColumn<String>(
        'uuid_notification_dispatch',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidNotificationEventMeta =
      const VerificationMeta('uuidNotificationEvent');
  @override
  late final GeneratedColumn<String> uuidNotificationEvent =
      GeneratedColumn<String>(
        'uuid_notification_event',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _triggerSourceMeta = const VerificationMeta(
    'triggerSource',
  );
  @override
  late final GeneratedColumn<String> triggerSource = GeneratedColumn<String>(
    'trigger_source',
    aliasedName,
    false,
    check: () => triggerSource.isIn(notificationDispatchTriggerSources),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidTriggeredByProfileMeta =
      const VerificationMeta('uuidTriggeredByProfile');
  @override
  late final GeneratedColumn<String> uuidTriggeredByProfile =
      GeneratedColumn<String>(
        'uuid_triggered_by_profile',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceEntityTypeMeta = const VerificationMeta(
    'sourceEntityType',
  );
  @override
  late final GeneratedColumn<String> sourceEntityType = GeneratedColumn<String>(
    'source_entity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEntityUuidMeta = const VerificationMeta(
    'sourceEntityUuid',
  );
  @override
  late final GeneratedColumn<String> sourceEntityUuid = GeneratedColumn<String>(
    'source_entity_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleSnapshotMeta = const VerificationMeta(
    'titleSnapshot',
  );
  @override
  late final GeneratedColumn<String> titleSnapshot = GeneratedColumn<String>(
    'title_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodySnapshotMeta = const VerificationMeta(
    'bodySnapshot',
  );
  @override
  late final GeneratedColumn<String> bodySnapshot = GeneratedColumn<String>(
    'body_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categorySnapshotMeta = const VerificationMeta(
    'categorySnapshot',
  );
  @override
  late final GeneratedColumn<String> categorySnapshot = GeneratedColumn<String>(
    'category_snapshot',
    aliasedName,
    false,
    check: () => categorySnapshot.isIn(notificationCategories),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audienceTypeSnapshotMeta =
      const VerificationMeta('audienceTypeSnapshot');
  @override
  late final GeneratedColumn<String> audienceTypeSnapshot =
      GeneratedColumn<String>(
        'audience_type_snapshot',
        aliasedName,
        false,
        check: () => audienceTypeSnapshot.isIn(notificationAudienceTypes),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actionTypeSnapshotMeta =
      const VerificationMeta('actionTypeSnapshot');
  @override
  late final GeneratedColumn<String> actionTypeSnapshot =
      GeneratedColumn<String>(
        'action_type_snapshot',
        aliasedName,
        false,
        check: () => actionTypeSnapshot.isIn(notificationActionTypes),
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actionPayloadSnapshotJsonMeta =
      const VerificationMeta('actionPayloadSnapshotJson');
  @override
  late final GeneratedColumn<String> actionPayloadSnapshotJson =
      GeneratedColumn<String>(
        'action_payload_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(notificationDispatchStatuses),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _targetProfileCountMeta =
      const VerificationMeta('targetProfileCount');
  @override
  late final GeneratedColumn<int> targetProfileCount = GeneratedColumn<int>(
    'target_profile_count',
    aliasedName,
    false,
    check: () => ComparableExpr(targetProfileCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetDeviceCountMeta = const VerificationMeta(
    'targetDeviceCount',
  );
  @override
  late final GeneratedColumn<int> targetDeviceCount = GeneratedColumn<int>(
    'target_device_count',
    aliasedName,
    false,
    check: () => ComparableExpr(targetDeviceCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _successDeviceCountMeta =
      const VerificationMeta('successDeviceCount');
  @override
  late final GeneratedColumn<int> successDeviceCount = GeneratedColumn<int>(
    'success_device_count',
    aliasedName,
    false,
    check: () => ComparableExpr(successDeviceCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failureDeviceCountMeta =
      const VerificationMeta('failureDeviceCount');
  @override
  late final GeneratedColumn<int> failureDeviceCount = GeneratedColumn<int>(
    'failure_device_count',
    aliasedName,
    false,
    check: () => ComparableExpr(failureDeviceCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _invalidTokenCountMeta = const VerificationMeta(
    'invalidTokenCount',
  );
  @override
  late final GeneratedColumn<int> invalidTokenCount = GeneratedColumn<int>(
    'invalid_token_count',
    aliasedName,
    false,
    check: () => ComparableExpr(invalidTokenCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorSummaryMeta = const VerificationMeta(
    'errorSummary',
  );
  @override
  late final GeneratedColumn<String> errorSummary = GeneratedColumn<String>(
    'error_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidNotificationDispatch,
    uuidNotificationEvent,
    triggerSource,
    uuidTriggeredByProfile,
    sourceEntityType,
    sourceEntityUuid,
    idempotencyKey,
    titleSnapshot,
    bodySnapshot,
    categorySnapshot,
    audienceTypeSnapshot,
    actionTypeSnapshot,
    actionPayloadSnapshotJson,
    status,
    targetProfileCount,
    targetDeviceCount,
    successDeviceCount,
    failureDeviceCount,
    invalidTokenCount,
    startedAt,
    completedAt,
    errorSummary,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notification_dispatches';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNotificationDispatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_notification_dispatch')) {
      context.handle(
        _uuidNotificationDispatchMeta,
        uuidNotificationDispatch.isAcceptableOrUnknown(
          data['uuid_notification_dispatch']!,
          _uuidNotificationDispatchMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationDispatchMeta);
    }
    if (data.containsKey('uuid_notification_event')) {
      context.handle(
        _uuidNotificationEventMeta,
        uuidNotificationEvent.isAcceptableOrUnknown(
          data['uuid_notification_event']!,
          _uuidNotificationEventMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationEventMeta);
    }
    if (data.containsKey('trigger_source')) {
      context.handle(
        _triggerSourceMeta,
        triggerSource.isAcceptableOrUnknown(
          data['trigger_source']!,
          _triggerSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerSourceMeta);
    }
    if (data.containsKey('uuid_triggered_by_profile')) {
      context.handle(
        _uuidTriggeredByProfileMeta,
        uuidTriggeredByProfile.isAcceptableOrUnknown(
          data['uuid_triggered_by_profile']!,
          _uuidTriggeredByProfileMeta,
        ),
      );
    }
    if (data.containsKey('source_entity_type')) {
      context.handle(
        _sourceEntityTypeMeta,
        sourceEntityType.isAcceptableOrUnknown(
          data['source_entity_type']!,
          _sourceEntityTypeMeta,
        ),
      );
    }
    if (data.containsKey('source_entity_uuid')) {
      context.handle(
        _sourceEntityUuidMeta,
        sourceEntityUuid.isAcceptableOrUnknown(
          data['source_entity_uuid']!,
          _sourceEntityUuidMeta,
        ),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('title_snapshot')) {
      context.handle(
        _titleSnapshotMeta,
        titleSnapshot.isAcceptableOrUnknown(
          data['title_snapshot']!,
          _titleSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titleSnapshotMeta);
    }
    if (data.containsKey('body_snapshot')) {
      context.handle(
        _bodySnapshotMeta,
        bodySnapshot.isAcceptableOrUnknown(
          data['body_snapshot']!,
          _bodySnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodySnapshotMeta);
    }
    if (data.containsKey('category_snapshot')) {
      context.handle(
        _categorySnapshotMeta,
        categorySnapshot.isAcceptableOrUnknown(
          data['category_snapshot']!,
          _categorySnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categorySnapshotMeta);
    }
    if (data.containsKey('audience_type_snapshot')) {
      context.handle(
        _audienceTypeSnapshotMeta,
        audienceTypeSnapshot.isAcceptableOrUnknown(
          data['audience_type_snapshot']!,
          _audienceTypeSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_audienceTypeSnapshotMeta);
    }
    if (data.containsKey('action_type_snapshot')) {
      context.handle(
        _actionTypeSnapshotMeta,
        actionTypeSnapshot.isAcceptableOrUnknown(
          data['action_type_snapshot']!,
          _actionTypeSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionTypeSnapshotMeta);
    }
    if (data.containsKey('action_payload_snapshot')) {
      context.handle(
        _actionPayloadSnapshotJsonMeta,
        actionPayloadSnapshotJson.isAcceptableOrUnknown(
          data['action_payload_snapshot']!,
          _actionPayloadSnapshotJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('target_profile_count')) {
      context.handle(
        _targetProfileCountMeta,
        targetProfileCount.isAcceptableOrUnknown(
          data['target_profile_count']!,
          _targetProfileCountMeta,
        ),
      );
    }
    if (data.containsKey('target_device_count')) {
      context.handle(
        _targetDeviceCountMeta,
        targetDeviceCount.isAcceptableOrUnknown(
          data['target_device_count']!,
          _targetDeviceCountMeta,
        ),
      );
    }
    if (data.containsKey('success_device_count')) {
      context.handle(
        _successDeviceCountMeta,
        successDeviceCount.isAcceptableOrUnknown(
          data['success_device_count']!,
          _successDeviceCountMeta,
        ),
      );
    }
    if (data.containsKey('failure_device_count')) {
      context.handle(
        _failureDeviceCountMeta,
        failureDeviceCount.isAcceptableOrUnknown(
          data['failure_device_count']!,
          _failureDeviceCountMeta,
        ),
      );
    }
    if (data.containsKey('invalid_token_count')) {
      context.handle(
        _invalidTokenCountMeta,
        invalidTokenCount.isAcceptableOrUnknown(
          data['invalid_token_count']!,
          _invalidTokenCountMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('error_summary')) {
      context.handle(
        _errorSummaryMeta,
        errorSummary.isAcceptableOrUnknown(
          data['error_summary']!,
          _errorSummaryMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidNotificationDispatch};
  @override
  LocalNotificationDispatch map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotificationDispatch(
      uuidNotificationDispatch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_dispatch'],
      )!,
      uuidNotificationEvent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_event'],
      )!,
      triggerSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_source'],
      )!,
      uuidTriggeredByProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_triggered_by_profile'],
      ),
      sourceEntityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entity_type'],
      ),
      sourceEntityUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_entity_uuid'],
      ),
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      titleSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_snapshot'],
      )!,
      bodySnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_snapshot'],
      )!,
      categorySnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_snapshot'],
      )!,
      audienceTypeSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience_type_snapshot'],
      )!,
      actionTypeSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type_snapshot'],
      )!,
      actionPayloadSnapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_payload_snapshot'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      targetProfileCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_profile_count'],
      )!,
      targetDeviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_device_count'],
      )!,
      successDeviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}success_device_count'],
      )!,
      failureDeviceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failure_device_count'],
      )!,
      invalidTokenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invalid_token_count'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      errorSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_summary'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $NotificationDispatchesTableTable createAlias(String alias) {
    return $NotificationDispatchesTableTable(attachedDatabase, alias);
  }
}

class LocalNotificationDispatch extends DataClass
    implements Insertable<LocalNotificationDispatch> {
  final String uuidNotificationDispatch;
  final String uuidNotificationEvent;
  final String triggerSource;
  final String? uuidTriggeredByProfile;
  final String? sourceEntityType;
  final String? sourceEntityUuid;
  final String idempotencyKey;
  final String titleSnapshot;
  final String bodySnapshot;
  final String categorySnapshot;
  final String audienceTypeSnapshot;
  final String actionTypeSnapshot;
  final String actionPayloadSnapshotJson;
  final String status;
  final int targetProfileCount;
  final int targetDeviceCount;
  final int successDeviceCount;
  final int failureDeviceCount;
  final int invalidTokenCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorSummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalNotificationDispatch({
    required this.uuidNotificationDispatch,
    required this.uuidNotificationEvent,
    required this.triggerSource,
    this.uuidTriggeredByProfile,
    this.sourceEntityType,
    this.sourceEntityUuid,
    required this.idempotencyKey,
    required this.titleSnapshot,
    required this.bodySnapshot,
    required this.categorySnapshot,
    required this.audienceTypeSnapshot,
    required this.actionTypeSnapshot,
    required this.actionPayloadSnapshotJson,
    required this.status,
    required this.targetProfileCount,
    required this.targetDeviceCount,
    required this.successDeviceCount,
    required this.failureDeviceCount,
    required this.invalidTokenCount,
    this.startedAt,
    this.completedAt,
    this.errorSummary,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_notification_dispatch'] = Variable<String>(
      uuidNotificationDispatch,
    );
    map['uuid_notification_event'] = Variable<String>(uuidNotificationEvent);
    map['trigger_source'] = Variable<String>(triggerSource);
    if (!nullToAbsent || uuidTriggeredByProfile != null) {
      map['uuid_triggered_by_profile'] = Variable<String>(
        uuidTriggeredByProfile,
      );
    }
    if (!nullToAbsent || sourceEntityType != null) {
      map['source_entity_type'] = Variable<String>(sourceEntityType);
    }
    if (!nullToAbsent || sourceEntityUuid != null) {
      map['source_entity_uuid'] = Variable<String>(sourceEntityUuid);
    }
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['title_snapshot'] = Variable<String>(titleSnapshot);
    map['body_snapshot'] = Variable<String>(bodySnapshot);
    map['category_snapshot'] = Variable<String>(categorySnapshot);
    map['audience_type_snapshot'] = Variable<String>(audienceTypeSnapshot);
    map['action_type_snapshot'] = Variable<String>(actionTypeSnapshot);
    map['action_payload_snapshot'] = Variable<String>(
      actionPayloadSnapshotJson,
    );
    map['status'] = Variable<String>(status);
    map['target_profile_count'] = Variable<int>(targetProfileCount);
    map['target_device_count'] = Variable<int>(targetDeviceCount);
    map['success_device_count'] = Variable<int>(successDeviceCount);
    map['failure_device_count'] = Variable<int>(failureDeviceCount);
    map['invalid_token_count'] = Variable<int>(invalidTokenCount);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || errorSummary != null) {
      map['error_summary'] = Variable<String>(errorSummary);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  NotificationDispatchesTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationDispatchesTableCompanion(
      uuidNotificationDispatch: Value(uuidNotificationDispatch),
      uuidNotificationEvent: Value(uuidNotificationEvent),
      triggerSource: Value(triggerSource),
      uuidTriggeredByProfile: uuidTriggeredByProfile == null && nullToAbsent
          ? const Value.absent()
          : Value(uuidTriggeredByProfile),
      sourceEntityType: sourceEntityType == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntityType),
      sourceEntityUuid: sourceEntityUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEntityUuid),
      idempotencyKey: Value(idempotencyKey),
      titleSnapshot: Value(titleSnapshot),
      bodySnapshot: Value(bodySnapshot),
      categorySnapshot: Value(categorySnapshot),
      audienceTypeSnapshot: Value(audienceTypeSnapshot),
      actionTypeSnapshot: Value(actionTypeSnapshot),
      actionPayloadSnapshotJson: Value(actionPayloadSnapshotJson),
      status: Value(status),
      targetProfileCount: Value(targetProfileCount),
      targetDeviceCount: Value(targetDeviceCount),
      successDeviceCount: Value(successDeviceCount),
      failureDeviceCount: Value(failureDeviceCount),
      invalidTokenCount: Value(invalidTokenCount),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      errorSummary: errorSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(errorSummary),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalNotificationDispatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotificationDispatch(
      uuidNotificationDispatch: serializer.fromJson<String>(
        json['uuidNotificationDispatch'],
      ),
      uuidNotificationEvent: serializer.fromJson<String>(
        json['uuidNotificationEvent'],
      ),
      triggerSource: serializer.fromJson<String>(json['triggerSource']),
      uuidTriggeredByProfile: serializer.fromJson<String?>(
        json['uuidTriggeredByProfile'],
      ),
      sourceEntityType: serializer.fromJson<String?>(json['sourceEntityType']),
      sourceEntityUuid: serializer.fromJson<String?>(json['sourceEntityUuid']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      titleSnapshot: serializer.fromJson<String>(json['titleSnapshot']),
      bodySnapshot: serializer.fromJson<String>(json['bodySnapshot']),
      categorySnapshot: serializer.fromJson<String>(json['categorySnapshot']),
      audienceTypeSnapshot: serializer.fromJson<String>(
        json['audienceTypeSnapshot'],
      ),
      actionTypeSnapshot: serializer.fromJson<String>(
        json['actionTypeSnapshot'],
      ),
      actionPayloadSnapshotJson: serializer.fromJson<String>(
        json['actionPayloadSnapshotJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      targetProfileCount: serializer.fromJson<int>(json['targetProfileCount']),
      targetDeviceCount: serializer.fromJson<int>(json['targetDeviceCount']),
      successDeviceCount: serializer.fromJson<int>(json['successDeviceCount']),
      failureDeviceCount: serializer.fromJson<int>(json['failureDeviceCount']),
      invalidTokenCount: serializer.fromJson<int>(json['invalidTokenCount']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      errorSummary: serializer.fromJson<String?>(json['errorSummary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidNotificationDispatch': serializer.toJson<String>(
        uuidNotificationDispatch,
      ),
      'uuidNotificationEvent': serializer.toJson<String>(uuidNotificationEvent),
      'triggerSource': serializer.toJson<String>(triggerSource),
      'uuidTriggeredByProfile': serializer.toJson<String?>(
        uuidTriggeredByProfile,
      ),
      'sourceEntityType': serializer.toJson<String?>(sourceEntityType),
      'sourceEntityUuid': serializer.toJson<String?>(sourceEntityUuid),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'titleSnapshot': serializer.toJson<String>(titleSnapshot),
      'bodySnapshot': serializer.toJson<String>(bodySnapshot),
      'categorySnapshot': serializer.toJson<String>(categorySnapshot),
      'audienceTypeSnapshot': serializer.toJson<String>(audienceTypeSnapshot),
      'actionTypeSnapshot': serializer.toJson<String>(actionTypeSnapshot),
      'actionPayloadSnapshotJson': serializer.toJson<String>(
        actionPayloadSnapshotJson,
      ),
      'status': serializer.toJson<String>(status),
      'targetProfileCount': serializer.toJson<int>(targetProfileCount),
      'targetDeviceCount': serializer.toJson<int>(targetDeviceCount),
      'successDeviceCount': serializer.toJson<int>(successDeviceCount),
      'failureDeviceCount': serializer.toJson<int>(failureDeviceCount),
      'invalidTokenCount': serializer.toJson<int>(invalidTokenCount),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'errorSummary': serializer.toJson<String?>(errorSummary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalNotificationDispatch copyWith({
    String? uuidNotificationDispatch,
    String? uuidNotificationEvent,
    String? triggerSource,
    Value<String?> uuidTriggeredByProfile = const Value.absent(),
    Value<String?> sourceEntityType = const Value.absent(),
    Value<String?> sourceEntityUuid = const Value.absent(),
    String? idempotencyKey,
    String? titleSnapshot,
    String? bodySnapshot,
    String? categorySnapshot,
    String? audienceTypeSnapshot,
    String? actionTypeSnapshot,
    String? actionPayloadSnapshotJson,
    String? status,
    int? targetProfileCount,
    int? targetDeviceCount,
    int? successDeviceCount,
    int? failureDeviceCount,
    int? invalidTokenCount,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> errorSummary = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalNotificationDispatch(
    uuidNotificationDispatch:
        uuidNotificationDispatch ?? this.uuidNotificationDispatch,
    uuidNotificationEvent: uuidNotificationEvent ?? this.uuidNotificationEvent,
    triggerSource: triggerSource ?? this.triggerSource,
    uuidTriggeredByProfile: uuidTriggeredByProfile.present
        ? uuidTriggeredByProfile.value
        : this.uuidTriggeredByProfile,
    sourceEntityType: sourceEntityType.present
        ? sourceEntityType.value
        : this.sourceEntityType,
    sourceEntityUuid: sourceEntityUuid.present
        ? sourceEntityUuid.value
        : this.sourceEntityUuid,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    titleSnapshot: titleSnapshot ?? this.titleSnapshot,
    bodySnapshot: bodySnapshot ?? this.bodySnapshot,
    categorySnapshot: categorySnapshot ?? this.categorySnapshot,
    audienceTypeSnapshot: audienceTypeSnapshot ?? this.audienceTypeSnapshot,
    actionTypeSnapshot: actionTypeSnapshot ?? this.actionTypeSnapshot,
    actionPayloadSnapshotJson:
        actionPayloadSnapshotJson ?? this.actionPayloadSnapshotJson,
    status: status ?? this.status,
    targetProfileCount: targetProfileCount ?? this.targetProfileCount,
    targetDeviceCount: targetDeviceCount ?? this.targetDeviceCount,
    successDeviceCount: successDeviceCount ?? this.successDeviceCount,
    failureDeviceCount: failureDeviceCount ?? this.failureDeviceCount,
    invalidTokenCount: invalidTokenCount ?? this.invalidTokenCount,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    errorSummary: errorSummary.present ? errorSummary.value : this.errorSummary,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalNotificationDispatch copyWithCompanion(
    NotificationDispatchesTableCompanion data,
  ) {
    return LocalNotificationDispatch(
      uuidNotificationDispatch: data.uuidNotificationDispatch.present
          ? data.uuidNotificationDispatch.value
          : this.uuidNotificationDispatch,
      uuidNotificationEvent: data.uuidNotificationEvent.present
          ? data.uuidNotificationEvent.value
          : this.uuidNotificationEvent,
      triggerSource: data.triggerSource.present
          ? data.triggerSource.value
          : this.triggerSource,
      uuidTriggeredByProfile: data.uuidTriggeredByProfile.present
          ? data.uuidTriggeredByProfile.value
          : this.uuidTriggeredByProfile,
      sourceEntityType: data.sourceEntityType.present
          ? data.sourceEntityType.value
          : this.sourceEntityType,
      sourceEntityUuid: data.sourceEntityUuid.present
          ? data.sourceEntityUuid.value
          : this.sourceEntityUuid,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      titleSnapshot: data.titleSnapshot.present
          ? data.titleSnapshot.value
          : this.titleSnapshot,
      bodySnapshot: data.bodySnapshot.present
          ? data.bodySnapshot.value
          : this.bodySnapshot,
      categorySnapshot: data.categorySnapshot.present
          ? data.categorySnapshot.value
          : this.categorySnapshot,
      audienceTypeSnapshot: data.audienceTypeSnapshot.present
          ? data.audienceTypeSnapshot.value
          : this.audienceTypeSnapshot,
      actionTypeSnapshot: data.actionTypeSnapshot.present
          ? data.actionTypeSnapshot.value
          : this.actionTypeSnapshot,
      actionPayloadSnapshotJson: data.actionPayloadSnapshotJson.present
          ? data.actionPayloadSnapshotJson.value
          : this.actionPayloadSnapshotJson,
      status: data.status.present ? data.status.value : this.status,
      targetProfileCount: data.targetProfileCount.present
          ? data.targetProfileCount.value
          : this.targetProfileCount,
      targetDeviceCount: data.targetDeviceCount.present
          ? data.targetDeviceCount.value
          : this.targetDeviceCount,
      successDeviceCount: data.successDeviceCount.present
          ? data.successDeviceCount.value
          : this.successDeviceCount,
      failureDeviceCount: data.failureDeviceCount.present
          ? data.failureDeviceCount.value
          : this.failureDeviceCount,
      invalidTokenCount: data.invalidTokenCount.present
          ? data.invalidTokenCount.value
          : this.invalidTokenCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      errorSummary: data.errorSummary.present
          ? data.errorSummary.value
          : this.errorSummary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationDispatch(')
          ..write('uuidNotificationDispatch: $uuidNotificationDispatch, ')
          ..write('uuidNotificationEvent: $uuidNotificationEvent, ')
          ..write('triggerSource: $triggerSource, ')
          ..write('uuidTriggeredByProfile: $uuidTriggeredByProfile, ')
          ..write('sourceEntityType: $sourceEntityType, ')
          ..write('sourceEntityUuid: $sourceEntityUuid, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('bodySnapshot: $bodySnapshot, ')
          ..write('categorySnapshot: $categorySnapshot, ')
          ..write('audienceTypeSnapshot: $audienceTypeSnapshot, ')
          ..write('actionTypeSnapshot: $actionTypeSnapshot, ')
          ..write('actionPayloadSnapshotJson: $actionPayloadSnapshotJson, ')
          ..write('status: $status, ')
          ..write('targetProfileCount: $targetProfileCount, ')
          ..write('targetDeviceCount: $targetDeviceCount, ')
          ..write('successDeviceCount: $successDeviceCount, ')
          ..write('failureDeviceCount: $failureDeviceCount, ')
          ..write('invalidTokenCount: $invalidTokenCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('errorSummary: $errorSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    uuidNotificationDispatch,
    uuidNotificationEvent,
    triggerSource,
    uuidTriggeredByProfile,
    sourceEntityType,
    sourceEntityUuid,
    idempotencyKey,
    titleSnapshot,
    bodySnapshot,
    categorySnapshot,
    audienceTypeSnapshot,
    actionTypeSnapshot,
    actionPayloadSnapshotJson,
    status,
    targetProfileCount,
    targetDeviceCount,
    successDeviceCount,
    failureDeviceCount,
    invalidTokenCount,
    startedAt,
    completedAt,
    errorSummary,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotificationDispatch &&
          other.uuidNotificationDispatch == this.uuidNotificationDispatch &&
          other.uuidNotificationEvent == this.uuidNotificationEvent &&
          other.triggerSource == this.triggerSource &&
          other.uuidTriggeredByProfile == this.uuidTriggeredByProfile &&
          other.sourceEntityType == this.sourceEntityType &&
          other.sourceEntityUuid == this.sourceEntityUuid &&
          other.idempotencyKey == this.idempotencyKey &&
          other.titleSnapshot == this.titleSnapshot &&
          other.bodySnapshot == this.bodySnapshot &&
          other.categorySnapshot == this.categorySnapshot &&
          other.audienceTypeSnapshot == this.audienceTypeSnapshot &&
          other.actionTypeSnapshot == this.actionTypeSnapshot &&
          other.actionPayloadSnapshotJson == this.actionPayloadSnapshotJson &&
          other.status == this.status &&
          other.targetProfileCount == this.targetProfileCount &&
          other.targetDeviceCount == this.targetDeviceCount &&
          other.successDeviceCount == this.successDeviceCount &&
          other.failureDeviceCount == this.failureDeviceCount &&
          other.invalidTokenCount == this.invalidTokenCount &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.errorSummary == this.errorSummary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class NotificationDispatchesTableCompanion
    extends UpdateCompanion<LocalNotificationDispatch> {
  final Value<String> uuidNotificationDispatch;
  final Value<String> uuidNotificationEvent;
  final Value<String> triggerSource;
  final Value<String?> uuidTriggeredByProfile;
  final Value<String?> sourceEntityType;
  final Value<String?> sourceEntityUuid;
  final Value<String> idempotencyKey;
  final Value<String> titleSnapshot;
  final Value<String> bodySnapshot;
  final Value<String> categorySnapshot;
  final Value<String> audienceTypeSnapshot;
  final Value<String> actionTypeSnapshot;
  final Value<String> actionPayloadSnapshotJson;
  final Value<String> status;
  final Value<int> targetProfileCount;
  final Value<int> targetDeviceCount;
  final Value<int> successDeviceCount;
  final Value<int> failureDeviceCount;
  final Value<int> invalidTokenCount;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> errorSummary;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const NotificationDispatchesTableCompanion({
    this.uuidNotificationDispatch = const Value.absent(),
    this.uuidNotificationEvent = const Value.absent(),
    this.triggerSource = const Value.absent(),
    this.uuidTriggeredByProfile = const Value.absent(),
    this.sourceEntityType = const Value.absent(),
    this.sourceEntityUuid = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.titleSnapshot = const Value.absent(),
    this.bodySnapshot = const Value.absent(),
    this.categorySnapshot = const Value.absent(),
    this.audienceTypeSnapshot = const Value.absent(),
    this.actionTypeSnapshot = const Value.absent(),
    this.actionPayloadSnapshotJson = const Value.absent(),
    this.status = const Value.absent(),
    this.targetProfileCount = const Value.absent(),
    this.targetDeviceCount = const Value.absent(),
    this.successDeviceCount = const Value.absent(),
    this.failureDeviceCount = const Value.absent(),
    this.invalidTokenCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationDispatchesTableCompanion.insert({
    required String uuidNotificationDispatch,
    required String uuidNotificationEvent,
    required String triggerSource,
    this.uuidTriggeredByProfile = const Value.absent(),
    this.sourceEntityType = const Value.absent(),
    this.sourceEntityUuid = const Value.absent(),
    required String idempotencyKey,
    required String titleSnapshot,
    required String bodySnapshot,
    required String categorySnapshot,
    required String audienceTypeSnapshot,
    required String actionTypeSnapshot,
    this.actionPayloadSnapshotJson = const Value.absent(),
    this.status = const Value.absent(),
    this.targetProfileCount = const Value.absent(),
    this.targetDeviceCount = const Value.absent(),
    this.successDeviceCount = const Value.absent(),
    this.failureDeviceCount = const Value.absent(),
    this.invalidTokenCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidNotificationDispatch = Value(uuidNotificationDispatch),
       uuidNotificationEvent = Value(uuidNotificationEvent),
       triggerSource = Value(triggerSource),
       idempotencyKey = Value(idempotencyKey),
       titleSnapshot = Value(titleSnapshot),
       bodySnapshot = Value(bodySnapshot),
       categorySnapshot = Value(categorySnapshot),
       audienceTypeSnapshot = Value(audienceTypeSnapshot),
       actionTypeSnapshot = Value(actionTypeSnapshot);
  static Insertable<LocalNotificationDispatch> custom({
    Expression<String>? uuidNotificationDispatch,
    Expression<String>? uuidNotificationEvent,
    Expression<String>? triggerSource,
    Expression<String>? uuidTriggeredByProfile,
    Expression<String>? sourceEntityType,
    Expression<String>? sourceEntityUuid,
    Expression<String>? idempotencyKey,
    Expression<String>? titleSnapshot,
    Expression<String>? bodySnapshot,
    Expression<String>? categorySnapshot,
    Expression<String>? audienceTypeSnapshot,
    Expression<String>? actionTypeSnapshot,
    Expression<String>? actionPayloadSnapshotJson,
    Expression<String>? status,
    Expression<int>? targetProfileCount,
    Expression<int>? targetDeviceCount,
    Expression<int>? successDeviceCount,
    Expression<int>? failureDeviceCount,
    Expression<int>? invalidTokenCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? errorSummary,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidNotificationDispatch != null)
        'uuid_notification_dispatch': uuidNotificationDispatch,
      if (uuidNotificationEvent != null)
        'uuid_notification_event': uuidNotificationEvent,
      if (triggerSource != null) 'trigger_source': triggerSource,
      if (uuidTriggeredByProfile != null)
        'uuid_triggered_by_profile': uuidTriggeredByProfile,
      if (sourceEntityType != null) 'source_entity_type': sourceEntityType,
      if (sourceEntityUuid != null) 'source_entity_uuid': sourceEntityUuid,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (titleSnapshot != null) 'title_snapshot': titleSnapshot,
      if (bodySnapshot != null) 'body_snapshot': bodySnapshot,
      if (categorySnapshot != null) 'category_snapshot': categorySnapshot,
      if (audienceTypeSnapshot != null)
        'audience_type_snapshot': audienceTypeSnapshot,
      if (actionTypeSnapshot != null)
        'action_type_snapshot': actionTypeSnapshot,
      if (actionPayloadSnapshotJson != null)
        'action_payload_snapshot': actionPayloadSnapshotJson,
      if (status != null) 'status': status,
      if (targetProfileCount != null)
        'target_profile_count': targetProfileCount,
      if (targetDeviceCount != null) 'target_device_count': targetDeviceCount,
      if (successDeviceCount != null)
        'success_device_count': successDeviceCount,
      if (failureDeviceCount != null)
        'failure_device_count': failureDeviceCount,
      if (invalidTokenCount != null) 'invalid_token_count': invalidTokenCount,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (errorSummary != null) 'error_summary': errorSummary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationDispatchesTableCompanion copyWith({
    Value<String>? uuidNotificationDispatch,
    Value<String>? uuidNotificationEvent,
    Value<String>? triggerSource,
    Value<String?>? uuidTriggeredByProfile,
    Value<String?>? sourceEntityType,
    Value<String?>? sourceEntityUuid,
    Value<String>? idempotencyKey,
    Value<String>? titleSnapshot,
    Value<String>? bodySnapshot,
    Value<String>? categorySnapshot,
    Value<String>? audienceTypeSnapshot,
    Value<String>? actionTypeSnapshot,
    Value<String>? actionPayloadSnapshotJson,
    Value<String>? status,
    Value<int>? targetProfileCount,
    Value<int>? targetDeviceCount,
    Value<int>? successDeviceCount,
    Value<int>? failureDeviceCount,
    Value<int>? invalidTokenCount,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? errorSummary,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return NotificationDispatchesTableCompanion(
      uuidNotificationDispatch:
          uuidNotificationDispatch ?? this.uuidNotificationDispatch,
      uuidNotificationEvent:
          uuidNotificationEvent ?? this.uuidNotificationEvent,
      triggerSource: triggerSource ?? this.triggerSource,
      uuidTriggeredByProfile:
          uuidTriggeredByProfile ?? this.uuidTriggeredByProfile,
      sourceEntityType: sourceEntityType ?? this.sourceEntityType,
      sourceEntityUuid: sourceEntityUuid ?? this.sourceEntityUuid,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      bodySnapshot: bodySnapshot ?? this.bodySnapshot,
      categorySnapshot: categorySnapshot ?? this.categorySnapshot,
      audienceTypeSnapshot: audienceTypeSnapshot ?? this.audienceTypeSnapshot,
      actionTypeSnapshot: actionTypeSnapshot ?? this.actionTypeSnapshot,
      actionPayloadSnapshotJson:
          actionPayloadSnapshotJson ?? this.actionPayloadSnapshotJson,
      status: status ?? this.status,
      targetProfileCount: targetProfileCount ?? this.targetProfileCount,
      targetDeviceCount: targetDeviceCount ?? this.targetDeviceCount,
      successDeviceCount: successDeviceCount ?? this.successDeviceCount,
      failureDeviceCount: failureDeviceCount ?? this.failureDeviceCount,
      invalidTokenCount: invalidTokenCount ?? this.invalidTokenCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorSummary: errorSummary ?? this.errorSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidNotificationDispatch.present) {
      map['uuid_notification_dispatch'] = Variable<String>(
        uuidNotificationDispatch.value,
      );
    }
    if (uuidNotificationEvent.present) {
      map['uuid_notification_event'] = Variable<String>(
        uuidNotificationEvent.value,
      );
    }
    if (triggerSource.present) {
      map['trigger_source'] = Variable<String>(triggerSource.value);
    }
    if (uuidTriggeredByProfile.present) {
      map['uuid_triggered_by_profile'] = Variable<String>(
        uuidTriggeredByProfile.value,
      );
    }
    if (sourceEntityType.present) {
      map['source_entity_type'] = Variable<String>(sourceEntityType.value);
    }
    if (sourceEntityUuid.present) {
      map['source_entity_uuid'] = Variable<String>(sourceEntityUuid.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (titleSnapshot.present) {
      map['title_snapshot'] = Variable<String>(titleSnapshot.value);
    }
    if (bodySnapshot.present) {
      map['body_snapshot'] = Variable<String>(bodySnapshot.value);
    }
    if (categorySnapshot.present) {
      map['category_snapshot'] = Variable<String>(categorySnapshot.value);
    }
    if (audienceTypeSnapshot.present) {
      map['audience_type_snapshot'] = Variable<String>(
        audienceTypeSnapshot.value,
      );
    }
    if (actionTypeSnapshot.present) {
      map['action_type_snapshot'] = Variable<String>(actionTypeSnapshot.value);
    }
    if (actionPayloadSnapshotJson.present) {
      map['action_payload_snapshot'] = Variable<String>(
        actionPayloadSnapshotJson.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (targetProfileCount.present) {
      map['target_profile_count'] = Variable<int>(targetProfileCount.value);
    }
    if (targetDeviceCount.present) {
      map['target_device_count'] = Variable<int>(targetDeviceCount.value);
    }
    if (successDeviceCount.present) {
      map['success_device_count'] = Variable<int>(successDeviceCount.value);
    }
    if (failureDeviceCount.present) {
      map['failure_device_count'] = Variable<int>(failureDeviceCount.value);
    }
    if (invalidTokenCount.present) {
      map['invalid_token_count'] = Variable<int>(invalidTokenCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (errorSummary.present) {
      map['error_summary'] = Variable<String>(errorSummary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationDispatchesTableCompanion(')
          ..write('uuidNotificationDispatch: $uuidNotificationDispatch, ')
          ..write('uuidNotificationEvent: $uuidNotificationEvent, ')
          ..write('triggerSource: $triggerSource, ')
          ..write('uuidTriggeredByProfile: $uuidTriggeredByProfile, ')
          ..write('sourceEntityType: $sourceEntityType, ')
          ..write('sourceEntityUuid: $sourceEntityUuid, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('titleSnapshot: $titleSnapshot, ')
          ..write('bodySnapshot: $bodySnapshot, ')
          ..write('categorySnapshot: $categorySnapshot, ')
          ..write('audienceTypeSnapshot: $audienceTypeSnapshot, ')
          ..write('actionTypeSnapshot: $actionTypeSnapshot, ')
          ..write('actionPayloadSnapshotJson: $actionPayloadSnapshotJson, ')
          ..write('status: $status, ')
          ..write('targetProfileCount: $targetProfileCount, ')
          ..write('targetDeviceCount: $targetDeviceCount, ')
          ..write('successDeviceCount: $successDeviceCount, ')
          ..write('failureDeviceCount: $failureDeviceCount, ')
          ..write('invalidTokenCount: $invalidTokenCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('errorSummary: $errorSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationsInboxTableTable extends NotificationsInboxTable
    with TableInfo<$NotificationsInboxTableTable, LocalNotificationInboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsInboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidNotificationInboxMeta =
      const VerificationMeta('uuidNotificationInbox');
  @override
  late final GeneratedColumn<String> uuidNotificationInbox =
      GeneratedColumn<String>(
        'uuid_notification_inbox',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidNotificationDispatchMeta =
      const VerificationMeta('uuidNotificationDispatch');
  @override
  late final GeneratedColumn<String> uuidNotificationDispatch =
      GeneratedColumn<String>(
        'uuid_notification_dispatch',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    check: () => category.isIn(notificationCategories),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    check: () => actionType.isIn(notificationActionTypes),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionPayloadJsonMeta = const VerificationMeta(
    'actionPayloadJson',
  );
  @override
  late final GeneratedColumn<String> actionPayloadJson =
      GeneratedColumn<String>(
        'action_payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidNotificationInbox,
    uuidNotificationDispatch,
    uuidProfile,
    title,
    body,
    category,
    actionType,
    actionPayloadJson,
    readAt,
    openedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_notifications_inbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNotificationInboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_notification_inbox')) {
      context.handle(
        _uuidNotificationInboxMeta,
        uuidNotificationInbox.isAcceptableOrUnknown(
          data['uuid_notification_inbox']!,
          _uuidNotificationInboxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationInboxMeta);
    }
    if (data.containsKey('uuid_notification_dispatch')) {
      context.handle(
        _uuidNotificationDispatchMeta,
        uuidNotificationDispatch.isAcceptableOrUnknown(
          data['uuid_notification_dispatch']!,
          _uuidNotificationDispatchMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidNotificationDispatchMeta);
    }
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('action_payload')) {
      context.handle(
        _actionPayloadJsonMeta,
        actionPayloadJson.isAcceptableOrUnknown(
          data['action_payload']!,
          _actionPayloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidNotificationInbox};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uuidNotificationDispatch, uuidProfile},
  ];
  @override
  LocalNotificationInboxItem map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNotificationInboxItem(
      uuidNotificationInbox: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_inbox'],
      )!,
      uuidNotificationDispatch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_notification_dispatch'],
      )!,
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      actionPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_payload'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $NotificationsInboxTableTable createAlias(String alias) {
    return $NotificationsInboxTableTable(attachedDatabase, alias);
  }
}

class LocalNotificationInboxItem extends DataClass
    implements Insertable<LocalNotificationInboxItem> {
  final String uuidNotificationInbox;
  final String uuidNotificationDispatch;
  final String uuidProfile;
  final String title;
  final String body;
  final String category;
  final String actionType;
  final String actionPayloadJson;
  final DateTime? readAt;
  final DateTime? openedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalNotificationInboxItem({
    required this.uuidNotificationInbox,
    required this.uuidNotificationDispatch,
    required this.uuidProfile,
    required this.title,
    required this.body,
    required this.category,
    required this.actionType,
    required this.actionPayloadJson,
    this.readAt,
    this.openedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_notification_inbox'] = Variable<String>(uuidNotificationInbox);
    map['uuid_notification_dispatch'] = Variable<String>(
      uuidNotificationDispatch,
    );
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['category'] = Variable<String>(category);
    map['action_type'] = Variable<String>(actionType);
    map['action_payload'] = Variable<String>(actionPayloadJson);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  NotificationsInboxTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationsInboxTableCompanion(
      uuidNotificationInbox: Value(uuidNotificationInbox),
      uuidNotificationDispatch: Value(uuidNotificationDispatch),
      uuidProfile: Value(uuidProfile),
      title: Value(title),
      body: Value(body),
      category: Value(category),
      actionType: Value(actionType),
      actionPayloadJson: Value(actionPayloadJson),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalNotificationInboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNotificationInboxItem(
      uuidNotificationInbox: serializer.fromJson<String>(
        json['uuidNotificationInbox'],
      ),
      uuidNotificationDispatch: serializer.fromJson<String>(
        json['uuidNotificationDispatch'],
      ),
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      category: serializer.fromJson<String>(json['category']),
      actionType: serializer.fromJson<String>(json['actionType']),
      actionPayloadJson: serializer.fromJson<String>(json['actionPayloadJson']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidNotificationInbox': serializer.toJson<String>(uuidNotificationInbox),
      'uuidNotificationDispatch': serializer.toJson<String>(
        uuidNotificationDispatch,
      ),
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'category': serializer.toJson<String>(category),
      'actionType': serializer.toJson<String>(actionType),
      'actionPayloadJson': serializer.toJson<String>(actionPayloadJson),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalNotificationInboxItem copyWith({
    String? uuidNotificationInbox,
    String? uuidNotificationDispatch,
    String? uuidProfile,
    String? title,
    String? body,
    String? category,
    String? actionType,
    String? actionPayloadJson,
    Value<DateTime?> readAt = const Value.absent(),
    Value<DateTime?> openedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalNotificationInboxItem(
    uuidNotificationInbox: uuidNotificationInbox ?? this.uuidNotificationInbox,
    uuidNotificationDispatch:
        uuidNotificationDispatch ?? this.uuidNotificationDispatch,
    uuidProfile: uuidProfile ?? this.uuidProfile,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    actionType: actionType ?? this.actionType,
    actionPayloadJson: actionPayloadJson ?? this.actionPayloadJson,
    readAt: readAt.present ? readAt.value : this.readAt,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalNotificationInboxItem copyWithCompanion(
    NotificationsInboxTableCompanion data,
  ) {
    return LocalNotificationInboxItem(
      uuidNotificationInbox: data.uuidNotificationInbox.present
          ? data.uuidNotificationInbox.value
          : this.uuidNotificationInbox,
      uuidNotificationDispatch: data.uuidNotificationDispatch.present
          ? data.uuidNotificationDispatch.value
          : this.uuidNotificationDispatch,
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      category: data.category.present ? data.category.value : this.category,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      actionPayloadJson: data.actionPayloadJson.present
          ? data.actionPayloadJson.value
          : this.actionPayloadJson,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNotificationInboxItem(')
          ..write('uuidNotificationInbox: $uuidNotificationInbox, ')
          ..write('uuidNotificationDispatch: $uuidNotificationDispatch, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadJson: $actionPayloadJson, ')
          ..write('readAt: $readAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidNotificationInbox,
    uuidNotificationDispatch,
    uuidProfile,
    title,
    body,
    category,
    actionType,
    actionPayloadJson,
    readAt,
    openedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNotificationInboxItem &&
          other.uuidNotificationInbox == this.uuidNotificationInbox &&
          other.uuidNotificationDispatch == this.uuidNotificationDispatch &&
          other.uuidProfile == this.uuidProfile &&
          other.title == this.title &&
          other.body == this.body &&
          other.category == this.category &&
          other.actionType == this.actionType &&
          other.actionPayloadJson == this.actionPayloadJson &&
          other.readAt == this.readAt &&
          other.openedAt == this.openedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class NotificationsInboxTableCompanion
    extends UpdateCompanion<LocalNotificationInboxItem> {
  final Value<String> uuidNotificationInbox;
  final Value<String> uuidNotificationDispatch;
  final Value<String> uuidProfile;
  final Value<String> title;
  final Value<String> body;
  final Value<String> category;
  final Value<String> actionType;
  final Value<String> actionPayloadJson;
  final Value<DateTime?> readAt;
  final Value<DateTime?> openedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const NotificationsInboxTableCompanion({
    this.uuidNotificationInbox = const Value.absent(),
    this.uuidNotificationDispatch = const Value.absent(),
    this.uuidProfile = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.category = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionPayloadJson = const Value.absent(),
    this.readAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsInboxTableCompanion.insert({
    required String uuidNotificationInbox,
    required String uuidNotificationDispatch,
    required String uuidProfile,
    required String title,
    required String body,
    required String category,
    required String actionType,
    this.actionPayloadJson = const Value.absent(),
    this.readAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidNotificationInbox = Value(uuidNotificationInbox),
       uuidNotificationDispatch = Value(uuidNotificationDispatch),
       uuidProfile = Value(uuidProfile),
       title = Value(title),
       body = Value(body),
       category = Value(category),
       actionType = Value(actionType);
  static Insertable<LocalNotificationInboxItem> custom({
    Expression<String>? uuidNotificationInbox,
    Expression<String>? uuidNotificationDispatch,
    Expression<String>? uuidProfile,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? category,
    Expression<String>? actionType,
    Expression<String>? actionPayloadJson,
    Expression<DateTime>? readAt,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidNotificationInbox != null)
        'uuid_notification_inbox': uuidNotificationInbox,
      if (uuidNotificationDispatch != null)
        'uuid_notification_dispatch': uuidNotificationDispatch,
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (category != null) 'category': category,
      if (actionType != null) 'action_type': actionType,
      if (actionPayloadJson != null) 'action_payload': actionPayloadJson,
      if (readAt != null) 'read_at': readAt,
      if (openedAt != null) 'opened_at': openedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsInboxTableCompanion copyWith({
    Value<String>? uuidNotificationInbox,
    Value<String>? uuidNotificationDispatch,
    Value<String>? uuidProfile,
    Value<String>? title,
    Value<String>? body,
    Value<String>? category,
    Value<String>? actionType,
    Value<String>? actionPayloadJson,
    Value<DateTime?>? readAt,
    Value<DateTime?>? openedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return NotificationsInboxTableCompanion(
      uuidNotificationInbox:
          uuidNotificationInbox ?? this.uuidNotificationInbox,
      uuidNotificationDispatch:
          uuidNotificationDispatch ?? this.uuidNotificationDispatch,
      uuidProfile: uuidProfile ?? this.uuidProfile,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      actionType: actionType ?? this.actionType,
      actionPayloadJson: actionPayloadJson ?? this.actionPayloadJson,
      readAt: readAt ?? this.readAt,
      openedAt: openedAt ?? this.openedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidNotificationInbox.present) {
      map['uuid_notification_inbox'] = Variable<String>(
        uuidNotificationInbox.value,
      );
    }
    if (uuidNotificationDispatch.present) {
      map['uuid_notification_dispatch'] = Variable<String>(
        uuidNotificationDispatch.value,
      );
    }
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionPayloadJson.present) {
      map['action_payload'] = Variable<String>(actionPayloadJson.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsInboxTableCompanion(')
          ..write('uuidNotificationInbox: $uuidNotificationInbox, ')
          ..write('uuidNotificationDispatch: $uuidNotificationDispatch, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('actionType: $actionType, ')
          ..write('actionPayloadJson: $actionPayloadJson, ')
          ..write('readAt: $readAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserContentStatesTableTable extends UserContentStatesTable
    with TableInfo<$UserContentStatesTableTable, LocalUserContentState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserContentStatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidUserContentStateMeta =
      const VerificationMeta('uuidUserContentState');
  @override
  late final GeneratedColumn<String> uuidUserContentState =
      GeneratedColumn<String>(
        'uuid_user_content_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidContentItemMeta = const VerificationMeta(
    'uuidContentItem',
  );
  @override
  late final GeneratedColumn<String> uuidContentItem = GeneratedColumn<String>(
    'uuid_content_item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoritoMeta = const VerificationMeta(
    'favorito',
  );
  @override
  late final GeneratedColumn<bool> favorito = GeneratedColumn<bool>(
    'favorito',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorito" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _progresoPorcentajeMeta =
      const VerificationMeta('progresoPorcentaje');
  @override
  late final GeneratedColumn<int> progresoPorcentaje = GeneratedColumn<int>(
    'progreso_porcentaje',
    aliasedName,
    false,
    check: () => ComparableExpr(progresoPorcentaje).isBetweenValues(0, 100),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ultimaPosicionSegundosMeta =
      const VerificationMeta('ultimaPosicionSegundos');
  @override
  late final GeneratedColumn<int> ultimaPosicionSegundos = GeneratedColumn<int>(
    'ultima_posicion_segundos',
    aliasedName,
    false,
    check: () => ComparableExpr(ultimaPosicionSegundos).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completadoMeta = const VerificationMeta(
    'completado',
  );
  @override
  late final GeneratedColumn<bool> completado = GeneratedColumn<bool>(
    'completado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidUserContentState,
    uuidProfile,
    uuidContentItem,
    favorito,
    progresoPorcentaje,
    ultimaPosicionSegundos,
    completado,
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_content_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserContentState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_user_content_state')) {
      context.handle(
        _uuidUserContentStateMeta,
        uuidUserContentState.isAcceptableOrUnknown(
          data['uuid_user_content_state']!,
          _uuidUserContentStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidUserContentStateMeta);
    }
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('uuid_content_item')) {
      context.handle(
        _uuidContentItemMeta,
        uuidContentItem.isAcceptableOrUnknown(
          data['uuid_content_item']!,
          _uuidContentItemMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidContentItemMeta);
    }
    if (data.containsKey('favorito')) {
      context.handle(
        _favoritoMeta,
        favorito.isAcceptableOrUnknown(data['favorito']!, _favoritoMeta),
      );
    }
    if (data.containsKey('progreso_porcentaje')) {
      context.handle(
        _progresoPorcentajeMeta,
        progresoPorcentaje.isAcceptableOrUnknown(
          data['progreso_porcentaje']!,
          _progresoPorcentajeMeta,
        ),
      );
    }
    if (data.containsKey('ultima_posicion_segundos')) {
      context.handle(
        _ultimaPosicionSegundosMeta,
        ultimaPosicionSegundos.isAcceptableOrUnknown(
          data['ultima_posicion_segundos']!,
          _ultimaPosicionSegundosMeta,
        ),
      );
    }
    if (data.containsKey('completado')) {
      context.handle(
        _completadoMeta,
        completado.isAcceptableOrUnknown(data['completado']!, _completadoMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidUserContentState};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uuidProfile, uuidContentItem},
  ];
  @override
  LocalUserContentState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserContentState(
      uuidUserContentState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_user_content_state'],
      )!,
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      uuidContentItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_content_item'],
      )!,
      favorito: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorito'],
      )!,
      progresoPorcentaje: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progreso_porcentaje'],
      )!,
      ultimaPosicionSegundos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ultima_posicion_segundos'],
      )!,
      completado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completado'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $UserContentStatesTableTable createAlias(String alias) {
    return $UserContentStatesTableTable(attachedDatabase, alias);
  }
}

class LocalUserContentState extends DataClass
    implements Insertable<LocalUserContentState> {
  final String uuidUserContentState;
  final String uuidProfile;
  final String uuidContentItem;
  final bool favorito;
  final int progresoPorcentaje;
  final int ultimaPosicionSegundos;
  final bool completado;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalUserContentState({
    required this.uuidUserContentState,
    required this.uuidProfile,
    required this.uuidContentItem,
    required this.favorito,
    required this.progresoPorcentaje,
    required this.ultimaPosicionSegundos,
    required this.completado,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_user_content_state'] = Variable<String>(uuidUserContentState);
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['uuid_content_item'] = Variable<String>(uuidContentItem);
    map['favorito'] = Variable<bool>(favorito);
    map['progreso_porcentaje'] = Variable<int>(progresoPorcentaje);
    map['ultima_posicion_segundos'] = Variable<int>(ultimaPosicionSegundos);
    map['completado'] = Variable<bool>(completado);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  UserContentStatesTableCompanion toCompanion(bool nullToAbsent) {
    return UserContentStatesTableCompanion(
      uuidUserContentState: Value(uuidUserContentState),
      uuidProfile: Value(uuidProfile),
      uuidContentItem: Value(uuidContentItem),
      favorito: Value(favorito),
      progresoPorcentaje: Value(progresoPorcentaje),
      ultimaPosicionSegundos: Value(ultimaPosicionSegundos),
      completado: Value(completado),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalUserContentState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserContentState(
      uuidUserContentState: serializer.fromJson<String>(
        json['uuidUserContentState'],
      ),
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      uuidContentItem: serializer.fromJson<String>(json['uuidContentItem']),
      favorito: serializer.fromJson<bool>(json['favorito']),
      progresoPorcentaje: serializer.fromJson<int>(json['progresoPorcentaje']),
      ultimaPosicionSegundos: serializer.fromJson<int>(
        json['ultimaPosicionSegundos'],
      ),
      completado: serializer.fromJson<bool>(json['completado']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidUserContentState': serializer.toJson<String>(uuidUserContentState),
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'uuidContentItem': serializer.toJson<String>(uuidContentItem),
      'favorito': serializer.toJson<bool>(favorito),
      'progresoPorcentaje': serializer.toJson<int>(progresoPorcentaje),
      'ultimaPosicionSegundos': serializer.toJson<int>(ultimaPosicionSegundos),
      'completado': serializer.toJson<bool>(completado),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalUserContentState copyWith({
    String? uuidUserContentState,
    String? uuidProfile,
    String? uuidContentItem,
    bool? favorito,
    int? progresoPorcentaje,
    int? ultimaPosicionSegundos,
    bool? completado,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalUserContentState(
    uuidUserContentState: uuidUserContentState ?? this.uuidUserContentState,
    uuidProfile: uuidProfile ?? this.uuidProfile,
    uuidContentItem: uuidContentItem ?? this.uuidContentItem,
    favorito: favorito ?? this.favorito,
    progresoPorcentaje: progresoPorcentaje ?? this.progresoPorcentaje,
    ultimaPosicionSegundos:
        ultimaPosicionSegundos ?? this.ultimaPosicionSegundos,
    completado: completado ?? this.completado,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalUserContentState copyWithCompanion(
    UserContentStatesTableCompanion data,
  ) {
    return LocalUserContentState(
      uuidUserContentState: data.uuidUserContentState.present
          ? data.uuidUserContentState.value
          : this.uuidUserContentState,
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      uuidContentItem: data.uuidContentItem.present
          ? data.uuidContentItem.value
          : this.uuidContentItem,
      favorito: data.favorito.present ? data.favorito.value : this.favorito,
      progresoPorcentaje: data.progresoPorcentaje.present
          ? data.progresoPorcentaje.value
          : this.progresoPorcentaje,
      ultimaPosicionSegundos: data.ultimaPosicionSegundos.present
          ? data.ultimaPosicionSegundos.value
          : this.ultimaPosicionSegundos,
      completado: data.completado.present
          ? data.completado.value
          : this.completado,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserContentState(')
          ..write('uuidUserContentState: $uuidUserContentState, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('favorito: $favorito, ')
          ..write('progresoPorcentaje: $progresoPorcentaje, ')
          ..write('ultimaPosicionSegundos: $ultimaPosicionSegundos, ')
          ..write('completado: $completado, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidUserContentState,
    uuidProfile,
    uuidContentItem,
    favorito,
    progresoPorcentaje,
    ultimaPosicionSegundos,
    completado,
    startedAt,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserContentState &&
          other.uuidUserContentState == this.uuidUserContentState &&
          other.uuidProfile == this.uuidProfile &&
          other.uuidContentItem == this.uuidContentItem &&
          other.favorito == this.favorito &&
          other.progresoPorcentaje == this.progresoPorcentaje &&
          other.ultimaPosicionSegundos == this.ultimaPosicionSegundos &&
          other.completado == this.completado &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class UserContentStatesTableCompanion
    extends UpdateCompanion<LocalUserContentState> {
  final Value<String> uuidUserContentState;
  final Value<String> uuidProfile;
  final Value<String> uuidContentItem;
  final Value<bool> favorito;
  final Value<int> progresoPorcentaje;
  final Value<int> ultimaPosicionSegundos;
  final Value<bool> completado;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const UserContentStatesTableCompanion({
    this.uuidUserContentState = const Value.absent(),
    this.uuidProfile = const Value.absent(),
    this.uuidContentItem = const Value.absent(),
    this.favorito = const Value.absent(),
    this.progresoPorcentaje = const Value.absent(),
    this.ultimaPosicionSegundos = const Value.absent(),
    this.completado = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserContentStatesTableCompanion.insert({
    required String uuidUserContentState,
    required String uuidProfile,
    required String uuidContentItem,
    this.favorito = const Value.absent(),
    this.progresoPorcentaje = const Value.absent(),
    this.ultimaPosicionSegundos = const Value.absent(),
    this.completado = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidUserContentState = Value(uuidUserContentState),
       uuidProfile = Value(uuidProfile),
       uuidContentItem = Value(uuidContentItem);
  static Insertable<LocalUserContentState> custom({
    Expression<String>? uuidUserContentState,
    Expression<String>? uuidProfile,
    Expression<String>? uuidContentItem,
    Expression<bool>? favorito,
    Expression<int>? progresoPorcentaje,
    Expression<int>? ultimaPosicionSegundos,
    Expression<bool>? completado,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidUserContentState != null)
        'uuid_user_content_state': uuidUserContentState,
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (uuidContentItem != null) 'uuid_content_item': uuidContentItem,
      if (favorito != null) 'favorito': favorito,
      if (progresoPorcentaje != null) 'progreso_porcentaje': progresoPorcentaje,
      if (ultimaPosicionSegundos != null)
        'ultima_posicion_segundos': ultimaPosicionSegundos,
      if (completado != null) 'completado': completado,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserContentStatesTableCompanion copyWith({
    Value<String>? uuidUserContentState,
    Value<String>? uuidProfile,
    Value<String>? uuidContentItem,
    Value<bool>? favorito,
    Value<int>? progresoPorcentaje,
    Value<int>? ultimaPosicionSegundos,
    Value<bool>? completado,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return UserContentStatesTableCompanion(
      uuidUserContentState: uuidUserContentState ?? this.uuidUserContentState,
      uuidProfile: uuidProfile ?? this.uuidProfile,
      uuidContentItem: uuidContentItem ?? this.uuidContentItem,
      favorito: favorito ?? this.favorito,
      progresoPorcentaje: progresoPorcentaje ?? this.progresoPorcentaje,
      ultimaPosicionSegundos:
          ultimaPosicionSegundos ?? this.ultimaPosicionSegundos,
      completado: completado ?? this.completado,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidUserContentState.present) {
      map['uuid_user_content_state'] = Variable<String>(
        uuidUserContentState.value,
      );
    }
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (uuidContentItem.present) {
      map['uuid_content_item'] = Variable<String>(uuidContentItem.value);
    }
    if (favorito.present) {
      map['favorito'] = Variable<bool>(favorito.value);
    }
    if (progresoPorcentaje.present) {
      map['progreso_porcentaje'] = Variable<int>(progresoPorcentaje.value);
    }
    if (ultimaPosicionSegundos.present) {
      map['ultima_posicion_segundos'] = Variable<int>(
        ultimaPosicionSegundos.value,
      );
    }
    if (completado.present) {
      map['completado'] = Variable<bool>(completado.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserContentStatesTableCompanion(')
          ..write('uuidUserContentState: $uuidUserContentState, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('uuidContentItem: $uuidContentItem, ')
          ..write('favorito: $favorito, ')
          ..write('progresoPorcentaje: $progresoPorcentaje, ')
          ..write('ultimaPosicionSegundos: $ultimaPosicionSegundos, ')
          ..write('completado: $completado, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellnessDailyLogsTableTable extends WellnessDailyLogsTable
    with TableInfo<$WellnessDailyLogsTableTable, LocalWellnessDailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellnessDailyLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidDailyLogMeta = const VerificationMeta(
    'uuidDailyLog',
  );
  @override
  late final GeneratedColumn<String> uuidDailyLog = GeneratedColumn<String>(
    'uuid_daily_log',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energiaMeta = const VerificationMeta(
    'energia',
  );
  @override
  late final GeneratedColumn<int> energia = GeneratedColumn<int>(
    'energia',
    aliasedName,
    false,
    check: () => ComparableExpr(energia).isBetweenValues(0, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calmaMeta = const VerificationMeta('calma');
  @override
  late final GeneratedColumn<int> calma = GeneratedColumn<int>(
    'calma',
    aliasedName,
    false,
    check: () => ComparableExpr(calma).isBetweenValues(0, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descansoMeta = const VerificationMeta(
    'descanso',
  );
  @override
  late final GeneratedColumn<int> descanso = GeneratedColumn<int>(
    'descanso',
    aliasedName,
    false,
    check: () => ComparableExpr(descanso).isBetweenValues(0, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conexionMeta = const VerificationMeta(
    'conexion',
  );
  @override
  late final GeneratedColumn<int> conexion = GeneratedColumn<int>(
    'conexion',
    aliasedName,
    false,
    check: () => ComparableExpr(conexion).isBetweenValues(0, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _meditacionCompletadaMeta =
      const VerificationMeta('meditacionCompletada');
  @override
  late final GeneratedColumn<bool> meditacionCompletada = GeneratedColumn<bool>(
    'meditacion_completada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("meditacion_completada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _minutosBienestarMeta = const VerificationMeta(
    'minutosBienestar',
  );
  @override
  late final GeneratedColumn<int> minutosBienestar = GeneratedColumn<int>(
    'minutos_bienestar',
    aliasedName,
    false,
    check: () => ComparableExpr(minutosBienestar).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidDailyLog,
    uuidProfile,
    fecha,
    mood,
    energia,
    calma,
    descanso,
    conexion,
    meditacionCompletada,
    minutosBienestar,
    nota,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_wellness_daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWellnessDailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_daily_log')) {
      context.handle(
        _uuidDailyLogMeta,
        uuidDailyLog.isAcceptableOrUnknown(
          data['uuid_daily_log']!,
          _uuidDailyLogMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidDailyLogMeta);
    }
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('energia')) {
      context.handle(
        _energiaMeta,
        energia.isAcceptableOrUnknown(data['energia']!, _energiaMeta),
      );
    }
    if (data.containsKey('calma')) {
      context.handle(
        _calmaMeta,
        calma.isAcceptableOrUnknown(data['calma']!, _calmaMeta),
      );
    }
    if (data.containsKey('descanso')) {
      context.handle(
        _descansoMeta,
        descanso.isAcceptableOrUnknown(data['descanso']!, _descansoMeta),
      );
    }
    if (data.containsKey('conexion')) {
      context.handle(
        _conexionMeta,
        conexion.isAcceptableOrUnknown(data['conexion']!, _conexionMeta),
      );
    }
    if (data.containsKey('meditacion_completada')) {
      context.handle(
        _meditacionCompletadaMeta,
        meditacionCompletada.isAcceptableOrUnknown(
          data['meditacion_completada']!,
          _meditacionCompletadaMeta,
        ),
      );
    }
    if (data.containsKey('minutos_bienestar')) {
      context.handle(
        _minutosBienestarMeta,
        minutosBienestar.isAcceptableOrUnknown(
          data['minutos_bienestar']!,
          _minutosBienestarMeta,
        ),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidDailyLog};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {uuidProfile, fecha},
  ];
  @override
  LocalWellnessDailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWellnessDailyLog(
      uuidDailyLog: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_daily_log'],
      )!,
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      energia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energia'],
      )!,
      calma: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calma'],
      )!,
      descanso: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}descanso'],
      )!,
      conexion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conexion'],
      )!,
      meditacionCompletada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}meditacion_completada'],
      )!,
      minutosBienestar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutos_bienestar'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $WellnessDailyLogsTableTable createAlias(String alias) {
    return $WellnessDailyLogsTableTable(attachedDatabase, alias);
  }
}

class LocalWellnessDailyLog extends DataClass
    implements Insertable<LocalWellnessDailyLog> {
  final String uuidDailyLog;
  final String uuidProfile;
  final String fecha;
  final String? mood;
  final int energia;
  final int calma;
  final int descanso;
  final int conexion;
  final bool meditacionCompletada;
  final int minutosBienestar;
  final String? nota;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? syncedAt;
  const LocalWellnessDailyLog({
    required this.uuidDailyLog,
    required this.uuidProfile,
    required this.fecha,
    this.mood,
    required this.energia,
    required this.calma,
    required this.descanso,
    required this.conexion,
    required this.meditacionCompletada,
    required this.minutosBienestar,
    this.nota,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_daily_log'] = Variable<String>(uuidDailyLog);
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['fecha'] = Variable<String>(fecha);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['energia'] = Variable<int>(energia);
    map['calma'] = Variable<int>(calma);
    map['descanso'] = Variable<int>(descanso);
    map['conexion'] = Variable<int>(conexion);
    map['meditacion_completada'] = Variable<bool>(meditacionCompletada);
    map['minutos_bienestar'] = Variable<int>(minutosBienestar);
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  WellnessDailyLogsTableCompanion toCompanion(bool nullToAbsent) {
    return WellnessDailyLogsTableCompanion(
      uuidDailyLog: Value(uuidDailyLog),
      uuidProfile: Value(uuidProfile),
      fecha: Value(fecha),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      energia: Value(energia),
      calma: Value(calma),
      descanso: Value(descanso),
      conexion: Value(conexion),
      meditacionCompletada: Value(meditacionCompletada),
      minutosBienestar: Value(minutosBienestar),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalWellnessDailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWellnessDailyLog(
      uuidDailyLog: serializer.fromJson<String>(json['uuidDailyLog']),
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      fecha: serializer.fromJson<String>(json['fecha']),
      mood: serializer.fromJson<String?>(json['mood']),
      energia: serializer.fromJson<int>(json['energia']),
      calma: serializer.fromJson<int>(json['calma']),
      descanso: serializer.fromJson<int>(json['descanso']),
      conexion: serializer.fromJson<int>(json['conexion']),
      meditacionCompletada: serializer.fromJson<bool>(
        json['meditacionCompletada'],
      ),
      minutosBienestar: serializer.fromJson<int>(json['minutosBienestar']),
      nota: serializer.fromJson<String?>(json['nota']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidDailyLog': serializer.toJson<String>(uuidDailyLog),
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'fecha': serializer.toJson<String>(fecha),
      'mood': serializer.toJson<String?>(mood),
      'energia': serializer.toJson<int>(energia),
      'calma': serializer.toJson<int>(calma),
      'descanso': serializer.toJson<int>(descanso),
      'conexion': serializer.toJson<int>(conexion),
      'meditacionCompletada': serializer.toJson<bool>(meditacionCompletada),
      'minutosBienestar': serializer.toJson<int>(minutosBienestar),
      'nota': serializer.toJson<String?>(nota),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalWellnessDailyLog copyWith({
    String? uuidDailyLog,
    String? uuidProfile,
    String? fecha,
    Value<String?> mood = const Value.absent(),
    int? energia,
    int? calma,
    int? descanso,
    int? conexion,
    bool? meditacionCompletada,
    int? minutosBienestar,
    Value<String?> nota = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalWellnessDailyLog(
    uuidDailyLog: uuidDailyLog ?? this.uuidDailyLog,
    uuidProfile: uuidProfile ?? this.uuidProfile,
    fecha: fecha ?? this.fecha,
    mood: mood.present ? mood.value : this.mood,
    energia: energia ?? this.energia,
    calma: calma ?? this.calma,
    descanso: descanso ?? this.descanso,
    conexion: conexion ?? this.conexion,
    meditacionCompletada: meditacionCompletada ?? this.meditacionCompletada,
    minutosBienestar: minutosBienestar ?? this.minutosBienestar,
    nota: nota.present ? nota.value : this.nota,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalWellnessDailyLog copyWithCompanion(
    WellnessDailyLogsTableCompanion data,
  ) {
    return LocalWellnessDailyLog(
      uuidDailyLog: data.uuidDailyLog.present
          ? data.uuidDailyLog.value
          : this.uuidDailyLog,
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      mood: data.mood.present ? data.mood.value : this.mood,
      energia: data.energia.present ? data.energia.value : this.energia,
      calma: data.calma.present ? data.calma.value : this.calma,
      descanso: data.descanso.present ? data.descanso.value : this.descanso,
      conexion: data.conexion.present ? data.conexion.value : this.conexion,
      meditacionCompletada: data.meditacionCompletada.present
          ? data.meditacionCompletada.value
          : this.meditacionCompletada,
      minutosBienestar: data.minutosBienestar.present
          ? data.minutosBienestar.value
          : this.minutosBienestar,
      nota: data.nota.present ? data.nota.value : this.nota,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWellnessDailyLog(')
          ..write('uuidDailyLog: $uuidDailyLog, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('fecha: $fecha, ')
          ..write('mood: $mood, ')
          ..write('energia: $energia, ')
          ..write('calma: $calma, ')
          ..write('descanso: $descanso, ')
          ..write('conexion: $conexion, ')
          ..write('meditacionCompletada: $meditacionCompletada, ')
          ..write('minutosBienestar: $minutosBienestar, ')
          ..write('nota: $nota, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidDailyLog,
    uuidProfile,
    fecha,
    mood,
    energia,
    calma,
    descanso,
    conexion,
    meditacionCompletada,
    minutosBienestar,
    nota,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWellnessDailyLog &&
          other.uuidDailyLog == this.uuidDailyLog &&
          other.uuidProfile == this.uuidProfile &&
          other.fecha == this.fecha &&
          other.mood == this.mood &&
          other.energia == this.energia &&
          other.calma == this.calma &&
          other.descanso == this.descanso &&
          other.conexion == this.conexion &&
          other.meditacionCompletada == this.meditacionCompletada &&
          other.minutosBienestar == this.minutosBienestar &&
          other.nota == this.nota &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class WellnessDailyLogsTableCompanion
    extends UpdateCompanion<LocalWellnessDailyLog> {
  final Value<String> uuidDailyLog;
  final Value<String> uuidProfile;
  final Value<String> fecha;
  final Value<String?> mood;
  final Value<int> energia;
  final Value<int> calma;
  final Value<int> descanso;
  final Value<int> conexion;
  final Value<bool> meditacionCompletada;
  final Value<int> minutosBienestar;
  final Value<String?> nota;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const WellnessDailyLogsTableCompanion({
    this.uuidDailyLog = const Value.absent(),
    this.uuidProfile = const Value.absent(),
    this.fecha = const Value.absent(),
    this.mood = const Value.absent(),
    this.energia = const Value.absent(),
    this.calma = const Value.absent(),
    this.descanso = const Value.absent(),
    this.conexion = const Value.absent(),
    this.meditacionCompletada = const Value.absent(),
    this.minutosBienestar = const Value.absent(),
    this.nota = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellnessDailyLogsTableCompanion.insert({
    required String uuidDailyLog,
    required String uuidProfile,
    required String fecha,
    this.mood = const Value.absent(),
    this.energia = const Value.absent(),
    this.calma = const Value.absent(),
    this.descanso = const Value.absent(),
    this.conexion = const Value.absent(),
    this.meditacionCompletada = const Value.absent(),
    this.minutosBienestar = const Value.absent(),
    this.nota = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidDailyLog = Value(uuidDailyLog),
       uuidProfile = Value(uuidProfile),
       fecha = Value(fecha);
  static Insertable<LocalWellnessDailyLog> custom({
    Expression<String>? uuidDailyLog,
    Expression<String>? uuidProfile,
    Expression<String>? fecha,
    Expression<String>? mood,
    Expression<int>? energia,
    Expression<int>? calma,
    Expression<int>? descanso,
    Expression<int>? conexion,
    Expression<bool>? meditacionCompletada,
    Expression<int>? minutosBienestar,
    Expression<String>? nota,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidDailyLog != null) 'uuid_daily_log': uuidDailyLog,
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (fecha != null) 'fecha': fecha,
      if (mood != null) 'mood': mood,
      if (energia != null) 'energia': energia,
      if (calma != null) 'calma': calma,
      if (descanso != null) 'descanso': descanso,
      if (conexion != null) 'conexion': conexion,
      if (meditacionCompletada != null)
        'meditacion_completada': meditacionCompletada,
      if (minutosBienestar != null) 'minutos_bienestar': minutosBienestar,
      if (nota != null) 'nota': nota,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellnessDailyLogsTableCompanion copyWith({
    Value<String>? uuidDailyLog,
    Value<String>? uuidProfile,
    Value<String>? fecha,
    Value<String?>? mood,
    Value<int>? energia,
    Value<int>? calma,
    Value<int>? descanso,
    Value<int>? conexion,
    Value<bool>? meditacionCompletada,
    Value<int>? minutosBienestar,
    Value<String?>? nota,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return WellnessDailyLogsTableCompanion(
      uuidDailyLog: uuidDailyLog ?? this.uuidDailyLog,
      uuidProfile: uuidProfile ?? this.uuidProfile,
      fecha: fecha ?? this.fecha,
      mood: mood ?? this.mood,
      energia: energia ?? this.energia,
      calma: calma ?? this.calma,
      descanso: descanso ?? this.descanso,
      conexion: conexion ?? this.conexion,
      meditacionCompletada: meditacionCompletada ?? this.meditacionCompletada,
      minutosBienestar: minutosBienestar ?? this.minutosBienestar,
      nota: nota ?? this.nota,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidDailyLog.present) {
      map['uuid_daily_log'] = Variable<String>(uuidDailyLog.value);
    }
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (energia.present) {
      map['energia'] = Variable<int>(energia.value);
    }
    if (calma.present) {
      map['calma'] = Variable<int>(calma.value);
    }
    if (descanso.present) {
      map['descanso'] = Variable<int>(descanso.value);
    }
    if (conexion.present) {
      map['conexion'] = Variable<int>(conexion.value);
    }
    if (meditacionCompletada.present) {
      map['meditacion_completada'] = Variable<bool>(meditacionCompletada.value);
    }
    if (minutosBienestar.present) {
      map['minutos_bienestar'] = Variable<int>(minutosBienestar.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellnessDailyLogsTableCompanion(')
          ..write('uuidDailyLog: $uuidDailyLog, ')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('fecha: $fecha, ')
          ..write('mood: $mood, ')
          ..write('energia: $energia, ')
          ..write('calma: $calma, ')
          ..write('descanso: $descanso, ')
          ..write('conexion: $conexion, ')
          ..write('meditacionCompletada: $meditacionCompletada, ')
          ..write('minutosBienestar: $minutosBienestar, ')
          ..write('nota: $nota, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WellnessProfileStatsTableTable extends WellnessProfileStatsTable
    with TableInfo<$WellnessProfileStatsTableTable, LocalWellnessProfileStats> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WellnessProfileStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidProfileMeta = const VerificationMeta(
    'uuidProfile',
  );
  @override
  late final GeneratedColumn<String> uuidProfile = GeneratedColumn<String>(
    'uuid_profile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    check: () => ComparableExpr(currentStreak).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    check: () => ComparableExpr(longestStreak).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActivityDateMeta = const VerificationMeta(
    'lastActivityDate',
  );
  @override
  late final GeneratedColumn<String> lastActivityDate = GeneratedColumn<String>(
    'last_activity_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalActiveDaysMeta = const VerificationMeta(
    'totalActiveDays',
  );
  @override
  late final GeneratedColumn<int> totalActiveDays = GeneratedColumn<int>(
    'total_active_days',
    aliasedName,
    false,
    check: () => ComparableExpr(totalActiveDays).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuidProfile,
    currentStreak,
    longestStreak,
    lastActivityDate,
    totalActiveDays,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_wellness_profile_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWellnessProfileStats> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid_profile')) {
      context.handle(
        _uuidProfileMeta,
        uuidProfile.isAcceptableOrUnknown(
          data['uuid_profile']!,
          _uuidProfileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_uuidProfileMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_activity_date')) {
      context.handle(
        _lastActivityDateMeta,
        lastActivityDate.isAcceptableOrUnknown(
          data['last_activity_date']!,
          _lastActivityDateMeta,
        ),
      );
    }
    if (data.containsKey('total_active_days')) {
      context.handle(
        _totalActiveDaysMeta,
        totalActiveDays.isAcceptableOrUnknown(
          data['total_active_days']!,
          _totalActiveDaysMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuidProfile};
  @override
  LocalWellnessProfileStats map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWellnessProfileStats(
      uuidProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid_profile'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastActivityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_activity_date'],
      ),
      totalActiveDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_active_days'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $WellnessProfileStatsTableTable createAlias(String alias) {
    return $WellnessProfileStatsTableTable(attachedDatabase, alias);
  }
}

class LocalWellnessProfileStats extends DataClass
    implements Insertable<LocalWellnessProfileStats> {
  final String uuidProfile;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int totalActiveDays;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  const LocalWellnessProfileStats({
    required this.uuidProfile,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.totalActiveDays,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid_profile'] = Variable<String>(uuidProfile);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastActivityDate != null) {
      map['last_activity_date'] = Variable<String>(lastActivityDate);
    }
    map['total_active_days'] = Variable<int>(totalActiveDays);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  WellnessProfileStatsTableCompanion toCompanion(bool nullToAbsent) {
    return WellnessProfileStatsTableCompanion(
      uuidProfile: Value(uuidProfile),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      lastActivityDate: lastActivityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityDate),
      totalActiveDays: Value(totalActiveDays),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory LocalWellnessProfileStats.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWellnessProfileStats(
      uuidProfile: serializer.fromJson<String>(json['uuidProfile']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      lastActivityDate: serializer.fromJson<String?>(json['lastActivityDate']),
      totalActiveDays: serializer.fromJson<int>(json['totalActiveDays']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuidProfile': serializer.toJson<String>(uuidProfile),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'lastActivityDate': serializer.toJson<String?>(lastActivityDate),
      'totalActiveDays': serializer.toJson<int>(totalActiveDays),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  LocalWellnessProfileStats copyWith({
    String? uuidProfile,
    int? currentStreak,
    int? longestStreak,
    Value<String?> lastActivityDate = const Value.absent(),
    int? totalActiveDays,
    DateTime? updatedAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => LocalWellnessProfileStats(
    uuidProfile: uuidProfile ?? this.uuidProfile,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActivityDate: lastActivityDate.present
        ? lastActivityDate.value
        : this.lastActivityDate,
    totalActiveDays: totalActiveDays ?? this.totalActiveDays,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  LocalWellnessProfileStats copyWithCompanion(
    WellnessProfileStatsTableCompanion data,
  ) {
    return LocalWellnessProfileStats(
      uuidProfile: data.uuidProfile.present
          ? data.uuidProfile.value
          : this.uuidProfile,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastActivityDate: data.lastActivityDate.present
          ? data.lastActivityDate.value
          : this.lastActivityDate,
      totalActiveDays: data.totalActiveDays.present
          ? data.totalActiveDays.value
          : this.totalActiveDays,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWellnessProfileStats(')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('totalActiveDays: $totalActiveDays, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    uuidProfile,
    currentStreak,
    longestStreak,
    lastActivityDate,
    totalActiveDays,
    updatedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWellnessProfileStats &&
          other.uuidProfile == this.uuidProfile &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.lastActivityDate == this.lastActivityDate &&
          other.totalActiveDays == this.totalActiveDays &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class WellnessProfileStatsTableCompanion
    extends UpdateCompanion<LocalWellnessProfileStats> {
  final Value<String> uuidProfile;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<String?> lastActivityDate;
  final Value<int> totalActiveDays;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const WellnessProfileStatsTableCompanion({
    this.uuidProfile = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastActivityDate = const Value.absent(),
    this.totalActiveDays = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WellnessProfileStatsTableCompanion.insert({
    required String uuidProfile,
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastActivityDate = const Value.absent(),
    this.totalActiveDays = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuidProfile = Value(uuidProfile);
  static Insertable<LocalWellnessProfileStats> custom({
    Expression<String>? uuidProfile,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<String>? lastActivityDate,
    Expression<int>? totalActiveDays,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuidProfile != null) 'uuid_profile': uuidProfile,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastActivityDate != null) 'last_activity_date': lastActivityDate,
      if (totalActiveDays != null) 'total_active_days': totalActiveDays,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WellnessProfileStatsTableCompanion copyWith({
    Value<String>? uuidProfile,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<String?>? lastActivityDate,
    Value<int>? totalActiveDays,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return WellnessProfileStatsTableCompanion(
      uuidProfile: uuidProfile ?? this.uuidProfile,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuidProfile.present) {
      map['uuid_profile'] = Variable<String>(uuidProfile.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastActivityDate.present) {
      map['last_activity_date'] = Variable<String>(lastActivityDate.value);
    }
    if (totalActiveDays.present) {
      map['total_active_days'] = Variable<int>(totalActiveDays.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WellnessProfileStatsTableCompanion(')
          ..write('uuidProfile: $uuidProfile, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('totalActiveDays: $totalActiveDays, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTableTable profilesTable = $ProfilesTableTable(this);
  late final $CompanyInfoTableTable companyInfoTable = $CompanyInfoTableTable(
    this,
  );
  late final $ContentDownloadsTableTable contentDownloadsTable =
      $ContentDownloadsTableTable(this);
  late final $ContentItemsTableTable contentItemsTable =
      $ContentItemsTableTable(this);
  late final $ContentMediaTableTable contentMediaTable =
      $ContentMediaTableTable(this);
  late final $NotificationDevicesTableTable notificationDevicesTable =
      $NotificationDevicesTableTable(this);
  late final $NotificationEventsTableTable notificationEventsTable =
      $NotificationEventsTableTable(this);
  late final $NotificationDispatchesTableTable notificationDispatchesTable =
      $NotificationDispatchesTableTable(this);
  late final $NotificationsInboxTableTable notificationsInboxTable =
      $NotificationsInboxTableTable(this);
  late final $UserContentStatesTableTable userContentStatesTable =
      $UserContentStatesTableTable(this);
  late final $WellnessDailyLogsTableTable wellnessDailyLogsTable =
      $WellnessDailyLogsTableTable(this);
  late final $WellnessProfileStatsTableTable wellnessProfileStatsTable =
      $WellnessProfileStatsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profilesTable,
    companyInfoTable,
    contentDownloadsTable,
    contentItemsTable,
    contentMediaTable,
    notificationDevicesTable,
    notificationEventsTable,
    notificationDispatchesTable,
    notificationsInboxTable,
    userContentStatesTable,
    wellnessDailyLogsTable,
    wellnessProfileStatsTable,
  ];
}

typedef $$ProfilesTableTableCreateCompanionBuilder =
    ProfilesTableCompanion Function({
      required String uuidProfile,
      required String authUserId,
      Value<String?> nombre,
      required String email,
      Value<String?> fotoPathSupabase,
      Value<String?> fotoPathLocal,
      Value<String> role,
      Value<bool> activo,
      Value<bool> onboardingCompletado,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ProfilesTableTableUpdateCompanionBuilder =
    ProfilesTableCompanion Function({
      Value<String> uuidProfile,
      Value<String> authUserId,
      Value<String?> nombre,
      Value<String> email,
      Value<String?> fotoPathSupabase,
      Value<String?> fotoPathLocal,
      Value<String> role,
      Value<bool> activo,
      Value<bool> onboardingCompletado,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPathSupabase => $composableBuilder(
    column: $table.fotoPathSupabase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoPathLocal => $composableBuilder(
    column: $table.fotoPathLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompletado => $composableBuilder(
    column: $table.onboardingCompletado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPathSupabase => $composableBuilder(
    column: $table.fotoPathSupabase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPathLocal => $composableBuilder(
    column: $table.fotoPathLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompletado => $composableBuilder(
    column: $table.onboardingCompletado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authUserId => $composableBuilder(
    column: $table.authUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fotoPathSupabase => $composableBuilder(
    column: $table.fotoPathSupabase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoPathLocal => $composableBuilder(
    column: $table.fotoPathLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompletado => $composableBuilder(
    column: $table.onboardingCompletado,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTableTable,
          LocalProfile,
          $$ProfilesTableTableFilterComposer,
          $$ProfilesTableTableOrderingComposer,
          $$ProfilesTableTableAnnotationComposer,
          $$ProfilesTableTableCreateCompanionBuilder,
          $$ProfilesTableTableUpdateCompanionBuilder,
          (
            LocalProfile,
            BaseReferences<_$AppDatabase, $ProfilesTableTable, LocalProfile>,
          ),
          LocalProfile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableTableManager(_$AppDatabase db, $ProfilesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuidProfile = const Value.absent(),
                Value<String> authUserId = const Value.absent(),
                Value<String?> nombre = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> fotoPathSupabase = const Value.absent(),
                Value<String?> fotoPathLocal = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<bool> onboardingCompletado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion(
                uuidProfile: uuidProfile,
                authUserId: authUserId,
                nombre: nombre,
                email: email,
                fotoPathSupabase: fotoPathSupabase,
                fotoPathLocal: fotoPathLocal,
                role: role,
                activo: activo,
                onboardingCompletado: onboardingCompletado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidProfile,
                required String authUserId,
                Value<String?> nombre = const Value.absent(),
                required String email,
                Value<String?> fotoPathSupabase = const Value.absent(),
                Value<String?> fotoPathLocal = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<bool> onboardingCompletado = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion.insert(
                uuidProfile: uuidProfile,
                authUserId: authUserId,
                nombre: nombre,
                email: email,
                fotoPathSupabase: fotoPathSupabase,
                fotoPathLocal: fotoPathLocal,
                role: role,
                activo: activo,
                onboardingCompletado: onboardingCompletado,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTableTable,
      LocalProfile,
      $$ProfilesTableTableFilterComposer,
      $$ProfilesTableTableOrderingComposer,
      $$ProfilesTableTableAnnotationComposer,
      $$ProfilesTableTableCreateCompanionBuilder,
      $$ProfilesTableTableUpdateCompanionBuilder,
      (
        LocalProfile,
        BaseReferences<_$AppDatabase, $ProfilesTableTable, LocalProfile>,
      ),
      LocalProfile,
      PrefetchHooks Function()
    >;
typedef $$CompanyInfoTableTableCreateCompanionBuilder =
    CompanyInfoTableCompanion Function({
      required String uuidCompanyInfo,
      Value<String> slug,
      Value<String> heroTitulo,
      Value<String> heroSubtitulo,
      Value<String?> heroImagePath,
      Value<String> textoEntrada,
      required String quienesSomos,
      Value<String> significadoAiki,
      required String mision,
      required String vision,
      required String filosofia,
      Value<String> mensajeFundadoresTitulo,
      Value<String> mensajeFundadoresTexto,
      Value<String?> mensajeFundadoresImagePath1,
      Value<String?> mensajeFundadoresImagePath2,
      Value<String?> mensajeFundadoresImagePath3,
      Value<String?> mensajeFundadoresImagePath4,
      Value<String?> mensajeFundadoresImagePath5,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$CompanyInfoTableTableUpdateCompanionBuilder =
    CompanyInfoTableCompanion Function({
      Value<String> uuidCompanyInfo,
      Value<String> slug,
      Value<String> heroTitulo,
      Value<String> heroSubtitulo,
      Value<String?> heroImagePath,
      Value<String> textoEntrada,
      Value<String> quienesSomos,
      Value<String> significadoAiki,
      Value<String> mision,
      Value<String> vision,
      Value<String> filosofia,
      Value<String> mensajeFundadoresTitulo,
      Value<String> mensajeFundadoresTexto,
      Value<String?> mensajeFundadoresImagePath1,
      Value<String?> mensajeFundadoresImagePath2,
      Value<String?> mensajeFundadoresImagePath3,
      Value<String?> mensajeFundadoresImagePath4,
      Value<String?> mensajeFundadoresImagePath5,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$CompanyInfoTableTableFilterComposer
    extends Composer<_$AppDatabase, $CompanyInfoTableTable> {
  $$CompanyInfoTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidCompanyInfo => $composableBuilder(
    column: $table.uuidCompanyInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroTitulo => $composableBuilder(
    column: $table.heroTitulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroSubtitulo => $composableBuilder(
    column: $table.heroSubtitulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroImagePath => $composableBuilder(
    column: $table.heroImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textoEntrada => $composableBuilder(
    column: $table.textoEntrada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quienesSomos => $composableBuilder(
    column: $table.quienesSomos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get significadoAiki => $composableBuilder(
    column: $table.significadoAiki,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mision => $composableBuilder(
    column: $table.mision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filosofia => $composableBuilder(
    column: $table.filosofia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresTitulo => $composableBuilder(
    column: $table.mensajeFundadoresTitulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresTexto => $composableBuilder(
    column: $table.mensajeFundadoresTexto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresImagePath1 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresImagePath2 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresImagePath3 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresImagePath4 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mensajeFundadoresImagePath5 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath5,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompanyInfoTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CompanyInfoTableTable> {
  $$CompanyInfoTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidCompanyInfo => $composableBuilder(
    column: $table.uuidCompanyInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroTitulo => $composableBuilder(
    column: $table.heroTitulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroSubtitulo => $composableBuilder(
    column: $table.heroSubtitulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroImagePath => $composableBuilder(
    column: $table.heroImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textoEntrada => $composableBuilder(
    column: $table.textoEntrada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quienesSomos => $composableBuilder(
    column: $table.quienesSomos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get significadoAiki => $composableBuilder(
    column: $table.significadoAiki,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mision => $composableBuilder(
    column: $table.mision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vision => $composableBuilder(
    column: $table.vision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filosofia => $composableBuilder(
    column: $table.filosofia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresTitulo => $composableBuilder(
    column: $table.mensajeFundadoresTitulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresTexto => $composableBuilder(
    column: $table.mensajeFundadoresTexto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresImagePath1 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresImagePath2 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresImagePath3 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresImagePath4 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mensajeFundadoresImagePath5 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath5,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompanyInfoTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompanyInfoTableTable> {
  $$CompanyInfoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidCompanyInfo => $composableBuilder(
    column: $table.uuidCompanyInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get heroTitulo => $composableBuilder(
    column: $table.heroTitulo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroSubtitulo => $composableBuilder(
    column: $table.heroSubtitulo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroImagePath => $composableBuilder(
    column: $table.heroImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textoEntrada => $composableBuilder(
    column: $table.textoEntrada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quienesSomos => $composableBuilder(
    column: $table.quienesSomos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get significadoAiki => $composableBuilder(
    column: $table.significadoAiki,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mision =>
      $composableBuilder(column: $table.mision, builder: (column) => column);

  GeneratedColumn<String> get vision =>
      $composableBuilder(column: $table.vision, builder: (column) => column);

  GeneratedColumn<String> get filosofia =>
      $composableBuilder(column: $table.filosofia, builder: (column) => column);

  GeneratedColumn<String> get mensajeFundadoresTitulo => $composableBuilder(
    column: $table.mensajeFundadoresTitulo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresTexto => $composableBuilder(
    column: $table.mensajeFundadoresTexto,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresImagePath1 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresImagePath2 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresImagePath3 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath3,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresImagePath4 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath4,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mensajeFundadoresImagePath5 => $composableBuilder(
    column: $table.mensajeFundadoresImagePath5,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$CompanyInfoTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompanyInfoTableTable,
          LocalCompanyInfo,
          $$CompanyInfoTableTableFilterComposer,
          $$CompanyInfoTableTableOrderingComposer,
          $$CompanyInfoTableTableAnnotationComposer,
          $$CompanyInfoTableTableCreateCompanionBuilder,
          $$CompanyInfoTableTableUpdateCompanionBuilder,
          (
            LocalCompanyInfo,
            BaseReferences<
              _$AppDatabase,
              $CompanyInfoTableTable,
              LocalCompanyInfo
            >,
          ),
          LocalCompanyInfo,
          PrefetchHooks Function()
        > {
  $$CompanyInfoTableTableTableManager(
    _$AppDatabase db,
    $CompanyInfoTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompanyInfoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompanyInfoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompanyInfoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuidCompanyInfo = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> heroTitulo = const Value.absent(),
                Value<String> heroSubtitulo = const Value.absent(),
                Value<String?> heroImagePath = const Value.absent(),
                Value<String> textoEntrada = const Value.absent(),
                Value<String> quienesSomos = const Value.absent(),
                Value<String> significadoAiki = const Value.absent(),
                Value<String> mision = const Value.absent(),
                Value<String> vision = const Value.absent(),
                Value<String> filosofia = const Value.absent(),
                Value<String> mensajeFundadoresTitulo = const Value.absent(),
                Value<String> mensajeFundadoresTexto = const Value.absent(),
                Value<String?> mensajeFundadoresImagePath1 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath2 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath3 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath4 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath5 =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyInfoTableCompanion(
                uuidCompanyInfo: uuidCompanyInfo,
                slug: slug,
                heroTitulo: heroTitulo,
                heroSubtitulo: heroSubtitulo,
                heroImagePath: heroImagePath,
                textoEntrada: textoEntrada,
                quienesSomos: quienesSomos,
                significadoAiki: significadoAiki,
                mision: mision,
                vision: vision,
                filosofia: filosofia,
                mensajeFundadoresTitulo: mensajeFundadoresTitulo,
                mensajeFundadoresTexto: mensajeFundadoresTexto,
                mensajeFundadoresImagePath1: mensajeFundadoresImagePath1,
                mensajeFundadoresImagePath2: mensajeFundadoresImagePath2,
                mensajeFundadoresImagePath3: mensajeFundadoresImagePath3,
                mensajeFundadoresImagePath4: mensajeFundadoresImagePath4,
                mensajeFundadoresImagePath5: mensajeFundadoresImagePath5,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidCompanyInfo,
                Value<String> slug = const Value.absent(),
                Value<String> heroTitulo = const Value.absent(),
                Value<String> heroSubtitulo = const Value.absent(),
                Value<String?> heroImagePath = const Value.absent(),
                Value<String> textoEntrada = const Value.absent(),
                required String quienesSomos,
                Value<String> significadoAiki = const Value.absent(),
                required String mision,
                required String vision,
                required String filosofia,
                Value<String> mensajeFundadoresTitulo = const Value.absent(),
                Value<String> mensajeFundadoresTexto = const Value.absent(),
                Value<String?> mensajeFundadoresImagePath1 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath2 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath3 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath4 =
                    const Value.absent(),
                Value<String?> mensajeFundadoresImagePath5 =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompanyInfoTableCompanion.insert(
                uuidCompanyInfo: uuidCompanyInfo,
                slug: slug,
                heroTitulo: heroTitulo,
                heroSubtitulo: heroSubtitulo,
                heroImagePath: heroImagePath,
                textoEntrada: textoEntrada,
                quienesSomos: quienesSomos,
                significadoAiki: significadoAiki,
                mision: mision,
                vision: vision,
                filosofia: filosofia,
                mensajeFundadoresTitulo: mensajeFundadoresTitulo,
                mensajeFundadoresTexto: mensajeFundadoresTexto,
                mensajeFundadoresImagePath1: mensajeFundadoresImagePath1,
                mensajeFundadoresImagePath2: mensajeFundadoresImagePath2,
                mensajeFundadoresImagePath3: mensajeFundadoresImagePath3,
                mensajeFundadoresImagePath4: mensajeFundadoresImagePath4,
                mensajeFundadoresImagePath5: mensajeFundadoresImagePath5,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompanyInfoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompanyInfoTableTable,
      LocalCompanyInfo,
      $$CompanyInfoTableTableFilterComposer,
      $$CompanyInfoTableTableOrderingComposer,
      $$CompanyInfoTableTableAnnotationComposer,
      $$CompanyInfoTableTableCreateCompanionBuilder,
      $$CompanyInfoTableTableUpdateCompanionBuilder,
      (
        LocalCompanyInfo,
        BaseReferences<_$AppDatabase, $CompanyInfoTableTable, LocalCompanyInfo>,
      ),
      LocalCompanyInfo,
      PrefetchHooks Function()
    >;
typedef $$ContentDownloadsTableTableCreateCompanionBuilder =
    ContentDownloadsTableCompanion Function({
      required String uuidContentDownload,
      required String uuidProfile,
      required String uuidContentItem,
      required String uuidContentMedia,
      required String storagePathSupabase,
      Value<String?> storagePathLocal,
      Value<String> status,
      Value<int> bytesDownloaded,
      Value<int> totalBytes,
      Value<DateTime?> downloadedAt,
      Value<DateTime?> accessExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ContentDownloadsTableTableUpdateCompanionBuilder =
    ContentDownloadsTableCompanion Function({
      Value<String> uuidContentDownload,
      Value<String> uuidProfile,
      Value<String> uuidContentItem,
      Value<String> uuidContentMedia,
      Value<String> storagePathSupabase,
      Value<String?> storagePathLocal,
      Value<String> status,
      Value<int> bytesDownloaded,
      Value<int> totalBytes,
      Value<DateTime?> downloadedAt,
      Value<DateTime?> accessExpiresAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ContentDownloadsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTableTable> {
  $$ContentDownloadsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidContentDownload => $composableBuilder(
    column: $table.uuidContentDownload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentDownloadsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTableTable> {
  $$ContentDownloadsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidContentDownload => $composableBuilder(
    column: $table.uuidContentDownload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentDownloadsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentDownloadsTableTable> {
  $$ContentDownloadsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidContentDownload => $composableBuilder(
    column: $table.uuidContentDownload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get accessExpiresAt => $composableBuilder(
    column: $table.accessExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ContentDownloadsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentDownloadsTableTable,
          LocalContentDownload,
          $$ContentDownloadsTableTableFilterComposer,
          $$ContentDownloadsTableTableOrderingComposer,
          $$ContentDownloadsTableTableAnnotationComposer,
          $$ContentDownloadsTableTableCreateCompanionBuilder,
          $$ContentDownloadsTableTableUpdateCompanionBuilder,
          (
            LocalContentDownload,
            BaseReferences<
              _$AppDatabase,
              $ContentDownloadsTableTable,
              LocalContentDownload
            >,
          ),
          LocalContentDownload,
          PrefetchHooks Function()
        > {
  $$ContentDownloadsTableTableTableManager(
    _$AppDatabase db,
    $ContentDownloadsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentDownloadsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContentDownloadsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContentDownloadsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidContentDownload = const Value.absent(),
                Value<String> uuidProfile = const Value.absent(),
                Value<String> uuidContentItem = const Value.absent(),
                Value<String> uuidContentMedia = const Value.absent(),
                Value<String> storagePathSupabase = const Value.absent(),
                Value<String?> storagePathLocal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime?> accessExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentDownloadsTableCompanion(
                uuidContentDownload: uuidContentDownload,
                uuidProfile: uuidProfile,
                uuidContentItem: uuidContentItem,
                uuidContentMedia: uuidContentMedia,
                storagePathSupabase: storagePathSupabase,
                storagePathLocal: storagePathLocal,
                status: status,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                downloadedAt: downloadedAt,
                accessExpiresAt: accessExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidContentDownload,
                required String uuidProfile,
                required String uuidContentItem,
                required String uuidContentMedia,
                required String storagePathSupabase,
                Value<String?> storagePathLocal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime?> accessExpiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentDownloadsTableCompanion.insert(
                uuidContentDownload: uuidContentDownload,
                uuidProfile: uuidProfile,
                uuidContentItem: uuidContentItem,
                uuidContentMedia: uuidContentMedia,
                storagePathSupabase: storagePathSupabase,
                storagePathLocal: storagePathLocal,
                status: status,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                downloadedAt: downloadedAt,
                accessExpiresAt: accessExpiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentDownloadsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentDownloadsTableTable,
      LocalContentDownload,
      $$ContentDownloadsTableTableFilterComposer,
      $$ContentDownloadsTableTableOrderingComposer,
      $$ContentDownloadsTableTableAnnotationComposer,
      $$ContentDownloadsTableTableCreateCompanionBuilder,
      $$ContentDownloadsTableTableUpdateCompanionBuilder,
      (
        LocalContentDownload,
        BaseReferences<
          _$AppDatabase,
          $ContentDownloadsTableTable,
          LocalContentDownload
        >,
      ),
      LocalContentDownload,
      PrefetchHooks Function()
    >;
typedef $$ContentItemsTableTableCreateCompanionBuilder =
    ContentItemsTableCompanion Function({
      required String uuidContentItem,
      required String tipo,
      required String titulo,
      Value<String?> subtitulo,
      Value<String?> descripcion,
      Value<String?> coverPathSupabase,
      Value<String?> coverPathLocal,
      Value<String> status,
      Value<bool> destacado,
      Value<bool> descargable,
      Value<int?> duracionSegundos,
      Value<int> orden,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ContentItemsTableTableUpdateCompanionBuilder =
    ContentItemsTableCompanion Function({
      Value<String> uuidContentItem,
      Value<String> tipo,
      Value<String> titulo,
      Value<String?> subtitulo,
      Value<String?> descripcion,
      Value<String?> coverPathSupabase,
      Value<String?> coverPathLocal,
      Value<String> status,
      Value<bool> destacado,
      Value<bool> descargable,
      Value<int?> duracionSegundos,
      Value<int> orden,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ContentItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContentItemsTableTable> {
  $$ContentItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitulo => $composableBuilder(
    column: $table.subtitulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPathSupabase => $composableBuilder(
    column: $table.coverPathSupabase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPathLocal => $composableBuilder(
    column: $table.coverPathLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get destacado => $composableBuilder(
    column: $table.destacado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get descargable => $composableBuilder(
    column: $table.descargable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentItemsTableTable> {
  $$ContentItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitulo => $composableBuilder(
    column: $table.subtitulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPathSupabase => $composableBuilder(
    column: $table.coverPathSupabase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPathLocal => $composableBuilder(
    column: $table.coverPathLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get destacado => $composableBuilder(
    column: $table.destacado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get descargable => $composableBuilder(
    column: $table.descargable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentItemsTableTable> {
  $$ContentItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get subtitulo =>
      $composableBuilder(column: $table.subtitulo, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPathSupabase => $composableBuilder(
    column: $table.coverPathSupabase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPathLocal => $composableBuilder(
    column: $table.coverPathLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get destacado =>
      $composableBuilder(column: $table.destacado, builder: (column) => column);

  GeneratedColumn<bool> get descargable => $composableBuilder(
    column: $table.descargable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ContentItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentItemsTableTable,
          LocalContentItem,
          $$ContentItemsTableTableFilterComposer,
          $$ContentItemsTableTableOrderingComposer,
          $$ContentItemsTableTableAnnotationComposer,
          $$ContentItemsTableTableCreateCompanionBuilder,
          $$ContentItemsTableTableUpdateCompanionBuilder,
          (
            LocalContentItem,
            BaseReferences<
              _$AppDatabase,
              $ContentItemsTableTable,
              LocalContentItem
            >,
          ),
          LocalContentItem,
          PrefetchHooks Function()
        > {
  $$ContentItemsTableTableTableManager(
    _$AppDatabase db,
    $ContentItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidContentItem = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> subtitulo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> coverPathSupabase = const Value.absent(),
                Value<String?> coverPathLocal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> destacado = const Value.absent(),
                Value<bool> descargable = const Value.absent(),
                Value<int?> duracionSegundos = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsTableCompanion(
                uuidContentItem: uuidContentItem,
                tipo: tipo,
                titulo: titulo,
                subtitulo: subtitulo,
                descripcion: descripcion,
                coverPathSupabase: coverPathSupabase,
                coverPathLocal: coverPathLocal,
                status: status,
                destacado: destacado,
                descargable: descargable,
                duracionSegundos: duracionSegundos,
                orden: orden,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidContentItem,
                required String tipo,
                required String titulo,
                Value<String?> subtitulo = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> coverPathSupabase = const Value.absent(),
                Value<String?> coverPathLocal = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> destacado = const Value.absent(),
                Value<bool> descargable = const Value.absent(),
                Value<int?> duracionSegundos = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentItemsTableCompanion.insert(
                uuidContentItem: uuidContentItem,
                tipo: tipo,
                titulo: titulo,
                subtitulo: subtitulo,
                descripcion: descripcion,
                coverPathSupabase: coverPathSupabase,
                coverPathLocal: coverPathLocal,
                status: status,
                destacado: destacado,
                descargable: descargable,
                duracionSegundos: duracionSegundos,
                orden: orden,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentItemsTableTable,
      LocalContentItem,
      $$ContentItemsTableTableFilterComposer,
      $$ContentItemsTableTableOrderingComposer,
      $$ContentItemsTableTableAnnotationComposer,
      $$ContentItemsTableTableCreateCompanionBuilder,
      $$ContentItemsTableTableUpdateCompanionBuilder,
      (
        LocalContentItem,
        BaseReferences<
          _$AppDatabase,
          $ContentItemsTableTable,
          LocalContentItem
        >,
      ),
      LocalContentItem,
      PrefetchHooks Function()
    >;
typedef $$ContentMediaTableTableCreateCompanionBuilder =
    ContentMediaTableCompanion Function({
      required String uuidContentMedia,
      required String uuidContentItem,
      required String tipo,
      Value<String?> titulo,
      required String storagePathSupabase,
      Value<String?> storagePathLocal,
      Value<int?> duracionSegundos,
      Value<int> orden,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$ContentMediaTableTableUpdateCompanionBuilder =
    ContentMediaTableCompanion Function({
      Value<String> uuidContentMedia,
      Value<String> uuidContentItem,
      Value<String> tipo,
      Value<String?> titulo,
      Value<String> storagePathSupabase,
      Value<String?> storagePathLocal,
      Value<int?> duracionSegundos,
      Value<int> orden,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$ContentMediaTableTableFilterComposer
    extends Composer<_$AppDatabase, $ContentMediaTableTable> {
  $$ContentMediaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContentMediaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentMediaTableTable> {
  $$ContentMediaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContentMediaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentMediaTableTable> {
  $$ContentMediaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidContentMedia => $composableBuilder(
    column: $table.uuidContentMedia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get storagePathSupabase => $composableBuilder(
    column: $table.storagePathSupabase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storagePathLocal => $composableBuilder(
    column: $table.storagePathLocal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duracionSegundos => $composableBuilder(
    column: $table.duracionSegundos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$ContentMediaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentMediaTableTable,
          LocalContentMedia,
          $$ContentMediaTableTableFilterComposer,
          $$ContentMediaTableTableOrderingComposer,
          $$ContentMediaTableTableAnnotationComposer,
          $$ContentMediaTableTableCreateCompanionBuilder,
          $$ContentMediaTableTableUpdateCompanionBuilder,
          (
            LocalContentMedia,
            BaseReferences<
              _$AppDatabase,
              $ContentMediaTableTable,
              LocalContentMedia
            >,
          ),
          LocalContentMedia,
          PrefetchHooks Function()
        > {
  $$ContentMediaTableTableTableManager(
    _$AppDatabase db,
    $ContentMediaTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentMediaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentMediaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentMediaTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidContentMedia = const Value.absent(),
                Value<String> uuidContentItem = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> titulo = const Value.absent(),
                Value<String> storagePathSupabase = const Value.absent(),
                Value<String?> storagePathLocal = const Value.absent(),
                Value<int?> duracionSegundos = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentMediaTableCompanion(
                uuidContentMedia: uuidContentMedia,
                uuidContentItem: uuidContentItem,
                tipo: tipo,
                titulo: titulo,
                storagePathSupabase: storagePathSupabase,
                storagePathLocal: storagePathLocal,
                duracionSegundos: duracionSegundos,
                orden: orden,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidContentMedia,
                required String uuidContentItem,
                required String tipo,
                Value<String?> titulo = const Value.absent(),
                required String storagePathSupabase,
                Value<String?> storagePathLocal = const Value.absent(),
                Value<int?> duracionSegundos = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentMediaTableCompanion.insert(
                uuidContentMedia: uuidContentMedia,
                uuidContentItem: uuidContentItem,
                tipo: tipo,
                titulo: titulo,
                storagePathSupabase: storagePathSupabase,
                storagePathLocal: storagePathLocal,
                duracionSegundos: duracionSegundos,
                orden: orden,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentMediaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentMediaTableTable,
      LocalContentMedia,
      $$ContentMediaTableTableFilterComposer,
      $$ContentMediaTableTableOrderingComposer,
      $$ContentMediaTableTableAnnotationComposer,
      $$ContentMediaTableTableCreateCompanionBuilder,
      $$ContentMediaTableTableUpdateCompanionBuilder,
      (
        LocalContentMedia,
        BaseReferences<
          _$AppDatabase,
          $ContentMediaTableTable,
          LocalContentMedia
        >,
      ),
      LocalContentMedia,
      PrefetchHooks Function()
    >;
typedef $$NotificationDevicesTableTableCreateCompanionBuilder =
    NotificationDevicesTableCompanion Function({
      required String uuidNotificationDevice,
      required String uuidProfile,
      required String installationId,
      Value<String?> fcmToken,
      required String platform,
      Value<String> permissionStatus,
      Value<String?> appVersion,
      Value<String?> timeZone,
      Value<bool> isActive,
      Value<DateTime?> registrationRefreshedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$NotificationDevicesTableTableUpdateCompanionBuilder =
    NotificationDevicesTableCompanion Function({
      Value<String> uuidNotificationDevice,
      Value<String> uuidProfile,
      Value<String> installationId,
      Value<String?> fcmToken,
      Value<String> platform,
      Value<String> permissionStatus,
      Value<String?> appVersion,
      Value<String?> timeZone,
      Value<bool> isActive,
      Value<DateTime?> registrationRefreshedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$NotificationDevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationDevicesTableTable> {
  $$NotificationDevicesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidNotificationDevice => $composableBuilder(
    column: $table.uuidNotificationDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionStatus => $composableBuilder(
    column: $table.permissionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get registrationRefreshedAt => $composableBuilder(
    column: $table.registrationRefreshedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationDevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationDevicesTableTable> {
  $$NotificationDevicesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidNotificationDevice => $composableBuilder(
    column: $table.uuidNotificationDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionStatus => $composableBuilder(
    column: $table.permissionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get registrationRefreshedAt => $composableBuilder(
    column: $table.registrationRefreshedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationDevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationDevicesTableTable> {
  $$NotificationDevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidNotificationDevice => $composableBuilder(
    column: $table.uuidNotificationDevice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get installationId => $composableBuilder(
    column: $table.installationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fcmToken =>
      $composableBuilder(column: $table.fcmToken, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get permissionStatus => $composableBuilder(
    column: $table.permissionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get registrationRefreshedAt => $composableBuilder(
    column: $table.registrationRefreshedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$NotificationDevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationDevicesTableTable,
          LocalNotificationDevice,
          $$NotificationDevicesTableTableFilterComposer,
          $$NotificationDevicesTableTableOrderingComposer,
          $$NotificationDevicesTableTableAnnotationComposer,
          $$NotificationDevicesTableTableCreateCompanionBuilder,
          $$NotificationDevicesTableTableUpdateCompanionBuilder,
          (
            LocalNotificationDevice,
            BaseReferences<
              _$AppDatabase,
              $NotificationDevicesTableTable,
              LocalNotificationDevice
            >,
          ),
          LocalNotificationDevice,
          PrefetchHooks Function()
        > {
  $$NotificationDevicesTableTableTableManager(
    _$AppDatabase db,
    $NotificationDevicesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationDevicesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationDevicesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationDevicesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidNotificationDevice = const Value.absent(),
                Value<String> uuidProfile = const Value.absent(),
                Value<String> installationId = const Value.absent(),
                Value<String?> fcmToken = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> permissionStatus = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> registrationRefreshedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationDevicesTableCompanion(
                uuidNotificationDevice: uuidNotificationDevice,
                uuidProfile: uuidProfile,
                installationId: installationId,
                fcmToken: fcmToken,
                platform: platform,
                permissionStatus: permissionStatus,
                appVersion: appVersion,
                timeZone: timeZone,
                isActive: isActive,
                registrationRefreshedAt: registrationRefreshedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidNotificationDevice,
                required String uuidProfile,
                required String installationId,
                Value<String?> fcmToken = const Value.absent(),
                required String platform,
                Value<String> permissionStatus = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> registrationRefreshedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationDevicesTableCompanion.insert(
                uuidNotificationDevice: uuidNotificationDevice,
                uuidProfile: uuidProfile,
                installationId: installationId,
                fcmToken: fcmToken,
                platform: platform,
                permissionStatus: permissionStatus,
                appVersion: appVersion,
                timeZone: timeZone,
                isActive: isActive,
                registrationRefreshedAt: registrationRefreshedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationDevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationDevicesTableTable,
      LocalNotificationDevice,
      $$NotificationDevicesTableTableFilterComposer,
      $$NotificationDevicesTableTableOrderingComposer,
      $$NotificationDevicesTableTableAnnotationComposer,
      $$NotificationDevicesTableTableCreateCompanionBuilder,
      $$NotificationDevicesTableTableUpdateCompanionBuilder,
      (
        LocalNotificationDevice,
        BaseReferences<
          _$AppDatabase,
          $NotificationDevicesTableTable,
          LocalNotificationDevice
        >,
      ),
      LocalNotificationDevice,
      PrefetchHooks Function()
    >;
typedef $$NotificationEventsTableTableCreateCompanionBuilder =
    NotificationEventsTableCompanion Function({
      required String uuidNotificationEvent,
      required String name,
      required String category,
      required String titleTemplate,
      required String bodyTemplate,
      required String triggerType,
      Value<String?> triggerKey,
      required String executionMode,
      required String audienceType,
      required String actionType,
      Value<String> actionPayloadTemplateJson,
      Value<String> triggerConfigJson,
      Value<DateTime> startsAt,
      Value<DateTime?> endsAt,
      Value<String> status,
      Value<String?> uuidCreatedByProfile,
      Value<String?> uuidUpdatedByProfile,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$NotificationEventsTableTableUpdateCompanionBuilder =
    NotificationEventsTableCompanion Function({
      Value<String> uuidNotificationEvent,
      Value<String> name,
      Value<String> category,
      Value<String> titleTemplate,
      Value<String> bodyTemplate,
      Value<String> triggerType,
      Value<String?> triggerKey,
      Value<String> executionMode,
      Value<String> audienceType,
      Value<String> actionType,
      Value<String> actionPayloadTemplateJson,
      Value<String> triggerConfigJson,
      Value<DateTime> startsAt,
      Value<DateTime?> endsAt,
      Value<String> status,
      Value<String?> uuidCreatedByProfile,
      Value<String?> uuidUpdatedByProfile,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$NotificationEventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationEventsTableTable> {
  $$NotificationEventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleTemplate => $composableBuilder(
    column: $table.titleTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executionMode => $composableBuilder(
    column: $table.executionMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audienceType => $composableBuilder(
    column: $table.audienceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPayloadTemplateJson => $composableBuilder(
    column: $table.actionPayloadTemplateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerConfigJson => $composableBuilder(
    column: $table.triggerConfigJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidCreatedByProfile => $composableBuilder(
    column: $table.uuidCreatedByProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidUpdatedByProfile => $composableBuilder(
    column: $table.uuidUpdatedByProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationEventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationEventsTableTable> {
  $$NotificationEventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleTemplate => $composableBuilder(
    column: $table.titleTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executionMode => $composableBuilder(
    column: $table.executionMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audienceType => $composableBuilder(
    column: $table.audienceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPayloadTemplateJson => $composableBuilder(
    column: $table.actionPayloadTemplateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerConfigJson => $composableBuilder(
    column: $table.triggerConfigJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidCreatedByProfile => $composableBuilder(
    column: $table.uuidCreatedByProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidUpdatedByProfile => $composableBuilder(
    column: $table.uuidUpdatedByProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationEventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationEventsTableTable> {
  $$NotificationEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get titleTemplate => $composableBuilder(
    column: $table.titleTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerType => $composableBuilder(
    column: $table.triggerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerKey => $composableBuilder(
    column: $table.triggerKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get executionMode => $composableBuilder(
    column: $table.executionMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audienceType => $composableBuilder(
    column: $table.audienceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionPayloadTemplateJson => $composableBuilder(
    column: $table.actionPayloadTemplateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerConfigJson => $composableBuilder(
    column: $table.triggerConfigJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get uuidCreatedByProfile => $composableBuilder(
    column: $table.uuidCreatedByProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidUpdatedByProfile => $composableBuilder(
    column: $table.uuidUpdatedByProfile,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$NotificationEventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationEventsTableTable,
          LocalNotificationEvent,
          $$NotificationEventsTableTableFilterComposer,
          $$NotificationEventsTableTableOrderingComposer,
          $$NotificationEventsTableTableAnnotationComposer,
          $$NotificationEventsTableTableCreateCompanionBuilder,
          $$NotificationEventsTableTableUpdateCompanionBuilder,
          (
            LocalNotificationEvent,
            BaseReferences<
              _$AppDatabase,
              $NotificationEventsTableTable,
              LocalNotificationEvent
            >,
          ),
          LocalNotificationEvent,
          PrefetchHooks Function()
        > {
  $$NotificationEventsTableTableTableManager(
    _$AppDatabase db,
    $NotificationEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationEventsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidNotificationEvent = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> titleTemplate = const Value.absent(),
                Value<String> bodyTemplate = const Value.absent(),
                Value<String> triggerType = const Value.absent(),
                Value<String?> triggerKey = const Value.absent(),
                Value<String> executionMode = const Value.absent(),
                Value<String> audienceType = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> actionPayloadTemplateJson = const Value.absent(),
                Value<String> triggerConfigJson = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> uuidCreatedByProfile = const Value.absent(),
                Value<String?> uuidUpdatedByProfile = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationEventsTableCompanion(
                uuidNotificationEvent: uuidNotificationEvent,
                name: name,
                category: category,
                titleTemplate: titleTemplate,
                bodyTemplate: bodyTemplate,
                triggerType: triggerType,
                triggerKey: triggerKey,
                executionMode: executionMode,
                audienceType: audienceType,
                actionType: actionType,
                actionPayloadTemplateJson: actionPayloadTemplateJson,
                triggerConfigJson: triggerConfigJson,
                startsAt: startsAt,
                endsAt: endsAt,
                status: status,
                uuidCreatedByProfile: uuidCreatedByProfile,
                uuidUpdatedByProfile: uuidUpdatedByProfile,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidNotificationEvent,
                required String name,
                required String category,
                required String titleTemplate,
                required String bodyTemplate,
                required String triggerType,
                Value<String?> triggerKey = const Value.absent(),
                required String executionMode,
                required String audienceType,
                required String actionType,
                Value<String> actionPayloadTemplateJson = const Value.absent(),
                Value<String> triggerConfigJson = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> uuidCreatedByProfile = const Value.absent(),
                Value<String?> uuidUpdatedByProfile = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationEventsTableCompanion.insert(
                uuidNotificationEvent: uuidNotificationEvent,
                name: name,
                category: category,
                titleTemplate: titleTemplate,
                bodyTemplate: bodyTemplate,
                triggerType: triggerType,
                triggerKey: triggerKey,
                executionMode: executionMode,
                audienceType: audienceType,
                actionType: actionType,
                actionPayloadTemplateJson: actionPayloadTemplateJson,
                triggerConfigJson: triggerConfigJson,
                startsAt: startsAt,
                endsAt: endsAt,
                status: status,
                uuidCreatedByProfile: uuidCreatedByProfile,
                uuidUpdatedByProfile: uuidUpdatedByProfile,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationEventsTableTable,
      LocalNotificationEvent,
      $$NotificationEventsTableTableFilterComposer,
      $$NotificationEventsTableTableOrderingComposer,
      $$NotificationEventsTableTableAnnotationComposer,
      $$NotificationEventsTableTableCreateCompanionBuilder,
      $$NotificationEventsTableTableUpdateCompanionBuilder,
      (
        LocalNotificationEvent,
        BaseReferences<
          _$AppDatabase,
          $NotificationEventsTableTable,
          LocalNotificationEvent
        >,
      ),
      LocalNotificationEvent,
      PrefetchHooks Function()
    >;
typedef $$NotificationDispatchesTableTableCreateCompanionBuilder =
    NotificationDispatchesTableCompanion Function({
      required String uuidNotificationDispatch,
      required String uuidNotificationEvent,
      required String triggerSource,
      Value<String?> uuidTriggeredByProfile,
      Value<String?> sourceEntityType,
      Value<String?> sourceEntityUuid,
      required String idempotencyKey,
      required String titleSnapshot,
      required String bodySnapshot,
      required String categorySnapshot,
      required String audienceTypeSnapshot,
      required String actionTypeSnapshot,
      Value<String> actionPayloadSnapshotJson,
      Value<String> status,
      Value<int> targetProfileCount,
      Value<int> targetDeviceCount,
      Value<int> successDeviceCount,
      Value<int> failureDeviceCount,
      Value<int> invalidTokenCount,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> errorSummary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$NotificationDispatchesTableTableUpdateCompanionBuilder =
    NotificationDispatchesTableCompanion Function({
      Value<String> uuidNotificationDispatch,
      Value<String> uuidNotificationEvent,
      Value<String> triggerSource,
      Value<String?> uuidTriggeredByProfile,
      Value<String?> sourceEntityType,
      Value<String?> sourceEntityUuid,
      Value<String> idempotencyKey,
      Value<String> titleSnapshot,
      Value<String> bodySnapshot,
      Value<String> categorySnapshot,
      Value<String> audienceTypeSnapshot,
      Value<String> actionTypeSnapshot,
      Value<String> actionPayloadSnapshotJson,
      Value<String> status,
      Value<int> targetProfileCount,
      Value<int> targetDeviceCount,
      Value<int> successDeviceCount,
      Value<int> failureDeviceCount,
      Value<int> invalidTokenCount,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> errorSummary,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$NotificationDispatchesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationDispatchesTableTable> {
  $$NotificationDispatchesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerSource => $composableBuilder(
    column: $table.triggerSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidTriggeredByProfile => $composableBuilder(
    column: $table.uuidTriggeredByProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEntityType => $composableBuilder(
    column: $table.sourceEntityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEntityUuid => $composableBuilder(
    column: $table.sourceEntityUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodySnapshot => $composableBuilder(
    column: $table.bodySnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorySnapshot => $composableBuilder(
    column: $table.categorySnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audienceTypeSnapshot => $composableBuilder(
    column: $table.audienceTypeSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionTypeSnapshot => $composableBuilder(
    column: $table.actionTypeSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPayloadSnapshotJson => $composableBuilder(
    column: $table.actionPayloadSnapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetProfileCount => $composableBuilder(
    column: $table.targetProfileCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetDeviceCount => $composableBuilder(
    column: $table.targetDeviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get successDeviceCount => $composableBuilder(
    column: $table.successDeviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failureDeviceCount => $composableBuilder(
    column: $table.failureDeviceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invalidTokenCount => $composableBuilder(
    column: $table.invalidTokenCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationDispatchesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationDispatchesTableTable> {
  $$NotificationDispatchesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerSource => $composableBuilder(
    column: $table.triggerSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidTriggeredByProfile => $composableBuilder(
    column: $table.uuidTriggeredByProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEntityType => $composableBuilder(
    column: $table.sourceEntityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEntityUuid => $composableBuilder(
    column: $table.sourceEntityUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodySnapshot => $composableBuilder(
    column: $table.bodySnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorySnapshot => $composableBuilder(
    column: $table.categorySnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audienceTypeSnapshot => $composableBuilder(
    column: $table.audienceTypeSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionTypeSnapshot => $composableBuilder(
    column: $table.actionTypeSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPayloadSnapshotJson => $composableBuilder(
    column: $table.actionPayloadSnapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetProfileCount => $composableBuilder(
    column: $table.targetProfileCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetDeviceCount => $composableBuilder(
    column: $table.targetDeviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get successDeviceCount => $composableBuilder(
    column: $table.successDeviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failureDeviceCount => $composableBuilder(
    column: $table.failureDeviceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invalidTokenCount => $composableBuilder(
    column: $table.invalidTokenCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationDispatchesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationDispatchesTableTable> {
  $$NotificationDispatchesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidNotificationEvent => $composableBuilder(
    column: $table.uuidNotificationEvent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get triggerSource => $composableBuilder(
    column: $table.triggerSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidTriggeredByProfile => $composableBuilder(
    column: $table.uuidTriggeredByProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEntityType => $composableBuilder(
    column: $table.sourceEntityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceEntityUuid => $composableBuilder(
    column: $table.sourceEntityUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titleSnapshot => $composableBuilder(
    column: $table.titleSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodySnapshot => $composableBuilder(
    column: $table.bodySnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categorySnapshot => $composableBuilder(
    column: $table.categorySnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audienceTypeSnapshot => $composableBuilder(
    column: $table.audienceTypeSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionTypeSnapshot => $composableBuilder(
    column: $table.actionTypeSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionPayloadSnapshotJson => $composableBuilder(
    column: $table.actionPayloadSnapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get targetProfileCount => $composableBuilder(
    column: $table.targetProfileCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetDeviceCount => $composableBuilder(
    column: $table.targetDeviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get successDeviceCount => $composableBuilder(
    column: $table.successDeviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failureDeviceCount => $composableBuilder(
    column: $table.failureDeviceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get invalidTokenCount => $composableBuilder(
    column: $table.invalidTokenCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$NotificationDispatchesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationDispatchesTableTable,
          LocalNotificationDispatch,
          $$NotificationDispatchesTableTableFilterComposer,
          $$NotificationDispatchesTableTableOrderingComposer,
          $$NotificationDispatchesTableTableAnnotationComposer,
          $$NotificationDispatchesTableTableCreateCompanionBuilder,
          $$NotificationDispatchesTableTableUpdateCompanionBuilder,
          (
            LocalNotificationDispatch,
            BaseReferences<
              _$AppDatabase,
              $NotificationDispatchesTableTable,
              LocalNotificationDispatch
            >,
          ),
          LocalNotificationDispatch,
          PrefetchHooks Function()
        > {
  $$NotificationDispatchesTableTableTableManager(
    _$AppDatabase db,
    $NotificationDispatchesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationDispatchesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationDispatchesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationDispatchesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidNotificationDispatch = const Value.absent(),
                Value<String> uuidNotificationEvent = const Value.absent(),
                Value<String> triggerSource = const Value.absent(),
                Value<String?> uuidTriggeredByProfile = const Value.absent(),
                Value<String?> sourceEntityType = const Value.absent(),
                Value<String?> sourceEntityUuid = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> titleSnapshot = const Value.absent(),
                Value<String> bodySnapshot = const Value.absent(),
                Value<String> categorySnapshot = const Value.absent(),
                Value<String> audienceTypeSnapshot = const Value.absent(),
                Value<String> actionTypeSnapshot = const Value.absent(),
                Value<String> actionPayloadSnapshotJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> targetProfileCount = const Value.absent(),
                Value<int> targetDeviceCount = const Value.absent(),
                Value<int> successDeviceCount = const Value.absent(),
                Value<int> failureDeviceCount = const Value.absent(),
                Value<int> invalidTokenCount = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationDispatchesTableCompanion(
                uuidNotificationDispatch: uuidNotificationDispatch,
                uuidNotificationEvent: uuidNotificationEvent,
                triggerSource: triggerSource,
                uuidTriggeredByProfile: uuidTriggeredByProfile,
                sourceEntityType: sourceEntityType,
                sourceEntityUuid: sourceEntityUuid,
                idempotencyKey: idempotencyKey,
                titleSnapshot: titleSnapshot,
                bodySnapshot: bodySnapshot,
                categorySnapshot: categorySnapshot,
                audienceTypeSnapshot: audienceTypeSnapshot,
                actionTypeSnapshot: actionTypeSnapshot,
                actionPayloadSnapshotJson: actionPayloadSnapshotJson,
                status: status,
                targetProfileCount: targetProfileCount,
                targetDeviceCount: targetDeviceCount,
                successDeviceCount: successDeviceCount,
                failureDeviceCount: failureDeviceCount,
                invalidTokenCount: invalidTokenCount,
                startedAt: startedAt,
                completedAt: completedAt,
                errorSummary: errorSummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidNotificationDispatch,
                required String uuidNotificationEvent,
                required String triggerSource,
                Value<String?> uuidTriggeredByProfile = const Value.absent(),
                Value<String?> sourceEntityType = const Value.absent(),
                Value<String?> sourceEntityUuid = const Value.absent(),
                required String idempotencyKey,
                required String titleSnapshot,
                required String bodySnapshot,
                required String categorySnapshot,
                required String audienceTypeSnapshot,
                required String actionTypeSnapshot,
                Value<String> actionPayloadSnapshotJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> targetProfileCount = const Value.absent(),
                Value<int> targetDeviceCount = const Value.absent(),
                Value<int> successDeviceCount = const Value.absent(),
                Value<int> failureDeviceCount = const Value.absent(),
                Value<int> invalidTokenCount = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationDispatchesTableCompanion.insert(
                uuidNotificationDispatch: uuidNotificationDispatch,
                uuidNotificationEvent: uuidNotificationEvent,
                triggerSource: triggerSource,
                uuidTriggeredByProfile: uuidTriggeredByProfile,
                sourceEntityType: sourceEntityType,
                sourceEntityUuid: sourceEntityUuid,
                idempotencyKey: idempotencyKey,
                titleSnapshot: titleSnapshot,
                bodySnapshot: bodySnapshot,
                categorySnapshot: categorySnapshot,
                audienceTypeSnapshot: audienceTypeSnapshot,
                actionTypeSnapshot: actionTypeSnapshot,
                actionPayloadSnapshotJson: actionPayloadSnapshotJson,
                status: status,
                targetProfileCount: targetProfileCount,
                targetDeviceCount: targetDeviceCount,
                successDeviceCount: successDeviceCount,
                failureDeviceCount: failureDeviceCount,
                invalidTokenCount: invalidTokenCount,
                startedAt: startedAt,
                completedAt: completedAt,
                errorSummary: errorSummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationDispatchesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationDispatchesTableTable,
      LocalNotificationDispatch,
      $$NotificationDispatchesTableTableFilterComposer,
      $$NotificationDispatchesTableTableOrderingComposer,
      $$NotificationDispatchesTableTableAnnotationComposer,
      $$NotificationDispatchesTableTableCreateCompanionBuilder,
      $$NotificationDispatchesTableTableUpdateCompanionBuilder,
      (
        LocalNotificationDispatch,
        BaseReferences<
          _$AppDatabase,
          $NotificationDispatchesTableTable,
          LocalNotificationDispatch
        >,
      ),
      LocalNotificationDispatch,
      PrefetchHooks Function()
    >;
typedef $$NotificationsInboxTableTableCreateCompanionBuilder =
    NotificationsInboxTableCompanion Function({
      required String uuidNotificationInbox,
      required String uuidNotificationDispatch,
      required String uuidProfile,
      required String title,
      required String body,
      required String category,
      required String actionType,
      Value<String> actionPayloadJson,
      Value<DateTime?> readAt,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$NotificationsInboxTableTableUpdateCompanionBuilder =
    NotificationsInboxTableCompanion Function({
      Value<String> uuidNotificationInbox,
      Value<String> uuidNotificationDispatch,
      Value<String> uuidProfile,
      Value<String> title,
      Value<String> body,
      Value<String> category,
      Value<String> actionType,
      Value<String> actionPayloadJson,
      Value<DateTime?> readAt,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$NotificationsInboxTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsInboxTableTable> {
  $$NotificationsInboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidNotificationInbox => $composableBuilder(
    column: $table.uuidNotificationInbox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsInboxTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsInboxTableTable> {
  $$NotificationsInboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidNotificationInbox => $composableBuilder(
    column: $table.uuidNotificationInbox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsInboxTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsInboxTableTable> {
  $$NotificationsInboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidNotificationInbox => $composableBuilder(
    column: $table.uuidNotificationInbox,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidNotificationDispatch => $composableBuilder(
    column: $table.uuidNotificationDispatch,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionPayloadJson => $composableBuilder(
    column: $table.actionPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$NotificationsInboxTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsInboxTableTable,
          LocalNotificationInboxItem,
          $$NotificationsInboxTableTableFilterComposer,
          $$NotificationsInboxTableTableOrderingComposer,
          $$NotificationsInboxTableTableAnnotationComposer,
          $$NotificationsInboxTableTableCreateCompanionBuilder,
          $$NotificationsInboxTableTableUpdateCompanionBuilder,
          (
            LocalNotificationInboxItem,
            BaseReferences<
              _$AppDatabase,
              $NotificationsInboxTableTable,
              LocalNotificationInboxItem
            >,
          ),
          LocalNotificationInboxItem,
          PrefetchHooks Function()
        > {
  $$NotificationsInboxTableTableTableManager(
    _$AppDatabase db,
    $NotificationsInboxTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsInboxTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationsInboxTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationsInboxTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidNotificationInbox = const Value.absent(),
                Value<String> uuidNotificationDispatch = const Value.absent(),
                Value<String> uuidProfile = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> actionPayloadJson = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsInboxTableCompanion(
                uuidNotificationInbox: uuidNotificationInbox,
                uuidNotificationDispatch: uuidNotificationDispatch,
                uuidProfile: uuidProfile,
                title: title,
                body: body,
                category: category,
                actionType: actionType,
                actionPayloadJson: actionPayloadJson,
                readAt: readAt,
                openedAt: openedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidNotificationInbox,
                required String uuidNotificationDispatch,
                required String uuidProfile,
                required String title,
                required String body,
                required String category,
                required String actionType,
                Value<String> actionPayloadJson = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationsInboxTableCompanion.insert(
                uuidNotificationInbox: uuidNotificationInbox,
                uuidNotificationDispatch: uuidNotificationDispatch,
                uuidProfile: uuidProfile,
                title: title,
                body: body,
                category: category,
                actionType: actionType,
                actionPayloadJson: actionPayloadJson,
                readAt: readAt,
                openedAt: openedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsInboxTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsInboxTableTable,
      LocalNotificationInboxItem,
      $$NotificationsInboxTableTableFilterComposer,
      $$NotificationsInboxTableTableOrderingComposer,
      $$NotificationsInboxTableTableAnnotationComposer,
      $$NotificationsInboxTableTableCreateCompanionBuilder,
      $$NotificationsInboxTableTableUpdateCompanionBuilder,
      (
        LocalNotificationInboxItem,
        BaseReferences<
          _$AppDatabase,
          $NotificationsInboxTableTable,
          LocalNotificationInboxItem
        >,
      ),
      LocalNotificationInboxItem,
      PrefetchHooks Function()
    >;
typedef $$UserContentStatesTableTableCreateCompanionBuilder =
    UserContentStatesTableCompanion Function({
      required String uuidUserContentState,
      required String uuidProfile,
      required String uuidContentItem,
      Value<bool> favorito,
      Value<int> progresoPorcentaje,
      Value<int> ultimaPosicionSegundos,
      Value<bool> completado,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$UserContentStatesTableTableUpdateCompanionBuilder =
    UserContentStatesTableCompanion Function({
      Value<String> uuidUserContentState,
      Value<String> uuidProfile,
      Value<String> uuidContentItem,
      Value<bool> favorito,
      Value<int> progresoPorcentaje,
      Value<int> ultimaPosicionSegundos,
      Value<bool> completado,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$UserContentStatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserContentStatesTableTable> {
  $$UserContentStatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidUserContentState => $composableBuilder(
    column: $table.uuidUserContentState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorito => $composableBuilder(
    column: $table.favorito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progresoPorcentaje => $composableBuilder(
    column: $table.progresoPorcentaje,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ultimaPosicionSegundos => $composableBuilder(
    column: $table.ultimaPosicionSegundos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserContentStatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserContentStatesTableTable> {
  $$UserContentStatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidUserContentState => $composableBuilder(
    column: $table.uuidUserContentState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorito => $composableBuilder(
    column: $table.favorito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progresoPorcentaje => $composableBuilder(
    column: $table.progresoPorcentaje,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ultimaPosicionSegundos => $composableBuilder(
    column: $table.ultimaPosicionSegundos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserContentStatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserContentStatesTableTable> {
  $$UserContentStatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidUserContentState => $composableBuilder(
    column: $table.uuidUserContentState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidContentItem => $composableBuilder(
    column: $table.uuidContentItem,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get favorito =>
      $composableBuilder(column: $table.favorito, builder: (column) => column);

  GeneratedColumn<int> get progresoPorcentaje => $composableBuilder(
    column: $table.progresoPorcentaje,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ultimaPosicionSegundos => $composableBuilder(
    column: $table.ultimaPosicionSegundos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completado => $composableBuilder(
    column: $table.completado,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$UserContentStatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserContentStatesTableTable,
          LocalUserContentState,
          $$UserContentStatesTableTableFilterComposer,
          $$UserContentStatesTableTableOrderingComposer,
          $$UserContentStatesTableTableAnnotationComposer,
          $$UserContentStatesTableTableCreateCompanionBuilder,
          $$UserContentStatesTableTableUpdateCompanionBuilder,
          (
            LocalUserContentState,
            BaseReferences<
              _$AppDatabase,
              $UserContentStatesTableTable,
              LocalUserContentState
            >,
          ),
          LocalUserContentState,
          PrefetchHooks Function()
        > {
  $$UserContentStatesTableTableTableManager(
    _$AppDatabase db,
    $UserContentStatesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserContentStatesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UserContentStatesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UserContentStatesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidUserContentState = const Value.absent(),
                Value<String> uuidProfile = const Value.absent(),
                Value<String> uuidContentItem = const Value.absent(),
                Value<bool> favorito = const Value.absent(),
                Value<int> progresoPorcentaje = const Value.absent(),
                Value<int> ultimaPosicionSegundos = const Value.absent(),
                Value<bool> completado = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserContentStatesTableCompanion(
                uuidUserContentState: uuidUserContentState,
                uuidProfile: uuidProfile,
                uuidContentItem: uuidContentItem,
                favorito: favorito,
                progresoPorcentaje: progresoPorcentaje,
                ultimaPosicionSegundos: ultimaPosicionSegundos,
                completado: completado,
                startedAt: startedAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidUserContentState,
                required String uuidProfile,
                required String uuidContentItem,
                Value<bool> favorito = const Value.absent(),
                Value<int> progresoPorcentaje = const Value.absent(),
                Value<int> ultimaPosicionSegundos = const Value.absent(),
                Value<bool> completado = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserContentStatesTableCompanion.insert(
                uuidUserContentState: uuidUserContentState,
                uuidProfile: uuidProfile,
                uuidContentItem: uuidContentItem,
                favorito: favorito,
                progresoPorcentaje: progresoPorcentaje,
                ultimaPosicionSegundos: ultimaPosicionSegundos,
                completado: completado,
                startedAt: startedAt,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserContentStatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserContentStatesTableTable,
      LocalUserContentState,
      $$UserContentStatesTableTableFilterComposer,
      $$UserContentStatesTableTableOrderingComposer,
      $$UserContentStatesTableTableAnnotationComposer,
      $$UserContentStatesTableTableCreateCompanionBuilder,
      $$UserContentStatesTableTableUpdateCompanionBuilder,
      (
        LocalUserContentState,
        BaseReferences<
          _$AppDatabase,
          $UserContentStatesTableTable,
          LocalUserContentState
        >,
      ),
      LocalUserContentState,
      PrefetchHooks Function()
    >;
typedef $$WellnessDailyLogsTableTableCreateCompanionBuilder =
    WellnessDailyLogsTableCompanion Function({
      required String uuidDailyLog,
      required String uuidProfile,
      required String fecha,
      Value<String?> mood,
      Value<int> energia,
      Value<int> calma,
      Value<int> descanso,
      Value<int> conexion,
      Value<bool> meditacionCompletada,
      Value<int> minutosBienestar,
      Value<String?> nota,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$WellnessDailyLogsTableTableUpdateCompanionBuilder =
    WellnessDailyLogsTableCompanion Function({
      Value<String> uuidDailyLog,
      Value<String> uuidProfile,
      Value<String> fecha,
      Value<String?> mood,
      Value<int> energia,
      Value<int> calma,
      Value<int> descanso,
      Value<int> conexion,
      Value<bool> meditacionCompletada,
      Value<int> minutosBienestar,
      Value<String?> nota,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$WellnessDailyLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WellnessDailyLogsTableTable> {
  $$WellnessDailyLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidDailyLog => $composableBuilder(
    column: $table.uuidDailyLog,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energia => $composableBuilder(
    column: $table.energia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calma => $composableBuilder(
    column: $table.calma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get descanso => $composableBuilder(
    column: $table.descanso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conexion => $composableBuilder(
    column: $table.conexion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get meditacionCompletada => $composableBuilder(
    column: $table.meditacionCompletada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutosBienestar => $composableBuilder(
    column: $table.minutosBienestar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellnessDailyLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WellnessDailyLogsTableTable> {
  $$WellnessDailyLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidDailyLog => $composableBuilder(
    column: $table.uuidDailyLog,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energia => $composableBuilder(
    column: $table.energia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calma => $composableBuilder(
    column: $table.calma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get descanso => $composableBuilder(
    column: $table.descanso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conexion => $composableBuilder(
    column: $table.conexion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get meditacionCompletada => $composableBuilder(
    column: $table.meditacionCompletada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutosBienestar => $composableBuilder(
    column: $table.minutosBienestar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellnessDailyLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellnessDailyLogsTableTable> {
  $$WellnessDailyLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidDailyLog => $composableBuilder(
    column: $table.uuidDailyLog,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<int> get energia =>
      $composableBuilder(column: $table.energia, builder: (column) => column);

  GeneratedColumn<int> get calma =>
      $composableBuilder(column: $table.calma, builder: (column) => column);

  GeneratedColumn<int> get descanso =>
      $composableBuilder(column: $table.descanso, builder: (column) => column);

  GeneratedColumn<int> get conexion =>
      $composableBuilder(column: $table.conexion, builder: (column) => column);

  GeneratedColumn<bool> get meditacionCompletada => $composableBuilder(
    column: $table.meditacionCompletada,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutosBienestar => $composableBuilder(
    column: $table.minutosBienestar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$WellnessDailyLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellnessDailyLogsTableTable,
          LocalWellnessDailyLog,
          $$WellnessDailyLogsTableTableFilterComposer,
          $$WellnessDailyLogsTableTableOrderingComposer,
          $$WellnessDailyLogsTableTableAnnotationComposer,
          $$WellnessDailyLogsTableTableCreateCompanionBuilder,
          $$WellnessDailyLogsTableTableUpdateCompanionBuilder,
          (
            LocalWellnessDailyLog,
            BaseReferences<
              _$AppDatabase,
              $WellnessDailyLogsTableTable,
              LocalWellnessDailyLog
            >,
          ),
          LocalWellnessDailyLog,
          PrefetchHooks Function()
        > {
  $$WellnessDailyLogsTableTableTableManager(
    _$AppDatabase db,
    $WellnessDailyLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellnessDailyLogsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WellnessDailyLogsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WellnessDailyLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidDailyLog = const Value.absent(),
                Value<String> uuidProfile = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<int> energia = const Value.absent(),
                Value<int> calma = const Value.absent(),
                Value<int> descanso = const Value.absent(),
                Value<int> conexion = const Value.absent(),
                Value<bool> meditacionCompletada = const Value.absent(),
                Value<int> minutosBienestar = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessDailyLogsTableCompanion(
                uuidDailyLog: uuidDailyLog,
                uuidProfile: uuidProfile,
                fecha: fecha,
                mood: mood,
                energia: energia,
                calma: calma,
                descanso: descanso,
                conexion: conexion,
                meditacionCompletada: meditacionCompletada,
                minutosBienestar: minutosBienestar,
                nota: nota,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidDailyLog,
                required String uuidProfile,
                required String fecha,
                Value<String?> mood = const Value.absent(),
                Value<int> energia = const Value.absent(),
                Value<int> calma = const Value.absent(),
                Value<int> descanso = const Value.absent(),
                Value<int> conexion = const Value.absent(),
                Value<bool> meditacionCompletada = const Value.absent(),
                Value<int> minutosBienestar = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessDailyLogsTableCompanion.insert(
                uuidDailyLog: uuidDailyLog,
                uuidProfile: uuidProfile,
                fecha: fecha,
                mood: mood,
                energia: energia,
                calma: calma,
                descanso: descanso,
                conexion: conexion,
                meditacionCompletada: meditacionCompletada,
                minutosBienestar: minutosBienestar,
                nota: nota,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellnessDailyLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellnessDailyLogsTableTable,
      LocalWellnessDailyLog,
      $$WellnessDailyLogsTableTableFilterComposer,
      $$WellnessDailyLogsTableTableOrderingComposer,
      $$WellnessDailyLogsTableTableAnnotationComposer,
      $$WellnessDailyLogsTableTableCreateCompanionBuilder,
      $$WellnessDailyLogsTableTableUpdateCompanionBuilder,
      (
        LocalWellnessDailyLog,
        BaseReferences<
          _$AppDatabase,
          $WellnessDailyLogsTableTable,
          LocalWellnessDailyLog
        >,
      ),
      LocalWellnessDailyLog,
      PrefetchHooks Function()
    >;
typedef $$WellnessProfileStatsTableTableCreateCompanionBuilder =
    WellnessProfileStatsTableCompanion Function({
      required String uuidProfile,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastActivityDate,
      Value<int> totalActiveDays,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });
typedef $$WellnessProfileStatsTableTableUpdateCompanionBuilder =
    WellnessProfileStatsTableCompanion Function({
      Value<String> uuidProfile,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<String?> lastActivityDate,
      Value<int> totalActiveDays,
      Value<DateTime> updatedAt,
      Value<DateTime?> syncedAt,
      Value<int> rowid,
    });

class $$WellnessProfileStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WellnessProfileStatsTableTable> {
  $$WellnessProfileStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalActiveDays => $composableBuilder(
    column: $table.totalActiveDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WellnessProfileStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WellnessProfileStatsTableTable> {
  $$WellnessProfileStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalActiveDays => $composableBuilder(
    column: $table.totalActiveDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WellnessProfileStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WellnessProfileStatsTableTable> {
  $$WellnessProfileStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuidProfile => $composableBuilder(
    column: $table.uuidProfile,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastActivityDate => $composableBuilder(
    column: $table.lastActivityDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalActiveDays => $composableBuilder(
    column: $table.totalActiveDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$WellnessProfileStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WellnessProfileStatsTableTable,
          LocalWellnessProfileStats,
          $$WellnessProfileStatsTableTableFilterComposer,
          $$WellnessProfileStatsTableTableOrderingComposer,
          $$WellnessProfileStatsTableTableAnnotationComposer,
          $$WellnessProfileStatsTableTableCreateCompanionBuilder,
          $$WellnessProfileStatsTableTableUpdateCompanionBuilder,
          (
            LocalWellnessProfileStats,
            BaseReferences<
              _$AppDatabase,
              $WellnessProfileStatsTableTable,
              LocalWellnessProfileStats
            >,
          ),
          LocalWellnessProfileStats,
          PrefetchHooks Function()
        > {
  $$WellnessProfileStatsTableTableTableManager(
    _$AppDatabase db,
    $WellnessProfileStatsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WellnessProfileStatsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WellnessProfileStatsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WellnessProfileStatsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> uuidProfile = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastActivityDate = const Value.absent(),
                Value<int> totalActiveDays = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessProfileStatsTableCompanion(
                uuidProfile: uuidProfile,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastActivityDate: lastActivityDate,
                totalActiveDays: totalActiveDays,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuidProfile,
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastActivityDate = const Value.absent(),
                Value<int> totalActiveDays = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WellnessProfileStatsTableCompanion.insert(
                uuidProfile: uuidProfile,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                lastActivityDate: lastActivityDate,
                totalActiveDays: totalActiveDays,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WellnessProfileStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WellnessProfileStatsTableTable,
      LocalWellnessProfileStats,
      $$WellnessProfileStatsTableTableFilterComposer,
      $$WellnessProfileStatsTableTableOrderingComposer,
      $$WellnessProfileStatsTableTableAnnotationComposer,
      $$WellnessProfileStatsTableTableCreateCompanionBuilder,
      $$WellnessProfileStatsTableTableUpdateCompanionBuilder,
      (
        LocalWellnessProfileStats,
        BaseReferences<
          _$AppDatabase,
          $WellnessProfileStatsTableTable,
          LocalWellnessProfileStats
        >,
      ),
      LocalWellnessProfileStats,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableTableManager get profilesTable =>
      $$ProfilesTableTableTableManager(_db, _db.profilesTable);
  $$CompanyInfoTableTableTableManager get companyInfoTable =>
      $$CompanyInfoTableTableTableManager(_db, _db.companyInfoTable);
  $$ContentDownloadsTableTableTableManager get contentDownloadsTable =>
      $$ContentDownloadsTableTableTableManager(_db, _db.contentDownloadsTable);
  $$ContentItemsTableTableTableManager get contentItemsTable =>
      $$ContentItemsTableTableTableManager(_db, _db.contentItemsTable);
  $$ContentMediaTableTableTableManager get contentMediaTable =>
      $$ContentMediaTableTableTableManager(_db, _db.contentMediaTable);
  $$NotificationDevicesTableTableTableManager get notificationDevicesTable =>
      $$NotificationDevicesTableTableTableManager(
        _db,
        _db.notificationDevicesTable,
      );
  $$NotificationEventsTableTableTableManager get notificationEventsTable =>
      $$NotificationEventsTableTableTableManager(
        _db,
        _db.notificationEventsTable,
      );
  $$NotificationDispatchesTableTableTableManager
  get notificationDispatchesTable =>
      $$NotificationDispatchesTableTableTableManager(
        _db,
        _db.notificationDispatchesTable,
      );
  $$NotificationsInboxTableTableTableManager get notificationsInboxTable =>
      $$NotificationsInboxTableTableTableManager(
        _db,
        _db.notificationsInboxTable,
      );
  $$UserContentStatesTableTableTableManager get userContentStatesTable =>
      $$UserContentStatesTableTableTableManager(
        _db,
        _db.userContentStatesTable,
      );
  $$WellnessDailyLogsTableTableTableManager get wellnessDailyLogsTable =>
      $$WellnessDailyLogsTableTableTableManager(
        _db,
        _db.wellnessDailyLogsTable,
      );
  $$WellnessProfileStatsTableTableTableManager get wellnessProfileStatsTable =>
      $$WellnessProfileStatsTableTableTableManager(
        _db,
        _db.wellnessProfileStatsTable,
      );
}
