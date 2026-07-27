// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
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
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Project({
    required this.id,
    required this.name,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationSubtypesTable extends OperationSubtypes
    with TableInfo<$OperationSubtypesTable, OperationSubtype> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationSubtypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperationCategory, String>
  category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OperationCategory>(
        $OperationSubtypesTable.$convertercategory,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    name,
    isBuiltIn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operation_subtypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationSubtype> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationSubtype map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationSubtype(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: $OperationSubtypesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OperationSubtypesTable createAlias(String alias) {
    return $OperationSubtypesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperationCategory, String, String>
  $convertercategory = const EnumNameConverter<OperationCategory>(
    OperationCategory.values,
  );
}

class OperationSubtype extends DataClass
    implements Insertable<OperationSubtype> {
  final String id;
  final OperationCategory category;
  final String name;
  final bool isBuiltIn;
  final DateTime createdAt;
  const OperationSubtype({
    required this.id,
    required this.category,
    required this.name,
    required this.isBuiltIn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['category'] = Variable<String>(
        $OperationSubtypesTable.$convertercategory.toSql(category),
      );
    }
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OperationSubtypesCompanion toCompanion(bool nullToAbsent) {
    return OperationSubtypesCompanion(
      id: Value(id),
      category: Value(category),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
      createdAt: Value(createdAt),
    );
  }

  factory OperationSubtype.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationSubtype(
      id: serializer.fromJson<String>(json['id']),
      category: $OperationSubtypesTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(
        $OperationSubtypesTable.$convertercategory.toJson(category),
      ),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OperationSubtype copyWith({
    String? id,
    OperationCategory? category,
    String? name,
    bool? isBuiltIn,
    DateTime? createdAt,
  }) => OperationSubtype(
    id: id ?? this.id,
    category: category ?? this.category,
    name: name ?? this.name,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    createdAt: createdAt ?? this.createdAt,
  );
  OperationSubtype copyWithCompanion(OperationSubtypesCompanion data) {
    return OperationSubtype(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationSubtype(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, name, isBuiltIn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationSubtype &&
          other.id == this.id &&
          other.category == this.category &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn &&
          other.createdAt == this.createdAt);
}

class OperationSubtypesCompanion extends UpdateCompanion<OperationSubtype> {
  final Value<String> id;
  final Value<OperationCategory> category;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OperationSubtypesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationSubtypesCompanion.insert({
    required String id,
    required OperationCategory category,
    required String name,
    this.isBuiltIn = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<OperationSubtype> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationSubtypesCompanion copyWith({
    Value<String>? id,
    Value<OperationCategory>? category,
    Value<String>? name,
    Value<bool>? isBuiltIn,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OperationSubtypesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
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
    if (category.present) {
      map['category'] = Variable<String>(
        $OperationSubtypesTable.$convertercategory.toSql(category.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
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
    return (StringBuffer('OperationSubtypesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogOperationsTable extends CatalogOperations
    with TableInfo<$CatalogOperationsTable, CatalogOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperationCategory, String>
  category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OperationCategory>(
        $CatalogOperationsTable.$convertercategory,
      );
  static const VerificationMeta _subtypeIdMeta = const VerificationMeta(
    'subtypeId',
  );
  @override
  late final GeneratedColumn<String> subtypeId = GeneratedColumn<String>(
    'subtype_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operation_subtypes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _referenceStandardMsMeta =
      const VerificationMeta('referenceStandardMs');
  @override
  late final GeneratedColumn<int> referenceStandardMs = GeneratedColumn<int>(
    'reference_standard_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subtype_id')) {
      context.handle(
        _subtypeIdMeta,
        subtypeId.isAcceptableOrUnknown(data['subtype_id']!, _subtypeIdMeta),
      );
    }
    if (data.containsKey('reference_standard_ms')) {
      context.handle(
        _referenceStandardMsMeta,
        referenceStandardMs.isAcceptableOrUnknown(
          data['reference_standard_ms']!,
          _referenceStandardMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $CatalogOperationsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subtypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype_id'],
      ),
      referenceStandardMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_standard_ms'],
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
  $CatalogOperationsTable createAlias(String alias) {
    return $CatalogOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperationCategory, String, String>
  $convertercategory = const EnumNameConverter<OperationCategory>(
    OperationCategory.values,
  );
}

class CatalogOperation extends DataClass
    implements Insertable<CatalogOperation> {
  final String id;
  final String name;
  final OperationCategory category;
  final String? subtypeId;

  /// Optional pre-existing benchmark ("reference standard"), in milliseconds.
  final int? referenceStandardMs;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CatalogOperation({
    required this.id,
    required this.name,
    required this.category,
    this.subtypeId,
    this.referenceStandardMs,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $CatalogOperationsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || subtypeId != null) {
      map['subtype_id'] = Variable<String>(subtypeId);
    }
    if (!nullToAbsent || referenceStandardMs != null) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CatalogOperationsCompanion toCompanion(bool nullToAbsent) {
    return CatalogOperationsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subtypeId: subtypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtypeId),
      referenceStandardMs: referenceStandardMs == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceStandardMs),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatalogOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogOperation(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $CatalogOperationsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      subtypeId: serializer.fromJson<String?>(json['subtypeId']),
      referenceStandardMs: serializer.fromJson<int?>(
        json['referenceStandardMs'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $CatalogOperationsTable.$convertercategory.toJson(category),
      ),
      'subtypeId': serializer.toJson<String?>(subtypeId),
      'referenceStandardMs': serializer.toJson<int?>(referenceStandardMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CatalogOperation copyWith({
    String? id,
    String? name,
    OperationCategory? category,
    Value<String?> subtypeId = const Value.absent(),
    Value<int?> referenceStandardMs = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CatalogOperation(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    subtypeId: subtypeId.present ? subtypeId.value : this.subtypeId,
    referenceStandardMs: referenceStandardMs.present
        ? referenceStandardMs.value
        : this.referenceStandardMs,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CatalogOperation copyWithCompanion(CatalogOperationsCompanion data) {
    return CatalogOperation(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subtypeId: data.subtypeId.present ? data.subtypeId.value : this.subtypeId,
      referenceStandardMs: data.referenceStandardMs.present
          ? data.referenceStandardMs.value
          : this.referenceStandardMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogOperation(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogOperation &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subtypeId == this.subtypeId &&
          other.referenceStandardMs == this.referenceStandardMs &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CatalogOperationsCompanion extends UpdateCompanion<CatalogOperation> {
  final Value<String> id;
  final Value<String> name;
  final Value<OperationCategory> category;
  final Value<String?> subtypeId;
  final Value<int?> referenceStandardMs;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CatalogOperationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogOperationsCompanion.insert({
    required String id,
    required String name,
    required OperationCategory category,
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatalogOperation> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subtypeId,
    Expression<int>? referenceStandardMs,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subtypeId != null) 'subtype_id': subtypeId,
      if (referenceStandardMs != null)
        'reference_standard_ms': referenceStandardMs,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<OperationCategory>? category,
    Value<String?>? subtypeId,
    Value<int?>? referenceStandardMs,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CatalogOperationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subtypeId: subtypeId ?? this.subtypeId,
      referenceStandardMs: referenceStandardMs ?? this.referenceStandardMs,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $CatalogOperationsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subtypeId.present) {
      map['subtype_id'] = Variable<String>(subtypeId.value);
    }
    if (referenceStandardMs.present) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs.value);
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
    return (StringBuffer('CatalogOperationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudiesTable extends Studies with TableInfo<$StudiesTable, Study> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StudyType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StudyType>($StudiesTable.$convertertype);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analystMeta = const VerificationMeta(
    'analyst',
  );
  @override
  late final GeneratedColumn<String> analyst = GeneratedColumn<String>(
    'analyst',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partProductMeta = const VerificationMeta(
    'partProduct',
  );
  @override
  late final GeneratedColumn<String> partProduct = GeneratedColumn<String>(
    'part_product',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processOperationMeta = const VerificationMeta(
    'processOperation',
  );
  @override
  late final GeneratedColumn<String> processOperation = GeneratedColumn<String>(
    'process_operation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _machineWorkstationMeta =
      const VerificationMeta('machineWorkstation');
  @override
  late final GeneratedColumn<String> machineWorkstation =
      GeneratedColumn<String>(
        'machine_workstation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lineCellMeta = const VerificationMeta(
    'lineCell',
  );
  @override
  late final GeneratedColumn<String> lineCell = GeneratedColumn<String>(
    'line_cell',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatorNameMeta = const VerificationMeta(
    'operatorName',
  );
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
    'operator_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftMeta = const VerificationMeta('shift');
  @override
  late final GeneratedColumn<String> shift = GeneratedColumn<String>(
    'shift',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workOrderNumberMeta = const VerificationMeta(
    'workOrderNumber',
  );
  @override
  late final GeneratedColumn<String> workOrderNumber = GeneratedColumn<String>(
    'work_order_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processTypeMeta = const VerificationMeta(
    'processType',
  );
  @override
  late final GeneratedColumn<String> processType = GeneratedColumn<String>(
    'process_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceLevelMeta = const VerificationMeta(
    'confidenceLevel',
  );
  @override
  late final GeneratedColumn<double> confidenceLevel = GeneratedColumn<double>(
    'confidence_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.95),
  );
  static const VerificationMeta _relativePrecisionMeta = const VerificationMeta(
    'relativePrecision',
  );
  @override
  late final GeneratedColumn<double> relativePrecision =
      GeneratedColumn<double>(
        'relative_precision',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.05),
      );
  static const VerificationMeta _nextPassIndexMeta = const VerificationMeta(
    'nextPassIndex',
  );
  @override
  late final GeneratedColumn<int> nextPassIndex = GeneratedColumn<int>(
    'next_pass_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    type,
    name,
    performedAt,
    analyst,
    partProduct,
    processOperation,
    machineWorkstation,
    lineCell,
    operatorName,
    shift,
    workOrderNumber,
    processType,
    notes,
    confidenceLevel,
    relativePrecision,
    nextPassIndex,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'studies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Study> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('analyst')) {
      context.handle(
        _analystMeta,
        analyst.isAcceptableOrUnknown(data['analyst']!, _analystMeta),
      );
    }
    if (data.containsKey('part_product')) {
      context.handle(
        _partProductMeta,
        partProduct.isAcceptableOrUnknown(
          data['part_product']!,
          _partProductMeta,
        ),
      );
    }
    if (data.containsKey('process_operation')) {
      context.handle(
        _processOperationMeta,
        processOperation.isAcceptableOrUnknown(
          data['process_operation']!,
          _processOperationMeta,
        ),
      );
    }
    if (data.containsKey('machine_workstation')) {
      context.handle(
        _machineWorkstationMeta,
        machineWorkstation.isAcceptableOrUnknown(
          data['machine_workstation']!,
          _machineWorkstationMeta,
        ),
      );
    }
    if (data.containsKey('line_cell')) {
      context.handle(
        _lineCellMeta,
        lineCell.isAcceptableOrUnknown(data['line_cell']!, _lineCellMeta),
      );
    }
    if (data.containsKey('operator_name')) {
      context.handle(
        _operatorNameMeta,
        operatorName.isAcceptableOrUnknown(
          data['operator_name']!,
          _operatorNameMeta,
        ),
      );
    }
    if (data.containsKey('shift')) {
      context.handle(
        _shiftMeta,
        shift.isAcceptableOrUnknown(data['shift']!, _shiftMeta),
      );
    }
    if (data.containsKey('work_order_number')) {
      context.handle(
        _workOrderNumberMeta,
        workOrderNumber.isAcceptableOrUnknown(
          data['work_order_number']!,
          _workOrderNumberMeta,
        ),
      );
    }
    if (data.containsKey('process_type')) {
      context.handle(
        _processTypeMeta,
        processType.isAcceptableOrUnknown(
          data['process_type']!,
          _processTypeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('confidence_level')) {
      context.handle(
        _confidenceLevelMeta,
        confidenceLevel.isAcceptableOrUnknown(
          data['confidence_level']!,
          _confidenceLevelMeta,
        ),
      );
    }
    if (data.containsKey('relative_precision')) {
      context.handle(
        _relativePrecisionMeta,
        relativePrecision.isAcceptableOrUnknown(
          data['relative_precision']!,
          _relativePrecisionMeta,
        ),
      );
    }
    if (data.containsKey('next_pass_index')) {
      context.handle(
        _nextPassIndexMeta,
        nextPassIndex.isAcceptableOrUnknown(
          data['next_pass_index']!,
          _nextPassIndexMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Study map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Study(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      type: $StudiesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      analyst: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analyst'],
      ),
      partProduct: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_product'],
      ),
      processOperation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_operation'],
      ),
      machineWorkstation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}machine_workstation'],
      ),
      lineCell: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_cell'],
      ),
      operatorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_name'],
      ),
      shift: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shift'],
      ),
      workOrderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_order_number'],
      ),
      processType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_type'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      confidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence_level'],
      )!,
      relativePrecision: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}relative_precision'],
      )!,
      nextPassIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_pass_index'],
      )!,
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
  $StudiesTable createAlias(String alias) {
    return $StudiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StudyType, String, String> $convertertype =
      const EnumNameConverter<StudyType>(StudyType.values);
}

class Study extends DataClass implements Insertable<Study> {
  final String id;
  final String projectId;
  final StudyType type;
  final String name;
  final DateTime performedAt;
  final String? analyst;
  final String? partProduct;
  final String? processOperation;
  final String? machineWorkstation;
  final String? lineCell;
  final String? operatorName;
  final String? shift;
  final String? workOrderNumber;

  /// Chosen value from the editable [ProcessTypeOptions] picklist, snapshotted
  /// as text so historical studies keep their value if the option changes.
  final String? processType;
  final String? notes;

  /// Sample-size criteria for a Sampling Study, **stored per study rather than
  /// as a global preference** (DESIGN.md §11.5).
  ///
  /// Same reasoning as snapshotting reference standards (§3.3): the criteria a
  /// study was judged against belong to that study. A global setting would
  /// silently re-judge every past study when someone changed it, so a report
  /// that read "adequate" could later read otherwise with no record of which
  /// criteria produced the original verdict.
  ///
  /// [confidenceLevel] is a probability (0,1) — 0.95 for 95 %. [relativePrecision]
  /// is a fraction of the mean — 0.05 for ±5 %. Both are meaningless for a Time
  /// Study and simply unused there.
  final double confidenceLevel;
  final double relativePrecision;

  /// The sequence index the next pass will take — a counter, not a count
  /// (DESIGN.md §11.3).
  ///
  /// Pass numbers are never reused, and `MAX(sequenceIndex) + 1` cannot deliver
  /// that: deleting the highest pass would hand its number straight back to the
  /// next one. Only a value that does not depend on which rows still exist can,
  /// so it lives here and only ever goes up. Starts at 1 because creating a
  /// study also creates pass 0 (§11.1).
  final int nextPassIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Study({
    required this.id,
    required this.projectId,
    required this.type,
    required this.name,
    required this.performedAt,
    this.analyst,
    this.partProduct,
    this.processOperation,
    this.machineWorkstation,
    this.lineCell,
    this.operatorName,
    this.shift,
    this.workOrderNumber,
    this.processType,
    this.notes,
    required this.confidenceLevel,
    required this.relativePrecision,
    required this.nextPassIndex,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    {
      map['type'] = Variable<String>($StudiesTable.$convertertype.toSql(type));
    }
    map['name'] = Variable<String>(name);
    map['performed_at'] = Variable<DateTime>(performedAt);
    if (!nullToAbsent || analyst != null) {
      map['analyst'] = Variable<String>(analyst);
    }
    if (!nullToAbsent || partProduct != null) {
      map['part_product'] = Variable<String>(partProduct);
    }
    if (!nullToAbsent || processOperation != null) {
      map['process_operation'] = Variable<String>(processOperation);
    }
    if (!nullToAbsent || machineWorkstation != null) {
      map['machine_workstation'] = Variable<String>(machineWorkstation);
    }
    if (!nullToAbsent || lineCell != null) {
      map['line_cell'] = Variable<String>(lineCell);
    }
    if (!nullToAbsent || operatorName != null) {
      map['operator_name'] = Variable<String>(operatorName);
    }
    if (!nullToAbsent || shift != null) {
      map['shift'] = Variable<String>(shift);
    }
    if (!nullToAbsent || workOrderNumber != null) {
      map['work_order_number'] = Variable<String>(workOrderNumber);
    }
    if (!nullToAbsent || processType != null) {
      map['process_type'] = Variable<String>(processType);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['confidence_level'] = Variable<double>(confidenceLevel);
    map['relative_precision'] = Variable<double>(relativePrecision);
    map['next_pass_index'] = Variable<int>(nextPassIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudiesCompanion toCompanion(bool nullToAbsent) {
    return StudiesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      type: Value(type),
      name: Value(name),
      performedAt: Value(performedAt),
      analyst: analyst == null && nullToAbsent
          ? const Value.absent()
          : Value(analyst),
      partProduct: partProduct == null && nullToAbsent
          ? const Value.absent()
          : Value(partProduct),
      processOperation: processOperation == null && nullToAbsent
          ? const Value.absent()
          : Value(processOperation),
      machineWorkstation: machineWorkstation == null && nullToAbsent
          ? const Value.absent()
          : Value(machineWorkstation),
      lineCell: lineCell == null && nullToAbsent
          ? const Value.absent()
          : Value(lineCell),
      operatorName: operatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorName),
      shift: shift == null && nullToAbsent
          ? const Value.absent()
          : Value(shift),
      workOrderNumber: workOrderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(workOrderNumber),
      processType: processType == null && nullToAbsent
          ? const Value.absent()
          : Value(processType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      confidenceLevel: Value(confidenceLevel),
      relativePrecision: Value(relativePrecision),
      nextPassIndex: Value(nextPassIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Study.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Study(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      type: $StudiesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      name: serializer.fromJson<String>(json['name']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      analyst: serializer.fromJson<String?>(json['analyst']),
      partProduct: serializer.fromJson<String?>(json['partProduct']),
      processOperation: serializer.fromJson<String?>(json['processOperation']),
      machineWorkstation: serializer.fromJson<String?>(
        json['machineWorkstation'],
      ),
      lineCell: serializer.fromJson<String?>(json['lineCell']),
      operatorName: serializer.fromJson<String?>(json['operatorName']),
      shift: serializer.fromJson<String?>(json['shift']),
      workOrderNumber: serializer.fromJson<String?>(json['workOrderNumber']),
      processType: serializer.fromJson<String?>(json['processType']),
      notes: serializer.fromJson<String?>(json['notes']),
      confidenceLevel: serializer.fromJson<double>(json['confidenceLevel']),
      relativePrecision: serializer.fromJson<double>(json['relativePrecision']),
      nextPassIndex: serializer.fromJson<int>(json['nextPassIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'type': serializer.toJson<String>(
        $StudiesTable.$convertertype.toJson(type),
      ),
      'name': serializer.toJson<String>(name),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'analyst': serializer.toJson<String?>(analyst),
      'partProduct': serializer.toJson<String?>(partProduct),
      'processOperation': serializer.toJson<String?>(processOperation),
      'machineWorkstation': serializer.toJson<String?>(machineWorkstation),
      'lineCell': serializer.toJson<String?>(lineCell),
      'operatorName': serializer.toJson<String?>(operatorName),
      'shift': serializer.toJson<String?>(shift),
      'workOrderNumber': serializer.toJson<String?>(workOrderNumber),
      'processType': serializer.toJson<String?>(processType),
      'notes': serializer.toJson<String?>(notes),
      'confidenceLevel': serializer.toJson<double>(confidenceLevel),
      'relativePrecision': serializer.toJson<double>(relativePrecision),
      'nextPassIndex': serializer.toJson<int>(nextPassIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Study copyWith({
    String? id,
    String? projectId,
    StudyType? type,
    String? name,
    DateTime? performedAt,
    Value<String?> analyst = const Value.absent(),
    Value<String?> partProduct = const Value.absent(),
    Value<String?> processOperation = const Value.absent(),
    Value<String?> machineWorkstation = const Value.absent(),
    Value<String?> lineCell = const Value.absent(),
    Value<String?> operatorName = const Value.absent(),
    Value<String?> shift = const Value.absent(),
    Value<String?> workOrderNumber = const Value.absent(),
    Value<String?> processType = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    double? confidenceLevel,
    double? relativePrecision,
    int? nextPassIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Study(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    type: type ?? this.type,
    name: name ?? this.name,
    performedAt: performedAt ?? this.performedAt,
    analyst: analyst.present ? analyst.value : this.analyst,
    partProduct: partProduct.present ? partProduct.value : this.partProduct,
    processOperation: processOperation.present
        ? processOperation.value
        : this.processOperation,
    machineWorkstation: machineWorkstation.present
        ? machineWorkstation.value
        : this.machineWorkstation,
    lineCell: lineCell.present ? lineCell.value : this.lineCell,
    operatorName: operatorName.present ? operatorName.value : this.operatorName,
    shift: shift.present ? shift.value : this.shift,
    workOrderNumber: workOrderNumber.present
        ? workOrderNumber.value
        : this.workOrderNumber,
    processType: processType.present ? processType.value : this.processType,
    notes: notes.present ? notes.value : this.notes,
    confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    relativePrecision: relativePrecision ?? this.relativePrecision,
    nextPassIndex: nextPassIndex ?? this.nextPassIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Study copyWithCompanion(StudiesCompanion data) {
    return Study(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      analyst: data.analyst.present ? data.analyst.value : this.analyst,
      partProduct: data.partProduct.present
          ? data.partProduct.value
          : this.partProduct,
      processOperation: data.processOperation.present
          ? data.processOperation.value
          : this.processOperation,
      machineWorkstation: data.machineWorkstation.present
          ? data.machineWorkstation.value
          : this.machineWorkstation,
      lineCell: data.lineCell.present ? data.lineCell.value : this.lineCell,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      shift: data.shift.present ? data.shift.value : this.shift,
      workOrderNumber: data.workOrderNumber.present
          ? data.workOrderNumber.value
          : this.workOrderNumber,
      processType: data.processType.present
          ? data.processType.value
          : this.processType,
      notes: data.notes.present ? data.notes.value : this.notes,
      confidenceLevel: data.confidenceLevel.present
          ? data.confidenceLevel.value
          : this.confidenceLevel,
      relativePrecision: data.relativePrecision.present
          ? data.relativePrecision.value
          : this.relativePrecision,
      nextPassIndex: data.nextPassIndex.present
          ? data.nextPassIndex.value
          : this.nextPassIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Study(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('performedAt: $performedAt, ')
          ..write('analyst: $analyst, ')
          ..write('partProduct: $partProduct, ')
          ..write('processOperation: $processOperation, ')
          ..write('machineWorkstation: $machineWorkstation, ')
          ..write('lineCell: $lineCell, ')
          ..write('operatorName: $operatorName, ')
          ..write('shift: $shift, ')
          ..write('workOrderNumber: $workOrderNumber, ')
          ..write('processType: $processType, ')
          ..write('notes: $notes, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('relativePrecision: $relativePrecision, ')
          ..write('nextPassIndex: $nextPassIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    type,
    name,
    performedAt,
    analyst,
    partProduct,
    processOperation,
    machineWorkstation,
    lineCell,
    operatorName,
    shift,
    workOrderNumber,
    processType,
    notes,
    confidenceLevel,
    relativePrecision,
    nextPassIndex,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Study &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.type == this.type &&
          other.name == this.name &&
          other.performedAt == this.performedAt &&
          other.analyst == this.analyst &&
          other.partProduct == this.partProduct &&
          other.processOperation == this.processOperation &&
          other.machineWorkstation == this.machineWorkstation &&
          other.lineCell == this.lineCell &&
          other.operatorName == this.operatorName &&
          other.shift == this.shift &&
          other.workOrderNumber == this.workOrderNumber &&
          other.processType == this.processType &&
          other.notes == this.notes &&
          other.confidenceLevel == this.confidenceLevel &&
          other.relativePrecision == this.relativePrecision &&
          other.nextPassIndex == this.nextPassIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudiesCompanion extends UpdateCompanion<Study> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<StudyType> type;
  final Value<String> name;
  final Value<DateTime> performedAt;
  final Value<String?> analyst;
  final Value<String?> partProduct;
  final Value<String?> processOperation;
  final Value<String?> machineWorkstation;
  final Value<String?> lineCell;
  final Value<String?> operatorName;
  final Value<String?> shift;
  final Value<String?> workOrderNumber;
  final Value<String?> processType;
  final Value<String?> notes;
  final Value<double> confidenceLevel;
  final Value<double> relativePrecision;
  final Value<int> nextPassIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudiesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.analyst = const Value.absent(),
    this.partProduct = const Value.absent(),
    this.processOperation = const Value.absent(),
    this.machineWorkstation = const Value.absent(),
    this.lineCell = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.shift = const Value.absent(),
    this.workOrderNumber = const Value.absent(),
    this.processType = const Value.absent(),
    this.notes = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.relativePrecision = const Value.absent(),
    this.nextPassIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudiesCompanion.insert({
    required String id,
    required String projectId,
    required StudyType type,
    required String name,
    required DateTime performedAt,
    this.analyst = const Value.absent(),
    this.partProduct = const Value.absent(),
    this.processOperation = const Value.absent(),
    this.machineWorkstation = const Value.absent(),
    this.lineCell = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.shift = const Value.absent(),
    this.workOrderNumber = const Value.absent(),
    this.processType = const Value.absent(),
    this.notes = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.relativePrecision = const Value.absent(),
    this.nextPassIndex = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       type = Value(type),
       name = Value(name),
       performedAt = Value(performedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Study> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<DateTime>? performedAt,
    Expression<String>? analyst,
    Expression<String>? partProduct,
    Expression<String>? processOperation,
    Expression<String>? machineWorkstation,
    Expression<String>? lineCell,
    Expression<String>? operatorName,
    Expression<String>? shift,
    Expression<String>? workOrderNumber,
    Expression<String>? processType,
    Expression<String>? notes,
    Expression<double>? confidenceLevel,
    Expression<double>? relativePrecision,
    Expression<int>? nextPassIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (performedAt != null) 'performed_at': performedAt,
      if (analyst != null) 'analyst': analyst,
      if (partProduct != null) 'part_product': partProduct,
      if (processOperation != null) 'process_operation': processOperation,
      if (machineWorkstation != null) 'machine_workstation': machineWorkstation,
      if (lineCell != null) 'line_cell': lineCell,
      if (operatorName != null) 'operator_name': operatorName,
      if (shift != null) 'shift': shift,
      if (workOrderNumber != null) 'work_order_number': workOrderNumber,
      if (processType != null) 'process_type': processType,
      if (notes != null) 'notes': notes,
      if (confidenceLevel != null) 'confidence_level': confidenceLevel,
      if (relativePrecision != null) 'relative_precision': relativePrecision,
      if (nextPassIndex != null) 'next_pass_index': nextPassIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudiesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<StudyType>? type,
    Value<String>? name,
    Value<DateTime>? performedAt,
    Value<String?>? analyst,
    Value<String?>? partProduct,
    Value<String?>? processOperation,
    Value<String?>? machineWorkstation,
    Value<String?>? lineCell,
    Value<String?>? operatorName,
    Value<String?>? shift,
    Value<String?>? workOrderNumber,
    Value<String?>? processType,
    Value<String?>? notes,
    Value<double>? confidenceLevel,
    Value<double>? relativePrecision,
    Value<int>? nextPassIndex,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StudiesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      name: name ?? this.name,
      performedAt: performedAt ?? this.performedAt,
      analyst: analyst ?? this.analyst,
      partProduct: partProduct ?? this.partProduct,
      processOperation: processOperation ?? this.processOperation,
      machineWorkstation: machineWorkstation ?? this.machineWorkstation,
      lineCell: lineCell ?? this.lineCell,
      operatorName: operatorName ?? this.operatorName,
      shift: shift ?? this.shift,
      workOrderNumber: workOrderNumber ?? this.workOrderNumber,
      processType: processType ?? this.processType,
      notes: notes ?? this.notes,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      relativePrecision: relativePrecision ?? this.relativePrecision,
      nextPassIndex: nextPassIndex ?? this.nextPassIndex,
      createdAt: createdAt ?? this.createdAt,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $StudiesTable.$convertertype.toSql(type.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (analyst.present) {
      map['analyst'] = Variable<String>(analyst.value);
    }
    if (partProduct.present) {
      map['part_product'] = Variable<String>(partProduct.value);
    }
    if (processOperation.present) {
      map['process_operation'] = Variable<String>(processOperation.value);
    }
    if (machineWorkstation.present) {
      map['machine_workstation'] = Variable<String>(machineWorkstation.value);
    }
    if (lineCell.present) {
      map['line_cell'] = Variable<String>(lineCell.value);
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(shift.value);
    }
    if (workOrderNumber.present) {
      map['work_order_number'] = Variable<String>(workOrderNumber.value);
    }
    if (processType.present) {
      map['process_type'] = Variable<String>(processType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (confidenceLevel.present) {
      map['confidence_level'] = Variable<double>(confidenceLevel.value);
    }
    if (relativePrecision.present) {
      map['relative_precision'] = Variable<double>(relativePrecision.value);
    }
    if (nextPassIndex.present) {
      map['next_pass_index'] = Variable<int>(nextPassIndex.value);
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
    return (StringBuffer('StudiesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('performedAt: $performedAt, ')
          ..write('analyst: $analyst, ')
          ..write('partProduct: $partProduct, ')
          ..write('processOperation: $processOperation, ')
          ..write('machineWorkstation: $machineWorkstation, ')
          ..write('lineCell: $lineCell, ')
          ..write('operatorName: $operatorName, ')
          ..write('shift: $shift, ')
          ..write('workOrderNumber: $workOrderNumber, ')
          ..write('processType: $processType, ')
          ..write('notes: $notes, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('relativePrecision: $relativePrecision, ')
          ..write('nextPassIndex: $nextPassIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyOperationsTable extends StudyOperations
    with TableInfo<$StudyOperationsTable, StudyOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studyIdMeta = const VerificationMeta(
    'studyId',
  );
  @override
  late final GeneratedColumn<String> studyId = GeneratedColumn<String>(
    'study_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES studies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _catalogOperationIdMeta =
      const VerificationMeta('catalogOperationId');
  @override
  late final GeneratedColumn<String> catalogOperationId =
      GeneratedColumn<String>(
        'catalog_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<double> orderIndex = GeneratedColumn<double>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperationCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<OperationCategory>($StudyOperationsTable.$convertercategory);
  static const VerificationMeta _subtypeIdMeta = const VerificationMeta(
    'subtypeId',
  );
  @override
  late final GeneratedColumn<String> subtypeId = GeneratedColumn<String>(
    'subtype_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operation_subtypes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _referenceStandardMsMeta =
      const VerificationMeta('referenceStandardMs');
  @override
  late final GeneratedColumn<int> referenceStandardMs = GeneratedColumn<int>(
    'reference_standard_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUnplannedMeta = const VerificationMeta(
    'isUnplanned',
  );
  @override
  late final GeneratedColumn<bool> isUnplanned = GeneratedColumn<bool>(
    'is_unplanned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unplanned" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studyId,
    catalogOperationId,
    orderIndex,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    isUnplanned,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('study_id')) {
      context.handle(
        _studyIdMeta,
        studyId.isAcceptableOrUnknown(data['study_id']!, _studyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studyIdMeta);
    }
    if (data.containsKey('catalog_operation_id')) {
      context.handle(
        _catalogOperationIdMeta,
        catalogOperationId.isAcceptableOrUnknown(
          data['catalog_operation_id']!,
          _catalogOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subtype_id')) {
      context.handle(
        _subtypeIdMeta,
        subtypeId.isAcceptableOrUnknown(data['subtype_id']!, _subtypeIdMeta),
      );
    }
    if (data.containsKey('reference_standard_ms')) {
      context.handle(
        _referenceStandardMsMeta,
        referenceStandardMs.isAcceptableOrUnknown(
          data['reference_standard_ms']!,
          _referenceStandardMsMeta,
        ),
      );
    }
    if (data.containsKey('is_unplanned')) {
      context.handle(
        _isUnplannedMeta,
        isUnplanned.isAcceptableOrUnknown(
          data['is_unplanned']!,
          _isUnplannedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_id'],
      )!,
      catalogOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_operation_id'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}order_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $StudyOperationsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subtypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype_id'],
      ),
      referenceStandardMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_standard_ms'],
      ),
      isUnplanned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unplanned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StudyOperationsTable createAlias(String alias) {
    return $StudyOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperationCategory, String, String>
  $convertercategory = const EnumNameConverter<OperationCategory>(
    OperationCategory.values,
  );
}

class StudyOperation extends DataClass implements Insertable<StudyOperation> {
  final String id;
  final String studyId;

  /// The catalog operation this was snapshotted from — **a value, not a
  /// reference** (DESIGN.md §11.8). Deliberately carries no foreign key.
  ///
  /// It is the key cross-study comparison groups by, and §3.3 promises it keeps
  /// working. As a foreign key with `setNull` it did not: deleting a catalog
  /// operation silently unmatched every study that had ever used it, with
  /// nothing said. Every other field here is already a snapshot for exactly this
  /// reason — the id was the one left live. Null means the operation was never
  /// from the catalog (added custom, or unplanned), which is the only reason it
  /// can be null now.
  final String? catalogOperationId;

  /// Fractional, so an unplanned op can be inserted between two existing ones
  /// (e.g. 2.5) without renumbering the rest of the sequence.
  final double orderIndex;
  final String name;
  final OperationCategory category;
  final String? subtypeId;
  final int? referenceStandardMs;
  final bool isUnplanned;
  final DateTime createdAt;
  const StudyOperation({
    required this.id,
    required this.studyId,
    this.catalogOperationId,
    required this.orderIndex,
    required this.name,
    required this.category,
    this.subtypeId,
    this.referenceStandardMs,
    required this.isUnplanned,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['study_id'] = Variable<String>(studyId);
    if (!nullToAbsent || catalogOperationId != null) {
      map['catalog_operation_id'] = Variable<String>(catalogOperationId);
    }
    map['order_index'] = Variable<double>(orderIndex);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $StudyOperationsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || subtypeId != null) {
      map['subtype_id'] = Variable<String>(subtypeId);
    }
    if (!nullToAbsent || referenceStandardMs != null) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs);
    }
    map['is_unplanned'] = Variable<bool>(isUnplanned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudyOperationsCompanion toCompanion(bool nullToAbsent) {
    return StudyOperationsCompanion(
      id: Value(id),
      studyId: Value(studyId),
      catalogOperationId: catalogOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogOperationId),
      orderIndex: Value(orderIndex),
      name: Value(name),
      category: Value(category),
      subtypeId: subtypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtypeId),
      referenceStandardMs: referenceStandardMs == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceStandardMs),
      isUnplanned: Value(isUnplanned),
      createdAt: Value(createdAt),
    );
  }

  factory StudyOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyOperation(
      id: serializer.fromJson<String>(json['id']),
      studyId: serializer.fromJson<String>(json['studyId']),
      catalogOperationId: serializer.fromJson<String?>(
        json['catalogOperationId'],
      ),
      orderIndex: serializer.fromJson<double>(json['orderIndex']),
      name: serializer.fromJson<String>(json['name']),
      category: $StudyOperationsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      subtypeId: serializer.fromJson<String?>(json['subtypeId']),
      referenceStandardMs: serializer.fromJson<int?>(
        json['referenceStandardMs'],
      ),
      isUnplanned: serializer.fromJson<bool>(json['isUnplanned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studyId': serializer.toJson<String>(studyId),
      'catalogOperationId': serializer.toJson<String?>(catalogOperationId),
      'orderIndex': serializer.toJson<double>(orderIndex),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $StudyOperationsTable.$convertercategory.toJson(category),
      ),
      'subtypeId': serializer.toJson<String?>(subtypeId),
      'referenceStandardMs': serializer.toJson<int?>(referenceStandardMs),
      'isUnplanned': serializer.toJson<bool>(isUnplanned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StudyOperation copyWith({
    String? id,
    String? studyId,
    Value<String?> catalogOperationId = const Value.absent(),
    double? orderIndex,
    String? name,
    OperationCategory? category,
    Value<String?> subtypeId = const Value.absent(),
    Value<int?> referenceStandardMs = const Value.absent(),
    bool? isUnplanned,
    DateTime? createdAt,
  }) => StudyOperation(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    catalogOperationId: catalogOperationId.present
        ? catalogOperationId.value
        : this.catalogOperationId,
    orderIndex: orderIndex ?? this.orderIndex,
    name: name ?? this.name,
    category: category ?? this.category,
    subtypeId: subtypeId.present ? subtypeId.value : this.subtypeId,
    referenceStandardMs: referenceStandardMs.present
        ? referenceStandardMs.value
        : this.referenceStandardMs,
    isUnplanned: isUnplanned ?? this.isUnplanned,
    createdAt: createdAt ?? this.createdAt,
  );
  StudyOperation copyWithCompanion(StudyOperationsCompanion data) {
    return StudyOperation(
      id: data.id.present ? data.id.value : this.id,
      studyId: data.studyId.present ? data.studyId.value : this.studyId,
      catalogOperationId: data.catalogOperationId.present
          ? data.catalogOperationId.value
          : this.catalogOperationId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subtypeId: data.subtypeId.present ? data.subtypeId.value : this.subtypeId,
      referenceStandardMs: data.referenceStandardMs.present
          ? data.referenceStandardMs.value
          : this.referenceStandardMs,
      isUnplanned: data.isUnplanned.present
          ? data.isUnplanned.value
          : this.isUnplanned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyOperation(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('catalogOperationId: $catalogOperationId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('isUnplanned: $isUnplanned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studyId,
    catalogOperationId,
    orderIndex,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    isUnplanned,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyOperation &&
          other.id == this.id &&
          other.studyId == this.studyId &&
          other.catalogOperationId == this.catalogOperationId &&
          other.orderIndex == this.orderIndex &&
          other.name == this.name &&
          other.category == this.category &&
          other.subtypeId == this.subtypeId &&
          other.referenceStandardMs == this.referenceStandardMs &&
          other.isUnplanned == this.isUnplanned &&
          other.createdAt == this.createdAt);
}

class StudyOperationsCompanion extends UpdateCompanion<StudyOperation> {
  final Value<String> id;
  final Value<String> studyId;
  final Value<String?> catalogOperationId;
  final Value<double> orderIndex;
  final Value<String> name;
  final Value<OperationCategory> category;
  final Value<String?> subtypeId;
  final Value<int?> referenceStandardMs;
  final Value<bool> isUnplanned;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StudyOperationsCompanion({
    this.id = const Value.absent(),
    this.studyId = const Value.absent(),
    this.catalogOperationId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    this.isUnplanned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyOperationsCompanion.insert({
    required String id,
    required String studyId,
    this.catalogOperationId = const Value.absent(),
    required double orderIndex,
    required String name,
    required OperationCategory category,
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    this.isUnplanned = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studyId = Value(studyId),
       orderIndex = Value(orderIndex),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<StudyOperation> custom({
    Expression<String>? id,
    Expression<String>? studyId,
    Expression<String>? catalogOperationId,
    Expression<double>? orderIndex,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subtypeId,
    Expression<int>? referenceStandardMs,
    Expression<bool>? isUnplanned,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyId != null) 'study_id': studyId,
      if (catalogOperationId != null)
        'catalog_operation_id': catalogOperationId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subtypeId != null) 'subtype_id': subtypeId,
      if (referenceStandardMs != null)
        'reference_standard_ms': referenceStandardMs,
      if (isUnplanned != null) 'is_unplanned': isUnplanned,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? studyId,
    Value<String?>? catalogOperationId,
    Value<double>? orderIndex,
    Value<String>? name,
    Value<OperationCategory>? category,
    Value<String?>? subtypeId,
    Value<int?>? referenceStandardMs,
    Value<bool>? isUnplanned,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StudyOperationsCompanion(
      id: id ?? this.id,
      studyId: studyId ?? this.studyId,
      catalogOperationId: catalogOperationId ?? this.catalogOperationId,
      orderIndex: orderIndex ?? this.orderIndex,
      name: name ?? this.name,
      category: category ?? this.category,
      subtypeId: subtypeId ?? this.subtypeId,
      referenceStandardMs: referenceStandardMs ?? this.referenceStandardMs,
      isUnplanned: isUnplanned ?? this.isUnplanned,
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
    if (studyId.present) {
      map['study_id'] = Variable<String>(studyId.value);
    }
    if (catalogOperationId.present) {
      map['catalog_operation_id'] = Variable<String>(catalogOperationId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<double>(orderIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $StudyOperationsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subtypeId.present) {
      map['subtype_id'] = Variable<String>(subtypeId.value);
    }
    if (referenceStandardMs.present) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs.value);
    }
    if (isUnplanned.present) {
      map['is_unplanned'] = Variable<bool>(isUnplanned.value);
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
    return (StringBuffer('StudyOperationsCompanion(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('catalogOperationId: $catalogOperationId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('isUnplanned: $isUnplanned, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservationsTable extends Observations
    with TableInfo<$ObservationsTable, Observation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studyIdMeta = const VerificationMeta(
    'studyId',
  );
  @override
  late final GeneratedColumn<String> studyId = GeneratedColumn<String>(
    'study_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES studies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceIndexMeta = const VerificationMeta(
    'sequenceIndex',
  );
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
    'sequence_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludedAtMeta = const VerificationMeta(
    'excludedAt',
  );
  @override
  late final GeneratedColumn<DateTime> excludedAt = GeneratedColumn<DateTime>(
    'excluded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exclusionReasonMeta = const VerificationMeta(
    'exclusionReason',
  );
  @override
  late final GeneratedColumn<String> exclusionReason = GeneratedColumn<String>(
    'exclusion_reason',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studyId,
    sequenceIndex,
    performedAt,
    notes,
    excludedAt,
    exclusionReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Observation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('study_id')) {
      context.handle(
        _studyIdMeta,
        studyId.isAcceptableOrUnknown(data['study_id']!, _studyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studyIdMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
        _sequenceIndexMeta,
        sequenceIndex.isAcceptableOrUnknown(
          data['sequence_index']!,
          _sequenceIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('excluded_at')) {
      context.handle(
        _excludedAtMeta,
        excludedAt.isAcceptableOrUnknown(data['excluded_at']!, _excludedAtMeta),
      );
    }
    if (data.containsKey('exclusion_reason')) {
      context.handle(
        _exclusionReasonMeta,
        exclusionReason.isAcceptableOrUnknown(
          data['exclusion_reason']!,
          _exclusionReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studyId, sequenceIndex},
  ];
  @override
  Observation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Observation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      studyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_id'],
      )!,
      sequenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_index'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      excludedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluded_at'],
      ),
      exclusionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclusion_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ObservationsTable createAlias(String alias) {
    return $ObservationsTable(attachedDatabase, alias);
  }
}

class Observation extends DataClass implements Insertable<Observation> {
  final String id;
  final String studyId;

  /// Position in the study, from 0. **Never renumbered and never reused**
  /// (DESIGN.md §11.3): "Pass 4" in an exported file or a written note has to
  /// mean the same pass forever, so a removed pass leaves a labelled gap rather
  /// than shifting the ones after it. Displayed as `sequenceIndex + 1`.
  final int sequenceIndex;
  final DateTime performedAt;
  final String? notes;

  /// When this whole pass was excluded from the statistics, or null if it counts
  /// (DESIGN.md §11.3).
  ///
  /// Excluding is **not** deleting: the pass keeps its measurements, its own
  /// report and its rows in the Segments sheet — it is only out of the aggregate
  /// mean, deviation, CV and sample-size verdict. Reversible, and the reason is
  /// recorded next to it, because "the line was starved" is the difference
  /// between a discarded pass and a suspicious one.
  final DateTime? excludedAt;
  final String? exclusionReason;
  final DateTime createdAt;
  const Observation({
    required this.id,
    required this.studyId,
    required this.sequenceIndex,
    required this.performedAt,
    this.notes,
    this.excludedAt,
    this.exclusionReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['study_id'] = Variable<String>(studyId);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    map['performed_at'] = Variable<DateTime>(performedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || excludedAt != null) {
      map['excluded_at'] = Variable<DateTime>(excludedAt);
    }
    if (!nullToAbsent || exclusionReason != null) {
      map['exclusion_reason'] = Variable<String>(exclusionReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ObservationsCompanion toCompanion(bool nullToAbsent) {
    return ObservationsCompanion(
      id: Value(id),
      studyId: Value(studyId),
      sequenceIndex: Value(sequenceIndex),
      performedAt: Value(performedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      excludedAt: excludedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(excludedAt),
      exclusionReason: exclusionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(exclusionReason),
      createdAt: Value(createdAt),
    );
  }

  factory Observation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Observation(
      id: serializer.fromJson<String>(json['id']),
      studyId: serializer.fromJson<String>(json['studyId']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      excludedAt: serializer.fromJson<DateTime?>(json['excludedAt']),
      exclusionReason: serializer.fromJson<String?>(json['exclusionReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'studyId': serializer.toJson<String>(studyId),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'notes': serializer.toJson<String?>(notes),
      'excludedAt': serializer.toJson<DateTime?>(excludedAt),
      'exclusionReason': serializer.toJson<String?>(exclusionReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Observation copyWith({
    String? id,
    String? studyId,
    int? sequenceIndex,
    DateTime? performedAt,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> excludedAt = const Value.absent(),
    Value<String?> exclusionReason = const Value.absent(),
    DateTime? createdAt,
  }) => Observation(
    id: id ?? this.id,
    studyId: studyId ?? this.studyId,
    sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    performedAt: performedAt ?? this.performedAt,
    notes: notes.present ? notes.value : this.notes,
    excludedAt: excludedAt.present ? excludedAt.value : this.excludedAt,
    exclusionReason: exclusionReason.present
        ? exclusionReason.value
        : this.exclusionReason,
    createdAt: createdAt ?? this.createdAt,
  );
  Observation copyWithCompanion(ObservationsCompanion data) {
    return Observation(
      id: data.id.present ? data.id.value : this.id,
      studyId: data.studyId.present ? data.studyId.value : this.studyId,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      excludedAt: data.excludedAt.present
          ? data.excludedAt.value
          : this.excludedAt,
      exclusionReason: data.exclusionReason.present
          ? data.exclusionReason.value
          : this.exclusionReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Observation(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes, ')
          ..write('excludedAt: $excludedAt, ')
          ..write('exclusionReason: $exclusionReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studyId,
    sequenceIndex,
    performedAt,
    notes,
    excludedAt,
    exclusionReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Observation &&
          other.id == this.id &&
          other.studyId == this.studyId &&
          other.sequenceIndex == this.sequenceIndex &&
          other.performedAt == this.performedAt &&
          other.notes == this.notes &&
          other.excludedAt == this.excludedAt &&
          other.exclusionReason == this.exclusionReason &&
          other.createdAt == this.createdAt);
}

class ObservationsCompanion extends UpdateCompanion<Observation> {
  final Value<String> id;
  final Value<String> studyId;
  final Value<int> sequenceIndex;
  final Value<DateTime> performedAt;
  final Value<String?> notes;
  final Value<DateTime?> excludedAt;
  final Value<String?> exclusionReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ObservationsCompanion({
    this.id = const Value.absent(),
    this.studyId = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.excludedAt = const Value.absent(),
    this.exclusionReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObservationsCompanion.insert({
    required String id,
    required String studyId,
    required int sequenceIndex,
    required DateTime performedAt,
    this.notes = const Value.absent(),
    this.excludedAt = const Value.absent(),
    this.exclusionReason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studyId = Value(studyId),
       sequenceIndex = Value(sequenceIndex),
       performedAt = Value(performedAt),
       createdAt = Value(createdAt);
  static Insertable<Observation> custom({
    Expression<String>? id,
    Expression<String>? studyId,
    Expression<int>? sequenceIndex,
    Expression<DateTime>? performedAt,
    Expression<String>? notes,
    Expression<DateTime>? excludedAt,
    Expression<String>? exclusionReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyId != null) 'study_id': studyId,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (performedAt != null) 'performed_at': performedAt,
      if (notes != null) 'notes': notes,
      if (excludedAt != null) 'excluded_at': excludedAt,
      if (exclusionReason != null) 'exclusion_reason': exclusionReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? studyId,
    Value<int>? sequenceIndex,
    Value<DateTime>? performedAt,
    Value<String?>? notes,
    Value<DateTime?>? excludedAt,
    Value<String?>? exclusionReason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ObservationsCompanion(
      id: id ?? this.id,
      studyId: studyId ?? this.studyId,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
      excludedAt: excludedAt ?? this.excludedAt,
      exclusionReason: exclusionReason ?? this.exclusionReason,
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
    if (studyId.present) {
      map['study_id'] = Variable<String>(studyId.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (excludedAt.present) {
      map['excluded_at'] = Variable<DateTime>(excludedAt.value);
    }
    if (exclusionReason.present) {
      map['exclusion_reason'] = Variable<String>(exclusionReason.value);
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
    return (StringBuffer('ObservationsCompanion(')
          ..write('id: $id, ')
          ..write('studyId: $studyId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('performedAt: $performedAt, ')
          ..write('notes: $notes, ')
          ..write('excludedAt: $excludedAt, ')
          ..write('exclusionReason: $exclusionReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationInstancesTable extends OperationInstances
    with TableInfo<$OperationInstancesTable, OperationInstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observationIdMeta = const VerificationMeta(
    'observationId',
  );
  @override
  late final GeneratedColumn<String> observationId = GeneratedColumn<String>(
    'observation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _studyOperationIdMeta = const VerificationMeta(
    'studyOperationId',
  );
  @override
  late final GeneratedColumn<String> studyOperationId = GeneratedColumn<String>(
    'study_operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_operations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _manualActualMsMeta = const VerificationMeta(
    'manualActualMs',
  );
  @override
  late final GeneratedColumn<int> manualActualMs = GeneratedColumn<int>(
    'manual_actual_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludedAtMeta = const VerificationMeta(
    'excludedAt',
  );
  @override
  late final GeneratedColumn<DateTime> excludedAt = GeneratedColumn<DateTime>(
    'excluded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exclusionReasonMeta = const VerificationMeta(
    'exclusionReason',
  );
  @override
  late final GeneratedColumn<String> exclusionReason = GeneratedColumn<String>(
    'exclusion_reason',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    observationId,
    studyOperationId,
    manualActualMs,
    completedAt,
    notes,
    excludedAt,
    exclusionReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operation_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationInstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('observation_id')) {
      context.handle(
        _observationIdMeta,
        observationId.isAcceptableOrUnknown(
          data['observation_id']!,
          _observationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationIdMeta);
    }
    if (data.containsKey('study_operation_id')) {
      context.handle(
        _studyOperationIdMeta,
        studyOperationId.isAcceptableOrUnknown(
          data['study_operation_id']!,
          _studyOperationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studyOperationIdMeta);
    }
    if (data.containsKey('manual_actual_ms')) {
      context.handle(
        _manualActualMsMeta,
        manualActualMs.isAcceptableOrUnknown(
          data['manual_actual_ms']!,
          _manualActualMsMeta,
        ),
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
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('excluded_at')) {
      context.handle(
        _excludedAtMeta,
        excludedAt.isAcceptableOrUnknown(data['excluded_at']!, _excludedAtMeta),
      );
    }
    if (data.containsKey('exclusion_reason')) {
      context.handle(
        _exclusionReasonMeta,
        exclusionReason.isAcceptableOrUnknown(
          data['exclusion_reason']!,
          _exclusionReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {observationId, studyOperationId},
  ];
  @override
  OperationInstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationInstance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      observationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_id'],
      )!,
      studyOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}study_operation_id'],
      )!,
      manualActualMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_actual_ms'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      excludedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluded_at'],
      ),
      exclusionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exclusion_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OperationInstancesTable createAlias(String alias) {
    return $OperationInstancesTable(attachedDatabase, alias);
  }
}

class OperationInstance extends DataClass
    implements Insertable<OperationInstance> {
  final String id;
  final String observationId;
  final String studyOperationId;

  /// Manual override of the actual time, in milliseconds. Null => use the sum
  /// of [OperationTimeSegments]. Setting it never deletes segments.
  final int? manualActualMs;

  /// When the operation was **stopped** (marked complete). Null while it is
  /// still pending, running, or merely paused. Lets the UI tell a paused
  /// operation (resumable) apart from a finished one, since both have no open
  /// segment. Cleared if timing resumes.
  final DateTime? completedAt;
  final String? notes;

  /// When this single reading was excluded from the statistics, or null if it
  /// counts (DESIGN.md §11.3).
  ///
  /// The finer grain of the pass-level flag above, for the ordinary case: one
  /// operation went wrong in an otherwise good pass. Cronoanálise discards
  /// anomalous readings before computing a mean, and without this the only ways
  /// to do that were to delete the whole pass — losing every other operation's
  /// good reading in it — or to type an override, inventing a number.
  ///
  /// The app may **flag** candidates (a reading beyond ±3s) and must never act
  /// on them: only the analyst knows whether a long cycle was legitimate, which
  /// is §10.4's reasoning about abandoned segments applied to a measured one.
  final DateTime? excludedAt;
  final String? exclusionReason;
  final DateTime createdAt;
  const OperationInstance({
    required this.id,
    required this.observationId,
    required this.studyOperationId,
    this.manualActualMs,
    this.completedAt,
    this.notes,
    this.excludedAt,
    this.exclusionReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['observation_id'] = Variable<String>(observationId);
    map['study_operation_id'] = Variable<String>(studyOperationId);
    if (!nullToAbsent || manualActualMs != null) {
      map['manual_actual_ms'] = Variable<int>(manualActualMs);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || excludedAt != null) {
      map['excluded_at'] = Variable<DateTime>(excludedAt);
    }
    if (!nullToAbsent || exclusionReason != null) {
      map['exclusion_reason'] = Variable<String>(exclusionReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OperationInstancesCompanion toCompanion(bool nullToAbsent) {
    return OperationInstancesCompanion(
      id: Value(id),
      observationId: Value(observationId),
      studyOperationId: Value(studyOperationId),
      manualActualMs: manualActualMs == null && nullToAbsent
          ? const Value.absent()
          : Value(manualActualMs),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      excludedAt: excludedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(excludedAt),
      exclusionReason: exclusionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(exclusionReason),
      createdAt: Value(createdAt),
    );
  }

  factory OperationInstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationInstance(
      id: serializer.fromJson<String>(json['id']),
      observationId: serializer.fromJson<String>(json['observationId']),
      studyOperationId: serializer.fromJson<String>(json['studyOperationId']),
      manualActualMs: serializer.fromJson<int?>(json['manualActualMs']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      excludedAt: serializer.fromJson<DateTime?>(json['excludedAt']),
      exclusionReason: serializer.fromJson<String?>(json['exclusionReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'observationId': serializer.toJson<String>(observationId),
      'studyOperationId': serializer.toJson<String>(studyOperationId),
      'manualActualMs': serializer.toJson<int?>(manualActualMs),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'notes': serializer.toJson<String?>(notes),
      'excludedAt': serializer.toJson<DateTime?>(excludedAt),
      'exclusionReason': serializer.toJson<String?>(exclusionReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OperationInstance copyWith({
    String? id,
    String? observationId,
    String? studyOperationId,
    Value<int?> manualActualMs = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> excludedAt = const Value.absent(),
    Value<String?> exclusionReason = const Value.absent(),
    DateTime? createdAt,
  }) => OperationInstance(
    id: id ?? this.id,
    observationId: observationId ?? this.observationId,
    studyOperationId: studyOperationId ?? this.studyOperationId,
    manualActualMs: manualActualMs.present
        ? manualActualMs.value
        : this.manualActualMs,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    notes: notes.present ? notes.value : this.notes,
    excludedAt: excludedAt.present ? excludedAt.value : this.excludedAt,
    exclusionReason: exclusionReason.present
        ? exclusionReason.value
        : this.exclusionReason,
    createdAt: createdAt ?? this.createdAt,
  );
  OperationInstance copyWithCompanion(OperationInstancesCompanion data) {
    return OperationInstance(
      id: data.id.present ? data.id.value : this.id,
      observationId: data.observationId.present
          ? data.observationId.value
          : this.observationId,
      studyOperationId: data.studyOperationId.present
          ? data.studyOperationId.value
          : this.studyOperationId,
      manualActualMs: data.manualActualMs.present
          ? data.manualActualMs.value
          : this.manualActualMs,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      excludedAt: data.excludedAt.present
          ? data.excludedAt.value
          : this.excludedAt,
      exclusionReason: data.exclusionReason.present
          ? data.exclusionReason.value
          : this.exclusionReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationInstance(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('studyOperationId: $studyOperationId, ')
          ..write('manualActualMs: $manualActualMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('excludedAt: $excludedAt, ')
          ..write('exclusionReason: $exclusionReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    observationId,
    studyOperationId,
    manualActualMs,
    completedAt,
    notes,
    excludedAt,
    exclusionReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationInstance &&
          other.id == this.id &&
          other.observationId == this.observationId &&
          other.studyOperationId == this.studyOperationId &&
          other.manualActualMs == this.manualActualMs &&
          other.completedAt == this.completedAt &&
          other.notes == this.notes &&
          other.excludedAt == this.excludedAt &&
          other.exclusionReason == this.exclusionReason &&
          other.createdAt == this.createdAt);
}

class OperationInstancesCompanion extends UpdateCompanion<OperationInstance> {
  final Value<String> id;
  final Value<String> observationId;
  final Value<String> studyOperationId;
  final Value<int?> manualActualMs;
  final Value<DateTime?> completedAt;
  final Value<String?> notes;
  final Value<DateTime?> excludedAt;
  final Value<String?> exclusionReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OperationInstancesCompanion({
    this.id = const Value.absent(),
    this.observationId = const Value.absent(),
    this.studyOperationId = const Value.absent(),
    this.manualActualMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.excludedAt = const Value.absent(),
    this.exclusionReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationInstancesCompanion.insert({
    required String id,
    required String observationId,
    required String studyOperationId,
    this.manualActualMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.excludedAt = const Value.absent(),
    this.exclusionReason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       observationId = Value(observationId),
       studyOperationId = Value(studyOperationId),
       createdAt = Value(createdAt);
  static Insertable<OperationInstance> custom({
    Expression<String>? id,
    Expression<String>? observationId,
    Expression<String>? studyOperationId,
    Expression<int>? manualActualMs,
    Expression<DateTime>? completedAt,
    Expression<String>? notes,
    Expression<DateTime>? excludedAt,
    Expression<String>? exclusionReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (observationId != null) 'observation_id': observationId,
      if (studyOperationId != null) 'study_operation_id': studyOperationId,
      if (manualActualMs != null) 'manual_actual_ms': manualActualMs,
      if (completedAt != null) 'completed_at': completedAt,
      if (notes != null) 'notes': notes,
      if (excludedAt != null) 'excluded_at': excludedAt,
      if (exclusionReason != null) 'exclusion_reason': exclusionReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationInstancesCompanion copyWith({
    Value<String>? id,
    Value<String>? observationId,
    Value<String>? studyOperationId,
    Value<int?>? manualActualMs,
    Value<DateTime?>? completedAt,
    Value<String?>? notes,
    Value<DateTime?>? excludedAt,
    Value<String?>? exclusionReason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OperationInstancesCompanion(
      id: id ?? this.id,
      observationId: observationId ?? this.observationId,
      studyOperationId: studyOperationId ?? this.studyOperationId,
      manualActualMs: manualActualMs ?? this.manualActualMs,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      excludedAt: excludedAt ?? this.excludedAt,
      exclusionReason: exclusionReason ?? this.exclusionReason,
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
    if (observationId.present) {
      map['observation_id'] = Variable<String>(observationId.value);
    }
    if (studyOperationId.present) {
      map['study_operation_id'] = Variable<String>(studyOperationId.value);
    }
    if (manualActualMs.present) {
      map['manual_actual_ms'] = Variable<int>(manualActualMs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (excludedAt.present) {
      map['excluded_at'] = Variable<DateTime>(excludedAt.value);
    }
    if (exclusionReason.present) {
      map['exclusion_reason'] = Variable<String>(exclusionReason.value);
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
    return (StringBuffer('OperationInstancesCompanion(')
          ..write('id: $id, ')
          ..write('observationId: $observationId, ')
          ..write('studyOperationId: $studyOperationId, ')
          ..write('manualActualMs: $manualActualMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('notes: $notes, ')
          ..write('excludedAt: $excludedAt, ')
          ..write('exclusionReason: $exclusionReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OperationTimeSegmentsTable extends OperationTimeSegments
    with TableInfo<$OperationTimeSegmentsTable, OperationTimeSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OperationTimeSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationInstanceIdMeta =
      const VerificationMeta('operationInstanceId');
  @override
  late final GeneratedColumn<String> operationInstanceId =
      GeneratedColumn<String>(
        'operation_instance_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES operation_instances (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _startAtMsMeta = const VerificationMeta(
    'startAtMs',
  );
  @override
  late final GeneratedColumn<int> startAtMs = GeneratedColumn<int>(
    'start_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMsMeta = const VerificationMeta(
    'endAtMs',
  );
  @override
  late final GeneratedColumn<int> endAtMs = GeneratedColumn<int>(
    'end_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationInstanceId,
    startAtMs,
    endAtMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'operation_time_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<OperationTimeSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_instance_id')) {
      context.handle(
        _operationInstanceIdMeta,
        operationInstanceId.isAcceptableOrUnknown(
          data['operation_instance_id']!,
          _operationInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationInstanceIdMeta);
    }
    if (data.containsKey('start_at_ms')) {
      context.handle(
        _startAtMsMeta,
        startAtMs.isAcceptableOrUnknown(data['start_at_ms']!, _startAtMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMsMeta);
    }
    if (data.containsKey('end_at_ms')) {
      context.handle(
        _endAtMsMeta,
        endAtMs.isAcceptableOrUnknown(data['end_at_ms']!, _endAtMsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OperationTimeSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OperationTimeSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_instance_id'],
      )!,
      startAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_at_ms'],
      )!,
      endAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_at_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OperationTimeSegmentsTable createAlias(String alias) {
    return $OperationTimeSegmentsTable(attachedDatabase, alias);
  }
}

class OperationTimeSegment extends DataClass
    implements Insertable<OperationTimeSegment> {
  final String id;
  final String operationInstanceId;
  final int startAtMs;
  final int? endAtMs;
  final DateTime createdAt;
  const OperationTimeSegment({
    required this.id,
    required this.operationInstanceId,
    required this.startAtMs,
    this.endAtMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_instance_id'] = Variable<String>(operationInstanceId);
    map['start_at_ms'] = Variable<int>(startAtMs);
    if (!nullToAbsent || endAtMs != null) {
      map['end_at_ms'] = Variable<int>(endAtMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OperationTimeSegmentsCompanion toCompanion(bool nullToAbsent) {
    return OperationTimeSegmentsCompanion(
      id: Value(id),
      operationInstanceId: Value(operationInstanceId),
      startAtMs: Value(startAtMs),
      endAtMs: endAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endAtMs),
      createdAt: Value(createdAt),
    );
  }

  factory OperationTimeSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OperationTimeSegment(
      id: serializer.fromJson<String>(json['id']),
      operationInstanceId: serializer.fromJson<String>(
        json['operationInstanceId'],
      ),
      startAtMs: serializer.fromJson<int>(json['startAtMs']),
      endAtMs: serializer.fromJson<int?>(json['endAtMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationInstanceId': serializer.toJson<String>(operationInstanceId),
      'startAtMs': serializer.toJson<int>(startAtMs),
      'endAtMs': serializer.toJson<int?>(endAtMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OperationTimeSegment copyWith({
    String? id,
    String? operationInstanceId,
    int? startAtMs,
    Value<int?> endAtMs = const Value.absent(),
    DateTime? createdAt,
  }) => OperationTimeSegment(
    id: id ?? this.id,
    operationInstanceId: operationInstanceId ?? this.operationInstanceId,
    startAtMs: startAtMs ?? this.startAtMs,
    endAtMs: endAtMs.present ? endAtMs.value : this.endAtMs,
    createdAt: createdAt ?? this.createdAt,
  );
  OperationTimeSegment copyWithCompanion(OperationTimeSegmentsCompanion data) {
    return OperationTimeSegment(
      id: data.id.present ? data.id.value : this.id,
      operationInstanceId: data.operationInstanceId.present
          ? data.operationInstanceId.value
          : this.operationInstanceId,
      startAtMs: data.startAtMs.present ? data.startAtMs.value : this.startAtMs,
      endAtMs: data.endAtMs.present ? data.endAtMs.value : this.endAtMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OperationTimeSegment(')
          ..write('id: $id, ')
          ..write('operationInstanceId: $operationInstanceId, ')
          ..write('startAtMs: $startAtMs, ')
          ..write('endAtMs: $endAtMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, operationInstanceId, startAtMs, endAtMs, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OperationTimeSegment &&
          other.id == this.id &&
          other.operationInstanceId == this.operationInstanceId &&
          other.startAtMs == this.startAtMs &&
          other.endAtMs == this.endAtMs &&
          other.createdAt == this.createdAt);
}

class OperationTimeSegmentsCompanion
    extends UpdateCompanion<OperationTimeSegment> {
  final Value<String> id;
  final Value<String> operationInstanceId;
  final Value<int> startAtMs;
  final Value<int?> endAtMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OperationTimeSegmentsCompanion({
    this.id = const Value.absent(),
    this.operationInstanceId = const Value.absent(),
    this.startAtMs = const Value.absent(),
    this.endAtMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OperationTimeSegmentsCompanion.insert({
    required String id,
    required String operationInstanceId,
    required int startAtMs,
    this.endAtMs = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationInstanceId = Value(operationInstanceId),
       startAtMs = Value(startAtMs),
       createdAt = Value(createdAt);
  static Insertable<OperationTimeSegment> custom({
    Expression<String>? id,
    Expression<String>? operationInstanceId,
    Expression<int>? startAtMs,
    Expression<int>? endAtMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationInstanceId != null)
        'operation_instance_id': operationInstanceId,
      if (startAtMs != null) 'start_at_ms': startAtMs,
      if (endAtMs != null) 'end_at_ms': endAtMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OperationTimeSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? operationInstanceId,
    Value<int>? startAtMs,
    Value<int?>? endAtMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OperationTimeSegmentsCompanion(
      id: id ?? this.id,
      operationInstanceId: operationInstanceId ?? this.operationInstanceId,
      startAtMs: startAtMs ?? this.startAtMs,
      endAtMs: endAtMs ?? this.endAtMs,
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
    if (operationInstanceId.present) {
      map['operation_instance_id'] = Variable<String>(
        operationInstanceId.value,
      );
    }
    if (startAtMs.present) {
      map['start_at_ms'] = Variable<int>(startAtMs.value);
    }
    if (endAtMs.present) {
      map['end_at_ms'] = Variable<int>(endAtMs.value);
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
    return (StringBuffer('OperationTimeSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('operationInstanceId: $operationInstanceId, ')
          ..write('startAtMs: $startAtMs, ')
          ..write('endAtMs: $endAtMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StudyType, String>
  defaultStudyType = GeneratedColumn<String>(
    'default_study_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<StudyType>($TemplatesTable.$converterdefaultStudyType);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    defaultStudyType,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Template> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultStudyType: $TemplatesTable.$converterdefaultStudyType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_study_type'],
        )!,
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
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StudyType, String, String>
  $converterdefaultStudyType = const EnumNameConverter<StudyType>(
    StudyType.values,
  );
}

class Template extends DataClass implements Insertable<Template> {
  final String id;
  final String name;
  final StudyType defaultStudyType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Template({
    required this.id,
    required this.name,
    required this.defaultStudyType,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['default_study_type'] = Variable<String>(
        $TemplatesTable.$converterdefaultStudyType.toSql(defaultStudyType),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      name: Value(name),
      defaultStudyType: Value(defaultStudyType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Template.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultStudyType: $TemplatesTable.$converterdefaultStudyType.fromJson(
        serializer.fromJson<String>(json['defaultStudyType']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'defaultStudyType': serializer.toJson<String>(
        $TemplatesTable.$converterdefaultStudyType.toJson(defaultStudyType),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Template copyWith({
    String? id,
    String? name,
    StudyType? defaultStudyType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Template(
    id: id ?? this.id,
    name: name ?? this.name,
    defaultStudyType: defaultStudyType ?? this.defaultStudyType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultStudyType: data.defaultStudyType.present
          ? data.defaultStudyType.value
          : this.defaultStudyType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultStudyType: $defaultStudyType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, defaultStudyType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultStudyType == this.defaultStudyType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<String> id;
  final Value<String> name;
  final Value<StudyType> defaultStudyType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultStudyType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplatesCompanion.insert({
    required String id,
    required String name,
    required StudyType defaultStudyType,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       defaultStudyType = Value(defaultStudyType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Template> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? defaultStudyType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultStudyType != null) 'default_study_type': defaultStudyType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<StudyType>? defaultStudyType,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultStudyType: defaultStudyType ?? this.defaultStudyType,
      createdAt: createdAt ?? this.createdAt,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultStudyType.present) {
      map['default_study_type'] = Variable<String>(
        $TemplatesTable.$converterdefaultStudyType.toSql(
          defaultStudyType.value,
        ),
      );
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
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultStudyType: $defaultStudyType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateOperationsTable extends TemplateOperations
    with TableInfo<$TemplateOperationsTable, TemplateOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _catalogOperationIdMeta =
      const VerificationMeta('catalogOperationId');
  @override
  late final GeneratedColumn<String> catalogOperationId =
      GeneratedColumn<String>(
        'catalog_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES catalog_operations (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<double> orderIndex = GeneratedColumn<double>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperationCategory, String>
  category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OperationCategory>(
        $TemplateOperationsTable.$convertercategory,
      );
  static const VerificationMeta _subtypeIdMeta = const VerificationMeta(
    'subtypeId',
  );
  @override
  late final GeneratedColumn<String> subtypeId = GeneratedColumn<String>(
    'subtype_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES operation_subtypes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _referenceStandardMsMeta =
      const VerificationMeta('referenceStandardMs');
  @override
  late final GeneratedColumn<int> referenceStandardMs = GeneratedColumn<int>(
    'reference_standard_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    catalogOperationId,
    orderIndex,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('catalog_operation_id')) {
      context.handle(
        _catalogOperationIdMeta,
        catalogOperationId.isAcceptableOrUnknown(
          data['catalog_operation_id']!,
          _catalogOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subtype_id')) {
      context.handle(
        _subtypeIdMeta,
        subtypeId.isAcceptableOrUnknown(data['subtype_id']!, _subtypeIdMeta),
      );
    }
    if (data.containsKey('reference_standard_ms')) {
      context.handle(
        _referenceStandardMsMeta,
        referenceStandardMs.isAcceptableOrUnknown(
          data['reference_standard_ms']!,
          _referenceStandardMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      catalogOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_operation_id'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}order_index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $TemplateOperationsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subtypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtype_id'],
      ),
      referenceStandardMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_standard_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TemplateOperationsTable createAlias(String alias) {
    return $TemplateOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperationCategory, String, String>
  $convertercategory = const EnumNameConverter<OperationCategory>(
    OperationCategory.values,
  );
}

class TemplateOperation extends DataClass
    implements Insertable<TemplateOperation> {
  final String id;
  final String templateId;
  final String? catalogOperationId;
  final double orderIndex;
  final String name;
  final OperationCategory category;
  final String? subtypeId;
  final int? referenceStandardMs;
  final DateTime createdAt;
  const TemplateOperation({
    required this.id,
    required this.templateId,
    this.catalogOperationId,
    required this.orderIndex,
    required this.name,
    required this.category,
    this.subtypeId,
    this.referenceStandardMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    if (!nullToAbsent || catalogOperationId != null) {
      map['catalog_operation_id'] = Variable<String>(catalogOperationId);
    }
    map['order_index'] = Variable<double>(orderIndex);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $TemplateOperationsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || subtypeId != null) {
      map['subtype_id'] = Variable<String>(subtypeId);
    }
    if (!nullToAbsent || referenceStandardMs != null) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TemplateOperationsCompanion toCompanion(bool nullToAbsent) {
    return TemplateOperationsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      catalogOperationId: catalogOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogOperationId),
      orderIndex: Value(orderIndex),
      name: Value(name),
      category: Value(category),
      subtypeId: subtypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtypeId),
      referenceStandardMs: referenceStandardMs == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceStandardMs),
      createdAt: Value(createdAt),
    );
  }

  factory TemplateOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateOperation(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      catalogOperationId: serializer.fromJson<String?>(
        json['catalogOperationId'],
      ),
      orderIndex: serializer.fromJson<double>(json['orderIndex']),
      name: serializer.fromJson<String>(json['name']),
      category: $TemplateOperationsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      subtypeId: serializer.fromJson<String?>(json['subtypeId']),
      referenceStandardMs: serializer.fromJson<int?>(
        json['referenceStandardMs'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'catalogOperationId': serializer.toJson<String?>(catalogOperationId),
      'orderIndex': serializer.toJson<double>(orderIndex),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $TemplateOperationsTable.$convertercategory.toJson(category),
      ),
      'subtypeId': serializer.toJson<String?>(subtypeId),
      'referenceStandardMs': serializer.toJson<int?>(referenceStandardMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TemplateOperation copyWith({
    String? id,
    String? templateId,
    Value<String?> catalogOperationId = const Value.absent(),
    double? orderIndex,
    String? name,
    OperationCategory? category,
    Value<String?> subtypeId = const Value.absent(),
    Value<int?> referenceStandardMs = const Value.absent(),
    DateTime? createdAt,
  }) => TemplateOperation(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    catalogOperationId: catalogOperationId.present
        ? catalogOperationId.value
        : this.catalogOperationId,
    orderIndex: orderIndex ?? this.orderIndex,
    name: name ?? this.name,
    category: category ?? this.category,
    subtypeId: subtypeId.present ? subtypeId.value : this.subtypeId,
    referenceStandardMs: referenceStandardMs.present
        ? referenceStandardMs.value
        : this.referenceStandardMs,
    createdAt: createdAt ?? this.createdAt,
  );
  TemplateOperation copyWithCompanion(TemplateOperationsCompanion data) {
    return TemplateOperation(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      catalogOperationId: data.catalogOperationId.present
          ? data.catalogOperationId.value
          : this.catalogOperationId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subtypeId: data.subtypeId.present ? data.subtypeId.value : this.subtypeId,
      referenceStandardMs: data.referenceStandardMs.present
          ? data.referenceStandardMs.value
          : this.referenceStandardMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateOperation(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('catalogOperationId: $catalogOperationId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    catalogOperationId,
    orderIndex,
    name,
    category,
    subtypeId,
    referenceStandardMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateOperation &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.catalogOperationId == this.catalogOperationId &&
          other.orderIndex == this.orderIndex &&
          other.name == this.name &&
          other.category == this.category &&
          other.subtypeId == this.subtypeId &&
          other.referenceStandardMs == this.referenceStandardMs &&
          other.createdAt == this.createdAt);
}

class TemplateOperationsCompanion extends UpdateCompanion<TemplateOperation> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String?> catalogOperationId;
  final Value<double> orderIndex;
  final Value<String> name;
  final Value<OperationCategory> category;
  final Value<String?> subtypeId;
  final Value<int?> referenceStandardMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TemplateOperationsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.catalogOperationId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateOperationsCompanion.insert({
    required String id,
    required String templateId,
    this.catalogOperationId = const Value.absent(),
    required double orderIndex,
    required String name,
    required OperationCategory category,
    this.subtypeId = const Value.absent(),
    this.referenceStandardMs = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       orderIndex = Value(orderIndex),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt);
  static Insertable<TemplateOperation> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? catalogOperationId,
    Expression<double>? orderIndex,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subtypeId,
    Expression<int>? referenceStandardMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (catalogOperationId != null)
        'catalog_operation_id': catalogOperationId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subtypeId != null) 'subtype_id': subtypeId,
      if (referenceStandardMs != null)
        'reference_standard_ms': referenceStandardMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String?>? catalogOperationId,
    Value<double>? orderIndex,
    Value<String>? name,
    Value<OperationCategory>? category,
    Value<String?>? subtypeId,
    Value<int?>? referenceStandardMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TemplateOperationsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      catalogOperationId: catalogOperationId ?? this.catalogOperationId,
      orderIndex: orderIndex ?? this.orderIndex,
      name: name ?? this.name,
      category: category ?? this.category,
      subtypeId: subtypeId ?? this.subtypeId,
      referenceStandardMs: referenceStandardMs ?? this.referenceStandardMs,
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
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (catalogOperationId.present) {
      map['catalog_operation_id'] = Variable<String>(catalogOperationId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<double>(orderIndex.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $TemplateOperationsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subtypeId.present) {
      map['subtype_id'] = Variable<String>(subtypeId.value);
    }
    if (referenceStandardMs.present) {
      map['reference_standard_ms'] = Variable<int>(referenceStandardMs.value);
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
    return (StringBuffer('TemplateOperationsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('catalogOperationId: $catalogOperationId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subtypeId: $subtypeId, ')
          ..write('referenceStandardMs: $referenceStandardMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProcessTypeOptionsTable extends ProcessTypeOptions
    with TableInfo<$ProcessTypeOptionsTable, ProcessTypeOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProcessTypeOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isBuiltIn,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'process_type_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProcessTypeOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProcessTypeOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProcessTypeOption(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProcessTypeOptionsTable createAlias(String alias) {
    return $ProcessTypeOptionsTable(attachedDatabase, alias);
  }
}

class ProcessTypeOption extends DataClass
    implements Insertable<ProcessTypeOption> {
  final String id;
  final String name;
  final bool isBuiltIn;
  final int sortOrder;
  final DateTime createdAt;
  const ProcessTypeOption({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProcessTypeOptionsCompanion toCompanion(bool nullToAbsent) {
    return ProcessTypeOptionsCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ProcessTypeOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProcessTypeOption(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProcessTypeOption copyWith({
    String? id,
    String? name,
    bool? isBuiltIn,
    int? sortOrder,
    DateTime? createdAt,
  }) => ProcessTypeOption(
    id: id ?? this.id,
    name: name ?? this.name,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ProcessTypeOption copyWithCompanion(ProcessTypeOptionsCompanion data) {
    return ProcessTypeOption(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProcessTypeOption(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn, sortOrder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProcessTypeOption &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ProcessTypeOptionsCompanion extends UpdateCompanion<ProcessTypeOption> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProcessTypeOptionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProcessTypeOptionsCompanion.insert({
    required String id,
    required String name,
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<ProcessTypeOption> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProcessTypeOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProcessTypeOptionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('ProcessTypeOptionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAttachmentsTable extends MediaAttachments
    with TableInfo<$MediaAttachmentsTable, MediaAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaOwnerType, String>
  ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MediaOwnerType>($MediaAttachmentsTable.$converterownerType);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaKind>($MediaAttachmentsTable.$converterkind);
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerType,
    ownerId,
    kind,
    relativePath,
    caption,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerType: $MediaAttachmentsTable.$converterownerType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}owner_type'],
        )!,
      ),
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      kind: $MediaAttachmentsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaAttachmentsTable createAlias(String alias) {
    return $MediaAttachmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaOwnerType, String, String>
  $converterownerType = const EnumNameConverter<MediaOwnerType>(
    MediaOwnerType.values,
  );
  static JsonTypeConverter2<MediaKind, String, String> $converterkind =
      const EnumNameConverter<MediaKind>(MediaKind.values);
}

class MediaAttachment extends DataClass implements Insertable<MediaAttachment> {
  final String id;
  final MediaOwnerType ownerType;
  final String ownerId;
  final MediaKind kind;
  final String relativePath;
  final String? caption;
  final DateTime createdAt;
  const MediaAttachment({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.kind,
    required this.relativePath,
    this.caption,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['owner_type'] = Variable<String>(
        $MediaAttachmentsTable.$converterownerType.toSql(ownerType),
      );
    }
    map['owner_id'] = Variable<String>(ownerId);
    {
      map['kind'] = Variable<String>(
        $MediaAttachmentsTable.$converterkind.toSql(kind),
      );
    }
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || caption != null) {
      map['caption'] = Variable<String>(caption);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return MediaAttachmentsCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      kind: Value(kind),
      relativePath: Value(relativePath),
      caption: caption == null && nullToAbsent
          ? const Value.absent()
          : Value(caption),
      createdAt: Value(createdAt),
    );
  }

  factory MediaAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAttachment(
      id: serializer.fromJson<String>(json['id']),
      ownerType: $MediaAttachmentsTable.$converterownerType.fromJson(
        serializer.fromJson<String>(json['ownerType']),
      ),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      kind: $MediaAttachmentsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      caption: serializer.fromJson<String?>(json['caption']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerType': serializer.toJson<String>(
        $MediaAttachmentsTable.$converterownerType.toJson(ownerType),
      ),
      'ownerId': serializer.toJson<String>(ownerId),
      'kind': serializer.toJson<String>(
        $MediaAttachmentsTable.$converterkind.toJson(kind),
      ),
      'relativePath': serializer.toJson<String>(relativePath),
      'caption': serializer.toJson<String?>(caption),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaAttachment copyWith({
    String? id,
    MediaOwnerType? ownerType,
    String? ownerId,
    MediaKind? kind,
    String? relativePath,
    Value<String?> caption = const Value.absent(),
    DateTime? createdAt,
  }) => MediaAttachment(
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    caption: caption.present ? caption.value : this.caption,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaAttachment copyWithCompanion(MediaAttachmentsCompanion data) {
    return MediaAttachment(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      caption: data.caption.present ? data.caption.value : this.caption,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAttachment(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerType,
    ownerId,
    kind,
    relativePath,
    caption,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAttachment &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.caption == this.caption &&
          other.createdAt == this.createdAt);
}

class MediaAttachmentsCompanion extends UpdateCompanion<MediaAttachment> {
  final Value<String> id;
  final Value<MediaOwnerType> ownerType;
  final Value<String> ownerId;
  final Value<MediaKind> kind;
  final Value<String> relativePath;
  final Value<String?> caption;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MediaAttachmentsCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.caption = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAttachmentsCompanion.insert({
    required String id,
    required MediaOwnerType ownerType,
    required String ownerId,
    required MediaKind kind,
    required String relativePath,
    this.caption = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       kind = Value(kind),
       relativePath = Value(relativePath),
       createdAt = Value(createdAt);
  static Insertable<MediaAttachment> custom({
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<String>? caption,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (caption != null) 'caption': caption,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<MediaOwnerType>? ownerType,
    Value<String>? ownerId,
    Value<MediaKind>? kind,
    Value<String>? relativePath,
    Value<String?>? caption,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaAttachmentsCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      caption: caption ?? this.caption,
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
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(
        $MediaAttachmentsTable.$converterownerType.toSql(ownerType.value),
      );
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $MediaAttachmentsTable.$converterkind.toSql(kind.value),
      );
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
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
    return (StringBuffer('MediaAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('caption: $caption, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localeCodeMeta = const VerificationMeta(
    'localeCode',
  );
  @override
  late final GeneratedColumn<String> localeCode = GeneratedColumn<String>(
    'locale_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultAnalystMeta = const VerificationMeta(
    'defaultAnalyst',
  );
  @override
  late final GeneratedColumn<String> defaultAnalyst = GeneratedColumn<String>(
    'default_analyst',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TimeUnit, String> timeUnit =
      GeneratedColumn<String>(
        'time_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TimeUnit>($AppSettingsTable.$convertertimeUnit);
  static const VerificationMeta _alertSoundsEnabledMeta =
      const VerificationMeta('alertSoundsEnabled');
  @override
  late final GeneratedColumn<bool> alertSoundsEnabled = GeneratedColumn<bool>(
    'alert_sounds_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alert_sounds_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localeCode,
    defaultAnalyst,
    timeUnit,
    alertSoundsEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locale_code')) {
      context.handle(
        _localeCodeMeta,
        localeCode.isAcceptableOrUnknown(data['locale_code']!, _localeCodeMeta),
      );
    }
    if (data.containsKey('default_analyst')) {
      context.handle(
        _defaultAnalystMeta,
        defaultAnalyst.isAcceptableOrUnknown(
          data['default_analyst']!,
          _defaultAnalystMeta,
        ),
      );
    }
    if (data.containsKey('alert_sounds_enabled')) {
      context.handle(
        _alertSoundsEnabledMeta,
        alertSoundsEnabled.isAcceptableOrUnknown(
          data['alert_sounds_enabled']!,
          _alertSoundsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_code'],
      ),
      defaultAnalyst: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_analyst'],
      ),
      timeUnit: $AppSettingsTable.$convertertimeUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}time_unit'],
        )!,
      ),
      alertSoundsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alert_sounds_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TimeUnit, String, String> $convertertimeUnit =
      const EnumNameConverter<TimeUnit>(TimeUnit.values);
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;

  /// null => follow the system locale; otherwise 'en' / 'pt' / 'es'.
  final String? localeCode;

  /// Pre-fills the Analyst field on new studies.
  final String? defaultAnalyst;
  final TimeUnit timeUnit;

  /// Sound when an operation nears or passes its reference standard (§3.6).
  final bool alertSoundsEnabled;
  final DateTime updatedAt;
  const AppSetting({
    required this.id,
    this.localeCode,
    this.defaultAnalyst,
    required this.timeUnit,
    required this.alertSoundsEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || localeCode != null) {
      map['locale_code'] = Variable<String>(localeCode);
    }
    if (!nullToAbsent || defaultAnalyst != null) {
      map['default_analyst'] = Variable<String>(defaultAnalyst);
    }
    {
      map['time_unit'] = Variable<String>(
        $AppSettingsTable.$convertertimeUnit.toSql(timeUnit),
      );
    }
    map['alert_sounds_enabled'] = Variable<bool>(alertSoundsEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      localeCode: localeCode == null && nullToAbsent
          ? const Value.absent()
          : Value(localeCode),
      defaultAnalyst: defaultAnalyst == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAnalyst),
      timeUnit: Value(timeUnit),
      alertSoundsEnabled: Value(alertSoundsEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      localeCode: serializer.fromJson<String?>(json['localeCode']),
      defaultAnalyst: serializer.fromJson<String?>(json['defaultAnalyst']),
      timeUnit: $AppSettingsTable.$convertertimeUnit.fromJson(
        serializer.fromJson<String>(json['timeUnit']),
      ),
      alertSoundsEnabled: serializer.fromJson<bool>(json['alertSoundsEnabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localeCode': serializer.toJson<String?>(localeCode),
      'defaultAnalyst': serializer.toJson<String?>(defaultAnalyst),
      'timeUnit': serializer.toJson<String>(
        $AppSettingsTable.$convertertimeUnit.toJson(timeUnit),
      ),
      'alertSoundsEnabled': serializer.toJson<bool>(alertSoundsEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({
    int? id,
    Value<String?> localeCode = const Value.absent(),
    Value<String?> defaultAnalyst = const Value.absent(),
    TimeUnit? timeUnit,
    bool? alertSoundsEnabled,
    DateTime? updatedAt,
  }) => AppSetting(
    id: id ?? this.id,
    localeCode: localeCode.present ? localeCode.value : this.localeCode,
    defaultAnalyst: defaultAnalyst.present
        ? defaultAnalyst.value
        : this.defaultAnalyst,
    timeUnit: timeUnit ?? this.timeUnit,
    alertSoundsEnabled: alertSoundsEnabled ?? this.alertSoundsEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      defaultAnalyst: data.defaultAnalyst.present
          ? data.defaultAnalyst.value
          : this.defaultAnalyst,
      timeUnit: data.timeUnit.present ? data.timeUnit.value : this.timeUnit,
      alertSoundsEnabled: data.alertSoundsEnabled.present
          ? data.alertSoundsEnabled.value
          : this.alertSoundsEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode, ')
          ..write('defaultAnalyst: $defaultAnalyst, ')
          ..write('timeUnit: $timeUnit, ')
          ..write('alertSoundsEnabled: $alertSoundsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localeCode,
    defaultAnalyst,
    timeUnit,
    alertSoundsEnabled,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.localeCode == this.localeCode &&
          other.defaultAnalyst == this.defaultAnalyst &&
          other.timeUnit == this.timeUnit &&
          other.alertSoundsEnabled == this.alertSoundsEnabled &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String?> localeCode;
  final Value<String?> defaultAnalyst;
  final Value<TimeUnit> timeUnit;
  final Value<bool> alertSoundsEnabled;
  final Value<DateTime> updatedAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.defaultAnalyst = const Value.absent(),
    this.timeUnit = const Value.absent(),
    this.alertSoundsEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.defaultAnalyst = const Value.absent(),
    required TimeUnit timeUnit,
    this.alertSoundsEnabled = const Value.absent(),
    required DateTime updatedAt,
  }) : timeUnit = Value(timeUnit),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? localeCode,
    Expression<String>? defaultAnalyst,
    Expression<String>? timeUnit,
    Expression<bool>? alertSoundsEnabled,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localeCode != null) 'locale_code': localeCode,
      if (defaultAnalyst != null) 'default_analyst': defaultAnalyst,
      if (timeUnit != null) 'time_unit': timeUnit,
      if (alertSoundsEnabled != null)
        'alert_sounds_enabled': alertSoundsEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? localeCode,
    Value<String?>? defaultAnalyst,
    Value<TimeUnit>? timeUnit,
    Value<bool>? alertSoundsEnabled,
    Value<DateTime>? updatedAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      localeCode: localeCode ?? this.localeCode,
      defaultAnalyst: defaultAnalyst ?? this.defaultAnalyst,
      timeUnit: timeUnit ?? this.timeUnit,
      alertSoundsEnabled: alertSoundsEnabled ?? this.alertSoundsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(localeCode.value);
    }
    if (defaultAnalyst.present) {
      map['default_analyst'] = Variable<String>(defaultAnalyst.value);
    }
    if (timeUnit.present) {
      map['time_unit'] = Variable<String>(
        $AppSettingsTable.$convertertimeUnit.toSql(timeUnit.value),
      );
    }
    if (alertSoundsEnabled.present) {
      map['alert_sounds_enabled'] = Variable<bool>(alertSoundsEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('localeCode: $localeCode, ')
          ..write('defaultAnalyst: $defaultAnalyst, ')
          ..write('timeUnit: $timeUnit, ')
          ..write('alertSoundsEnabled: $alertSoundsEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $OperationSubtypesTable operationSubtypes =
      $OperationSubtypesTable(this);
  late final $CatalogOperationsTable catalogOperations =
      $CatalogOperationsTable(this);
  late final $StudiesTable studies = $StudiesTable(this);
  late final $StudyOperationsTable studyOperations = $StudyOperationsTable(
    this,
  );
  late final $ObservationsTable observations = $ObservationsTable(this);
  late final $OperationInstancesTable operationInstances =
      $OperationInstancesTable(this);
  late final $OperationTimeSegmentsTable operationTimeSegments =
      $OperationTimeSegmentsTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $TemplateOperationsTable templateOperations =
      $TemplateOperationsTable(this);
  late final $ProcessTypeOptionsTable processTypeOptions =
      $ProcessTypeOptionsTable(this);
  late final $MediaAttachmentsTable mediaAttachments = $MediaAttachmentsTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    operationSubtypes,
    catalogOperations,
    studies,
    studyOperations,
    observations,
    operationInstances,
    operationTimeSegments,
    templates,
    templateOperations,
    processTypeOptions,
    mediaAttachments,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'operation_subtypes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('catalog_operations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('studies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'studies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_operations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'operation_subtypes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_operations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'studies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('observations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'observations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('operation_instances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_operations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('operation_instances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'operation_instances',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('operation_time_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('template_operations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_operations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('template_operations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'operation_subtypes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('template_operations', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudiesTable, List<Study>> _studiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.studies,
    aliasName: 'projects__id__studies__project_id',
  );

  $$StudiesTableProcessedTableManager get studiesRefs {
    final manager = $$StudiesTableTableManager(
      $_db,
      $_db.studies,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_studiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  Expression<bool> studiesRefs(
    Expression<bool> Function($$StudiesTableFilterComposer f) f,
  ) {
    final $$StudiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableFilterComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> studiesRefs<T extends Object>(
    Expression<T> Function($$StudiesTableAnnotationComposer a) f,
  ) {
    final $$StudiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableAnnotationComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool studiesRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (studiesRefs) db.studies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (studiesRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Study>(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._studiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProjectsTableReferences(db, table, p0).studiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool studiesRefs})
    >;
typedef $$OperationSubtypesTableCreateCompanionBuilder =
    OperationSubtypesCompanion Function({
      required String id,
      required OperationCategory category,
      required String name,
      Value<bool> isBuiltIn,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OperationSubtypesTableUpdateCompanionBuilder =
    OperationSubtypesCompanion Function({
      Value<String> id,
      Value<OperationCategory> category,
      Value<String> name,
      Value<bool> isBuiltIn,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$OperationSubtypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OperationSubtypesTable,
          OperationSubtype
        > {
  $$OperationSubtypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CatalogOperationsTable, List<CatalogOperation>>
  _catalogOperationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.catalogOperations,
        aliasName: 'operation_subtypes__id__catalog_operations__subtype_id',
      );

  $$CatalogOperationsTableProcessedTableManager get catalogOperationsRefs {
    final manager = $$CatalogOperationsTableTableManager(
      $_db,
      $_db.catalogOperations,
    ).filter((f) => f.subtypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _catalogOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyOperationsTable, List<StudyOperation>>
  _studyOperationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyOperations,
    aliasName: 'operation_subtypes__id__study_operations__subtype_id',
  );

  $$StudyOperationsTableProcessedTableManager get studyOperationsRefs {
    final manager = $$StudyOperationsTableTableManager(
      $_db,
      $_db.studyOperations,
    ).filter((f) => f.subtypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studyOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemplateOperationsTable, List<TemplateOperation>>
  _templateOperationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateOperations,
        aliasName: 'operation_subtypes__id__template_operations__subtype_id',
      );

  $$TemplateOperationsTableProcessedTableManager get templateOperationsRefs {
    final manager = $$TemplateOperationsTableTableManager(
      $_db,
      $_db.templateOperations,
    ).filter((f) => f.subtypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OperationSubtypesTableFilterComposer
    extends Composer<_$AppDatabase, $OperationSubtypesTable> {
  $$OperationSubtypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperationCategory, OperationCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> catalogOperationsRefs(
    Expression<bool> Function($$CatalogOperationsTableFilterComposer f) f,
  ) {
    final $$CatalogOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.catalogOperations,
      getReferencedColumn: (t) => t.subtypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogOperationsTableFilterComposer(
            $db: $db,
            $table: $db.catalogOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyOperationsRefs(
    Expression<bool> Function($$StudyOperationsTableFilterComposer f) f,
  ) {
    final $$StudyOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.subtypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableFilterComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> templateOperationsRefs(
    Expression<bool> Function($$TemplateOperationsTableFilterComposer f) f,
  ) {
    final $$TemplateOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateOperations,
      getReferencedColumn: (t) => t.subtypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateOperationsTableFilterComposer(
            $db: $db,
            $table: $db.templateOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OperationSubtypesTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationSubtypesTable> {
  $$OperationSubtypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OperationSubtypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationSubtypesTable> {
  $$OperationSubtypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OperationCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> catalogOperationsRefs<T extends Object>(
    Expression<T> Function($$CatalogOperationsTableAnnotationComposer a) f,
  ) {
    final $$CatalogOperationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.catalogOperations,
          getReferencedColumn: (t) => t.subtypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CatalogOperationsTableAnnotationComposer(
                $db: $db,
                $table: $db.catalogOperations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> studyOperationsRefs<T extends Object>(
    Expression<T> Function($$StudyOperationsTableAnnotationComposer a) f,
  ) {
    final $$StudyOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.subtypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> templateOperationsRefs<T extends Object>(
    Expression<T> Function($$TemplateOperationsTableAnnotationComposer a) f,
  ) {
    final $$TemplateOperationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateOperations,
          getReferencedColumn: (t) => t.subtypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateOperationsTableAnnotationComposer(
                $db: $db,
                $table: $db.templateOperations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OperationSubtypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationSubtypesTable,
          OperationSubtype,
          $$OperationSubtypesTableFilterComposer,
          $$OperationSubtypesTableOrderingComposer,
          $$OperationSubtypesTableAnnotationComposer,
          $$OperationSubtypesTableCreateCompanionBuilder,
          $$OperationSubtypesTableUpdateCompanionBuilder,
          (OperationSubtype, $$OperationSubtypesTableReferences),
          OperationSubtype,
          PrefetchHooks Function({
            bool catalogOperationsRefs,
            bool studyOperationsRefs,
            bool templateOperationsRefs,
          })
        > {
  $$OperationSubtypesTableTableManager(
    _$AppDatabase db,
    $OperationSubtypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationSubtypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationSubtypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationSubtypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<OperationCategory> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationSubtypesCompanion(
                id: id,
                category: category,
                name: name,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required OperationCategory category,
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OperationSubtypesCompanion.insert(
                id: id,
                category: category,
                name: name,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationSubtypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                catalogOperationsRefs = false,
                studyOperationsRefs = false,
                templateOperationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (catalogOperationsRefs) db.catalogOperations,
                    if (studyOperationsRefs) db.studyOperations,
                    if (templateOperationsRefs) db.templateOperations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (catalogOperationsRefs)
                        await $_getPrefetchedData<
                          OperationSubtype,
                          $OperationSubtypesTable,
                          CatalogOperation
                        >(
                          currentTable: table,
                          referencedTable: $$OperationSubtypesTableReferences
                              ._catalogOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperationSubtypesTableReferences(
                                db,
                                table,
                                p0,
                              ).catalogOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subtypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (studyOperationsRefs)
                        await $_getPrefetchedData<
                          OperationSubtype,
                          $OperationSubtypesTable,
                          StudyOperation
                        >(
                          currentTable: table,
                          referencedTable: $$OperationSubtypesTableReferences
                              ._studyOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperationSubtypesTableReferences(
                                db,
                                table,
                                p0,
                              ).studyOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subtypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (templateOperationsRefs)
                        await $_getPrefetchedData<
                          OperationSubtype,
                          $OperationSubtypesTable,
                          TemplateOperation
                        >(
                          currentTable: table,
                          referencedTable: $$OperationSubtypesTableReferences
                              ._templateOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperationSubtypesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subtypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OperationSubtypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationSubtypesTable,
      OperationSubtype,
      $$OperationSubtypesTableFilterComposer,
      $$OperationSubtypesTableOrderingComposer,
      $$OperationSubtypesTableAnnotationComposer,
      $$OperationSubtypesTableCreateCompanionBuilder,
      $$OperationSubtypesTableUpdateCompanionBuilder,
      (OperationSubtype, $$OperationSubtypesTableReferences),
      OperationSubtype,
      PrefetchHooks Function({
        bool catalogOperationsRefs,
        bool studyOperationsRefs,
        bool templateOperationsRefs,
      })
    >;
typedef $$CatalogOperationsTableCreateCompanionBuilder =
    CatalogOperationsCompanion Function({
      required String id,
      required String name,
      required OperationCategory category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CatalogOperationsTableUpdateCompanionBuilder =
    CatalogOperationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<OperationCategory> category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CatalogOperationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CatalogOperationsTable,
          CatalogOperation
        > {
  $$CatalogOperationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OperationSubtypesTable _subtypeIdTable(_$AppDatabase db) => db
      .operationSubtypes
      .createAlias('catalog_operations__subtype_id__operation_subtypes__id');

  $$OperationSubtypesTableProcessedTableManager? get subtypeId {
    final $_column = $_itemColumn<String>('subtype_id');
    if ($_column == null) return null;
    final manager = $$OperationSubtypesTableTableManager(
      $_db,
      $_db.operationSubtypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TemplateOperationsTable, List<TemplateOperation>>
  _templateOperationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateOperations,
        aliasName:
            'catalog_operations__id__template_operations__catalog_operation_id',
      );

  $$TemplateOperationsTableProcessedTableManager get templateOperationsRefs {
    final manager =
        $$TemplateOperationsTableTableManager(
          $_db,
          $_db.templateOperations,
        ).filter(
          (f) => f.catalogOperationId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _templateOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogOperationsTable> {
  $$CatalogOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperationCategory, OperationCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
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

  $$OperationSubtypesTableFilterComposer get subtypeId {
    final $$OperationSubtypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableFilterComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> templateOperationsRefs(
    Expression<bool> Function($$TemplateOperationsTableFilterComposer f) f,
  ) {
    final $$TemplateOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateOperations,
      getReferencedColumn: (t) => t.catalogOperationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateOperationsTableFilterComposer(
            $db: $db,
            $table: $db.templateOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogOperationsTable> {
  $$CatalogOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
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

  ColumnOrderings<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
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

  $$OperationSubtypesTableOrderingComposer get subtypeId {
    final $$OperationSubtypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableOrderingComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CatalogOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogOperationsTable> {
  $$CatalogOperationsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<OperationCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OperationSubtypesTableAnnotationComposer get subtypeId {
    final $$OperationSubtypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.subtypeId,
          referencedTable: $db.operationSubtypes,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationSubtypesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationSubtypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> templateOperationsRefs<T extends Object>(
    Expression<T> Function($$TemplateOperationsTableAnnotationComposer a) f,
  ) {
    final $$TemplateOperationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateOperations,
          getReferencedColumn: (t) => t.catalogOperationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateOperationsTableAnnotationComposer(
                $db: $db,
                $table: $db.templateOperations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CatalogOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogOperationsTable,
          CatalogOperation,
          $$CatalogOperationsTableFilterComposer,
          $$CatalogOperationsTableOrderingComposer,
          $$CatalogOperationsTableAnnotationComposer,
          $$CatalogOperationsTableCreateCompanionBuilder,
          $$CatalogOperationsTableUpdateCompanionBuilder,
          (CatalogOperation, $$CatalogOperationsTableReferences),
          CatalogOperation,
          PrefetchHooks Function({bool subtypeId, bool templateOperationsRefs})
        > {
  $$CatalogOperationsTableTableManager(
    _$AppDatabase db,
    $CatalogOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<OperationCategory> category = const Value.absent(),
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogOperationsCompanion(
                id: id,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required OperationCategory category,
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CatalogOperationsCompanion.insert(
                id: id,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogOperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({subtypeId = false, templateOperationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (templateOperationsRefs) db.templateOperations,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (subtypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subtypeId,
                                    referencedTable:
                                        $$CatalogOperationsTableReferences
                                            ._subtypeIdTable(db),
                                    referencedColumn:
                                        $$CatalogOperationsTableReferences
                                            ._subtypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (templateOperationsRefs)
                        await $_getPrefetchedData<
                          CatalogOperation,
                          $CatalogOperationsTable,
                          TemplateOperation
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogOperationsTableReferences
                              ._templateOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogOperationsTableReferences(
                                db,
                                table,
                                p0,
                              ).templateOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.catalogOperationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CatalogOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogOperationsTable,
      CatalogOperation,
      $$CatalogOperationsTableFilterComposer,
      $$CatalogOperationsTableOrderingComposer,
      $$CatalogOperationsTableAnnotationComposer,
      $$CatalogOperationsTableCreateCompanionBuilder,
      $$CatalogOperationsTableUpdateCompanionBuilder,
      (CatalogOperation, $$CatalogOperationsTableReferences),
      CatalogOperation,
      PrefetchHooks Function({bool subtypeId, bool templateOperationsRefs})
    >;
typedef $$StudiesTableCreateCompanionBuilder =
    StudiesCompanion Function({
      required String id,
      required String projectId,
      required StudyType type,
      required String name,
      required DateTime performedAt,
      Value<String?> analyst,
      Value<String?> partProduct,
      Value<String?> processOperation,
      Value<String?> machineWorkstation,
      Value<String?> lineCell,
      Value<String?> operatorName,
      Value<String?> shift,
      Value<String?> workOrderNumber,
      Value<String?> processType,
      Value<String?> notes,
      Value<double> confidenceLevel,
      Value<double> relativePrecision,
      Value<int> nextPassIndex,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StudiesTableUpdateCompanionBuilder =
    StudiesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<StudyType> type,
      Value<String> name,
      Value<DateTime> performedAt,
      Value<String?> analyst,
      Value<String?> partProduct,
      Value<String?> processOperation,
      Value<String?> machineWorkstation,
      Value<String?> lineCell,
      Value<String?> operatorName,
      Value<String?> shift,
      Value<String?> workOrderNumber,
      Value<String?> processType,
      Value<String?> notes,
      Value<double> confidenceLevel,
      Value<double> relativePrecision,
      Value<int> nextPassIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StudiesTableReferences
    extends BaseReferences<_$AppDatabase, $StudiesTable, Study> {
  $$StudiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('studies__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudyOperationsTable, List<StudyOperation>>
  _studyOperationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studyOperations,
    aliasName: 'studies__id__study_operations__study_id',
  );

  $$StudyOperationsTableProcessedTableManager get studyOperationsRefs {
    final manager = $$StudyOperationsTableTableManager(
      $_db,
      $_db.studyOperations,
    ).filter((f) => f.studyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studyOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ObservationsTable, List<Observation>>
  _observationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observations,
    aliasName: 'studies__id__observations__study_id',
  );

  $$ObservationsTableProcessedTableManager get observationsRefs {
    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.studyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_observationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudiesTableFilterComposer
    extends Composer<_$AppDatabase, $StudiesTable> {
  $$StudiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StudyType, StudyType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analyst => $composableBuilder(
    column: $table.analyst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partProduct => $composableBuilder(
    column: $table.partProduct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processOperation => $composableBuilder(
    column: $table.processOperation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get machineWorkstation => $composableBuilder(
    column: $table.machineWorkstation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineCell => $composableBuilder(
    column: $table.lineCell,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processType => $composableBuilder(
    column: $table.processType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get relativePrecision => $composableBuilder(
    column: $table.relativePrecision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextPassIndex => $composableBuilder(
    column: $table.nextPassIndex,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studyOperationsRefs(
    Expression<bool> Function($$StudyOperationsTableFilterComposer f) f,
  ) {
    final $$StudyOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.studyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableFilterComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observationsRefs(
    Expression<bool> Function($$ObservationsTableFilterComposer f) f,
  ) {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.studyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudiesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudiesTable> {
  $$StudiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analyst => $composableBuilder(
    column: $table.analyst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partProduct => $composableBuilder(
    column: $table.partProduct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processOperation => $composableBuilder(
    column: $table.processOperation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get machineWorkstation => $composableBuilder(
    column: $table.machineWorkstation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineCell => $composableBuilder(
    column: $table.lineCell,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processType => $composableBuilder(
    column: $table.processType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get relativePrecision => $composableBuilder(
    column: $table.relativePrecision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextPassIndex => $composableBuilder(
    column: $table.nextPassIndex,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudiesTable> {
  $$StudiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StudyType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analyst =>
      $composableBuilder(column: $table.analyst, builder: (column) => column);

  GeneratedColumn<String> get partProduct => $composableBuilder(
    column: $table.partProduct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processOperation => $composableBuilder(
    column: $table.processOperation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get machineWorkstation => $composableBuilder(
    column: $table.machineWorkstation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lineCell =>
      $composableBuilder(column: $table.lineCell, builder: (column) => column);

  GeneratedColumn<String> get operatorName => $composableBuilder(
    column: $table.operatorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<String> get workOrderNumber => $composableBuilder(
    column: $table.workOrderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processType => $composableBuilder(
    column: $table.processType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get relativePrecision => $composableBuilder(
    column: $table.relativePrecision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextPassIndex => $composableBuilder(
    column: $table.nextPassIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studyOperationsRefs<T extends Object>(
    Expression<T> Function($$StudyOperationsTableAnnotationComposer a) f,
  ) {
    final $$StudyOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.studyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observationsRefs<T extends Object>(
    Expression<T> Function($$ObservationsTableAnnotationComposer a) f,
  ) {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.studyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudiesTable,
          Study,
          $$StudiesTableFilterComposer,
          $$StudiesTableOrderingComposer,
          $$StudiesTableAnnotationComposer,
          $$StudiesTableCreateCompanionBuilder,
          $$StudiesTableUpdateCompanionBuilder,
          (Study, $$StudiesTableReferences),
          Study,
          PrefetchHooks Function({
            bool projectId,
            bool studyOperationsRefs,
            bool observationsRefs,
          })
        > {
  $$StudiesTableTableManager(_$AppDatabase db, $StudiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<StudyType> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<String?> analyst = const Value.absent(),
                Value<String?> partProduct = const Value.absent(),
                Value<String?> processOperation = const Value.absent(),
                Value<String?> machineWorkstation = const Value.absent(),
                Value<String?> lineCell = const Value.absent(),
                Value<String?> operatorName = const Value.absent(),
                Value<String?> shift = const Value.absent(),
                Value<String?> workOrderNumber = const Value.absent(),
                Value<String?> processType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> confidenceLevel = const Value.absent(),
                Value<double> relativePrecision = const Value.absent(),
                Value<int> nextPassIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudiesCompanion(
                id: id,
                projectId: projectId,
                type: type,
                name: name,
                performedAt: performedAt,
                analyst: analyst,
                partProduct: partProduct,
                processOperation: processOperation,
                machineWorkstation: machineWorkstation,
                lineCell: lineCell,
                operatorName: operatorName,
                shift: shift,
                workOrderNumber: workOrderNumber,
                processType: processType,
                notes: notes,
                confidenceLevel: confidenceLevel,
                relativePrecision: relativePrecision,
                nextPassIndex: nextPassIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required StudyType type,
                required String name,
                required DateTime performedAt,
                Value<String?> analyst = const Value.absent(),
                Value<String?> partProduct = const Value.absent(),
                Value<String?> processOperation = const Value.absent(),
                Value<String?> machineWorkstation = const Value.absent(),
                Value<String?> lineCell = const Value.absent(),
                Value<String?> operatorName = const Value.absent(),
                Value<String?> shift = const Value.absent(),
                Value<String?> workOrderNumber = const Value.absent(),
                Value<String?> processType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<double> confidenceLevel = const Value.absent(),
                Value<double> relativePrecision = const Value.absent(),
                Value<int> nextPassIndex = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StudiesCompanion.insert(
                id: id,
                projectId: projectId,
                type: type,
                name: name,
                performedAt: performedAt,
                analyst: analyst,
                partProduct: partProduct,
                processOperation: processOperation,
                machineWorkstation: machineWorkstation,
                lineCell: lineCell,
                operatorName: operatorName,
                shift: shift,
                workOrderNumber: workOrderNumber,
                processType: processType,
                notes: notes,
                confidenceLevel: confidenceLevel,
                relativePrecision: relativePrecision,
                nextPassIndex: nextPassIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                studyOperationsRefs = false,
                observationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studyOperationsRefs) db.studyOperations,
                    if (observationsRefs) db.observations,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$StudiesTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$StudiesTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studyOperationsRefs)
                        await $_getPrefetchedData<
                          Study,
                          $StudiesTable,
                          StudyOperation
                        >(
                          currentTable: table,
                          referencedTable: $$StudiesTableReferences
                              ._studyOperationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudiesTableReferences(
                                db,
                                table,
                                p0,
                              ).studyOperationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observationsRefs)
                        await $_getPrefetchedData<
                          Study,
                          $StudiesTable,
                          Observation
                        >(
                          currentTable: table,
                          referencedTable: $$StudiesTableReferences
                              ._observationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudiesTableReferences(
                                db,
                                table,
                                p0,
                              ).observationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudiesTable,
      Study,
      $$StudiesTableFilterComposer,
      $$StudiesTableOrderingComposer,
      $$StudiesTableAnnotationComposer,
      $$StudiesTableCreateCompanionBuilder,
      $$StudiesTableUpdateCompanionBuilder,
      (Study, $$StudiesTableReferences),
      Study,
      PrefetchHooks Function({
        bool projectId,
        bool studyOperationsRefs,
        bool observationsRefs,
      })
    >;
typedef $$StudyOperationsTableCreateCompanionBuilder =
    StudyOperationsCompanion Function({
      required String id,
      required String studyId,
      Value<String?> catalogOperationId,
      required double orderIndex,
      required String name,
      required OperationCategory category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      Value<bool> isUnplanned,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StudyOperationsTableUpdateCompanionBuilder =
    StudyOperationsCompanion Function({
      Value<String> id,
      Value<String> studyId,
      Value<String?> catalogOperationId,
      Value<double> orderIndex,
      Value<String> name,
      Value<OperationCategory> category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      Value<bool> isUnplanned,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StudyOperationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StudyOperationsTable, StudyOperation> {
  $$StudyOperationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudiesTable _studyIdTable(_$AppDatabase db) =>
      db.studies.createAlias('study_operations__study_id__studies__id');

  $$StudiesTableProcessedTableManager get studyId {
    final $_column = $_itemColumn<String>('study_id')!;

    final manager = $$StudiesTableTableManager(
      $_db,
      $_db.studies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OperationSubtypesTable _subtypeIdTable(_$AppDatabase db) => db
      .operationSubtypes
      .createAlias('study_operations__subtype_id__operation_subtypes__id');

  $$OperationSubtypesTableProcessedTableManager? get subtypeId {
    final $_column = $_itemColumn<String>('subtype_id');
    if ($_column == null) return null;
    final manager = $$OperationSubtypesTableTableManager(
      $_db,
      $_db.operationSubtypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationInstancesTable, List<OperationInstance>>
  _operationInstancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.operationInstances,
        aliasName:
            'study_operations__id__operation_instances__study_operation_id',
      );

  $$OperationInstancesTableProcessedTableManager get operationInstancesRefs {
    final manager =
        $$OperationInstancesTableTableManager(
          $_db,
          $_db.operationInstances,
        ).filter(
          (f) => f.studyOperationId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _operationInstancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudyOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyOperationsTable> {
  $$StudyOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogOperationId => $composableBuilder(
    column: $table.catalogOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperationCategory, OperationCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnplanned => $composableBuilder(
    column: $table.isUnplanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudiesTableFilterComposer get studyId {
    final $$StudiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableFilterComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationSubtypesTableFilterComposer get subtypeId {
    final $$OperationSubtypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableFilterComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationInstancesRefs(
    Expression<bool> Function($$OperationInstancesTableFilterComposer f) f,
  ) {
    final $$OperationInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationInstances,
      getReferencedColumn: (t) => t.studyOperationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationInstancesTableFilterComposer(
            $db: $db,
            $table: $db.operationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyOperationsTable> {
  $$StudyOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogOperationId => $composableBuilder(
    column: $table.catalogOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
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

  ColumnOrderings<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnplanned => $composableBuilder(
    column: $table.isUnplanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudiesTableOrderingComposer get studyId {
    final $$StudiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableOrderingComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationSubtypesTableOrderingComposer get subtypeId {
    final $$OperationSubtypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableOrderingComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyOperationsTable> {
  $$StudyOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catalogOperationId => $composableBuilder(
    column: $table.catalogOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OperationCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnplanned => $composableBuilder(
    column: $table.isUnplanned,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudiesTableAnnotationComposer get studyId {
    final $$StudiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableAnnotationComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationSubtypesTableAnnotationComposer get subtypeId {
    final $$OperationSubtypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.subtypeId,
          referencedTable: $db.operationSubtypes,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationSubtypesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationSubtypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> operationInstancesRefs<T extends Object>(
    Expression<T> Function($$OperationInstancesTableAnnotationComposer a) f,
  ) {
    final $$OperationInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.operationInstances,
          getReferencedColumn: (t) => t.studyOperationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StudyOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyOperationsTable,
          StudyOperation,
          $$StudyOperationsTableFilterComposer,
          $$StudyOperationsTableOrderingComposer,
          $$StudyOperationsTableAnnotationComposer,
          $$StudyOperationsTableCreateCompanionBuilder,
          $$StudyOperationsTableUpdateCompanionBuilder,
          (StudyOperation, $$StudyOperationsTableReferences),
          StudyOperation,
          PrefetchHooks Function({
            bool studyId,
            bool subtypeId,
            bool operationInstancesRefs,
          })
        > {
  $$StudyOperationsTableTableManager(
    _$AppDatabase db,
    $StudyOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studyId = const Value.absent(),
                Value<String?> catalogOperationId = const Value.absent(),
                Value<double> orderIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<OperationCategory> category = const Value.absent(),
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                Value<bool> isUnplanned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyOperationsCompanion(
                id: id,
                studyId: studyId,
                catalogOperationId: catalogOperationId,
                orderIndex: orderIndex,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                isUnplanned: isUnplanned,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studyId,
                Value<String?> catalogOperationId = const Value.absent(),
                required double orderIndex,
                required String name,
                required OperationCategory category,
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                Value<bool> isUnplanned = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StudyOperationsCompanion.insert(
                id: id,
                studyId: studyId,
                catalogOperationId: catalogOperationId,
                orderIndex: orderIndex,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                isUnplanned: isUnplanned,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudyOperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                studyId = false,
                subtypeId = false,
                operationInstancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationInstancesRefs) db.operationInstances,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (studyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studyId,
                                    referencedTable:
                                        $$StudyOperationsTableReferences
                                            ._studyIdTable(db),
                                    referencedColumn:
                                        $$StudyOperationsTableReferences
                                            ._studyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subtypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subtypeId,
                                    referencedTable:
                                        $$StudyOperationsTableReferences
                                            ._subtypeIdTable(db),
                                    referencedColumn:
                                        $$StudyOperationsTableReferences
                                            ._subtypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationInstancesRefs)
                        await $_getPrefetchedData<
                          StudyOperation,
                          $StudyOperationsTable,
                          OperationInstance
                        >(
                          currentTable: table,
                          referencedTable: $$StudyOperationsTableReferences
                              ._operationInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudyOperationsTableReferences(
                                db,
                                table,
                                p0,
                              ).operationInstancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studyOperationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudyOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyOperationsTable,
      StudyOperation,
      $$StudyOperationsTableFilterComposer,
      $$StudyOperationsTableOrderingComposer,
      $$StudyOperationsTableAnnotationComposer,
      $$StudyOperationsTableCreateCompanionBuilder,
      $$StudyOperationsTableUpdateCompanionBuilder,
      (StudyOperation, $$StudyOperationsTableReferences),
      StudyOperation,
      PrefetchHooks Function({
        bool studyId,
        bool subtypeId,
        bool operationInstancesRefs,
      })
    >;
typedef $$ObservationsTableCreateCompanionBuilder =
    ObservationsCompanion Function({
      required String id,
      required String studyId,
      required int sequenceIndex,
      required DateTime performedAt,
      Value<String?> notes,
      Value<DateTime?> excludedAt,
      Value<String?> exclusionReason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ObservationsTableUpdateCompanionBuilder =
    ObservationsCompanion Function({
      Value<String> id,
      Value<String> studyId,
      Value<int> sequenceIndex,
      Value<DateTime> performedAt,
      Value<String?> notes,
      Value<DateTime?> excludedAt,
      Value<String?> exclusionReason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ObservationsTableReferences
    extends BaseReferences<_$AppDatabase, $ObservationsTable, Observation> {
  $$ObservationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudiesTable _studyIdTable(_$AppDatabase db) =>
      db.studies.createAlias('observations__study_id__studies__id');

  $$StudiesTableProcessedTableManager get studyId {
    final $_column = $_itemColumn<String>('study_id')!;

    final manager = $$StudiesTableTableManager(
      $_db,
      $_db.studies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OperationInstancesTable, List<OperationInstance>>
  _operationInstancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.operationInstances,
        aliasName: 'observations__id__operation_instances__observation_id',
      );

  $$OperationInstancesTableProcessedTableManager get operationInstancesRefs {
    final manager = $$OperationInstancesTableTableManager(
      $_db,
      $_db.operationInstances,
    ).filter((f) => f.observationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _operationInstancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudiesTableFilterComposer get studyId {
    final $$StudiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableFilterComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationInstancesRefs(
    Expression<bool> Function($$OperationInstancesTableFilterComposer f) f,
  ) {
    final $$OperationInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.operationInstances,
      getReferencedColumn: (t) => t.observationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationInstancesTableFilterComposer(
            $db: $db,
            $table: $db.operationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudiesTableOrderingComposer get studyId {
    final $$StudiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableOrderingComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservationsTable> {
  $$ObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudiesTableAnnotationComposer get studyId {
    final $$StudiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyId,
      referencedTable: $db.studies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudiesTableAnnotationComposer(
            $db: $db,
            $table: $db.studies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationInstancesRefs<T extends Object>(
    Expression<T> Function($$OperationInstancesTableAnnotationComposer a) f,
  ) {
    final $$OperationInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.operationInstances,
          getReferencedColumn: (t) => t.observationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ObservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservationsTable,
          Observation,
          $$ObservationsTableFilterComposer,
          $$ObservationsTableOrderingComposer,
          $$ObservationsTableAnnotationComposer,
          $$ObservationsTableCreateCompanionBuilder,
          $$ObservationsTableUpdateCompanionBuilder,
          (Observation, $$ObservationsTableReferences),
          Observation,
          PrefetchHooks Function({bool studyId, bool operationInstancesRefs})
        > {
  $$ObservationsTableTableManager(_$AppDatabase db, $ObservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> studyId = const Value.absent(),
                Value<int> sequenceIndex = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> excludedAt = const Value.absent(),
                Value<String?> exclusionReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion(
                id: id,
                studyId: studyId,
                sequenceIndex: sequenceIndex,
                performedAt: performedAt,
                notes: notes,
                excludedAt: excludedAt,
                exclusionReason: exclusionReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String studyId,
                required int sequenceIndex,
                required DateTime performedAt,
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> excludedAt = const Value.absent(),
                Value<String?> exclusionReason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ObservationsCompanion.insert(
                id: id,
                studyId: studyId,
                sequenceIndex: sequenceIndex,
                performedAt: performedAt,
                notes: notes,
                excludedAt: excludedAt,
                exclusionReason: exclusionReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ObservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({studyId = false, operationInstancesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationInstancesRefs) db.operationInstances,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (studyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studyId,
                                    referencedTable:
                                        $$ObservationsTableReferences
                                            ._studyIdTable(db),
                                    referencedColumn:
                                        $$ObservationsTableReferences
                                            ._studyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationInstancesRefs)
                        await $_getPrefetchedData<
                          Observation,
                          $ObservationsTable,
                          OperationInstance
                        >(
                          currentTable: table,
                          referencedTable: $$ObservationsTableReferences
                              ._operationInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).operationInstancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.observationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservationsTable,
      Observation,
      $$ObservationsTableFilterComposer,
      $$ObservationsTableOrderingComposer,
      $$ObservationsTableAnnotationComposer,
      $$ObservationsTableCreateCompanionBuilder,
      $$ObservationsTableUpdateCompanionBuilder,
      (Observation, $$ObservationsTableReferences),
      Observation,
      PrefetchHooks Function({bool studyId, bool operationInstancesRefs})
    >;
typedef $$OperationInstancesTableCreateCompanionBuilder =
    OperationInstancesCompanion Function({
      required String id,
      required String observationId,
      required String studyOperationId,
      Value<int?> manualActualMs,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<DateTime?> excludedAt,
      Value<String?> exclusionReason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OperationInstancesTableUpdateCompanionBuilder =
    OperationInstancesCompanion Function({
      Value<String> id,
      Value<String> observationId,
      Value<String> studyOperationId,
      Value<int?> manualActualMs,
      Value<DateTime?> completedAt,
      Value<String?> notes,
      Value<DateTime?> excludedAt,
      Value<String?> exclusionReason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$OperationInstancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OperationInstancesTable,
          OperationInstance
        > {
  $$OperationInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObservationsTable _observationIdTable(_$AppDatabase db) => db
      .observations
      .createAlias('operation_instances__observation_id__observations__id');

  $$ObservationsTableProcessedTableManager get observationId {
    final $_column = $_itemColumn<String>('observation_id')!;

    final manager = $$ObservationsTableTableManager(
      $_db,
      $_db.observations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_observationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudyOperationsTable _studyOperationIdTable(_$AppDatabase db) =>
      db.studyOperations.createAlias(
        'operation_instances__study_operation_id__study_operations__id',
      );

  $$StudyOperationsTableProcessedTableManager get studyOperationId {
    final $_column = $_itemColumn<String>('study_operation_id')!;

    final manager = $$StudyOperationsTableTableManager(
      $_db,
      $_db.studyOperations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyOperationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $OperationTimeSegmentsTable,
    List<OperationTimeSegment>
  >
  _operationTimeSegmentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.operationTimeSegments,
    aliasName:
        'operation_instances__id__operation_time_segments__operation_instance_id',
  );

  $$OperationTimeSegmentsTableProcessedTableManager
  get operationTimeSegmentsRefs {
    final manager =
        $$OperationTimeSegmentsTableTableManager(
          $_db,
          $_db.operationTimeSegments,
        ).filter(
          (f) =>
              f.operationInstanceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _operationTimeSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OperationInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $OperationInstancesTable> {
  $$OperationInstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualActualMs => $composableBuilder(
    column: $table.manualActualMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ObservationsTableFilterComposer get observationId {
    final $$ObservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableFilterComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyOperationsTableFilterComposer get studyOperationId {
    final $$StudyOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyOperationId,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableFilterComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> operationTimeSegmentsRefs(
    Expression<bool> Function($$OperationTimeSegmentsTableFilterComposer f) f,
  ) {
    final $$OperationTimeSegmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.operationTimeSegments,
          getReferencedColumn: (t) => t.operationInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationTimeSegmentsTableFilterComposer(
                $db: $db,
                $table: $db.operationTimeSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OperationInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationInstancesTable> {
  $$OperationInstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualActualMs => $composableBuilder(
    column: $table.manualActualMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObservationsTableOrderingComposer get observationId {
    final $$ObservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableOrderingComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyOperationsTableOrderingComposer get studyOperationId {
    final $$StudyOperationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyOperationId,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableOrderingComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationInstancesTable> {
  $$OperationInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get manualActualMs => $composableBuilder(
    column: $table.manualActualMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get excludedAt => $composableBuilder(
    column: $table.excludedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exclusionReason => $composableBuilder(
    column: $table.exclusionReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ObservationsTableAnnotationComposer get observationId {
    final $$ObservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.observationId,
      referencedTable: $db.observations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.observations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyOperationsTableAnnotationComposer get studyOperationId {
    final $$StudyOperationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyOperationId,
      referencedTable: $db.studyOperations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyOperationsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> operationTimeSegmentsRefs<T extends Object>(
    Expression<T> Function($$OperationTimeSegmentsTableAnnotationComposer a) f,
  ) {
    final $$OperationTimeSegmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.operationTimeSegments,
          getReferencedColumn: (t) => t.operationInstanceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationTimeSegmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.operationTimeSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OperationInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationInstancesTable,
          OperationInstance,
          $$OperationInstancesTableFilterComposer,
          $$OperationInstancesTableOrderingComposer,
          $$OperationInstancesTableAnnotationComposer,
          $$OperationInstancesTableCreateCompanionBuilder,
          $$OperationInstancesTableUpdateCompanionBuilder,
          (OperationInstance, $$OperationInstancesTableReferences),
          OperationInstance,
          PrefetchHooks Function({
            bool observationId,
            bool studyOperationId,
            bool operationTimeSegmentsRefs,
          })
        > {
  $$OperationInstancesTableTableManager(
    _$AppDatabase db,
    $OperationInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OperationInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OperationInstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> observationId = const Value.absent(),
                Value<String> studyOperationId = const Value.absent(),
                Value<int?> manualActualMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> excludedAt = const Value.absent(),
                Value<String?> exclusionReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationInstancesCompanion(
                id: id,
                observationId: observationId,
                studyOperationId: studyOperationId,
                manualActualMs: manualActualMs,
                completedAt: completedAt,
                notes: notes,
                excludedAt: excludedAt,
                exclusionReason: exclusionReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String observationId,
                required String studyOperationId,
                Value<int?> manualActualMs = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> excludedAt = const Value.absent(),
                Value<String?> exclusionReason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OperationInstancesCompanion.insert(
                id: id,
                observationId: observationId,
                studyOperationId: studyOperationId,
                manualActualMs: manualActualMs,
                completedAt: completedAt,
                notes: notes,
                excludedAt: excludedAt,
                exclusionReason: exclusionReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                observationId = false,
                studyOperationId = false,
                operationTimeSegmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (operationTimeSegmentsRefs) db.operationTimeSegments,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (observationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.observationId,
                                    referencedTable:
                                        $$OperationInstancesTableReferences
                                            ._observationIdTable(db),
                                    referencedColumn:
                                        $$OperationInstancesTableReferences
                                            ._observationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (studyOperationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studyOperationId,
                                    referencedTable:
                                        $$OperationInstancesTableReferences
                                            ._studyOperationIdTable(db),
                                    referencedColumn:
                                        $$OperationInstancesTableReferences
                                            ._studyOperationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (operationTimeSegmentsRefs)
                        await $_getPrefetchedData<
                          OperationInstance,
                          $OperationInstancesTable,
                          OperationTimeSegment
                        >(
                          currentTable: table,
                          referencedTable: $$OperationInstancesTableReferences
                              ._operationTimeSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OperationInstancesTableReferences(
                                db,
                                table,
                                p0,
                              ).operationTimeSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.operationInstanceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OperationInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationInstancesTable,
      OperationInstance,
      $$OperationInstancesTableFilterComposer,
      $$OperationInstancesTableOrderingComposer,
      $$OperationInstancesTableAnnotationComposer,
      $$OperationInstancesTableCreateCompanionBuilder,
      $$OperationInstancesTableUpdateCompanionBuilder,
      (OperationInstance, $$OperationInstancesTableReferences),
      OperationInstance,
      PrefetchHooks Function({
        bool observationId,
        bool studyOperationId,
        bool operationTimeSegmentsRefs,
      })
    >;
typedef $$OperationTimeSegmentsTableCreateCompanionBuilder =
    OperationTimeSegmentsCompanion Function({
      required String id,
      required String operationInstanceId,
      required int startAtMs,
      Value<int?> endAtMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OperationTimeSegmentsTableUpdateCompanionBuilder =
    OperationTimeSegmentsCompanion Function({
      Value<String> id,
      Value<String> operationInstanceId,
      Value<int> startAtMs,
      Value<int?> endAtMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$OperationTimeSegmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OperationTimeSegmentsTable,
          OperationTimeSegment
        > {
  $$OperationTimeSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OperationInstancesTable _operationInstanceIdTable(
    _$AppDatabase db,
  ) => db.operationInstances.createAlias(
    'operation_time_segments__operation_instance_id__operation_instances__id',
  );

  $$OperationInstancesTableProcessedTableManager get operationInstanceId {
    final $_column = $_itemColumn<String>('operation_instance_id')!;

    final manager = $$OperationInstancesTableTableManager(
      $_db,
      $_db.operationInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_operationInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OperationTimeSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $OperationTimeSegmentsTable> {
  $$OperationTimeSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startAtMs => $composableBuilder(
    column: $table.startAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAtMs => $composableBuilder(
    column: $table.endAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OperationInstancesTableFilterComposer get operationInstanceId {
    final $$OperationInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationInstanceId,
      referencedTable: $db.operationInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationInstancesTableFilterComposer(
            $db: $db,
            $table: $db.operationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationTimeSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $OperationTimeSegmentsTable> {
  $$OperationTimeSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startAtMs => $composableBuilder(
    column: $table.startAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAtMs => $composableBuilder(
    column: $table.endAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OperationInstancesTableOrderingComposer get operationInstanceId {
    final $$OperationInstancesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.operationInstanceId,
      referencedTable: $db.operationInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationInstancesTableOrderingComposer(
            $db: $db,
            $table: $db.operationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OperationTimeSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OperationTimeSegmentsTable> {
  $$OperationTimeSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startAtMs =>
      $composableBuilder(column: $table.startAtMs, builder: (column) => column);

  GeneratedColumn<int> get endAtMs =>
      $composableBuilder(column: $table.endAtMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OperationInstancesTableAnnotationComposer get operationInstanceId {
    final $$OperationInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.operationInstanceId,
          referencedTable: $db.operationInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$OperationTimeSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OperationTimeSegmentsTable,
          OperationTimeSegment,
          $$OperationTimeSegmentsTableFilterComposer,
          $$OperationTimeSegmentsTableOrderingComposer,
          $$OperationTimeSegmentsTableAnnotationComposer,
          $$OperationTimeSegmentsTableCreateCompanionBuilder,
          $$OperationTimeSegmentsTableUpdateCompanionBuilder,
          (OperationTimeSegment, $$OperationTimeSegmentsTableReferences),
          OperationTimeSegment,
          PrefetchHooks Function({bool operationInstanceId})
        > {
  $$OperationTimeSegmentsTableTableManager(
    _$AppDatabase db,
    $OperationTimeSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OperationTimeSegmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OperationTimeSegmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OperationTimeSegmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationInstanceId = const Value.absent(),
                Value<int> startAtMs = const Value.absent(),
                Value<int?> endAtMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OperationTimeSegmentsCompanion(
                id: id,
                operationInstanceId: operationInstanceId,
                startAtMs: startAtMs,
                endAtMs: endAtMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationInstanceId,
                required int startAtMs,
                Value<int?> endAtMs = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OperationTimeSegmentsCompanion.insert(
                id: id,
                operationInstanceId: operationInstanceId,
                startAtMs: startAtMs,
                endAtMs: endAtMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OperationTimeSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({operationInstanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (operationInstanceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.operationInstanceId,
                                referencedTable:
                                    $$OperationTimeSegmentsTableReferences
                                        ._operationInstanceIdTable(db),
                                referencedColumn:
                                    $$OperationTimeSegmentsTableReferences
                                        ._operationInstanceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OperationTimeSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OperationTimeSegmentsTable,
      OperationTimeSegment,
      $$OperationTimeSegmentsTableFilterComposer,
      $$OperationTimeSegmentsTableOrderingComposer,
      $$OperationTimeSegmentsTableAnnotationComposer,
      $$OperationTimeSegmentsTableCreateCompanionBuilder,
      $$OperationTimeSegmentsTableUpdateCompanionBuilder,
      (OperationTimeSegment, $$OperationTimeSegmentsTableReferences),
      OperationTimeSegment,
      PrefetchHooks Function({bool operationInstanceId})
    >;
typedef $$TemplatesTableCreateCompanionBuilder =
    TemplatesCompanion Function({
      required String id,
      required String name,
      required StudyType defaultStudyType,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TemplatesTableUpdateCompanionBuilder =
    TemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<StudyType> defaultStudyType,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $TemplatesTable, Template> {
  $$TemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TemplateOperationsTable, List<TemplateOperation>>
  _templateOperationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateOperations,
        aliasName: 'templates__id__template_operations__template_id',
      );

  $$TemplateOperationsTableProcessedTableManager get templateOperationsRefs {
    final manager = $$TemplateOperationsTableTableManager(
      $_db,
      $_db.templateOperations,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateOperationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StudyType, StudyType, String>
  get defaultStudyType => $composableBuilder(
    column: $table.defaultStudyType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> templateOperationsRefs(
    Expression<bool> Function($$TemplateOperationsTableFilterComposer f) f,
  ) {
    final $$TemplateOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateOperations,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateOperationsTableFilterComposer(
            $db: $db,
            $table: $db.templateOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultStudyType => $composableBuilder(
    column: $table.defaultStudyType,
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

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<StudyType, String> get defaultStudyType =>
      $composableBuilder(
        column: $table.defaultStudyType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> templateOperationsRefs<T extends Object>(
    Expression<T> Function($$TemplateOperationsTableAnnotationComposer a) f,
  ) {
    final $$TemplateOperationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateOperations,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateOperationsTableAnnotationComposer(
                $db: $db,
                $table: $db.templateOperations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplatesTable,
          Template,
          $$TemplatesTableFilterComposer,
          $$TemplatesTableOrderingComposer,
          $$TemplatesTableAnnotationComposer,
          $$TemplatesTableCreateCompanionBuilder,
          $$TemplatesTableUpdateCompanionBuilder,
          (Template, $$TemplatesTableReferences),
          Template,
          PrefetchHooks Function({bool templateOperationsRefs})
        > {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<StudyType> defaultStudyType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplatesCompanion(
                id: id,
                name: name,
                defaultStudyType: defaultStudyType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required StudyType defaultStudyType,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TemplatesCompanion.insert(
                id: id,
                name: name,
                defaultStudyType: defaultStudyType,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateOperationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templateOperationsRefs) db.templateOperations,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templateOperationsRefs)
                    await $_getPrefetchedData<
                      Template,
                      $TemplatesTable,
                      TemplateOperation
                    >(
                      currentTable: table,
                      referencedTable: $$TemplatesTableReferences
                          ._templateOperationsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).templateOperationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplatesTable,
      Template,
      $$TemplatesTableFilterComposer,
      $$TemplatesTableOrderingComposer,
      $$TemplatesTableAnnotationComposer,
      $$TemplatesTableCreateCompanionBuilder,
      $$TemplatesTableUpdateCompanionBuilder,
      (Template, $$TemplatesTableReferences),
      Template,
      PrefetchHooks Function({bool templateOperationsRefs})
    >;
typedef $$TemplateOperationsTableCreateCompanionBuilder =
    TemplateOperationsCompanion Function({
      required String id,
      required String templateId,
      Value<String?> catalogOperationId,
      required double orderIndex,
      required String name,
      required OperationCategory category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TemplateOperationsTableUpdateCompanionBuilder =
    TemplateOperationsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String?> catalogOperationId,
      Value<double> orderIndex,
      Value<String> name,
      Value<OperationCategory> category,
      Value<String?> subtypeId,
      Value<int?> referenceStandardMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TemplateOperationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TemplateOperationsTable,
          TemplateOperation
        > {
  $$TemplateOperationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TemplatesTable _templateIdTable(_$AppDatabase db) => db.templates
      .createAlias('template_operations__template_id__templates__id');

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$TemplatesTableTableManager(
      $_db,
      $_db.templates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CatalogOperationsTable _catalogOperationIdTable(_$AppDatabase db) =>
      db.catalogOperations.createAlias(
        'template_operations__catalog_operation_id__catalog_operations__id',
      );

  $$CatalogOperationsTableProcessedTableManager? get catalogOperationId {
    final $_column = $_itemColumn<String>('catalog_operation_id');
    if ($_column == null) return null;
    final manager = $$CatalogOperationsTableTableManager(
      $_db,
      $_db.catalogOperations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_catalogOperationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OperationSubtypesTable _subtypeIdTable(_$AppDatabase db) => db
      .operationSubtypes
      .createAlias('template_operations__subtype_id__operation_subtypes__id');

  $$OperationSubtypesTableProcessedTableManager? get subtypeId {
    final $_column = $_itemColumn<String>('subtype_id');
    if ($_column == null) return null;
    final manager = $$OperationSubtypesTableTableManager(
      $_db,
      $_db.operationSubtypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateOperationsTable> {
  $$TemplateOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperationCategory, OperationCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableFilterComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogOperationsTableFilterComposer get catalogOperationId {
    final $$CatalogOperationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogOperationId,
      referencedTable: $db.catalogOperations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogOperationsTableFilterComposer(
            $db: $db,
            $table: $db.catalogOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationSubtypesTableFilterComposer get subtypeId {
    final $$OperationSubtypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableFilterComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateOperationsTable> {
  $$TemplateOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
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

  ColumnOrderings<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogOperationsTableOrderingComposer get catalogOperationId {
    final $$CatalogOperationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.catalogOperationId,
      referencedTable: $db.catalogOperations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogOperationsTableOrderingComposer(
            $db: $db,
            $table: $db.catalogOperations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OperationSubtypesTableOrderingComposer get subtypeId {
    final $$OperationSubtypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtypeId,
      referencedTable: $db.operationSubtypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OperationSubtypesTableOrderingComposer(
            $db: $db,
            $table: $db.operationSubtypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateOperationsTable> {
  $$TemplateOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OperationCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get referenceStandardMs => $composableBuilder(
    column: $table.referenceStandardMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CatalogOperationsTableAnnotationComposer get catalogOperationId {
    final $$CatalogOperationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.catalogOperationId,
          referencedTable: $db.catalogOperations,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CatalogOperationsTableAnnotationComposer(
                $db: $db,
                $table: $db.catalogOperations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$OperationSubtypesTableAnnotationComposer get subtypeId {
    final $$OperationSubtypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.subtypeId,
          referencedTable: $db.operationSubtypes,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OperationSubtypesTableAnnotationComposer(
                $db: $db,
                $table: $db.operationSubtypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TemplateOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateOperationsTable,
          TemplateOperation,
          $$TemplateOperationsTableFilterComposer,
          $$TemplateOperationsTableOrderingComposer,
          $$TemplateOperationsTableAnnotationComposer,
          $$TemplateOperationsTableCreateCompanionBuilder,
          $$TemplateOperationsTableUpdateCompanionBuilder,
          (TemplateOperation, $$TemplateOperationsTableReferences),
          TemplateOperation,
          PrefetchHooks Function({
            bool templateId,
            bool catalogOperationId,
            bool subtypeId,
          })
        > {
  $$TemplateOperationsTableTableManager(
    _$AppDatabase db,
    $TemplateOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String?> catalogOperationId = const Value.absent(),
                Value<double> orderIndex = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<OperationCategory> category = const Value.absent(),
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateOperationsCompanion(
                id: id,
                templateId: templateId,
                catalogOperationId: catalogOperationId,
                orderIndex: orderIndex,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                Value<String?> catalogOperationId = const Value.absent(),
                required double orderIndex,
                required String name,
                required OperationCategory category,
                Value<String?> subtypeId = const Value.absent(),
                Value<int?> referenceStandardMs = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TemplateOperationsCompanion.insert(
                id: id,
                templateId: templateId,
                catalogOperationId: catalogOperationId,
                orderIndex: orderIndex,
                name: name,
                category: category,
                subtypeId: subtypeId,
                referenceStandardMs: referenceStandardMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateOperationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateId = false,
                catalogOperationId = false,
                subtypeId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (templateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.templateId,
                                    referencedTable:
                                        $$TemplateOperationsTableReferences
                                            ._templateIdTable(db),
                                    referencedColumn:
                                        $$TemplateOperationsTableReferences
                                            ._templateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (catalogOperationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.catalogOperationId,
                                    referencedTable:
                                        $$TemplateOperationsTableReferences
                                            ._catalogOperationIdTable(db),
                                    referencedColumn:
                                        $$TemplateOperationsTableReferences
                                            ._catalogOperationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subtypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subtypeId,
                                    referencedTable:
                                        $$TemplateOperationsTableReferences
                                            ._subtypeIdTable(db),
                                    referencedColumn:
                                        $$TemplateOperationsTableReferences
                                            ._subtypeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TemplateOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateOperationsTable,
      TemplateOperation,
      $$TemplateOperationsTableFilterComposer,
      $$TemplateOperationsTableOrderingComposer,
      $$TemplateOperationsTableAnnotationComposer,
      $$TemplateOperationsTableCreateCompanionBuilder,
      $$TemplateOperationsTableUpdateCompanionBuilder,
      (TemplateOperation, $$TemplateOperationsTableReferences),
      TemplateOperation,
      PrefetchHooks Function({
        bool templateId,
        bool catalogOperationId,
        bool subtypeId,
      })
    >;
typedef $$ProcessTypeOptionsTableCreateCompanionBuilder =
    ProcessTypeOptionsCompanion Function({
      required String id,
      required String name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProcessTypeOptionsTableUpdateCompanionBuilder =
    ProcessTypeOptionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProcessTypeOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $ProcessTypeOptionsTable> {
  $$ProcessTypeOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProcessTypeOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProcessTypeOptionsTable> {
  $$ProcessTypeOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProcessTypeOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProcessTypeOptionsTable> {
  $$ProcessTypeOptionsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProcessTypeOptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProcessTypeOptionsTable,
          ProcessTypeOption,
          $$ProcessTypeOptionsTableFilterComposer,
          $$ProcessTypeOptionsTableOrderingComposer,
          $$ProcessTypeOptionsTableAnnotationComposer,
          $$ProcessTypeOptionsTableCreateCompanionBuilder,
          $$ProcessTypeOptionsTableUpdateCompanionBuilder,
          (
            ProcessTypeOption,
            BaseReferences<
              _$AppDatabase,
              $ProcessTypeOptionsTable,
              ProcessTypeOption
            >,
          ),
          ProcessTypeOption,
          PrefetchHooks Function()
        > {
  $$ProcessTypeOptionsTableTableManager(
    _$AppDatabase db,
    $ProcessTypeOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProcessTypeOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProcessTypeOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProcessTypeOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProcessTypeOptionsCompanion(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProcessTypeOptionsCompanion.insert(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProcessTypeOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProcessTypeOptionsTable,
      ProcessTypeOption,
      $$ProcessTypeOptionsTableFilterComposer,
      $$ProcessTypeOptionsTableOrderingComposer,
      $$ProcessTypeOptionsTableAnnotationComposer,
      $$ProcessTypeOptionsTableCreateCompanionBuilder,
      $$ProcessTypeOptionsTableUpdateCompanionBuilder,
      (
        ProcessTypeOption,
        BaseReferences<
          _$AppDatabase,
          $ProcessTypeOptionsTable,
          ProcessTypeOption
        >,
      ),
      ProcessTypeOption,
      PrefetchHooks Function()
    >;
typedef $$MediaAttachmentsTableCreateCompanionBuilder =
    MediaAttachmentsCompanion Function({
      required String id,
      required MediaOwnerType ownerType,
      required String ownerId,
      required MediaKind kind,
      required String relativePath,
      Value<String?> caption,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MediaAttachmentsTableUpdateCompanionBuilder =
    MediaAttachmentsCompanion Function({
      Value<String> id,
      Value<MediaOwnerType> ownerType,
      Value<String> ownerId,
      Value<MediaKind> kind,
      Value<String> relativePath,
      Value<String?> caption,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MediaAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaOwnerType, MediaOwnerType, String>
  get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaKind, MediaKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaAttachmentsTable> {
  $$MediaAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaOwnerType, String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MediaAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaAttachmentsTable,
          MediaAttachment,
          $$MediaAttachmentsTableFilterComposer,
          $$MediaAttachmentsTableOrderingComposer,
          $$MediaAttachmentsTableAnnotationComposer,
          $$MediaAttachmentsTableCreateCompanionBuilder,
          $$MediaAttachmentsTableUpdateCompanionBuilder,
          (
            MediaAttachment,
            BaseReferences<
              _$AppDatabase,
              $MediaAttachmentsTable,
              MediaAttachment
            >,
          ),
          MediaAttachment,
          PrefetchHooks Function()
        > {
  $$MediaAttachmentsTableTableManager(
    _$AppDatabase db,
    $MediaAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<MediaOwnerType> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<MediaKind> kind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String?> caption = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAttachmentsCompanion(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                kind: kind,
                relativePath: relativePath,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required MediaOwnerType ownerType,
                required String ownerId,
                required MediaKind kind,
                required String relativePath,
                Value<String?> caption = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaAttachmentsCompanion.insert(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                kind: kind,
                relativePath: relativePath,
                caption: caption,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaAttachmentsTable,
      MediaAttachment,
      $$MediaAttachmentsTableFilterComposer,
      $$MediaAttachmentsTableOrderingComposer,
      $$MediaAttachmentsTableAnnotationComposer,
      $$MediaAttachmentsTableCreateCompanionBuilder,
      $$MediaAttachmentsTableUpdateCompanionBuilder,
      (
        MediaAttachment,
        BaseReferences<_$AppDatabase, $MediaAttachmentsTable, MediaAttachment>,
      ),
      MediaAttachment,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String?> localeCode,
      Value<String?> defaultAnalyst,
      required TimeUnit timeUnit,
      Value<bool> alertSoundsEnabled,
      required DateTime updatedAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String?> localeCode,
      Value<String?> defaultAnalyst,
      Value<TimeUnit> timeUnit,
      Value<bool> alertSoundsEnabled,
      Value<DateTime> updatedAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultAnalyst => $composableBuilder(
    column: $table.defaultAnalyst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TimeUnit, TimeUnit, String> get timeUnit =>
      $composableBuilder(
        column: $table.timeUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get alertSoundsEnabled => $composableBuilder(
    column: $table.alertSoundsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultAnalyst => $composableBuilder(
    column: $table.defaultAnalyst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeUnit => $composableBuilder(
    column: $table.timeUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alertSoundsEnabled => $composableBuilder(
    column: $table.alertSoundsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultAnalyst => $composableBuilder(
    column: $table.defaultAnalyst,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TimeUnit, String> get timeUnit =>
      $composableBuilder(column: $table.timeUnit, builder: (column) => column);

  GeneratedColumn<bool> get alertSoundsEnabled => $composableBuilder(
    column: $table.alertSoundsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> localeCode = const Value.absent(),
                Value<String?> defaultAnalyst = const Value.absent(),
                Value<TimeUnit> timeUnit = const Value.absent(),
                Value<bool> alertSoundsEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                localeCode: localeCode,
                defaultAnalyst: defaultAnalyst,
                timeUnit: timeUnit,
                alertSoundsEnabled: alertSoundsEnabled,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> localeCode = const Value.absent(),
                Value<String?> defaultAnalyst = const Value.absent(),
                required TimeUnit timeUnit,
                Value<bool> alertSoundsEnabled = const Value.absent(),
                required DateTime updatedAt,
              }) => AppSettingsCompanion.insert(
                id: id,
                localeCode: localeCode,
                defaultAnalyst: defaultAnalyst,
                timeUnit: timeUnit,
                alertSoundsEnabled: alertSoundsEnabled,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$OperationSubtypesTableTableManager get operationSubtypes =>
      $$OperationSubtypesTableTableManager(_db, _db.operationSubtypes);
  $$CatalogOperationsTableTableManager get catalogOperations =>
      $$CatalogOperationsTableTableManager(_db, _db.catalogOperations);
  $$StudiesTableTableManager get studies =>
      $$StudiesTableTableManager(_db, _db.studies);
  $$StudyOperationsTableTableManager get studyOperations =>
      $$StudyOperationsTableTableManager(_db, _db.studyOperations);
  $$ObservationsTableTableManager get observations =>
      $$ObservationsTableTableManager(_db, _db.observations);
  $$OperationInstancesTableTableManager get operationInstances =>
      $$OperationInstancesTableTableManager(_db, _db.operationInstances);
  $$OperationTimeSegmentsTableTableManager get operationTimeSegments =>
      $$OperationTimeSegmentsTableTableManager(_db, _db.operationTimeSegments);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$TemplateOperationsTableTableManager get templateOperations =>
      $$TemplateOperationsTableTableManager(_db, _db.templateOperations);
  $$ProcessTypeOptionsTableTableManager get processTypeOptions =>
      $$ProcessTypeOptionsTableTableManager(_db, _db.processTypeOptions);
  $$MediaAttachmentsTableTableManager get mediaAttachments =>
      $$MediaAttachmentsTableTableManager(_db, _db.mediaAttachments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
