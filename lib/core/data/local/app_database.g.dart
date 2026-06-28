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
  late final $ContentItemsTableTable contentItemsTable =
      $ContentItemsTableTable(this);
  late final $ContentMediaTableTable contentMediaTable =
      $ContentMediaTableTable(this);
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
    contentItemsTable,
    contentMediaTable,
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
  $$ContentItemsTableTableTableManager get contentItemsTable =>
      $$ContentItemsTableTableTableManager(_db, _db.contentItemsTable);
  $$ContentMediaTableTableTableManager get contentMediaTable =>
      $$ContentMediaTableTableTableManager(_db, _db.contentMediaTable);
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
