// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _feeMeta = const VerificationMeta('fee');
  @override
  late final GeneratedColumn<double> fee = GeneratedColumn<double>(
      'fee', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _feeAssetMeta =
      const VerificationMeta('feeAsset');
  @override
  late final GeneratedColumn<String> feeAsset = GeneratedColumn<String>(
      'fee_asset', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, symbol, type, quantity, price, fee, feeAsset, timestamp, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('fee')) {
      context.handle(
          _feeMeta, fee.isAcceptableOrUnknown(data['fee']!, _feeMeta));
    }
    if (data.containsKey('fee_asset')) {
      context.handle(_feeAssetMeta,
          feeAsset.isAcceptableOrUnknown(data['fee_asset']!, _feeAssetMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      fee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fee']),
      feeAsset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fee_asset']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String symbol;
  final String type;
  final double quantity;
  final double price;
  final double? fee;
  final String? feeAsset;
  final DateTime timestamp;
  final String? note;
  const Transaction(
      {required this.id,
      required this.symbol,
      required this.type,
      required this.quantity,
      required this.price,
      this.fee,
      this.feeAsset,
      required this.timestamp,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<double>(quantity);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || fee != null) {
      map['fee'] = Variable<double>(fee);
    }
    if (!nullToAbsent || feeAsset != null) {
      map['fee_asset'] = Variable<String>(feeAsset);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      type: Value(type),
      quantity: Value(quantity),
      price: Value(price),
      fee: fee == null && nullToAbsent ? const Value.absent() : Value(fee),
      feeAsset: feeAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(feeAsset),
      timestamp: Value(timestamp),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<double>(json['quantity']),
      price: serializer.fromJson<double>(json['price']),
      fee: serializer.fromJson<double?>(json['fee']),
      feeAsset: serializer.fromJson<String?>(json['feeAsset']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<double>(quantity),
      'price': serializer.toJson<double>(price),
      'fee': serializer.toJson<double?>(fee),
      'feeAsset': serializer.toJson<String?>(feeAsset),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'note': serializer.toJson<String?>(note),
    };
  }

  Transaction copyWith(
          {String? id,
          String? symbol,
          String? type,
          double? quantity,
          double? price,
          Value<double?> fee = const Value.absent(),
          Value<String?> feeAsset = const Value.absent(),
          DateTime? timestamp,
          Value<String?> note = const Value.absent()}) =>
      Transaction(
        id: id ?? this.id,
        symbol: symbol ?? this.symbol,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
        fee: fee.present ? fee.value : this.fee,
        feeAsset: feeAsset.present ? feeAsset.value : this.feeAsset,
        timestamp: timestamp ?? this.timestamp,
        note: note.present ? note.value : this.note,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      fee: data.fee.present ? data.fee.value : this.fee,
      feeAsset: data.feeAsset.present ? data.feeAsset.value : this.feeAsset,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('fee: $fee, ')
          ..write('feeAsset: $feeAsset, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, symbol, type, quantity, price, fee, feeAsset, timestamp, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.fee == this.fee &&
          other.feeAsset == this.feeAsset &&
          other.timestamp == this.timestamp &&
          other.note == this.note);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> type;
  final Value<double> quantity;
  final Value<double> price;
  final Value<double?> fee;
  final Value<String?> feeAsset;
  final Value<DateTime> timestamp;
  final Value<String?> note;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.fee = const Value.absent(),
    this.feeAsset = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String symbol,
    required String type,
    required double quantity,
    required double price,
    this.fee = const Value.absent(),
    this.feeAsset = const Value.absent(),
    required DateTime timestamp,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        type = Value(type),
        quantity = Value(quantity),
        price = Value(price),
        timestamp = Value(timestamp);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? type,
    Expression<double>? quantity,
    Expression<double>? price,
    Expression<double>? fee,
    Expression<String>? feeAsset,
    Expression<DateTime>? timestamp,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (fee != null) 'fee': fee,
      if (feeAsset != null) 'fee_asset': feeAsset,
      if (timestamp != null) 'timestamp': timestamp,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? type,
      Value<double>? quantity,
      Value<double>? price,
      Value<double?>? fee,
      Value<String?>? feeAsset,
      Value<DateTime>? timestamp,
      Value<String?>? note,
      Value<int>? rowid}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      fee: fee ?? this.fee,
      feeAsset: feeAsset ?? this.feeAsset,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (fee.present) {
      map['fee'] = Variable<double>(fee.value);
    }
    if (feeAsset.present) {
      map['fee_asset'] = Variable<String>(feeAsset.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('fee: $fee, ')
          ..write('feeAsset: $feeAsset, ')
          ..write('timestamp: $timestamp, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PortfolioDatabase extends GeneratedDatabase {
  _$PortfolioDatabase(QueryExecutor e) : super(e);
  $PortfolioDatabaseManager get managers => $PortfolioDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [transactions];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  required String id,
  required String symbol,
  required String type,
  required double quantity,
  required double price,
  Value<double?> fee,
  Value<String?> feeAsset,
  required DateTime timestamp,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> type,
  Value<double> quantity,
  Value<double> price,
  Value<double?> fee,
  Value<String?> feeAsset,
  Value<DateTime> timestamp,
  Value<String?> note,
  Value<int> rowid,
});

class $$TransactionsTableTableManager extends RootTableManager<
    _$PortfolioDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder> {
  $$TransactionsTableTableManager(
      _$PortfolioDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TransactionsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TransactionsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double?> fee = const Value.absent(),
            Value<String?> feeAsset = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            symbol: symbol,
            type: type,
            quantity: quantity,
            price: price,
            fee: fee,
            feeAsset: feeAsset,
            timestamp: timestamp,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String type,
            required double quantity,
            required double price,
            Value<double?> fee = const Value.absent(),
            Value<String?> feeAsset = const Value.absent(),
            required DateTime timestamp,
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            symbol: symbol,
            type: type,
            quantity: quantity,
            price: price,
            fee: fee,
            feeAsset: feeAsset,
            timestamp: timestamp,
            note: note,
            rowid: rowid,
          ),
        ));
}

class $$TransactionsTableFilterComposer
    extends FilterComposer<_$PortfolioDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get price => $state.composableBuilder(
      column: $state.table.price,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get fee => $state.composableBuilder(
      column: $state.table.fee,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get feeAsset => $state.composableBuilder(
      column: $state.table.feeAsset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TransactionsTableOrderingComposer
    extends OrderingComposer<_$PortfolioDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get price => $state.composableBuilder(
      column: $state.table.price,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get fee => $state.composableBuilder(
      column: $state.table.fee,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get feeAsset => $state.composableBuilder(
      column: $state.table.feeAsset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $PortfolioDatabaseManager {
  final _$PortfolioDatabase _db;
  $PortfolioDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
