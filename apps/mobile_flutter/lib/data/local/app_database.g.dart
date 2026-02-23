// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CitiesTable extends Cities with TableInfo<$CitiesTable, City> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
      'slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameRuMeta = const VerificationMeta('nameRu');
  @override
  late final GeneratedColumn<String> nameRu = GeneratedColumn<String>(
      'name_ru', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, slug, nameRu, isActive, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cities';
  @override
  VerificationContext validateIntegrity(Insertable<City> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
          _slugMeta, slug.isAcceptableOrUnknown(data['slug']!, _slugMeta));
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name_ru')) {
      context.handle(_nameRuMeta,
          nameRu.isAcceptableOrUnknown(data['name_ru']!, _nameRuMeta));
    } else if (isInserting) {
      context.missing(_nameRuMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  City map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return City(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      slug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}slug'])!,
      nameRu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ru'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $CitiesTable createAlias(String alias) {
    return $CitiesTable(attachedDatabase, alias);
  }
}

class City extends DataClass implements Insertable<City> {
  final String id;
  final String slug;
  final String nameRu;
  final bool isActive;
  final DateTime? updatedAt;
  const City(
      {required this.id,
      required this.slug,
      required this.nameRu,
      required this.isActive,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['name_ru'] = Variable<String>(nameRu);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CitiesCompanion toCompanion(bool nullToAbsent) {
    return CitiesCompanion(
      id: Value(id),
      slug: Value(slug),
      nameRu: Value(nameRu),
      isActive: Value(isActive),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory City.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return City(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      nameRu: serializer.fromJson<String>(json['nameRu']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'nameRu': serializer.toJson<String>(nameRu),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  City copyWith(
          {String? id,
          String? slug,
          String? nameRu,
          bool? isActive,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      City(
        id: id ?? this.id,
        slug: slug ?? this.slug,
        nameRu: nameRu ?? this.nameRu,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  City copyWithCompanion(CitiesCompanion data) {
    return City(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      nameRu: data.nameRu.present ? data.nameRu.value : this.nameRu,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('City(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameRu: $nameRu, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, slug, nameRu, isActive, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is City &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.nameRu == this.nameRu &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CitiesCompanion extends UpdateCompanion<City> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> nameRu;
  final Value<bool> isActive;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const CitiesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.nameRu = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CitiesCompanion.insert({
    required String id,
    required String slug,
    required String nameRu,
    required bool isActive,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        slug = Value(slug),
        nameRu = Value(nameRu),
        isActive = Value(isActive);
  static Insertable<City> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? nameRu,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (nameRu != null) 'name_ru': nameRu,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? slug,
      Value<String>? nameRu,
      Value<bool>? isActive,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return CitiesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      nameRu: nameRu ?? this.nameRu,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (nameRu.present) {
      map['name_ru'] = Variable<String>(nameRu.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('CitiesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('nameRu: $nameRu, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToursTable extends Tours with TableInfo<$ToursTable, Tour> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToursTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _citySlugMeta =
      const VerificationMeta('citySlug');
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
      'city_slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleRuMeta =
      const VerificationMeta('titleRu');
  @override
  late final GeneratedColumn<String> titleRu = GeneratedColumn<String>(
      'title_ru', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionRuMeta =
      const VerificationMeta('descriptionRu');
  @override
  late final GeneratedColumn<String> descriptionRu = GeneratedColumn<String>(
      'description_ru', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverImageMeta =
      const VerificationMeta('coverImage');
  @override
  late final GeneratedColumn<String> coverImage = GeneratedColumn<String>(
      'cover_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _transportTypeMeta =
      const VerificationMeta('transportType');
  @override
  late final GeneratedColumn<String> transportType = GeneratedColumn<String>(
      'transport_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _distanceKmMeta =
      const VerificationMeta('distanceKm');
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
      'distance_km', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _tourTypeMeta =
      const VerificationMeta('tourType');
  @override
  late final GeneratedColumn<String> tourType = GeneratedColumn<String>(
      'tour_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('walking'));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('easy'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        citySlug,
        titleRu,
        descriptionRu,
        coverImage,
        durationMinutes,
        transportType,
        distanceKm,
        tourType,
        difficulty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tours';
  @override
  VerificationContext validateIntegrity(Insertable<Tour> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('city_slug')) {
      context.handle(_citySlugMeta,
          citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta));
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('title_ru')) {
      context.handle(_titleRuMeta,
          titleRu.isAcceptableOrUnknown(data['title_ru']!, _titleRuMeta));
    } else if (isInserting) {
      context.missing(_titleRuMeta);
    }
    if (data.containsKey('description_ru')) {
      context.handle(
          _descriptionRuMeta,
          descriptionRu.isAcceptableOrUnknown(
              data['description_ru']!, _descriptionRuMeta));
    }
    if (data.containsKey('cover_image')) {
      context.handle(
          _coverImageMeta,
          coverImage.isAcceptableOrUnknown(
              data['cover_image']!, _coverImageMeta));
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    }
    if (data.containsKey('transport_type')) {
      context.handle(
          _transportTypeMeta,
          transportType.isAcceptableOrUnknown(
              data['transport_type']!, _transportTypeMeta));
    }
    if (data.containsKey('distance_km')) {
      context.handle(
          _distanceKmMeta,
          distanceKm.isAcceptableOrUnknown(
              data['distance_km']!, _distanceKmMeta));
    }
    if (data.containsKey('tour_type')) {
      context.handle(_tourTypeMeta,
          tourType.isAcceptableOrUnknown(data['tour_type']!, _tourTypeMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tour map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tour(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      citySlug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_slug'])!,
      titleRu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_ru'])!,
      descriptionRu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description_ru']),
      coverImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image']),
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes']),
      transportType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transport_type']),
      distanceKm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance_km']),
      tourType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tour_type'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
    );
  }

  @override
  $ToursTable createAlias(String alias) {
    return $ToursTable(attachedDatabase, alias);
  }
}

class Tour extends DataClass implements Insertable<Tour> {
  final String id;
  final String citySlug;
  final String titleRu;
  final String? descriptionRu;
  final String? coverImage;
  final int? durationMinutes;
  final String? transportType;
  final double? distanceKm;
  final String tourType;
  final String difficulty;
  const Tour(
      {required this.id,
      required this.citySlug,
      required this.titleRu,
      this.descriptionRu,
      this.coverImage,
      this.durationMinutes,
      this.transportType,
      this.distanceKm,
      required this.tourType,
      required this.difficulty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['city_slug'] = Variable<String>(citySlug);
    map['title_ru'] = Variable<String>(titleRu);
    if (!nullToAbsent || descriptionRu != null) {
      map['description_ru'] = Variable<String>(descriptionRu);
    }
    if (!nullToAbsent || coverImage != null) {
      map['cover_image'] = Variable<String>(coverImage);
    }
    if (!nullToAbsent || durationMinutes != null) {
      map['duration_minutes'] = Variable<int>(durationMinutes);
    }
    if (!nullToAbsent || transportType != null) {
      map['transport_type'] = Variable<String>(transportType);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    map['tour_type'] = Variable<String>(tourType);
    map['difficulty'] = Variable<String>(difficulty);
    return map;
  }

  ToursCompanion toCompanion(bool nullToAbsent) {
    return ToursCompanion(
      id: Value(id),
      citySlug: Value(citySlug),
      titleRu: Value(titleRu),
      descriptionRu: descriptionRu == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionRu),
      coverImage: coverImage == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImage),
      durationMinutes: durationMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMinutes),
      transportType: transportType == null && nullToAbsent
          ? const Value.absent()
          : Value(transportType),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      tourType: Value(tourType),
      difficulty: Value(difficulty),
    );
  }

  factory Tour.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tour(
      id: serializer.fromJson<String>(json['id']),
      citySlug: serializer.fromJson<String>(json['citySlug']),
      titleRu: serializer.fromJson<String>(json['titleRu']),
      descriptionRu: serializer.fromJson<String?>(json['descriptionRu']),
      coverImage: serializer.fromJson<String?>(json['coverImage']),
      durationMinutes: serializer.fromJson<int?>(json['durationMinutes']),
      transportType: serializer.fromJson<String?>(json['transportType']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      tourType: serializer.fromJson<String>(json['tourType']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'citySlug': serializer.toJson<String>(citySlug),
      'titleRu': serializer.toJson<String>(titleRu),
      'descriptionRu': serializer.toJson<String?>(descriptionRu),
      'coverImage': serializer.toJson<String?>(coverImage),
      'durationMinutes': serializer.toJson<int?>(durationMinutes),
      'transportType': serializer.toJson<String?>(transportType),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'tourType': serializer.toJson<String>(tourType),
      'difficulty': serializer.toJson<String>(difficulty),
    };
  }

  Tour copyWith(
          {String? id,
          String? citySlug,
          String? titleRu,
          Value<String?> descriptionRu = const Value.absent(),
          Value<String?> coverImage = const Value.absent(),
          Value<int?> durationMinutes = const Value.absent(),
          Value<String?> transportType = const Value.absent(),
          Value<double?> distanceKm = const Value.absent(),
          String? tourType,
          String? difficulty}) =>
      Tour(
        id: id ?? this.id,
        citySlug: citySlug ?? this.citySlug,
        titleRu: titleRu ?? this.titleRu,
        descriptionRu:
            descriptionRu.present ? descriptionRu.value : this.descriptionRu,
        coverImage: coverImage.present ? coverImage.value : this.coverImage,
        durationMinutes: durationMinutes.present
            ? durationMinutes.value
            : this.durationMinutes,
        transportType:
            transportType.present ? transportType.value : this.transportType,
        distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
        tourType: tourType ?? this.tourType,
        difficulty: difficulty ?? this.difficulty,
      );
  Tour copyWithCompanion(ToursCompanion data) {
    return Tour(
      id: data.id.present ? data.id.value : this.id,
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      titleRu: data.titleRu.present ? data.titleRu.value : this.titleRu,
      descriptionRu: data.descriptionRu.present
          ? data.descriptionRu.value
          : this.descriptionRu,
      coverImage:
          data.coverImage.present ? data.coverImage.value : this.coverImage,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      transportType: data.transportType.present
          ? data.transportType.value
          : this.transportType,
      distanceKm:
          data.distanceKm.present ? data.distanceKm.value : this.distanceKm,
      tourType: data.tourType.present ? data.tourType.value : this.tourType,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tour(')
          ..write('id: $id, ')
          ..write('citySlug: $citySlug, ')
          ..write('titleRu: $titleRu, ')
          ..write('descriptionRu: $descriptionRu, ')
          ..write('coverImage: $coverImage, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('transportType: $transportType, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('tourType: $tourType, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      citySlug,
      titleRu,
      descriptionRu,
      coverImage,
      durationMinutes,
      transportType,
      distanceKm,
      tourType,
      difficulty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tour &&
          other.id == this.id &&
          other.citySlug == this.citySlug &&
          other.titleRu == this.titleRu &&
          other.descriptionRu == this.descriptionRu &&
          other.coverImage == this.coverImage &&
          other.durationMinutes == this.durationMinutes &&
          other.transportType == this.transportType &&
          other.distanceKm == this.distanceKm &&
          other.tourType == this.tourType &&
          other.difficulty == this.difficulty);
}

class ToursCompanion extends UpdateCompanion<Tour> {
  final Value<String> id;
  final Value<String> citySlug;
  final Value<String> titleRu;
  final Value<String?> descriptionRu;
  final Value<String?> coverImage;
  final Value<int?> durationMinutes;
  final Value<String?> transportType;
  final Value<double?> distanceKm;
  final Value<String> tourType;
  final Value<String> difficulty;
  final Value<int> rowid;
  const ToursCompanion({
    this.id = const Value.absent(),
    this.citySlug = const Value.absent(),
    this.titleRu = const Value.absent(),
    this.descriptionRu = const Value.absent(),
    this.coverImage = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.transportType = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.tourType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ToursCompanion.insert({
    required String id,
    required String citySlug,
    required String titleRu,
    this.descriptionRu = const Value.absent(),
    this.coverImage = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.transportType = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.tourType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        citySlug = Value(citySlug),
        titleRu = Value(titleRu);
  static Insertable<Tour> custom({
    Expression<String>? id,
    Expression<String>? citySlug,
    Expression<String>? titleRu,
    Expression<String>? descriptionRu,
    Expression<String>? coverImage,
    Expression<int>? durationMinutes,
    Expression<String>? transportType,
    Expression<double>? distanceKm,
    Expression<String>? tourType,
    Expression<String>? difficulty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (citySlug != null) 'city_slug': citySlug,
      if (titleRu != null) 'title_ru': titleRu,
      if (descriptionRu != null) 'description_ru': descriptionRu,
      if (coverImage != null) 'cover_image': coverImage,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (transportType != null) 'transport_type': transportType,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (tourType != null) 'tour_type': tourType,
      if (difficulty != null) 'difficulty': difficulty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ToursCompanion copyWith(
      {Value<String>? id,
      Value<String>? citySlug,
      Value<String>? titleRu,
      Value<String?>? descriptionRu,
      Value<String?>? coverImage,
      Value<int?>? durationMinutes,
      Value<String?>? transportType,
      Value<double?>? distanceKm,
      Value<String>? tourType,
      Value<String>? difficulty,
      Value<int>? rowid}) {
    return ToursCompanion(
      id: id ?? this.id,
      citySlug: citySlug ?? this.citySlug,
      titleRu: titleRu ?? this.titleRu,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      coverImage: coverImage ?? this.coverImage,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      transportType: transportType ?? this.transportType,
      distanceKm: distanceKm ?? this.distanceKm,
      tourType: tourType ?? this.tourType,
      difficulty: difficulty ?? this.difficulty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (titleRu.present) {
      map['title_ru'] = Variable<String>(titleRu.value);
    }
    if (descriptionRu.present) {
      map['description_ru'] = Variable<String>(descriptionRu.value);
    }
    if (coverImage.present) {
      map['cover_image'] = Variable<String>(coverImage.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (transportType.present) {
      map['transport_type'] = Variable<String>(transportType.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (tourType.present) {
      map['tour_type'] = Variable<String>(tourType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToursCompanion(')
          ..write('id: $id, ')
          ..write('citySlug: $citySlug, ')
          ..write('titleRu: $titleRu, ')
          ..write('descriptionRu: $descriptionRu, ')
          ..write('coverImage: $coverImage, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('transportType: $transportType, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('tourType: $tourType, ')
          ..write('difficulty: $difficulty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoisTable extends Pois with TableInfo<$PoisTable, Poi> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _citySlugMeta =
      const VerificationMeta('citySlug');
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
      'city_slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleRuMeta =
      const VerificationMeta('titleRu');
  @override
  late final GeneratedColumn<String> titleRu = GeneratedColumn<String>(
      'title_ru', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionRuMeta =
      const VerificationMeta('descriptionRu');
  @override
  late final GeneratedColumn<String> descriptionRu = GeneratedColumn<String>(
      'description_ru', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _previewAudioUrlMeta =
      const VerificationMeta('previewAudioUrl');
  @override
  late final GeneratedColumn<String> previewAudioUrl = GeneratedColumn<String>(
      'preview_audio_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hasAccessMeta =
      const VerificationMeta('hasAccess');
  @override
  late final GeneratedColumn<bool> hasAccess = GeneratedColumn<bool>(
      'has_access', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("has_access" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wikidataIdMeta =
      const VerificationMeta('wikidataId');
  @override
  late final GeneratedColumn<String> wikidataId = GeneratedColumn<String>(
      'wikidata_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _osmIdMeta = const VerificationMeta('osmId');
  @override
  late final GeneratedColumn<String> osmId = GeneratedColumn<String>(
      'osm_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceScoreMeta =
      const VerificationMeta('confidenceScore');
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
      'confidence_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _openingHoursMeta =
      const VerificationMeta('openingHours');
  @override
  late final GeneratedColumn<String> openingHours = GeneratedColumn<String>(
      'opening_hours', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _externalLinksMeta =
      const VerificationMeta('externalLinks');
  @override
  late final GeneratedColumn<String> externalLinks = GeneratedColumn<String>(
      'external_links', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        citySlug,
        titleRu,
        descriptionRu,
        lat,
        lon,
        previewAudioUrl,
        hasAccess,
        isFavorite,
        category,
        wikidataId,
        osmId,
        confidenceScore,
        openingHours,
        externalLinks
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pois';
  @override
  VerificationContext validateIntegrity(Insertable<Poi> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('city_slug')) {
      context.handle(_citySlugMeta,
          citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta));
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('title_ru')) {
      context.handle(_titleRuMeta,
          titleRu.isAcceptableOrUnknown(data['title_ru']!, _titleRuMeta));
    } else if (isInserting) {
      context.missing(_titleRuMeta);
    }
    if (data.containsKey('description_ru')) {
      context.handle(
          _descriptionRuMeta,
          descriptionRu.isAcceptableOrUnknown(
              data['description_ru']!, _descriptionRuMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('preview_audio_url')) {
      context.handle(
          _previewAudioUrlMeta,
          previewAudioUrl.isAcceptableOrUnknown(
              data['preview_audio_url']!, _previewAudioUrlMeta));
    }
    if (data.containsKey('has_access')) {
      context.handle(_hasAccessMeta,
          hasAccess.isAcceptableOrUnknown(data['has_access']!, _hasAccessMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('wikidata_id')) {
      context.handle(
          _wikidataIdMeta,
          wikidataId.isAcceptableOrUnknown(
              data['wikidata_id']!, _wikidataIdMeta));
    }
    if (data.containsKey('osm_id')) {
      context.handle(
          _osmIdMeta, osmId.isAcceptableOrUnknown(data['osm_id']!, _osmIdMeta));
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
          _confidenceScoreMeta,
          confidenceScore.isAcceptableOrUnknown(
              data['confidence_score']!, _confidenceScoreMeta));
    }
    if (data.containsKey('opening_hours')) {
      context.handle(
          _openingHoursMeta,
          openingHours.isAcceptableOrUnknown(
              data['opening_hours']!, _openingHoursMeta));
    }
    if (data.containsKey('external_links')) {
      context.handle(
          _externalLinksMeta,
          externalLinks.isAcceptableOrUnknown(
              data['external_links']!, _externalLinksMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {citySlug, osmId},
        {citySlug, category},
      ];
  @override
  Poi map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Poi(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      citySlug: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_slug'])!,
      titleRu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title_ru'])!,
      descriptionRu: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description_ru']),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      previewAudioUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preview_audio_url']),
      hasAccess: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_access'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      wikidataId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wikidata_id']),
      osmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}osm_id']),
      confidenceScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}confidence_score'])!,
      openingHours: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opening_hours']),
      externalLinks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}external_links']),
    );
  }

  @override
  $PoisTable createAlias(String alias) {
    return $PoisTable(attachedDatabase, alias);
  }
}

class Poi extends DataClass implements Insertable<Poi> {
  final String id;
  final String citySlug;
  final String titleRu;
  final String? descriptionRu;
  final double lat;
  final double lon;
  final String? previewAudioUrl;
  final bool hasAccess;
  final bool isFavorite;
  final String? category;
  final String? wikidataId;
  final String? osmId;
  final double confidenceScore;
  final String? openingHours;
  final String? externalLinks;
  const Poi(
      {required this.id,
      required this.citySlug,
      required this.titleRu,
      this.descriptionRu,
      required this.lat,
      required this.lon,
      this.previewAudioUrl,
      required this.hasAccess,
      required this.isFavorite,
      this.category,
      this.wikidataId,
      this.osmId,
      required this.confidenceScore,
      this.openingHours,
      this.externalLinks});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['city_slug'] = Variable<String>(citySlug);
    map['title_ru'] = Variable<String>(titleRu);
    if (!nullToAbsent || descriptionRu != null) {
      map['description_ru'] = Variable<String>(descriptionRu);
    }
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    if (!nullToAbsent || previewAudioUrl != null) {
      map['preview_audio_url'] = Variable<String>(previewAudioUrl);
    }
    map['has_access'] = Variable<bool>(hasAccess);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || wikidataId != null) {
      map['wikidata_id'] = Variable<String>(wikidataId);
    }
    if (!nullToAbsent || osmId != null) {
      map['osm_id'] = Variable<String>(osmId);
    }
    map['confidence_score'] = Variable<double>(confidenceScore);
    if (!nullToAbsent || openingHours != null) {
      map['opening_hours'] = Variable<String>(openingHours);
    }
    if (!nullToAbsent || externalLinks != null) {
      map['external_links'] = Variable<String>(externalLinks);
    }
    return map;
  }

  PoisCompanion toCompanion(bool nullToAbsent) {
    return PoisCompanion(
      id: Value(id),
      citySlug: Value(citySlug),
      titleRu: Value(titleRu),
      descriptionRu: descriptionRu == null && nullToAbsent
          ? const Value.absent()
          : Value(descriptionRu),
      lat: Value(lat),
      lon: Value(lon),
      previewAudioUrl: previewAudioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(previewAudioUrl),
      hasAccess: Value(hasAccess),
      isFavorite: Value(isFavorite),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      wikidataId: wikidataId == null && nullToAbsent
          ? const Value.absent()
          : Value(wikidataId),
      osmId:
          osmId == null && nullToAbsent ? const Value.absent() : Value(osmId),
      confidenceScore: Value(confidenceScore),
      openingHours: openingHours == null && nullToAbsent
          ? const Value.absent()
          : Value(openingHours),
      externalLinks: externalLinks == null && nullToAbsent
          ? const Value.absent()
          : Value(externalLinks),
    );
  }

  factory Poi.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Poi(
      id: serializer.fromJson<String>(json['id']),
      citySlug: serializer.fromJson<String>(json['citySlug']),
      titleRu: serializer.fromJson<String>(json['titleRu']),
      descriptionRu: serializer.fromJson<String?>(json['descriptionRu']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      previewAudioUrl: serializer.fromJson<String?>(json['previewAudioUrl']),
      hasAccess: serializer.fromJson<bool>(json['hasAccess']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      category: serializer.fromJson<String?>(json['category']),
      wikidataId: serializer.fromJson<String?>(json['wikidataId']),
      osmId: serializer.fromJson<String?>(json['osmId']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      openingHours: serializer.fromJson<String?>(json['openingHours']),
      externalLinks: serializer.fromJson<String?>(json['externalLinks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'citySlug': serializer.toJson<String>(citySlug),
      'titleRu': serializer.toJson<String>(titleRu),
      'descriptionRu': serializer.toJson<String?>(descriptionRu),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'previewAudioUrl': serializer.toJson<String?>(previewAudioUrl),
      'hasAccess': serializer.toJson<bool>(hasAccess),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'category': serializer.toJson<String?>(category),
      'wikidataId': serializer.toJson<String?>(wikidataId),
      'osmId': serializer.toJson<String?>(osmId),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'openingHours': serializer.toJson<String?>(openingHours),
      'externalLinks': serializer.toJson<String?>(externalLinks),
    };
  }

  Poi copyWith(
          {String? id,
          String? citySlug,
          String? titleRu,
          Value<String?> descriptionRu = const Value.absent(),
          double? lat,
          double? lon,
          Value<String?> previewAudioUrl = const Value.absent(),
          bool? hasAccess,
          bool? isFavorite,
          Value<String?> category = const Value.absent(),
          Value<String?> wikidataId = const Value.absent(),
          Value<String?> osmId = const Value.absent(),
          double? confidenceScore,
          Value<String?> openingHours = const Value.absent(),
          Value<String?> externalLinks = const Value.absent()}) =>
      Poi(
        id: id ?? this.id,
        citySlug: citySlug ?? this.citySlug,
        titleRu: titleRu ?? this.titleRu,
        descriptionRu:
            descriptionRu.present ? descriptionRu.value : this.descriptionRu,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        previewAudioUrl: previewAudioUrl.present
            ? previewAudioUrl.value
            : this.previewAudioUrl,
        hasAccess: hasAccess ?? this.hasAccess,
        isFavorite: isFavorite ?? this.isFavorite,
        category: category.present ? category.value : this.category,
        wikidataId: wikidataId.present ? wikidataId.value : this.wikidataId,
        osmId: osmId.present ? osmId.value : this.osmId,
        confidenceScore: confidenceScore ?? this.confidenceScore,
        openingHours:
            openingHours.present ? openingHours.value : this.openingHours,
        externalLinks:
            externalLinks.present ? externalLinks.value : this.externalLinks,
      );
  Poi copyWithCompanion(PoisCompanion data) {
    return Poi(
      id: data.id.present ? data.id.value : this.id,
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      titleRu: data.titleRu.present ? data.titleRu.value : this.titleRu,
      descriptionRu: data.descriptionRu.present
          ? data.descriptionRu.value
          : this.descriptionRu,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      previewAudioUrl: data.previewAudioUrl.present
          ? data.previewAudioUrl.value
          : this.previewAudioUrl,
      hasAccess: data.hasAccess.present ? data.hasAccess.value : this.hasAccess,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      category: data.category.present ? data.category.value : this.category,
      wikidataId:
          data.wikidataId.present ? data.wikidataId.value : this.wikidataId,
      osmId: data.osmId.present ? data.osmId.value : this.osmId,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      openingHours: data.openingHours.present
          ? data.openingHours.value
          : this.openingHours,
      externalLinks: data.externalLinks.present
          ? data.externalLinks.value
          : this.externalLinks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Poi(')
          ..write('id: $id, ')
          ..write('citySlug: $citySlug, ')
          ..write('titleRu: $titleRu, ')
          ..write('descriptionRu: $descriptionRu, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('previewAudioUrl: $previewAudioUrl, ')
          ..write('hasAccess: $hasAccess, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('category: $category, ')
          ..write('wikidataId: $wikidataId, ')
          ..write('osmId: $osmId, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('openingHours: $openingHours, ')
          ..write('externalLinks: $externalLinks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      citySlug,
      titleRu,
      descriptionRu,
      lat,
      lon,
      previewAudioUrl,
      hasAccess,
      isFavorite,
      category,
      wikidataId,
      osmId,
      confidenceScore,
      openingHours,
      externalLinks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Poi &&
          other.id == this.id &&
          other.citySlug == this.citySlug &&
          other.titleRu == this.titleRu &&
          other.descriptionRu == this.descriptionRu &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.previewAudioUrl == this.previewAudioUrl &&
          other.hasAccess == this.hasAccess &&
          other.isFavorite == this.isFavorite &&
          other.category == this.category &&
          other.wikidataId == this.wikidataId &&
          other.osmId == this.osmId &&
          other.confidenceScore == this.confidenceScore &&
          other.openingHours == this.openingHours &&
          other.externalLinks == this.externalLinks);
}

class PoisCompanion extends UpdateCompanion<Poi> {
  final Value<String> id;
  final Value<String> citySlug;
  final Value<String> titleRu;
  final Value<String?> descriptionRu;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String?> previewAudioUrl;
  final Value<bool> hasAccess;
  final Value<bool> isFavorite;
  final Value<String?> category;
  final Value<String?> wikidataId;
  final Value<String?> osmId;
  final Value<double> confidenceScore;
  final Value<String?> openingHours;
  final Value<String?> externalLinks;
  final Value<int> rowid;
  const PoisCompanion({
    this.id = const Value.absent(),
    this.citySlug = const Value.absent(),
    this.titleRu = const Value.absent(),
    this.descriptionRu = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.previewAudioUrl = const Value.absent(),
    this.hasAccess = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.category = const Value.absent(),
    this.wikidataId = const Value.absent(),
    this.osmId = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.openingHours = const Value.absent(),
    this.externalLinks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoisCompanion.insert({
    required String id,
    required String citySlug,
    required String titleRu,
    this.descriptionRu = const Value.absent(),
    required double lat,
    required double lon,
    this.previewAudioUrl = const Value.absent(),
    this.hasAccess = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.category = const Value.absent(),
    this.wikidataId = const Value.absent(),
    this.osmId = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.openingHours = const Value.absent(),
    this.externalLinks = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        citySlug = Value(citySlug),
        titleRu = Value(titleRu),
        lat = Value(lat),
        lon = Value(lon);
  static Insertable<Poi> custom({
    Expression<String>? id,
    Expression<String>? citySlug,
    Expression<String>? titleRu,
    Expression<String>? descriptionRu,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? previewAudioUrl,
    Expression<bool>? hasAccess,
    Expression<bool>? isFavorite,
    Expression<String>? category,
    Expression<String>? wikidataId,
    Expression<String>? osmId,
    Expression<double>? confidenceScore,
    Expression<String>? openingHours,
    Expression<String>? externalLinks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (citySlug != null) 'city_slug': citySlug,
      if (titleRu != null) 'title_ru': titleRu,
      if (descriptionRu != null) 'description_ru': descriptionRu,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (previewAudioUrl != null) 'preview_audio_url': previewAudioUrl,
      if (hasAccess != null) 'has_access': hasAccess,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (category != null) 'category': category,
      if (wikidataId != null) 'wikidata_id': wikidataId,
      if (osmId != null) 'osm_id': osmId,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (openingHours != null) 'opening_hours': openingHours,
      if (externalLinks != null) 'external_links': externalLinks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoisCompanion copyWith(
      {Value<String>? id,
      Value<String>? citySlug,
      Value<String>? titleRu,
      Value<String?>? descriptionRu,
      Value<double>? lat,
      Value<double>? lon,
      Value<String?>? previewAudioUrl,
      Value<bool>? hasAccess,
      Value<bool>? isFavorite,
      Value<String?>? category,
      Value<String?>? wikidataId,
      Value<String?>? osmId,
      Value<double>? confidenceScore,
      Value<String?>? openingHours,
      Value<String?>? externalLinks,
      Value<int>? rowid}) {
    return PoisCompanion(
      id: id ?? this.id,
      citySlug: citySlug ?? this.citySlug,
      titleRu: titleRu ?? this.titleRu,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      previewAudioUrl: previewAudioUrl ?? this.previewAudioUrl,
      hasAccess: hasAccess ?? this.hasAccess,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      wikidataId: wikidataId ?? this.wikidataId,
      osmId: osmId ?? this.osmId,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      openingHours: openingHours ?? this.openingHours,
      externalLinks: externalLinks ?? this.externalLinks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (titleRu.present) {
      map['title_ru'] = Variable<String>(titleRu.value);
    }
    if (descriptionRu.present) {
      map['description_ru'] = Variable<String>(descriptionRu.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (previewAudioUrl.present) {
      map['preview_audio_url'] = Variable<String>(previewAudioUrl.value);
    }
    if (hasAccess.present) {
      map['has_access'] = Variable<bool>(hasAccess.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (wikidataId.present) {
      map['wikidata_id'] = Variable<String>(wikidataId.value);
    }
    if (osmId.present) {
      map['osm_id'] = Variable<String>(osmId.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (openingHours.present) {
      map['opening_hours'] = Variable<String>(openingHours.value);
    }
    if (externalLinks.present) {
      map['external_links'] = Variable<String>(externalLinks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoisCompanion(')
          ..write('id: $id, ')
          ..write('citySlug: $citySlug, ')
          ..write('titleRu: $titleRu, ')
          ..write('descriptionRu: $descriptionRu, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('previewAudioUrl: $previewAudioUrl, ')
          ..write('hasAccess: $hasAccess, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('category: $category, ')
          ..write('wikidataId: $wikidataId, ')
          ..write('osmId: $osmId, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('openingHours: $openingHours, ')
          ..write('externalLinks: $externalLinks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TourItemsTable extends TourItems
    with TableInfo<$TourItemsTable, TourItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TourItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tourIdMeta = const VerificationMeta('tourId');
  @override
  late final GeneratedColumn<String> tourId = GeneratedColumn<String>(
      'tour_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tours (id) ON DELETE CASCADE'));
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
      'poi_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pois (id) ON DELETE CASCADE'));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, tourId, poiId, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tour_items';
  @override
  VerificationContext validateIntegrity(Insertable<TourItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tour_id')) {
      context.handle(_tourIdMeta,
          tourId.isAcceptableOrUnknown(data['tour_id']!, _tourIdMeta));
    } else if (isInserting) {
      context.missing(_tourIdMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
          _poiIdMeta, poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta));
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TourItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TourItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tourId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tour_id'])!,
      poiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $TourItemsTable createAlias(String alias) {
    return $TourItemsTable(attachedDatabase, alias);
  }
}

class TourItem extends DataClass implements Insertable<TourItem> {
  final String id;
  final String tourId;
  final String poiId;
  final int orderIndex;
  const TourItem(
      {required this.id,
      required this.tourId,
      required this.poiId,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tour_id'] = Variable<String>(tourId);
    map['poi_id'] = Variable<String>(poiId);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TourItemsCompanion toCompanion(bool nullToAbsent) {
    return TourItemsCompanion(
      id: Value(id),
      tourId: Value(tourId),
      poiId: Value(poiId),
      orderIndex: Value(orderIndex),
    );
  }

  factory TourItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TourItem(
      id: serializer.fromJson<String>(json['id']),
      tourId: serializer.fromJson<String>(json['tourId']),
      poiId: serializer.fromJson<String>(json['poiId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tourId': serializer.toJson<String>(tourId),
      'poiId': serializer.toJson<String>(poiId),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  TourItem copyWith(
          {String? id, String? tourId, String? poiId, int? orderIndex}) =>
      TourItem(
        id: id ?? this.id,
        tourId: tourId ?? this.tourId,
        poiId: poiId ?? this.poiId,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  TourItem copyWithCompanion(TourItemsCompanion data) {
    return TourItem(
      id: data.id.present ? data.id.value : this.id,
      tourId: data.tourId.present ? data.tourId.value : this.tourId,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TourItem(')
          ..write('id: $id, ')
          ..write('tourId: $tourId, ')
          ..write('poiId: $poiId, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tourId, poiId, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TourItem &&
          other.id == this.id &&
          other.tourId == this.tourId &&
          other.poiId == this.poiId &&
          other.orderIndex == this.orderIndex);
}

class TourItemsCompanion extends UpdateCompanion<TourItem> {
  final Value<String> id;
  final Value<String> tourId;
  final Value<String> poiId;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const TourItemsCompanion({
    this.id = const Value.absent(),
    this.tourId = const Value.absent(),
    this.poiId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TourItemsCompanion.insert({
    required String id,
    required String tourId,
    required String poiId,
    required int orderIndex,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tourId = Value(tourId),
        poiId = Value(poiId),
        orderIndex = Value(orderIndex);
  static Insertable<TourItem> custom({
    Expression<String>? id,
    Expression<String>? tourId,
    Expression<String>? poiId,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tourId != null) 'tour_id': tourId,
      if (poiId != null) 'poi_id': poiId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TourItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tourId,
      Value<String>? poiId,
      Value<int>? orderIndex,
      Value<int>? rowid}) {
    return TourItemsCompanion(
      id: id ?? this.id,
      tourId: tourId ?? this.tourId,
      poiId: poiId ?? this.poiId,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tourId.present) {
      map['tour_id'] = Variable<String>(tourId.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TourItemsCompanion(')
          ..write('id: $id, ')
          ..write('tourId: $tourId, ')
          ..write('poiId: $poiId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NarrationsTable extends Narrations
    with TableInfo<$NarrationsTable, Narration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NarrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
      'poi_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pois (id) ON DELETE CASCADE'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
      'duration_seconds', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _transcriptMeta =
      const VerificationMeta('transcript');
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
      'transcript', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _kidsUrlMeta =
      const VerificationMeta('kidsUrl');
  @override
  late final GeneratedColumn<String> kidsUrl = GeneratedColumn<String>(
      'kids_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voiceIdMeta =
      const VerificationMeta('voiceId');
  @override
  late final GeneratedColumn<String> voiceId = GeneratedColumn<String>(
      'voice_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _filesizeBytesMeta =
      const VerificationMeta('filesizeBytes');
  @override
  late final GeneratedColumn<int> filesizeBytes = GeneratedColumn<int>(
      'filesize_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        poiId,
        url,
        locale,
        durationSeconds,
        transcript,
        localPath,
        kidsUrl,
        voiceId,
        filesizeBytes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'narrations';
  @override
  VerificationContext validateIntegrity(Insertable<Narration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
          _poiIdMeta, poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta));
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('transcript')) {
      context.handle(
          _transcriptMeta,
          transcript.isAcceptableOrUnknown(
              data['transcript']!, _transcriptMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('kids_url')) {
      context.handle(_kidsUrlMeta,
          kidsUrl.isAcceptableOrUnknown(data['kids_url']!, _kidsUrlMeta));
    }
    if (data.containsKey('voice_id')) {
      context.handle(_voiceIdMeta,
          voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta));
    }
    if (data.containsKey('filesize_bytes')) {
      context.handle(
          _filesizeBytesMeta,
          filesizeBytes.isAcceptableOrUnknown(
              data['filesize_bytes']!, _filesizeBytesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Narration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Narration(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      durationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}duration_seconds']),
      transcript: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transcript']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      kidsUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kids_url']),
      voiceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_id']),
      filesizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}filesize_bytes']),
    );
  }

  @override
  $NarrationsTable createAlias(String alias) {
    return $NarrationsTable(attachedDatabase, alias);
  }
}

class Narration extends DataClass implements Insertable<Narration> {
  final String id;
  final String poiId;
  final String url;
  final String locale;
  final double? durationSeconds;
  final String? transcript;
  final String? localPath;
  final String? kidsUrl;
  final String? voiceId;
  final int? filesizeBytes;
  const Narration(
      {required this.id,
      required this.poiId,
      required this.url,
      required this.locale,
      this.durationSeconds,
      this.transcript,
      this.localPath,
      this.kidsUrl,
      this.voiceId,
      this.filesizeBytes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    map['url'] = Variable<String>(url);
    map['locale'] = Variable<String>(locale);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<double>(durationSeconds);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || kidsUrl != null) {
      map['kids_url'] = Variable<String>(kidsUrl);
    }
    if (!nullToAbsent || voiceId != null) {
      map['voice_id'] = Variable<String>(voiceId);
    }
    if (!nullToAbsent || filesizeBytes != null) {
      map['filesize_bytes'] = Variable<int>(filesizeBytes);
    }
    return map;
  }

  NarrationsCompanion toCompanion(bool nullToAbsent) {
    return NarrationsCompanion(
      id: Value(id),
      poiId: Value(poiId),
      url: Value(url),
      locale: Value(locale),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      kidsUrl: kidsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(kidsUrl),
      voiceId: voiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceId),
      filesizeBytes: filesizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(filesizeBytes),
    );
  }

  factory Narration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Narration(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      url: serializer.fromJson<String>(json['url']),
      locale: serializer.fromJson<String>(json['locale']),
      durationSeconds: serializer.fromJson<double?>(json['durationSeconds']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      kidsUrl: serializer.fromJson<String?>(json['kidsUrl']),
      voiceId: serializer.fromJson<String?>(json['voiceId']),
      filesizeBytes: serializer.fromJson<int?>(json['filesizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'url': serializer.toJson<String>(url),
      'locale': serializer.toJson<String>(locale),
      'durationSeconds': serializer.toJson<double?>(durationSeconds),
      'transcript': serializer.toJson<String?>(transcript),
      'localPath': serializer.toJson<String?>(localPath),
      'kidsUrl': serializer.toJson<String?>(kidsUrl),
      'voiceId': serializer.toJson<String?>(voiceId),
      'filesizeBytes': serializer.toJson<int?>(filesizeBytes),
    };
  }

  Narration copyWith(
          {String? id,
          String? poiId,
          String? url,
          String? locale,
          Value<double?> durationSeconds = const Value.absent(),
          Value<String?> transcript = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          Value<String?> kidsUrl = const Value.absent(),
          Value<String?> voiceId = const Value.absent(),
          Value<int?> filesizeBytes = const Value.absent()}) =>
      Narration(
        id: id ?? this.id,
        poiId: poiId ?? this.poiId,
        url: url ?? this.url,
        locale: locale ?? this.locale,
        durationSeconds: durationSeconds.present
            ? durationSeconds.value
            : this.durationSeconds,
        transcript: transcript.present ? transcript.value : this.transcript,
        localPath: localPath.present ? localPath.value : this.localPath,
        kidsUrl: kidsUrl.present ? kidsUrl.value : this.kidsUrl,
        voiceId: voiceId.present ? voiceId.value : this.voiceId,
        filesizeBytes:
            filesizeBytes.present ? filesizeBytes.value : this.filesizeBytes,
      );
  Narration copyWithCompanion(NarrationsCompanion data) {
    return Narration(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      url: data.url.present ? data.url.value : this.url,
      locale: data.locale.present ? data.locale.value : this.locale,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      transcript:
          data.transcript.present ? data.transcript.value : this.transcript,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      kidsUrl: data.kidsUrl.present ? data.kidsUrl.value : this.kidsUrl,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      filesizeBytes: data.filesizeBytes.present
          ? data.filesizeBytes.value
          : this.filesizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Narration(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('url: $url, ')
          ..write('locale: $locale, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('transcript: $transcript, ')
          ..write('localPath: $localPath, ')
          ..write('kidsUrl: $kidsUrl, ')
          ..write('voiceId: $voiceId, ')
          ..write('filesizeBytes: $filesizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, poiId, url, locale, durationSeconds,
      transcript, localPath, kidsUrl, voiceId, filesizeBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Narration &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.url == this.url &&
          other.locale == this.locale &&
          other.durationSeconds == this.durationSeconds &&
          other.transcript == this.transcript &&
          other.localPath == this.localPath &&
          other.kidsUrl == this.kidsUrl &&
          other.voiceId == this.voiceId &&
          other.filesizeBytes == this.filesizeBytes);
}

class NarrationsCompanion extends UpdateCompanion<Narration> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String> url;
  final Value<String> locale;
  final Value<double?> durationSeconds;
  final Value<String?> transcript;
  final Value<String?> localPath;
  final Value<String?> kidsUrl;
  final Value<String?> voiceId;
  final Value<int?> filesizeBytes;
  final Value<int> rowid;
  const NarrationsCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.url = const Value.absent(),
    this.locale = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.transcript = const Value.absent(),
    this.localPath = const Value.absent(),
    this.kidsUrl = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.filesizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NarrationsCompanion.insert({
    required String id,
    required String poiId,
    required String url,
    required String locale,
    this.durationSeconds = const Value.absent(),
    this.transcript = const Value.absent(),
    this.localPath = const Value.absent(),
    this.kidsUrl = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.filesizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poiId = Value(poiId),
        url = Value(url),
        locale = Value(locale);
  static Insertable<Narration> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? url,
    Expression<String>? locale,
    Expression<double>? durationSeconds,
    Expression<String>? transcript,
    Expression<String>? localPath,
    Expression<String>? kidsUrl,
    Expression<String>? voiceId,
    Expression<int>? filesizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (url != null) 'url': url,
      if (locale != null) 'locale': locale,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (transcript != null) 'transcript': transcript,
      if (localPath != null) 'local_path': localPath,
      if (kidsUrl != null) 'kids_url': kidsUrl,
      if (voiceId != null) 'voice_id': voiceId,
      if (filesizeBytes != null) 'filesize_bytes': filesizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NarrationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? poiId,
      Value<String>? url,
      Value<String>? locale,
      Value<double?>? durationSeconds,
      Value<String?>? transcript,
      Value<String?>? localPath,
      Value<String?>? kidsUrl,
      Value<String?>? voiceId,
      Value<int?>? filesizeBytes,
      Value<int>? rowid}) {
    return NarrationsCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      url: url ?? this.url,
      locale: locale ?? this.locale,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      transcript: transcript ?? this.transcript,
      localPath: localPath ?? this.localPath,
      kidsUrl: kidsUrl ?? this.kidsUrl,
      voiceId: voiceId ?? this.voiceId,
      filesizeBytes: filesizeBytes ?? this.filesizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (kidsUrl.present) {
      map['kids_url'] = Variable<String>(kidsUrl.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<String>(voiceId.value);
    }
    if (filesizeBytes.present) {
      map['filesize_bytes'] = Variable<int>(filesizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NarrationsCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('url: $url, ')
          ..write('locale: $locale, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('transcript: $transcript, ')
          ..write('localPath: $localPath, ')
          ..write('kidsUrl: $kidsUrl, ')
          ..write('voiceId: $voiceId, ')
          ..write('filesizeBytes: $filesizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
      'poi_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pois (id) ON DELETE CASCADE'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mediaTypeMeta =
      const VerificationMeta('mediaType');
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
      'media_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourcePageUrlMeta =
      const VerificationMeta('sourcePageUrl');
  @override
  late final GeneratedColumn<String> sourcePageUrl = GeneratedColumn<String>(
      'source_page_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _licenseTypeMeta =
      const VerificationMeta('licenseType');
  @override
  late final GeneratedColumn<String> licenseType = GeneratedColumn<String>(
      'license_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        poiId,
        url,
        mediaType,
        author,
        sourcePageUrl,
        licenseType,
        localPath
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(Insertable<MediaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
          _poiIdMeta, poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta));
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(_mediaTypeMeta,
          mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta));
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('source_page_url')) {
      context.handle(
          _sourcePageUrlMeta,
          sourcePageUrl.isAcceptableOrUnknown(
              data['source_page_url']!, _sourcePageUrlMeta));
    }
    if (data.containsKey('license_type')) {
      context.handle(
          _licenseTypeMeta,
          licenseType.isAcceptableOrUnknown(
              data['license_type']!, _licenseTypeMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      mediaType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_type'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author']),
      sourcePageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_page_url']),
      licenseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license_type']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaData extends DataClass implements Insertable<MediaData> {
  final String id;
  final String poiId;
  final String url;
  final String mediaType;
  final String? author;
  final String? sourcePageUrl;
  final String? licenseType;
  final String? localPath;
  const MediaData(
      {required this.id,
      required this.poiId,
      required this.url,
      required this.mediaType,
      this.author,
      this.sourcePageUrl,
      this.licenseType,
      this.localPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    map['url'] = Variable<String>(url);
    map['media_type'] = Variable<String>(mediaType);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || sourcePageUrl != null) {
      map['source_page_url'] = Variable<String>(sourcePageUrl);
    }
    if (!nullToAbsent || licenseType != null) {
      map['license_type'] = Variable<String>(licenseType);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      poiId: Value(poiId),
      url: Value(url),
      mediaType: Value(mediaType),
      author:
          author == null && nullToAbsent ? const Value.absent() : Value(author),
      sourcePageUrl: sourcePageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePageUrl),
      licenseType: licenseType == null && nullToAbsent
          ? const Value.absent()
          : Value(licenseType),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
    );
  }

  factory MediaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaData(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      url: serializer.fromJson<String>(json['url']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      author: serializer.fromJson<String?>(json['author']),
      sourcePageUrl: serializer.fromJson<String?>(json['sourcePageUrl']),
      licenseType: serializer.fromJson<String?>(json['licenseType']),
      localPath: serializer.fromJson<String?>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'url': serializer.toJson<String>(url),
      'mediaType': serializer.toJson<String>(mediaType),
      'author': serializer.toJson<String?>(author),
      'sourcePageUrl': serializer.toJson<String?>(sourcePageUrl),
      'licenseType': serializer.toJson<String?>(licenseType),
      'localPath': serializer.toJson<String?>(localPath),
    };
  }

  MediaData copyWith(
          {String? id,
          String? poiId,
          String? url,
          String? mediaType,
          Value<String?> author = const Value.absent(),
          Value<String?> sourcePageUrl = const Value.absent(),
          Value<String?> licenseType = const Value.absent(),
          Value<String?> localPath = const Value.absent()}) =>
      MediaData(
        id: id ?? this.id,
        poiId: poiId ?? this.poiId,
        url: url ?? this.url,
        mediaType: mediaType ?? this.mediaType,
        author: author.present ? author.value : this.author,
        sourcePageUrl:
            sourcePageUrl.present ? sourcePageUrl.value : this.sourcePageUrl,
        licenseType: licenseType.present ? licenseType.value : this.licenseType,
        localPath: localPath.present ? localPath.value : this.localPath,
      );
  MediaData copyWithCompanion(MediaCompanion data) {
    return MediaData(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      url: data.url.present ? data.url.value : this.url,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      author: data.author.present ? data.author.value : this.author,
      sourcePageUrl: data.sourcePageUrl.present
          ? data.sourcePageUrl.value
          : this.sourcePageUrl,
      licenseType:
          data.licenseType.present ? data.licenseType.value : this.licenseType,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaData(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('url: $url, ')
          ..write('mediaType: $mediaType, ')
          ..write('author: $author, ')
          ..write('sourcePageUrl: $sourcePageUrl, ')
          ..write('licenseType: $licenseType, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, poiId, url, mediaType, author, sourcePageUrl, licenseType, localPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaData &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.url == this.url &&
          other.mediaType == this.mediaType &&
          other.author == this.author &&
          other.sourcePageUrl == this.sourcePageUrl &&
          other.licenseType == this.licenseType &&
          other.localPath == this.localPath);
}

class MediaCompanion extends UpdateCompanion<MediaData> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String> url;
  final Value<String> mediaType;
  final Value<String?> author;
  final Value<String?> sourcePageUrl;
  final Value<String?> licenseType;
  final Value<String?> localPath;
  final Value<int> rowid;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.url = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.author = const Value.absent(),
    this.sourcePageUrl = const Value.absent(),
    this.licenseType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCompanion.insert({
    required String id,
    required String poiId,
    required String url,
    required String mediaType,
    this.author = const Value.absent(),
    this.sourcePageUrl = const Value.absent(),
    this.licenseType = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poiId = Value(poiId),
        url = Value(url),
        mediaType = Value(mediaType);
  static Insertable<MediaData> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? url,
    Expression<String>? mediaType,
    Expression<String>? author,
    Expression<String>? sourcePageUrl,
    Expression<String>? licenseType,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (url != null) 'url': url,
      if (mediaType != null) 'media_type': mediaType,
      if (author != null) 'author': author,
      if (sourcePageUrl != null) 'source_page_url': sourcePageUrl,
      if (licenseType != null) 'license_type': licenseType,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCompanion copyWith(
      {Value<String>? id,
      Value<String>? poiId,
      Value<String>? url,
      Value<String>? mediaType,
      Value<String?>? author,
      Value<String?>? sourcePageUrl,
      Value<String?>? licenseType,
      Value<String?>? localPath,
      Value<int>? rowid}) {
    return MediaCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      url: url ?? this.url,
      mediaType: mediaType ?? this.mediaType,
      author: author ?? this.author,
      sourcePageUrl: sourcePageUrl ?? this.sourcePageUrl,
      licenseType: licenseType ?? this.licenseType,
      localPath: localPath ?? this.localPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (sourcePageUrl.present) {
      map['source_page_url'] = Variable<String>(sourcePageUrl.value);
    }
    if (licenseType.present) {
      map['license_type'] = Variable<String>(licenseType.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('url: $url, ')
          ..write('mediaType: $mediaType, ')
          ..write('author: $author, ')
          ..write('sourcePageUrl: $sourcePageUrl, ')
          ..write('licenseType: $licenseType, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PoiSourcesTable extends PoiSources
    with TableInfo<$PoiSourcesTable, PoiSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoiSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poiIdMeta = const VerificationMeta('poiId');
  @override
  late final GeneratedColumn<String> poiId = GeneratedColumn<String>(
      'poi_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES pois (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, poiId, name, url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'poi_sources';
  @override
  VerificationContext validateIntegrity(Insertable<PoiSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('poi_id')) {
      context.handle(
          _poiIdMeta, poiId.isAcceptableOrUnknown(data['poi_id']!, _poiIdMeta));
    } else if (isInserting) {
      context.missing(_poiIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoiSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoiSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}poi_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
    );
  }

  @override
  $PoiSourcesTable createAlias(String alias) {
    return $PoiSourcesTable(attachedDatabase, alias);
  }
}

class PoiSource extends DataClass implements Insertable<PoiSource> {
  final String id;
  final String poiId;
  final String name;
  final String? url;
  const PoiSource(
      {required this.id, required this.poiId, required this.name, this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['poi_id'] = Variable<String>(poiId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  PoiSourcesCompanion toCompanion(bool nullToAbsent) {
    return PoiSourcesCompanion(
      id: Value(id),
      poiId: Value(poiId),
      name: Value(name),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory PoiSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoiSource(
      id: serializer.fromJson<String>(json['id']),
      poiId: serializer.fromJson<String>(json['poiId']),
      name: serializer.fromJson<String>(json['name']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poiId': serializer.toJson<String>(poiId),
      'name': serializer.toJson<String>(name),
      'url': serializer.toJson<String?>(url),
    };
  }

  PoiSource copyWith(
          {String? id,
          String? poiId,
          String? name,
          Value<String?> url = const Value.absent()}) =>
      PoiSource(
        id: id ?? this.id,
        poiId: poiId ?? this.poiId,
        name: name ?? this.name,
        url: url.present ? url.value : this.url,
      );
  PoiSource copyWithCompanion(PoiSourcesCompanion data) {
    return PoiSource(
      id: data.id.present ? data.id.value : this.id,
      poiId: data.poiId.present ? data.poiId.value : this.poiId,
      name: data.name.present ? data.name.value : this.name,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoiSource(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('name: $name, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, poiId, name, url);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoiSource &&
          other.id == this.id &&
          other.poiId == this.poiId &&
          other.name == this.name &&
          other.url == this.url);
}

class PoiSourcesCompanion extends UpdateCompanion<PoiSource> {
  final Value<String> id;
  final Value<String> poiId;
  final Value<String> name;
  final Value<String?> url;
  final Value<int> rowid;
  const PoiSourcesCompanion({
    this.id = const Value.absent(),
    this.poiId = const Value.absent(),
    this.name = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoiSourcesCompanion.insert({
    required String id,
    required String poiId,
    required String name,
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poiId = Value(poiId),
        name = Value(name);
  static Insertable<PoiSource> custom({
    Expression<String>? id,
    Expression<String>? poiId,
    Expression<String>? name,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poiId != null) 'poi_id': poiId,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoiSourcesCompanion copyWith(
      {Value<String>? id,
      Value<String>? poiId,
      Value<String>? name,
      Value<String?>? url,
      Value<int>? rowid}) {
    return PoiSourcesCompanion(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      name: name ?? this.name,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poiId.present) {
      map['poi_id'] = Variable<String>(poiId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoiSourcesCompanion(')
          ..write('id: $id, ')
          ..write('poiId: $poiId, ')
          ..write('name: $name, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitlementGrantsTable extends EntitlementGrants
    with TableInfo<$EntitlementGrantsTable, EntitlementGrant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitlementGrantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entitlementSlugMeta =
      const VerificationMeta('entitlementSlug');
  @override
  late final GeneratedColumn<String> entitlementSlug = GeneratedColumn<String>(
      'entitlement_slug', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
      'ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _grantedAtMeta =
      const VerificationMeta('grantedAt');
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
      'granted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, entitlementSlug, scope, ref, grantedAt, expiresAt, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entitlement_grants';
  @override
  VerificationContext validateIntegrity(Insertable<EntitlementGrant> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entitlement_slug')) {
      context.handle(
          _entitlementSlugMeta,
          entitlementSlug.isAcceptableOrUnknown(
              data['entitlement_slug']!, _entitlementSlugMeta));
    } else if (isInserting) {
      context.missing(_entitlementSlugMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
          _refMeta, ref.isAcceptableOrUnknown(data['ref']!, _refMeta));
    }
    if (data.containsKey('granted_at')) {
      context.handle(_grantedAtMeta,
          grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta));
    } else if (isInserting) {
      context.missing(_grantedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntitlementGrant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitlementGrant(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entitlementSlug: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entitlement_slug'])!,
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      ref: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref']),
      grantedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}granted_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $EntitlementGrantsTable createAlias(String alias) {
    return $EntitlementGrantsTable(attachedDatabase, alias);
  }
}

class EntitlementGrant extends DataClass
    implements Insertable<EntitlementGrant> {
  final String id;
  final String entitlementSlug;
  final String scope;
  final String? ref;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final bool isActive;
  const EntitlementGrant(
      {required this.id,
      required this.entitlementSlug,
      required this.scope,
      this.ref,
      required this.grantedAt,
      this.expiresAt,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entitlement_slug'] = Variable<String>(entitlementSlug);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    map['granted_at'] = Variable<DateTime>(grantedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  EntitlementGrantsCompanion toCompanion(bool nullToAbsent) {
    return EntitlementGrantsCompanion(
      id: Value(id),
      entitlementSlug: Value(entitlementSlug),
      scope: Value(scope),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      grantedAt: Value(grantedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      isActive: Value(isActive),
    );
  }

  factory EntitlementGrant.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitlementGrant(
      id: serializer.fromJson<String>(json['id']),
      entitlementSlug: serializer.fromJson<String>(json['entitlementSlug']),
      scope: serializer.fromJson<String>(json['scope']),
      ref: serializer.fromJson<String?>(json['ref']),
      grantedAt: serializer.fromJson<DateTime>(json['grantedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entitlementSlug': serializer.toJson<String>(entitlementSlug),
      'scope': serializer.toJson<String>(scope),
      'ref': serializer.toJson<String?>(ref),
      'grantedAt': serializer.toJson<DateTime>(grantedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  EntitlementGrant copyWith(
          {String? id,
          String? entitlementSlug,
          String? scope,
          Value<String?> ref = const Value.absent(),
          DateTime? grantedAt,
          Value<DateTime?> expiresAt = const Value.absent(),
          bool? isActive}) =>
      EntitlementGrant(
        id: id ?? this.id,
        entitlementSlug: entitlementSlug ?? this.entitlementSlug,
        scope: scope ?? this.scope,
        ref: ref.present ? ref.value : this.ref,
        grantedAt: grantedAt ?? this.grantedAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        isActive: isActive ?? this.isActive,
      );
  EntitlementGrant copyWithCompanion(EntitlementGrantsCompanion data) {
    return EntitlementGrant(
      id: data.id.present ? data.id.value : this.id,
      entitlementSlug: data.entitlementSlug.present
          ? data.entitlementSlug.value
          : this.entitlementSlug,
      scope: data.scope.present ? data.scope.value : this.scope,
      ref: data.ref.present ? data.ref.value : this.ref,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementGrant(')
          ..write('id: $id, ')
          ..write('entitlementSlug: $entitlementSlug, ')
          ..write('scope: $scope, ')
          ..write('ref: $ref, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entitlementSlug, scope, ref, grantedAt, expiresAt, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitlementGrant &&
          other.id == this.id &&
          other.entitlementSlug == this.entitlementSlug &&
          other.scope == this.scope &&
          other.ref == this.ref &&
          other.grantedAt == this.grantedAt &&
          other.expiresAt == this.expiresAt &&
          other.isActive == this.isActive);
}

class EntitlementGrantsCompanion extends UpdateCompanion<EntitlementGrant> {
  final Value<String> id;
  final Value<String> entitlementSlug;
  final Value<String> scope;
  final Value<String?> ref;
  final Value<DateTime> grantedAt;
  final Value<DateTime?> expiresAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const EntitlementGrantsCompanion({
    this.id = const Value.absent(),
    this.entitlementSlug = const Value.absent(),
    this.scope = const Value.absent(),
    this.ref = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitlementGrantsCompanion.insert({
    required String id,
    required String entitlementSlug,
    required String scope,
    this.ref = const Value.absent(),
    required DateTime grantedAt,
    this.expiresAt = const Value.absent(),
    required bool isActive,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entitlementSlug = Value(entitlementSlug),
        scope = Value(scope),
        grantedAt = Value(grantedAt),
        isActive = Value(isActive);
  static Insertable<EntitlementGrant> custom({
    Expression<String>? id,
    Expression<String>? entitlementSlug,
    Expression<String>? scope,
    Expression<String>? ref,
    Expression<DateTime>? grantedAt,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entitlementSlug != null) 'entitlement_slug': entitlementSlug,
      if (scope != null) 'scope': scope,
      if (ref != null) 'ref': ref,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitlementGrantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? entitlementSlug,
      Value<String>? scope,
      Value<String?>? ref,
      Value<DateTime>? grantedAt,
      Value<DateTime?>? expiresAt,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return EntitlementGrantsCompanion(
      id: id ?? this.id,
      entitlementSlug: entitlementSlug ?? this.entitlementSlug,
      scope: scope ?? this.scope,
      ref: ref ?? this.ref,
      grantedAt: grantedAt ?? this.grantedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entitlementSlug.present) {
      map['entitlement_slug'] = Variable<String>(entitlementSlug.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementGrantsCompanion(')
          ..write('id: $id, ')
          ..write('entitlementSlug: $entitlementSlug, ')
          ..write('scope: $scope, ')
          ..write('ref: $ref, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EtagsTable extends Etags with TableInfo<$EtagsTable, Etag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
      'etag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [url, etag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etags';
  @override
  VerificationContext validateIntegrity(Insertable<Etag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
          _etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    } else if (isInserting) {
      context.missing(_etagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  Etag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Etag(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      etag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}etag'])!,
    );
  }

  @override
  $EtagsTable createAlias(String alias) {
    return $EtagsTable(attachedDatabase, alias);
  }
}

class Etag extends DataClass implements Insertable<Etag> {
  final String url;
  final String etag;
  const Etag({required this.url, required this.etag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['etag'] = Variable<String>(etag);
    return map;
  }

  EtagsCompanion toCompanion(bool nullToAbsent) {
    return EtagsCompanion(
      url: Value(url),
      etag: Value(etag),
    );
  }

  factory Etag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Etag(
      url: serializer.fromJson<String>(json['url']),
      etag: serializer.fromJson<String>(json['etag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'etag': serializer.toJson<String>(etag),
    };
  }

  Etag copyWith({String? url, String? etag}) => Etag(
        url: url ?? this.url,
        etag: etag ?? this.etag,
      );
  Etag copyWithCompanion(EtagsCompanion data) {
    return Etag(
      url: data.url.present ? data.url.value : this.url,
      etag: data.etag.present ? data.etag.value : this.etag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Etag(')
          ..write('url: $url, ')
          ..write('etag: $etag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(url, etag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Etag && other.url == this.url && other.etag == this.etag);
}

class EtagsCompanion extends UpdateCompanion<Etag> {
  final Value<String> url;
  final Value<String> etag;
  final Value<int> rowid;
  const EtagsCompanion({
    this.url = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EtagsCompanion.insert({
    required String url,
    required String etag,
    this.rowid = const Value.absent(),
  })  : url = Value(url),
        etag = Value(etag);
  static Insertable<Etag> custom({
    Expression<String>? url,
    Expression<String>? etag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (etag != null) 'etag': etag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EtagsCompanion copyWith(
      {Value<String>? url, Value<String>? etag, Value<int>? rowid}) {
    return EtagsCompanion(
      url: url ?? this.url,
      etag: etag ?? this.etag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtagsCompanion(')
          ..write('url: $url, ')
          ..write('etag: $etag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QrMappingsCacheTable extends QrMappingsCache
    with TableInfo<$QrMappingsCacheTable, QrMappingsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QrMappingsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetTypeMeta =
      const VerificationMeta('targetType');
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
      'target_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _redirectUrlMeta =
      const VerificationMeta('redirectUrl');
  @override
  late final GeneratedColumn<String> redirectUrl = GeneratedColumn<String>(
      'redirect_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [code, targetType, targetId, redirectUrl, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'qr_mappings_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<QrMappingsCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
          _targetTypeMeta,
          targetType.isAcceptableOrUnknown(
              data['target_type']!, _targetTypeMeta));
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('redirect_url')) {
      context.handle(
          _redirectUrlMeta,
          redirectUrl.isAcceptableOrUnknown(
              data['redirect_url']!, _redirectUrlMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  QrMappingsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QrMappingsCacheData(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      targetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_type'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id'])!,
      redirectUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}redirect_url']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $QrMappingsCacheTable createAlias(String alias) {
    return $QrMappingsCacheTable(attachedDatabase, alias);
  }
}

class QrMappingsCacheData extends DataClass
    implements Insertable<QrMappingsCacheData> {
  final String code;
  final String targetType;
  final String targetId;
  final String? redirectUrl;
  final DateTime cachedAt;
  const QrMappingsCacheData(
      {required this.code,
      required this.targetType,
      required this.targetId,
      this.redirectUrl,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    if (!nullToAbsent || redirectUrl != null) {
      map['redirect_url'] = Variable<String>(redirectUrl);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  QrMappingsCacheCompanion toCompanion(bool nullToAbsent) {
    return QrMappingsCacheCompanion(
      code: Value(code),
      targetType: Value(targetType),
      targetId: Value(targetId),
      redirectUrl: redirectUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(redirectUrl),
      cachedAt: Value(cachedAt),
    );
  }

  factory QrMappingsCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QrMappingsCacheData(
      code: serializer.fromJson<String>(json['code']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      redirectUrl: serializer.fromJson<String?>(json['redirectUrl']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'redirectUrl': serializer.toJson<String?>(redirectUrl),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  QrMappingsCacheData copyWith(
          {String? code,
          String? targetType,
          String? targetId,
          Value<String?> redirectUrl = const Value.absent(),
          DateTime? cachedAt}) =>
      QrMappingsCacheData(
        code: code ?? this.code,
        targetType: targetType ?? this.targetType,
        targetId: targetId ?? this.targetId,
        redirectUrl: redirectUrl.present ? redirectUrl.value : this.redirectUrl,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  QrMappingsCacheData copyWithCompanion(QrMappingsCacheCompanion data) {
    return QrMappingsCacheData(
      code: data.code.present ? data.code.value : this.code,
      targetType:
          data.targetType.present ? data.targetType.value : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      redirectUrl:
          data.redirectUrl.present ? data.redirectUrl.value : this.redirectUrl,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QrMappingsCacheData(')
          ..write('code: $code, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('redirectUrl: $redirectUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, targetType, targetId, redirectUrl, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QrMappingsCacheData &&
          other.code == this.code &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.redirectUrl == this.redirectUrl &&
          other.cachedAt == this.cachedAt);
}

class QrMappingsCacheCompanion extends UpdateCompanion<QrMappingsCacheData> {
  final Value<String> code;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<String?> redirectUrl;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const QrMappingsCacheCompanion({
    this.code = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.redirectUrl = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QrMappingsCacheCompanion.insert({
    required String code,
    required String targetType,
    required String targetId,
    this.redirectUrl = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        targetType = Value(targetType),
        targetId = Value(targetId),
        cachedAt = Value(cachedAt);
  static Insertable<QrMappingsCacheData> custom({
    Expression<String>? code,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? redirectUrl,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (redirectUrl != null) 'redirect_url': redirectUrl,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QrMappingsCacheCompanion copyWith(
      {Value<String>? code,
      Value<String>? targetType,
      Value<String>? targetId,
      Value<String?>? redirectUrl,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return QrMappingsCacheCompanion(
      code: code ?? this.code,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (redirectUrl.present) {
      map['redirect_url'] = Variable<String>(redirectUrl.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QrMappingsCacheCompanion(')
          ..write('code: $code, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('redirectUrl: $redirectUrl, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsPendingEventsTable extends AnalyticsPendingEvents
    with TableInfo<$AnalyticsPendingEventsTable, AnalyticsPendingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsPendingEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, eventType, payloadJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_pending_events';
  @override
  VerificationContext validateIntegrity(
      Insertable<AnalyticsPendingEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsPendingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsPendingEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AnalyticsPendingEventsTable createAlias(String alias) {
    return $AnalyticsPendingEventsTable(attachedDatabase, alias);
  }
}

class AnalyticsPendingEvent extends DataClass
    implements Insertable<AnalyticsPendingEvent> {
  final String id;
  final String eventType;
  final String? payloadJson;
  final DateTime createdAt;
  const AnalyticsPendingEvent(
      {required this.id,
      required this.eventType,
      this.payloadJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AnalyticsPendingEventsCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsPendingEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory AnalyticsPendingEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsPendingEvent(
      id: serializer.fromJson<String>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AnalyticsPendingEvent copyWith(
          {String? id,
          String? eventType,
          Value<String?> payloadJson = const Value.absent(),
          DateTime? createdAt}) =>
      AnalyticsPendingEvent(
        id: id ?? this.id,
        eventType: eventType ?? this.eventType,
        payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
      );
  AnalyticsPendingEvent copyWithCompanion(
      AnalyticsPendingEventsCompanion data) {
    return AnalyticsPendingEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsPendingEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventType, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsPendingEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class AnalyticsPendingEventsCompanion
    extends UpdateCompanion<AnalyticsPendingEvent> {
  final Value<String> id;
  final Value<String> eventType;
  final Value<String?> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AnalyticsPendingEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AnalyticsPendingEventsCompanion.insert({
    required String id,
    required String eventType,
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventType = Value(eventType);
  static Insertable<AnalyticsPendingEvent> custom({
    Expression<String>? id,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AnalyticsPendingEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? eventType,
      Value<String?>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AnalyticsPendingEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsPendingEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CitiesTable cities = $CitiesTable(this);
  late final $ToursTable tours = $ToursTable(this);
  late final $PoisTable pois = $PoisTable(this);
  late final $TourItemsTable tourItems = $TourItemsTable(this);
  late final $NarrationsTable narrations = $NarrationsTable(this);
  late final $MediaTable media = $MediaTable(this);
  late final $PoiSourcesTable poiSources = $PoiSourcesTable(this);
  late final $EntitlementGrantsTable entitlementGrants =
      $EntitlementGrantsTable(this);
  late final $EtagsTable etags = $EtagsTable(this);
  late final $QrMappingsCacheTable qrMappingsCache =
      $QrMappingsCacheTable(this);
  late final $AnalyticsPendingEventsTable analyticsPendingEvents =
      $AnalyticsPendingEventsTable(this);
  late final CityDao cityDao = CityDao(this as AppDatabase);
  late final TourDao tourDao = TourDao(this as AppDatabase);
  late final PoiDao poiDao = PoiDao(this as AppDatabase);
  late final EntitlementDao entitlementDao =
      EntitlementDao(this as AppDatabase);
  late final EtagDao etagDao = EtagDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cities,
        tours,
        pois,
        tourItems,
        narrations,
        media,
        poiSources,
        entitlementGrants,
        etags,
        qrMappingsCache,
        analyticsPendingEvents
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('tours',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tour_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pois',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tour_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pois',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('narrations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pois',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('media', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('pois',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('poi_sources', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CitiesTableCreateCompanionBuilder = CitiesCompanion Function({
  required String id,
  required String slug,
  required String nameRu,
  required bool isActive,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$CitiesTableUpdateCompanionBuilder = CitiesCompanion Function({
  Value<String> id,
  Value<String> slug,
  Value<String> nameRu,
  Value<bool> isActive,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$CitiesTableFilterComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameRu => $composableBuilder(
      column: $table.nameRu, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slug => $composableBuilder(
      column: $table.slug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameRu => $composableBuilder(
      column: $table.nameRu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CitiesTable> {
  $$CitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get nameRu =>
      $composableBuilder(column: $table.nameRu, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CitiesTable,
    City,
    $$CitiesTableFilterComposer,
    $$CitiesTableOrderingComposer,
    $$CitiesTableAnnotationComposer,
    $$CitiesTableCreateCompanionBuilder,
    $$CitiesTableUpdateCompanionBuilder,
    (City, BaseReferences<_$AppDatabase, $CitiesTable, City>),
    City,
    PrefetchHooks Function()> {
  $$CitiesTableTableManager(_$AppDatabase db, $CitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> slug = const Value.absent(),
            Value<String> nameRu = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CitiesCompanion(
            id: id,
            slug: slug,
            nameRu: nameRu,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String slug,
            required String nameRu,
            required bool isActive,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CitiesCompanion.insert(
            id: id,
            slug: slug,
            nameRu: nameRu,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CitiesTable,
    City,
    $$CitiesTableFilterComposer,
    $$CitiesTableOrderingComposer,
    $$CitiesTableAnnotationComposer,
    $$CitiesTableCreateCompanionBuilder,
    $$CitiesTableUpdateCompanionBuilder,
    (City, BaseReferences<_$AppDatabase, $CitiesTable, City>),
    City,
    PrefetchHooks Function()>;
typedef $$ToursTableCreateCompanionBuilder = ToursCompanion Function({
  required String id,
  required String citySlug,
  required String titleRu,
  Value<String?> descriptionRu,
  Value<String?> coverImage,
  Value<int?> durationMinutes,
  Value<String?> transportType,
  Value<double?> distanceKm,
  Value<String> tourType,
  Value<String> difficulty,
  Value<int> rowid,
});
typedef $$ToursTableUpdateCompanionBuilder = ToursCompanion Function({
  Value<String> id,
  Value<String> citySlug,
  Value<String> titleRu,
  Value<String?> descriptionRu,
  Value<String?> coverImage,
  Value<int?> durationMinutes,
  Value<String?> transportType,
  Value<double?> distanceKm,
  Value<String> tourType,
  Value<String> difficulty,
  Value<int> rowid,
});

final class $$ToursTableReferences
    extends BaseReferences<_$AppDatabase, $ToursTable, Tour> {
  $$ToursTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TourItemsTable, List<TourItem>>
      _tourItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.tourItems,
          aliasName: $_aliasNameGenerator(db.tours.id, db.tourItems.tourId));

  $$TourItemsTableProcessedTableManager get tourItemsRefs {
    final manager = $$TourItemsTableTableManager($_db, $_db.tourItems)
        .filter((f) => f.tourId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tourItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ToursTableFilterComposer extends Composer<_$AppDatabase, $ToursTable> {
  $$ToursTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citySlug => $composableBuilder(
      column: $table.citySlug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleRu => $composableBuilder(
      column: $table.titleRu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImage => $composableBuilder(
      column: $table.coverImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transportType => $composableBuilder(
      column: $table.transportType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tourType => $composableBuilder(
      column: $table.tourType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  Expression<bool> tourItemsRefs(
      Expression<bool> Function($$TourItemsTableFilterComposer f) f) {
    final $$TourItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tourItems,
        getReferencedColumn: (t) => t.tourId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TourItemsTableFilterComposer(
              $db: $db,
              $table: $db.tourItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ToursTableOrderingComposer
    extends Composer<_$AppDatabase, $ToursTable> {
  $$ToursTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citySlug => $composableBuilder(
      column: $table.citySlug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleRu => $composableBuilder(
      column: $table.titleRu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImage => $composableBuilder(
      column: $table.coverImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transportType => $composableBuilder(
      column: $table.transportType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tourType => $composableBuilder(
      column: $table.tourType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));
}

class $$ToursTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToursTable> {
  $$ToursTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<String> get titleRu =>
      $composableBuilder(column: $table.titleRu, builder: (column) => column);

  GeneratedColumn<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu, builder: (column) => column);

  GeneratedColumn<String> get coverImage => $composableBuilder(
      column: $table.coverImage, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<String> get transportType => $composableBuilder(
      column: $table.transportType, builder: (column) => column);

  GeneratedColumn<double> get distanceKm => $composableBuilder(
      column: $table.distanceKm, builder: (column) => column);

  GeneratedColumn<String> get tourType =>
      $composableBuilder(column: $table.tourType, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  Expression<T> tourItemsRefs<T extends Object>(
      Expression<T> Function($$TourItemsTableAnnotationComposer a) f) {
    final $$TourItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tourItems,
        getReferencedColumn: (t) => t.tourId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TourItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.tourItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ToursTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ToursTable,
    Tour,
    $$ToursTableFilterComposer,
    $$ToursTableOrderingComposer,
    $$ToursTableAnnotationComposer,
    $$ToursTableCreateCompanionBuilder,
    $$ToursTableUpdateCompanionBuilder,
    (Tour, $$ToursTableReferences),
    Tour,
    PrefetchHooks Function({bool tourItemsRefs})> {
  $$ToursTableTableManager(_$AppDatabase db, $ToursTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToursTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToursTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToursTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> citySlug = const Value.absent(),
            Value<String> titleRu = const Value.absent(),
            Value<String?> descriptionRu = const Value.absent(),
            Value<String?> coverImage = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<String?> transportType = const Value.absent(),
            Value<double?> distanceKm = const Value.absent(),
            Value<String> tourType = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToursCompanion(
            id: id,
            citySlug: citySlug,
            titleRu: titleRu,
            descriptionRu: descriptionRu,
            coverImage: coverImage,
            durationMinutes: durationMinutes,
            transportType: transportType,
            distanceKm: distanceKm,
            tourType: tourType,
            difficulty: difficulty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String citySlug,
            required String titleRu,
            Value<String?> descriptionRu = const Value.absent(),
            Value<String?> coverImage = const Value.absent(),
            Value<int?> durationMinutes = const Value.absent(),
            Value<String?> transportType = const Value.absent(),
            Value<double?> distanceKm = const Value.absent(),
            Value<String> tourType = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToursCompanion.insert(
            id: id,
            citySlug: citySlug,
            titleRu: titleRu,
            descriptionRu: descriptionRu,
            coverImage: coverImage,
            durationMinutes: durationMinutes,
            transportType: transportType,
            distanceKm: distanceKm,
            tourType: tourType,
            difficulty: difficulty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ToursTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tourItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tourItemsRefs) db.tourItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tourItemsRefs)
                    await $_getPrefetchedData<Tour, $ToursTable, TourItem>(
                        currentTable: table,
                        referencedTable:
                            $$ToursTableReferences._tourItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ToursTableReferences(db, table, p0).tourItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tourId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ToursTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ToursTable,
    Tour,
    $$ToursTableFilterComposer,
    $$ToursTableOrderingComposer,
    $$ToursTableAnnotationComposer,
    $$ToursTableCreateCompanionBuilder,
    $$ToursTableUpdateCompanionBuilder,
    (Tour, $$ToursTableReferences),
    Tour,
    PrefetchHooks Function({bool tourItemsRefs})>;
typedef $$PoisTableCreateCompanionBuilder = PoisCompanion Function({
  required String id,
  required String citySlug,
  required String titleRu,
  Value<String?> descriptionRu,
  required double lat,
  required double lon,
  Value<String?> previewAudioUrl,
  Value<bool> hasAccess,
  Value<bool> isFavorite,
  Value<String?> category,
  Value<String?> wikidataId,
  Value<String?> osmId,
  Value<double> confidenceScore,
  Value<String?> openingHours,
  Value<String?> externalLinks,
  Value<int> rowid,
});
typedef $$PoisTableUpdateCompanionBuilder = PoisCompanion Function({
  Value<String> id,
  Value<String> citySlug,
  Value<String> titleRu,
  Value<String?> descriptionRu,
  Value<double> lat,
  Value<double> lon,
  Value<String?> previewAudioUrl,
  Value<bool> hasAccess,
  Value<bool> isFavorite,
  Value<String?> category,
  Value<String?> wikidataId,
  Value<String?> osmId,
  Value<double> confidenceScore,
  Value<String?> openingHours,
  Value<String?> externalLinks,
  Value<int> rowid,
});

final class $$PoisTableReferences
    extends BaseReferences<_$AppDatabase, $PoisTable, Poi> {
  $$PoisTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TourItemsTable, List<TourItem>>
      _tourItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tourItems,
              aliasName: $_aliasNameGenerator(db.pois.id, db.tourItems.poiId));

  $$TourItemsTableProcessedTableManager get tourItemsRefs {
    final manager = $$TourItemsTableTableManager($_db, $_db.tourItems)
        .filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tourItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NarrationsTable, List<Narration>>
      _narrationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.narrations,
              aliasName: $_aliasNameGenerator(db.pois.id, db.narrations.poiId));

  $$NarrationsTableProcessedTableManager get narrationsRefs {
    final manager = $$NarrationsTableTableManager($_db, $_db.narrations)
        .filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_narrationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MediaTable, List<MediaData>> _mediaRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.media,
          aliasName: $_aliasNameGenerator(db.pois.id, db.media.poiId));

  $$MediaTableProcessedTableManager get mediaRefs {
    final manager = $$MediaTableTableManager($_db, $_db.media)
        .filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PoiSourcesTable, List<PoiSource>>
      _poiSourcesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.poiSources,
              aliasName: $_aliasNameGenerator(db.pois.id, db.poiSources.poiId));

  $$PoiSourcesTableProcessedTableManager get poiSourcesRefs {
    final manager = $$PoiSourcesTableTableManager($_db, $_db.poiSources)
        .filter((f) => f.poiId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_poiSourcesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PoisTableFilterComposer extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citySlug => $composableBuilder(
      column: $table.citySlug, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titleRu => $composableBuilder(
      column: $table.titleRu, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewAudioUrl => $composableBuilder(
      column: $table.previewAudioUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasAccess => $composableBuilder(
      column: $table.hasAccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wikidataId => $composableBuilder(
      column: $table.wikidataId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get osmId => $composableBuilder(
      column: $table.osmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openingHours => $composableBuilder(
      column: $table.openingHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get externalLinks => $composableBuilder(
      column: $table.externalLinks, builder: (column) => ColumnFilters(column));

  Expression<bool> tourItemsRefs(
      Expression<bool> Function($$TourItemsTableFilterComposer f) f) {
    final $$TourItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tourItems,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TourItemsTableFilterComposer(
              $db: $db,
              $table: $db.tourItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> narrationsRefs(
      Expression<bool> Function($$NarrationsTableFilterComposer f) f) {
    final $$NarrationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.narrations,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NarrationsTableFilterComposer(
              $db: $db,
              $table: $db.narrations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mediaRefs(
      Expression<bool> Function($$MediaTableFilterComposer f) f) {
    final $$MediaTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.media,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTableFilterComposer(
              $db: $db,
              $table: $db.media,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> poiSourcesRefs(
      Expression<bool> Function($$PoiSourcesTableFilterComposer f) f) {
    final $$PoiSourcesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.poiSources,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoiSourcesTableFilterComposer(
              $db: $db,
              $table: $db.poiSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PoisTableOrderingComposer extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citySlug => $composableBuilder(
      column: $table.citySlug, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titleRu => $composableBuilder(
      column: $table.titleRu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewAudioUrl => $composableBuilder(
      column: $table.previewAudioUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasAccess => $composableBuilder(
      column: $table.hasAccess, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wikidataId => $composableBuilder(
      column: $table.wikidataId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get osmId => $composableBuilder(
      column: $table.osmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openingHours => $composableBuilder(
      column: $table.openingHours,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get externalLinks => $composableBuilder(
      column: $table.externalLinks,
      builder: (column) => ColumnOrderings(column));
}

class $$PoisTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoisTable> {
  $$PoisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<String> get titleRu =>
      $composableBuilder(column: $table.titleRu, builder: (column) => column);

  GeneratedColumn<String> get descriptionRu => $composableBuilder(
      column: $table.descriptionRu, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get previewAudioUrl => $composableBuilder(
      column: $table.previewAudioUrl, builder: (column) => column);

  GeneratedColumn<bool> get hasAccess =>
      $composableBuilder(column: $table.hasAccess, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get wikidataId => $composableBuilder(
      column: $table.wikidataId, builder: (column) => column);

  GeneratedColumn<String> get osmId =>
      $composableBuilder(column: $table.osmId, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore, builder: (column) => column);

  GeneratedColumn<String> get openingHours => $composableBuilder(
      column: $table.openingHours, builder: (column) => column);

  GeneratedColumn<String> get externalLinks => $composableBuilder(
      column: $table.externalLinks, builder: (column) => column);

  Expression<T> tourItemsRefs<T extends Object>(
      Expression<T> Function($$TourItemsTableAnnotationComposer a) f) {
    final $$TourItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tourItems,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TourItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.tourItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> narrationsRefs<T extends Object>(
      Expression<T> Function($$NarrationsTableAnnotationComposer a) f) {
    final $$NarrationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.narrations,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NarrationsTableAnnotationComposer(
              $db: $db,
              $table: $db.narrations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mediaRefs<T extends Object>(
      Expression<T> Function($$MediaTableAnnotationComposer a) f) {
    final $$MediaTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.media,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTableAnnotationComposer(
              $db: $db,
              $table: $db.media,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> poiSourcesRefs<T extends Object>(
      Expression<T> Function($$PoiSourcesTableAnnotationComposer a) f) {
    final $$PoiSourcesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.poiSources,
        getReferencedColumn: (t) => t.poiId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoiSourcesTableAnnotationComposer(
              $db: $db,
              $table: $db.poiSources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PoisTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PoisTable,
    Poi,
    $$PoisTableFilterComposer,
    $$PoisTableOrderingComposer,
    $$PoisTableAnnotationComposer,
    $$PoisTableCreateCompanionBuilder,
    $$PoisTableUpdateCompanionBuilder,
    (Poi, $$PoisTableReferences),
    Poi,
    PrefetchHooks Function(
        {bool tourItemsRefs,
        bool narrationsRefs,
        bool mediaRefs,
        bool poiSourcesRefs})> {
  $$PoisTableTableManager(_$AppDatabase db, $PoisTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> citySlug = const Value.absent(),
            Value<String> titleRu = const Value.absent(),
            Value<String?> descriptionRu = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<String?> previewAudioUrl = const Value.absent(),
            Value<bool> hasAccess = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> wikidataId = const Value.absent(),
            Value<String?> osmId = const Value.absent(),
            Value<double> confidenceScore = const Value.absent(),
            Value<String?> openingHours = const Value.absent(),
            Value<String?> externalLinks = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoisCompanion(
            id: id,
            citySlug: citySlug,
            titleRu: titleRu,
            descriptionRu: descriptionRu,
            lat: lat,
            lon: lon,
            previewAudioUrl: previewAudioUrl,
            hasAccess: hasAccess,
            isFavorite: isFavorite,
            category: category,
            wikidataId: wikidataId,
            osmId: osmId,
            confidenceScore: confidenceScore,
            openingHours: openingHours,
            externalLinks: externalLinks,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String citySlug,
            required String titleRu,
            Value<String?> descriptionRu = const Value.absent(),
            required double lat,
            required double lon,
            Value<String?> previewAudioUrl = const Value.absent(),
            Value<bool> hasAccess = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> wikidataId = const Value.absent(),
            Value<String?> osmId = const Value.absent(),
            Value<double> confidenceScore = const Value.absent(),
            Value<String?> openingHours = const Value.absent(),
            Value<String?> externalLinks = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoisCompanion.insert(
            id: id,
            citySlug: citySlug,
            titleRu: titleRu,
            descriptionRu: descriptionRu,
            lat: lat,
            lon: lon,
            previewAudioUrl: previewAudioUrl,
            hasAccess: hasAccess,
            isFavorite: isFavorite,
            category: category,
            wikidataId: wikidataId,
            osmId: osmId,
            confidenceScore: confidenceScore,
            openingHours: openingHours,
            externalLinks: externalLinks,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PoisTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {tourItemsRefs = false,
              narrationsRefs = false,
              mediaRefs = false,
              poiSourcesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tourItemsRefs) db.tourItems,
                if (narrationsRefs) db.narrations,
                if (mediaRefs) db.media,
                if (poiSourcesRefs) db.poiSources
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tourItemsRefs)
                    await $_getPrefetchedData<Poi, $PoisTable, TourItem>(
                        currentTable: table,
                        referencedTable:
                            $$PoisTableReferences._tourItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PoisTableReferences(db, table, p0).tourItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.poiId == item.id),
                        typedResults: items),
                  if (narrationsRefs)
                    await $_getPrefetchedData<Poi, $PoisTable, Narration>(
                        currentTable: table,
                        referencedTable:
                            $$PoisTableReferences._narrationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PoisTableReferences(db, table, p0).narrationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.poiId == item.id),
                        typedResults: items),
                  if (mediaRefs)
                    await $_getPrefetchedData<Poi, $PoisTable, MediaData>(
                        currentTable: table,
                        referencedTable:
                            $$PoisTableReferences._mediaRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PoisTableReferences(db, table, p0).mediaRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.poiId == item.id),
                        typedResults: items),
                  if (poiSourcesRefs)
                    await $_getPrefetchedData<Poi, $PoisTable, PoiSource>(
                        currentTable: table,
                        referencedTable:
                            $$PoisTableReferences._poiSourcesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PoisTableReferences(db, table, p0).poiSourcesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.poiId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PoisTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PoisTable,
    Poi,
    $$PoisTableFilterComposer,
    $$PoisTableOrderingComposer,
    $$PoisTableAnnotationComposer,
    $$PoisTableCreateCompanionBuilder,
    $$PoisTableUpdateCompanionBuilder,
    (Poi, $$PoisTableReferences),
    Poi,
    PrefetchHooks Function(
        {bool tourItemsRefs,
        bool narrationsRefs,
        bool mediaRefs,
        bool poiSourcesRefs})>;
typedef $$TourItemsTableCreateCompanionBuilder = TourItemsCompanion Function({
  required String id,
  required String tourId,
  required String poiId,
  required int orderIndex,
  Value<int> rowid,
});
typedef $$TourItemsTableUpdateCompanionBuilder = TourItemsCompanion Function({
  Value<String> id,
  Value<String> tourId,
  Value<String> poiId,
  Value<int> orderIndex,
  Value<int> rowid,
});

final class $$TourItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TourItemsTable, TourItem> {
  $$TourItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ToursTable _tourIdTable(_$AppDatabase db) => db.tours
      .createAlias($_aliasNameGenerator(db.tourItems.tourId, db.tours.id));

  $$ToursTableProcessedTableManager get tourId {
    final $_column = $_itemColumn<String>('tour_id')!;

    final manager = $$ToursTableTableManager($_db, $_db.tours)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tourIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PoisTable _poiIdTable(_$AppDatabase db) =>
      db.pois.createAlias($_aliasNameGenerator(db.tourItems.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager($_db, $_db.pois)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TourItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TourItemsTable> {
  $$TourItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$ToursTableFilterComposer get tourId {
    final $$ToursTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tourId,
        referencedTable: $db.tours,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToursTableFilterComposer(
              $db: $db,
              $table: $db.tours,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableFilterComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TourItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TourItemsTable> {
  $$TourItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$ToursTableOrderingComposer get tourId {
    final $$ToursTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tourId,
        referencedTable: $db.tours,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToursTableOrderingComposer(
              $db: $db,
              $table: $db.tours,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableOrderingComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TourItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TourItemsTable> {
  $$TourItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$ToursTableAnnotationComposer get tourId {
    final $$ToursTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tourId,
        referencedTable: $db.tours,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToursTableAnnotationComposer(
              $db: $db,
              $table: $db.tours,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableAnnotationComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TourItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TourItemsTable,
    TourItem,
    $$TourItemsTableFilterComposer,
    $$TourItemsTableOrderingComposer,
    $$TourItemsTableAnnotationComposer,
    $$TourItemsTableCreateCompanionBuilder,
    $$TourItemsTableUpdateCompanionBuilder,
    (TourItem, $$TourItemsTableReferences),
    TourItem,
    PrefetchHooks Function({bool tourId, bool poiId})> {
  $$TourItemsTableTableManager(_$AppDatabase db, $TourItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TourItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TourItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TourItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tourId = const Value.absent(),
            Value<String> poiId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TourItemsCompanion(
            id: id,
            tourId: tourId,
            poiId: poiId,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tourId,
            required String poiId,
            required int orderIndex,
            Value<int> rowid = const Value.absent(),
          }) =>
              TourItemsCompanion.insert(
            id: id,
            tourId: tourId,
            poiId: poiId,
            orderIndex: orderIndex,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TourItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tourId = false, poiId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tourId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tourId,
                    referencedTable:
                        $$TourItemsTableReferences._tourIdTable(db),
                    referencedColumn:
                        $$TourItemsTableReferences._tourIdTable(db).id,
                  ) as T;
                }
                if (poiId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.poiId,
                    referencedTable: $$TourItemsTableReferences._poiIdTable(db),
                    referencedColumn:
                        $$TourItemsTableReferences._poiIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TourItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TourItemsTable,
    TourItem,
    $$TourItemsTableFilterComposer,
    $$TourItemsTableOrderingComposer,
    $$TourItemsTableAnnotationComposer,
    $$TourItemsTableCreateCompanionBuilder,
    $$TourItemsTableUpdateCompanionBuilder,
    (TourItem, $$TourItemsTableReferences),
    TourItem,
    PrefetchHooks Function({bool tourId, bool poiId})>;
typedef $$NarrationsTableCreateCompanionBuilder = NarrationsCompanion Function({
  required String id,
  required String poiId,
  required String url,
  required String locale,
  Value<double?> durationSeconds,
  Value<String?> transcript,
  Value<String?> localPath,
  Value<String?> kidsUrl,
  Value<String?> voiceId,
  Value<int?> filesizeBytes,
  Value<int> rowid,
});
typedef $$NarrationsTableUpdateCompanionBuilder = NarrationsCompanion Function({
  Value<String> id,
  Value<String> poiId,
  Value<String> url,
  Value<String> locale,
  Value<double?> durationSeconds,
  Value<String?> transcript,
  Value<String?> localPath,
  Value<String?> kidsUrl,
  Value<String?> voiceId,
  Value<int?> filesizeBytes,
  Value<int> rowid,
});

final class $$NarrationsTableReferences
    extends BaseReferences<_$AppDatabase, $NarrationsTable, Narration> {
  $$NarrationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) => db.pois
      .createAlias($_aliasNameGenerator(db.narrations.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager($_db, $_db.pois)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NarrationsTableFilterComposer
    extends Composer<_$AppDatabase, $NarrationsTable> {
  $$NarrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kidsUrl => $composableBuilder(
      column: $table.kidsUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceId => $composableBuilder(
      column: $table.voiceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get filesizeBytes => $composableBuilder(
      column: $table.filesizeBytes, builder: (column) => ColumnFilters(column));

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableFilterComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NarrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NarrationsTable> {
  $$NarrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kidsUrl => $composableBuilder(
      column: $table.kidsUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceId => $composableBuilder(
      column: $table.voiceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get filesizeBytes => $composableBuilder(
      column: $table.filesizeBytes,
      builder: (column) => ColumnOrderings(column));

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableOrderingComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NarrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NarrationsTable> {
  $$NarrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get kidsUrl =>
      $composableBuilder(column: $table.kidsUrl, builder: (column) => column);

  GeneratedColumn<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<int> get filesizeBytes => $composableBuilder(
      column: $table.filesizeBytes, builder: (column) => column);

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableAnnotationComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NarrationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NarrationsTable,
    Narration,
    $$NarrationsTableFilterComposer,
    $$NarrationsTableOrderingComposer,
    $$NarrationsTableAnnotationComposer,
    $$NarrationsTableCreateCompanionBuilder,
    $$NarrationsTableUpdateCompanionBuilder,
    (Narration, $$NarrationsTableReferences),
    Narration,
    PrefetchHooks Function({bool poiId})> {
  $$NarrationsTableTableManager(_$AppDatabase db, $NarrationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NarrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NarrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NarrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poiId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<double?> durationSeconds = const Value.absent(),
            Value<String?> transcript = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> kidsUrl = const Value.absent(),
            Value<String?> voiceId = const Value.absent(),
            Value<int?> filesizeBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NarrationsCompanion(
            id: id,
            poiId: poiId,
            url: url,
            locale: locale,
            durationSeconds: durationSeconds,
            transcript: transcript,
            localPath: localPath,
            kidsUrl: kidsUrl,
            voiceId: voiceId,
            filesizeBytes: filesizeBytes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poiId,
            required String url,
            required String locale,
            Value<double?> durationSeconds = const Value.absent(),
            Value<String?> transcript = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> kidsUrl = const Value.absent(),
            Value<String?> voiceId = const Value.absent(),
            Value<int?> filesizeBytes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NarrationsCompanion.insert(
            id: id,
            poiId: poiId,
            url: url,
            locale: locale,
            durationSeconds: durationSeconds,
            transcript: transcript,
            localPath: localPath,
            kidsUrl: kidsUrl,
            voiceId: voiceId,
            filesizeBytes: filesizeBytes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NarrationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({poiId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (poiId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.poiId,
                    referencedTable:
                        $$NarrationsTableReferences._poiIdTable(db),
                    referencedColumn:
                        $$NarrationsTableReferences._poiIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NarrationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NarrationsTable,
    Narration,
    $$NarrationsTableFilterComposer,
    $$NarrationsTableOrderingComposer,
    $$NarrationsTableAnnotationComposer,
    $$NarrationsTableCreateCompanionBuilder,
    $$NarrationsTableUpdateCompanionBuilder,
    (Narration, $$NarrationsTableReferences),
    Narration,
    PrefetchHooks Function({bool poiId})>;
typedef $$MediaTableCreateCompanionBuilder = MediaCompanion Function({
  required String id,
  required String poiId,
  required String url,
  required String mediaType,
  Value<String?> author,
  Value<String?> sourcePageUrl,
  Value<String?> licenseType,
  Value<String?> localPath,
  Value<int> rowid,
});
typedef $$MediaTableUpdateCompanionBuilder = MediaCompanion Function({
  Value<String> id,
  Value<String> poiId,
  Value<String> url,
  Value<String> mediaType,
  Value<String?> author,
  Value<String?> sourcePageUrl,
  Value<String?> licenseType,
  Value<String?> localPath,
  Value<int> rowid,
});

final class $$MediaTableReferences
    extends BaseReferences<_$AppDatabase, $MediaTable, MediaData> {
  $$MediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) =>
      db.pois.createAlias($_aliasNameGenerator(db.media.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager($_db, $_db.pois)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourcePageUrl => $composableBuilder(
      column: $table.sourcePageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableFilterComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaType => $composableBuilder(
      column: $table.mediaType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourcePageUrl => $composableBuilder(
      column: $table.sourcePageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableOrderingComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get sourcePageUrl => $composableBuilder(
      column: $table.sourcePageUrl, builder: (column) => column);

  GeneratedColumn<String> get licenseType => $composableBuilder(
      column: $table.licenseType, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableAnnotationComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaTable,
    MediaData,
    $$MediaTableFilterComposer,
    $$MediaTableOrderingComposer,
    $$MediaTableAnnotationComposer,
    $$MediaTableCreateCompanionBuilder,
    $$MediaTableUpdateCompanionBuilder,
    (MediaData, $$MediaTableReferences),
    MediaData,
    PrefetchHooks Function({bool poiId})> {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poiId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> mediaType = const Value.absent(),
            Value<String?> author = const Value.absent(),
            Value<String?> sourcePageUrl = const Value.absent(),
            Value<String?> licenseType = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaCompanion(
            id: id,
            poiId: poiId,
            url: url,
            mediaType: mediaType,
            author: author,
            sourcePageUrl: sourcePageUrl,
            licenseType: licenseType,
            localPath: localPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poiId,
            required String url,
            required String mediaType,
            Value<String?> author = const Value.absent(),
            Value<String?> sourcePageUrl = const Value.absent(),
            Value<String?> licenseType = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaCompanion.insert(
            id: id,
            poiId: poiId,
            url: url,
            mediaType: mediaType,
            author: author,
            sourcePageUrl: sourcePageUrl,
            licenseType: licenseType,
            localPath: localPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MediaTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({poiId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (poiId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.poiId,
                    referencedTable: $$MediaTableReferences._poiIdTable(db),
                    referencedColumn: $$MediaTableReferences._poiIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MediaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaTable,
    MediaData,
    $$MediaTableFilterComposer,
    $$MediaTableOrderingComposer,
    $$MediaTableAnnotationComposer,
    $$MediaTableCreateCompanionBuilder,
    $$MediaTableUpdateCompanionBuilder,
    (MediaData, $$MediaTableReferences),
    MediaData,
    PrefetchHooks Function({bool poiId})>;
typedef $$PoiSourcesTableCreateCompanionBuilder = PoiSourcesCompanion Function({
  required String id,
  required String poiId,
  required String name,
  Value<String?> url,
  Value<int> rowid,
});
typedef $$PoiSourcesTableUpdateCompanionBuilder = PoiSourcesCompanion Function({
  Value<String> id,
  Value<String> poiId,
  Value<String> name,
  Value<String?> url,
  Value<int> rowid,
});

final class $$PoiSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $PoiSourcesTable, PoiSource> {
  $$PoiSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PoisTable _poiIdTable(_$AppDatabase db) => db.pois
      .createAlias($_aliasNameGenerator(db.poiSources.poiId, db.pois.id));

  $$PoisTableProcessedTableManager get poiId {
    final $_column = $_itemColumn<String>('poi_id')!;

    final manager = $$PoisTableTableManager($_db, $_db.pois)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PoiSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $PoiSourcesTable> {
  $$PoiSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  $$PoisTableFilterComposer get poiId {
    final $$PoisTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableFilterComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PoiSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $PoiSourcesTable> {
  $$PoiSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  $$PoisTableOrderingComposer get poiId {
    final $$PoisTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableOrderingComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PoiSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoiSourcesTable> {
  $$PoiSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  $$PoisTableAnnotationComposer get poiId {
    final $$PoisTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.poiId,
        referencedTable: $db.pois,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PoisTableAnnotationComposer(
              $db: $db,
              $table: $db.pois,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PoiSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PoiSourcesTable,
    PoiSource,
    $$PoiSourcesTableFilterComposer,
    $$PoiSourcesTableOrderingComposer,
    $$PoiSourcesTableAnnotationComposer,
    $$PoiSourcesTableCreateCompanionBuilder,
    $$PoiSourcesTableUpdateCompanionBuilder,
    (PoiSource, $$PoiSourcesTableReferences),
    PoiSource,
    PrefetchHooks Function({bool poiId})> {
  $$PoiSourcesTableTableManager(_$AppDatabase db, $PoiSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoiSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoiSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoiSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poiId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoiSourcesCompanion(
            id: id,
            poiId: poiId,
            name: name,
            url: url,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poiId,
            required String name,
            Value<String?> url = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoiSourcesCompanion.insert(
            id: id,
            poiId: poiId,
            name: name,
            url: url,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PoiSourcesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({poiId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (poiId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.poiId,
                    referencedTable:
                        $$PoiSourcesTableReferences._poiIdTable(db),
                    referencedColumn:
                        $$PoiSourcesTableReferences._poiIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PoiSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PoiSourcesTable,
    PoiSource,
    $$PoiSourcesTableFilterComposer,
    $$PoiSourcesTableOrderingComposer,
    $$PoiSourcesTableAnnotationComposer,
    $$PoiSourcesTableCreateCompanionBuilder,
    $$PoiSourcesTableUpdateCompanionBuilder,
    (PoiSource, $$PoiSourcesTableReferences),
    PoiSource,
    PrefetchHooks Function({bool poiId})>;
typedef $$EntitlementGrantsTableCreateCompanionBuilder
    = EntitlementGrantsCompanion Function({
  required String id,
  required String entitlementSlug,
  required String scope,
  Value<String?> ref,
  required DateTime grantedAt,
  Value<DateTime?> expiresAt,
  required bool isActive,
  Value<int> rowid,
});
typedef $$EntitlementGrantsTableUpdateCompanionBuilder
    = EntitlementGrantsCompanion Function({
  Value<String> id,
  Value<String> entitlementSlug,
  Value<String> scope,
  Value<String?> ref,
  Value<DateTime> grantedAt,
  Value<DateTime?> expiresAt,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$EntitlementGrantsTableFilterComposer
    extends Composer<_$AppDatabase, $EntitlementGrantsTable> {
  $$EntitlementGrantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entitlementSlug => $composableBuilder(
      column: $table.entitlementSlug,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ref => $composableBuilder(
      column: $table.ref, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$EntitlementGrantsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitlementGrantsTable> {
  $$EntitlementGrantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entitlementSlug => $composableBuilder(
      column: $table.entitlementSlug,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ref => $composableBuilder(
      column: $table.ref, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
      column: $table.grantedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$EntitlementGrantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitlementGrantsTable> {
  $$EntitlementGrantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entitlementSlug => $composableBuilder(
      column: $table.entitlementSlug, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$EntitlementGrantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntitlementGrantsTable,
    EntitlementGrant,
    $$EntitlementGrantsTableFilterComposer,
    $$EntitlementGrantsTableOrderingComposer,
    $$EntitlementGrantsTableAnnotationComposer,
    $$EntitlementGrantsTableCreateCompanionBuilder,
    $$EntitlementGrantsTableUpdateCompanionBuilder,
    (
      EntitlementGrant,
      BaseReferences<_$AppDatabase, $EntitlementGrantsTable, EntitlementGrant>
    ),
    EntitlementGrant,
    PrefetchHooks Function()> {
  $$EntitlementGrantsTableTableManager(
      _$AppDatabase db, $EntitlementGrantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitlementGrantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitlementGrantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitlementGrantsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entitlementSlug = const Value.absent(),
            Value<String> scope = const Value.absent(),
            Value<String?> ref = const Value.absent(),
            Value<DateTime> grantedAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntitlementGrantsCompanion(
            id: id,
            entitlementSlug: entitlementSlug,
            scope: scope,
            ref: ref,
            grantedAt: grantedAt,
            expiresAt: expiresAt,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entitlementSlug,
            required String scope,
            Value<String?> ref = const Value.absent(),
            required DateTime grantedAt,
            Value<DateTime?> expiresAt = const Value.absent(),
            required bool isActive,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntitlementGrantsCompanion.insert(
            id: id,
            entitlementSlug: entitlementSlug,
            scope: scope,
            ref: ref,
            grantedAt: grantedAt,
            expiresAt: expiresAt,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntitlementGrantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntitlementGrantsTable,
    EntitlementGrant,
    $$EntitlementGrantsTableFilterComposer,
    $$EntitlementGrantsTableOrderingComposer,
    $$EntitlementGrantsTableAnnotationComposer,
    $$EntitlementGrantsTableCreateCompanionBuilder,
    $$EntitlementGrantsTableUpdateCompanionBuilder,
    (
      EntitlementGrant,
      BaseReferences<_$AppDatabase, $EntitlementGrantsTable, EntitlementGrant>
    ),
    EntitlementGrant,
    PrefetchHooks Function()>;
typedef $$EtagsTableCreateCompanionBuilder = EtagsCompanion Function({
  required String url,
  required String etag,
  Value<int> rowid,
});
typedef $$EtagsTableUpdateCompanionBuilder = EtagsCompanion Function({
  Value<String> url,
  Value<String> etag,
  Value<int> rowid,
});

class $$EtagsTableFilterComposer extends Composer<_$AppDatabase, $EtagsTable> {
  $$EtagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnFilters(column));
}

class $$EtagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EtagsTable> {
  $$EtagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get etag => $composableBuilder(
      column: $table.etag, builder: (column) => ColumnOrderings(column));
}

class $$EtagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EtagsTable> {
  $$EtagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);
}

class $$EtagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EtagsTable,
    Etag,
    $$EtagsTableFilterComposer,
    $$EtagsTableOrderingComposer,
    $$EtagsTableAnnotationComposer,
    $$EtagsTableCreateCompanionBuilder,
    $$EtagsTableUpdateCompanionBuilder,
    (Etag, BaseReferences<_$AppDatabase, $EtagsTable, Etag>),
    Etag,
    PrefetchHooks Function()> {
  $$EtagsTableTableManager(_$AppDatabase db, $EtagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EtagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EtagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EtagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<String> etag = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EtagsCompanion(
            url: url,
            etag: etag,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            required String etag,
            Value<int> rowid = const Value.absent(),
          }) =>
              EtagsCompanion.insert(
            url: url,
            etag: etag,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EtagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EtagsTable,
    Etag,
    $$EtagsTableFilterComposer,
    $$EtagsTableOrderingComposer,
    $$EtagsTableAnnotationComposer,
    $$EtagsTableCreateCompanionBuilder,
    $$EtagsTableUpdateCompanionBuilder,
    (Etag, BaseReferences<_$AppDatabase, $EtagsTable, Etag>),
    Etag,
    PrefetchHooks Function()>;
typedef $$QrMappingsCacheTableCreateCompanionBuilder = QrMappingsCacheCompanion
    Function({
  required String code,
  required String targetType,
  required String targetId,
  Value<String?> redirectUrl,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$QrMappingsCacheTableUpdateCompanionBuilder = QrMappingsCacheCompanion
    Function({
  Value<String> code,
  Value<String> targetType,
  Value<String> targetId,
  Value<String?> redirectUrl,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$QrMappingsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QrMappingsCacheTable> {
  $$QrMappingsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get redirectUrl => $composableBuilder(
      column: $table.redirectUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$QrMappingsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QrMappingsCacheTable> {
  $$QrMappingsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get redirectUrl => $composableBuilder(
      column: $table.redirectUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$QrMappingsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QrMappingsCacheTable> {
  $$QrMappingsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
      column: $table.targetType, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get redirectUrl => $composableBuilder(
      column: $table.redirectUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$QrMappingsCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QrMappingsCacheTable,
    QrMappingsCacheData,
    $$QrMappingsCacheTableFilterComposer,
    $$QrMappingsCacheTableOrderingComposer,
    $$QrMappingsCacheTableAnnotationComposer,
    $$QrMappingsCacheTableCreateCompanionBuilder,
    $$QrMappingsCacheTableUpdateCompanionBuilder,
    (
      QrMappingsCacheData,
      BaseReferences<_$AppDatabase, $QrMappingsCacheTable, QrMappingsCacheData>
    ),
    QrMappingsCacheData,
    PrefetchHooks Function()> {
  $$QrMappingsCacheTableTableManager(
      _$AppDatabase db, $QrMappingsCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QrMappingsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QrMappingsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QrMappingsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> targetType = const Value.absent(),
            Value<String> targetId = const Value.absent(),
            Value<String?> redirectUrl = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QrMappingsCacheCompanion(
            code: code,
            targetType: targetType,
            targetId: targetId,
            redirectUrl: redirectUrl,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            required String targetType,
            required String targetId,
            Value<String?> redirectUrl = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QrMappingsCacheCompanion.insert(
            code: code,
            targetType: targetType,
            targetId: targetId,
            redirectUrl: redirectUrl,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QrMappingsCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QrMappingsCacheTable,
    QrMappingsCacheData,
    $$QrMappingsCacheTableFilterComposer,
    $$QrMappingsCacheTableOrderingComposer,
    $$QrMappingsCacheTableAnnotationComposer,
    $$QrMappingsCacheTableCreateCompanionBuilder,
    $$QrMappingsCacheTableUpdateCompanionBuilder,
    (
      QrMappingsCacheData,
      BaseReferences<_$AppDatabase, $QrMappingsCacheTable, QrMappingsCacheData>
    ),
    QrMappingsCacheData,
    PrefetchHooks Function()>;
typedef $$AnalyticsPendingEventsTableCreateCompanionBuilder
    = AnalyticsPendingEventsCompanion Function({
  required String id,
  required String eventType,
  Value<String?> payloadJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AnalyticsPendingEventsTableUpdateCompanionBuilder
    = AnalyticsPendingEventsCompanion Function({
  Value<String> id,
  Value<String> eventType,
  Value<String?> payloadJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AnalyticsPendingEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsPendingEventsTable> {
  $$AnalyticsPendingEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AnalyticsPendingEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsPendingEventsTable> {
  $$AnalyticsPendingEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AnalyticsPendingEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsPendingEventsTable> {
  $$AnalyticsPendingEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AnalyticsPendingEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AnalyticsPendingEventsTable,
    AnalyticsPendingEvent,
    $$AnalyticsPendingEventsTableFilterComposer,
    $$AnalyticsPendingEventsTableOrderingComposer,
    $$AnalyticsPendingEventsTableAnnotationComposer,
    $$AnalyticsPendingEventsTableCreateCompanionBuilder,
    $$AnalyticsPendingEventsTableUpdateCompanionBuilder,
    (
      AnalyticsPendingEvent,
      BaseReferences<_$AppDatabase, $AnalyticsPendingEventsTable,
          AnalyticsPendingEvent>
    ),
    AnalyticsPendingEvent,
    PrefetchHooks Function()> {
  $$AnalyticsPendingEventsTableTableManager(
      _$AppDatabase db, $AnalyticsPendingEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsPendingEventsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsPendingEventsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalyticsPendingEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String?> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnalyticsPendingEventsCompanion(
            id: id,
            eventType: eventType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eventType,
            Value<String?> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AnalyticsPendingEventsCompanion.insert(
            id: id,
            eventType: eventType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AnalyticsPendingEventsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AnalyticsPendingEventsTable,
        AnalyticsPendingEvent,
        $$AnalyticsPendingEventsTableFilterComposer,
        $$AnalyticsPendingEventsTableOrderingComposer,
        $$AnalyticsPendingEventsTableAnnotationComposer,
        $$AnalyticsPendingEventsTableCreateCompanionBuilder,
        $$AnalyticsPendingEventsTableUpdateCompanionBuilder,
        (
          AnalyticsPendingEvent,
          BaseReferences<_$AppDatabase, $AnalyticsPendingEventsTable,
              AnalyticsPendingEvent>
        ),
        AnalyticsPendingEvent,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db, _db.cities);
  $$ToursTableTableManager get tours =>
      $$ToursTableTableManager(_db, _db.tours);
  $$PoisTableTableManager get pois => $$PoisTableTableManager(_db, _db.pois);
  $$TourItemsTableTableManager get tourItems =>
      $$TourItemsTableTableManager(_db, _db.tourItems);
  $$NarrationsTableTableManager get narrations =>
      $$NarrationsTableTableManager(_db, _db.narrations);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$PoiSourcesTableTableManager get poiSources =>
      $$PoiSourcesTableTableManager(_db, _db.poiSources);
  $$EntitlementGrantsTableTableManager get entitlementGrants =>
      $$EntitlementGrantsTableTableManager(_db, _db.entitlementGrants);
  $$EtagsTableTableManager get etags =>
      $$EtagsTableTableManager(_db, _db.etags);
  $$QrMappingsCacheTableTableManager get qrMappingsCache =>
      $$QrMappingsCacheTableTableManager(_db, _db.qrMappingsCache);
  $$AnalyticsPendingEventsTableTableManager get analyticsPendingEvents =>
      $$AnalyticsPendingEventsTableTableManager(
          _db, _db.analyticsPendingEvents);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appDatabaseProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'8c69eb46d45206533c176c88a926608e79ca927d';
