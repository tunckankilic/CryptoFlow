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

class $JournalEntriesTable extends JournalEntries
    with TableInfo<$JournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryPriceMeta =
      const VerificationMeta('entryPrice');
  @override
  late final GeneratedColumn<double> entryPrice = GeneratedColumn<double>(
      'entry_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _exitPriceMeta =
      const VerificationMeta('exitPrice');
  @override
  late final GeneratedColumn<double> exitPrice = GeneratedColumn<double>(
      'exit_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _pnlMeta = const VerificationMeta('pnl');
  @override
  late final GeneratedColumn<double> pnl = GeneratedColumn<double>(
      'pnl', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pnlPercentageMeta =
      const VerificationMeta('pnlPercentage');
  @override
  late final GeneratedColumn<double> pnlPercentage = GeneratedColumn<double>(
      'pnl_percentage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _riskRewardRatioMeta =
      const VerificationMeta('riskRewardRatio');
  @override
  late final GeneratedColumn<double> riskRewardRatio = GeneratedColumn<double>(
      'risk_reward_ratio', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _strategyMeta =
      const VerificationMeta('strategy');
  @override
  late final GeneratedColumn<String> strategy = GeneratedColumn<String>(
      'strategy', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emotionMeta =
      const VerificationMeta('emotion');
  @override
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
      'emotion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _screenshotPathMeta =
      const VerificationMeta('screenshotPath');
  @override
  late final GeneratedColumn<String> screenshotPath = GeneratedColumn<String>(
      'screenshot_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entryDateMeta =
      const VerificationMeta('entryDate');
  @override
  late final GeneratedColumn<DateTime> entryDate = GeneratedColumn<DateTime>(
      'entry_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _exitDateMeta =
      const VerificationMeta('exitDate');
  @override
  late final GeneratedColumn<DateTime> exitDate = GeneratedColumn<DateTime>(
      'exit_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        symbol,
        side,
        entryPrice,
        exitPrice,
        quantity,
        pnl,
        pnlPercentage,
        riskRewardRatio,
        strategy,
        emotion,
        notes,
        tags,
        screenshotPath,
        entryDate,
        exitDate,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(Insertable<JournalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('entry_price')) {
      context.handle(
          _entryPriceMeta,
          entryPrice.isAcceptableOrUnknown(
              data['entry_price']!, _entryPriceMeta));
    } else if (isInserting) {
      context.missing(_entryPriceMeta);
    }
    if (data.containsKey('exit_price')) {
      context.handle(_exitPriceMeta,
          exitPrice.isAcceptableOrUnknown(data['exit_price']!, _exitPriceMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('pnl')) {
      context.handle(
          _pnlMeta, pnl.isAcceptableOrUnknown(data['pnl']!, _pnlMeta));
    }
    if (data.containsKey('pnl_percentage')) {
      context.handle(
          _pnlPercentageMeta,
          pnlPercentage.isAcceptableOrUnknown(
              data['pnl_percentage']!, _pnlPercentageMeta));
    }
    if (data.containsKey('risk_reward_ratio')) {
      context.handle(
          _riskRewardRatioMeta,
          riskRewardRatio.isAcceptableOrUnknown(
              data['risk_reward_ratio']!, _riskRewardRatioMeta));
    }
    if (data.containsKey('strategy')) {
      context.handle(_strategyMeta,
          strategy.isAcceptableOrUnknown(data['strategy']!, _strategyMeta));
    }
    if (data.containsKey('emotion')) {
      context.handle(_emotionMeta,
          emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta));
    } else if (isInserting) {
      context.missing(_emotionMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('screenshot_path')) {
      context.handle(
          _screenshotPathMeta,
          screenshotPath.isAcceptableOrUnknown(
              data['screenshot_path']!, _screenshotPathMeta));
    }
    if (data.containsKey('entry_date')) {
      context.handle(_entryDateMeta,
          entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta));
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('exit_date')) {
      context.handle(_exitDateMeta,
          exitDate.isAcceptableOrUnknown(data['exit_date']!, _exitDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id']),
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side'])!,
      entryPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}entry_price'])!,
      exitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}exit_price']),
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      pnl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pnl']),
      pnlPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pnl_percentage']),
      riskRewardRatio: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}risk_reward_ratio']),
      strategy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strategy']),
      emotion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emotion'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      screenshotPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}screenshot_path']),
      entryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}entry_date'])!,
      exitDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}exit_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $JournalEntriesTable createAlias(String alias) {
    return $JournalEntriesTable(attachedDatabase, alias);
  }
}

class JournalEntry extends DataClass implements Insertable<JournalEntry> {
  /// Unique identifier (auto-generated)
  final int id;

  /// Optional reference to transaction in transactions table
  final String? transactionId;

  /// Trading symbol (e.g., "BTCUSDT")
  final String symbol;

  /// Trade side: "long" or "short"
  final String side;

  /// Entry price
  final double entryPrice;

  /// Exit price (nullable for open positions)
  final double? exitPrice;

  /// Quantity traded
  final double quantity;

  /// Profit/Loss (calculated)
  final double? pnl;

  /// P&L as percentage
  final double? pnlPercentage;

  /// Risk/Reward ratio
  final double? riskRewardRatio;

  /// Strategy name (e.g., "breakout", "support bounce")
  final String? strategy;

  /// Emotional state during trade
  /// Values: "confident", "neutral", "fearful", "greedy", "fomo", "revenge"
  final String emotion;

  /// Trade notes/description
  final String? notes;

  /// Tags as JSON array string (e.g., '["swing", "scalp", "news"]')
  final String tags;

  /// Local file path to chart screenshot
  final String? screenshotPath;

  /// Entry date/time
  final DateTime entryDate;

  /// Exit date/time (nullable for open positions)
  final DateTime? exitDate;

  /// Record creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;
  const JournalEntry(
      {required this.id,
      this.transactionId,
      required this.symbol,
      required this.side,
      required this.entryPrice,
      this.exitPrice,
      required this.quantity,
      this.pnl,
      this.pnlPercentage,
      this.riskRewardRatio,
      this.strategy,
      required this.emotion,
      this.notes,
      required this.tags,
      this.screenshotPath,
      required this.entryDate,
      this.exitDate,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    map['symbol'] = Variable<String>(symbol);
    map['side'] = Variable<String>(side);
    map['entry_price'] = Variable<double>(entryPrice);
    if (!nullToAbsent || exitPrice != null) {
      map['exit_price'] = Variable<double>(exitPrice);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || pnl != null) {
      map['pnl'] = Variable<double>(pnl);
    }
    if (!nullToAbsent || pnlPercentage != null) {
      map['pnl_percentage'] = Variable<double>(pnlPercentage);
    }
    if (!nullToAbsent || riskRewardRatio != null) {
      map['risk_reward_ratio'] = Variable<double>(riskRewardRatio);
    }
    if (!nullToAbsent || strategy != null) {
      map['strategy'] = Variable<String>(strategy);
    }
    map['emotion'] = Variable<String>(emotion);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || screenshotPath != null) {
      map['screenshot_path'] = Variable<String>(screenshotPath);
    }
    map['entry_date'] = Variable<DateTime>(entryDate);
    if (!nullToAbsent || exitDate != null) {
      map['exit_date'] = Variable<DateTime>(exitDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JournalEntriesCompanion toCompanion(bool nullToAbsent) {
    return JournalEntriesCompanion(
      id: Value(id),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      symbol: Value(symbol),
      side: Value(side),
      entryPrice: Value(entryPrice),
      exitPrice: exitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(exitPrice),
      quantity: Value(quantity),
      pnl: pnl == null && nullToAbsent ? const Value.absent() : Value(pnl),
      pnlPercentage: pnlPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(pnlPercentage),
      riskRewardRatio: riskRewardRatio == null && nullToAbsent
          ? const Value.absent()
          : Value(riskRewardRatio),
      strategy: strategy == null && nullToAbsent
          ? const Value.absent()
          : Value(strategy),
      emotion: Value(emotion),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      tags: Value(tags),
      screenshotPath: screenshotPath == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotPath),
      entryDate: Value(entryDate),
      exitDate: exitDate == null && nullToAbsent
          ? const Value.absent()
          : Value(exitDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalEntry(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      side: serializer.fromJson<String>(json['side']),
      entryPrice: serializer.fromJson<double>(json['entryPrice']),
      exitPrice: serializer.fromJson<double?>(json['exitPrice']),
      quantity: serializer.fromJson<double>(json['quantity']),
      pnl: serializer.fromJson<double?>(json['pnl']),
      pnlPercentage: serializer.fromJson<double?>(json['pnlPercentage']),
      riskRewardRatio: serializer.fromJson<double?>(json['riskRewardRatio']),
      strategy: serializer.fromJson<String?>(json['strategy']),
      emotion: serializer.fromJson<String>(json['emotion']),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      screenshotPath: serializer.fromJson<String?>(json['screenshotPath']),
      entryDate: serializer.fromJson<DateTime>(json['entryDate']),
      exitDate: serializer.fromJson<DateTime?>(json['exitDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String?>(transactionId),
      'symbol': serializer.toJson<String>(symbol),
      'side': serializer.toJson<String>(side),
      'entryPrice': serializer.toJson<double>(entryPrice),
      'exitPrice': serializer.toJson<double?>(exitPrice),
      'quantity': serializer.toJson<double>(quantity),
      'pnl': serializer.toJson<double?>(pnl),
      'pnlPercentage': serializer.toJson<double?>(pnlPercentage),
      'riskRewardRatio': serializer.toJson<double?>(riskRewardRatio),
      'strategy': serializer.toJson<String?>(strategy),
      'emotion': serializer.toJson<String>(emotion),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String>(tags),
      'screenshotPath': serializer.toJson<String?>(screenshotPath),
      'entryDate': serializer.toJson<DateTime>(entryDate),
      'exitDate': serializer.toJson<DateTime?>(exitDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JournalEntry copyWith(
          {int? id,
          Value<String?> transactionId = const Value.absent(),
          String? symbol,
          String? side,
          double? entryPrice,
          Value<double?> exitPrice = const Value.absent(),
          double? quantity,
          Value<double?> pnl = const Value.absent(),
          Value<double?> pnlPercentage = const Value.absent(),
          Value<double?> riskRewardRatio = const Value.absent(),
          Value<String?> strategy = const Value.absent(),
          String? emotion,
          Value<String?> notes = const Value.absent(),
          String? tags,
          Value<String?> screenshotPath = const Value.absent(),
          DateTime? entryDate,
          Value<DateTime?> exitDate = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      JournalEntry(
        id: id ?? this.id,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        symbol: symbol ?? this.symbol,
        side: side ?? this.side,
        entryPrice: entryPrice ?? this.entryPrice,
        exitPrice: exitPrice.present ? exitPrice.value : this.exitPrice,
        quantity: quantity ?? this.quantity,
        pnl: pnl.present ? pnl.value : this.pnl,
        pnlPercentage:
            pnlPercentage.present ? pnlPercentage.value : this.pnlPercentage,
        riskRewardRatio: riskRewardRatio.present
            ? riskRewardRatio.value
            : this.riskRewardRatio,
        strategy: strategy.present ? strategy.value : this.strategy,
        emotion: emotion ?? this.emotion,
        notes: notes.present ? notes.value : this.notes,
        tags: tags ?? this.tags,
        screenshotPath:
            screenshotPath.present ? screenshotPath.value : this.screenshotPath,
        entryDate: entryDate ?? this.entryDate,
        exitDate: exitDate.present ? exitDate.value : this.exitDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  JournalEntry copyWithCompanion(JournalEntriesCompanion data) {
    return JournalEntry(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      side: data.side.present ? data.side.value : this.side,
      entryPrice:
          data.entryPrice.present ? data.entryPrice.value : this.entryPrice,
      exitPrice: data.exitPrice.present ? data.exitPrice.value : this.exitPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      pnl: data.pnl.present ? data.pnl.value : this.pnl,
      pnlPercentage: data.pnlPercentage.present
          ? data.pnlPercentage.value
          : this.pnlPercentage,
      riskRewardRatio: data.riskRewardRatio.present
          ? data.riskRewardRatio.value
          : this.riskRewardRatio,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      screenshotPath: data.screenshotPath.present
          ? data.screenshotPath.value
          : this.screenshotPath,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      exitDate: data.exitDate.present ? data.exitDate.value : this.exitDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntry(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('pnl: $pnl, ')
          ..write('pnlPercentage: $pnlPercentage, ')
          ..write('riskRewardRatio: $riskRewardRatio, ')
          ..write('strategy: $strategy, ')
          ..write('emotion: $emotion, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      symbol,
      side,
      entryPrice,
      exitPrice,
      quantity,
      pnl,
      pnlPercentage,
      riskRewardRatio,
      strategy,
      emotion,
      notes,
      tags,
      screenshotPath,
      entryDate,
      exitDate,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalEntry &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.symbol == this.symbol &&
          other.side == this.side &&
          other.entryPrice == this.entryPrice &&
          other.exitPrice == this.exitPrice &&
          other.quantity == this.quantity &&
          other.pnl == this.pnl &&
          other.pnlPercentage == this.pnlPercentage &&
          other.riskRewardRatio == this.riskRewardRatio &&
          other.strategy == this.strategy &&
          other.emotion == this.emotion &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.screenshotPath == this.screenshotPath &&
          other.entryDate == this.entryDate &&
          other.exitDate == this.exitDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String?> transactionId;
  final Value<String> symbol;
  final Value<String> side;
  final Value<double> entryPrice;
  final Value<double?> exitPrice;
  final Value<double> quantity;
  final Value<double?> pnl;
  final Value<double?> pnlPercentage;
  final Value<double?> riskRewardRatio;
  final Value<String?> strategy;
  final Value<String> emotion;
  final Value<String?> notes;
  final Value<String> tags;
  final Value<String?> screenshotPath;
  final Value<DateTime> entryDate;
  final Value<DateTime?> exitDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const JournalEntriesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.side = const Value.absent(),
    this.entryPrice = const Value.absent(),
    this.exitPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.pnl = const Value.absent(),
    this.pnlPercentage = const Value.absent(),
    this.riskRewardRatio = const Value.absent(),
    this.strategy = const Value.absent(),
    this.emotion = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.screenshotPath = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  JournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    required String symbol,
    required String side,
    required double entryPrice,
    this.exitPrice = const Value.absent(),
    required double quantity,
    this.pnl = const Value.absent(),
    this.pnlPercentage = const Value.absent(),
    this.riskRewardRatio = const Value.absent(),
    this.strategy = const Value.absent(),
    required String emotion,
    this.notes = const Value.absent(),
    required String tags,
    this.screenshotPath = const Value.absent(),
    required DateTime entryDate,
    this.exitDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : symbol = Value(symbol),
        side = Value(side),
        entryPrice = Value(entryPrice),
        quantity = Value(quantity),
        emotion = Value(emotion),
        tags = Value(tags),
        entryDate = Value(entryDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<String>? symbol,
    Expression<String>? side,
    Expression<double>? entryPrice,
    Expression<double>? exitPrice,
    Expression<double>? quantity,
    Expression<double>? pnl,
    Expression<double>? pnlPercentage,
    Expression<double>? riskRewardRatio,
    Expression<String>? strategy,
    Expression<String>? emotion,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<String>? screenshotPath,
    Expression<DateTime>? entryDate,
    Expression<DateTime>? exitDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (symbol != null) 'symbol': symbol,
      if (side != null) 'side': side,
      if (entryPrice != null) 'entry_price': entryPrice,
      if (exitPrice != null) 'exit_price': exitPrice,
      if (quantity != null) 'quantity': quantity,
      if (pnl != null) 'pnl': pnl,
      if (pnlPercentage != null) 'pnl_percentage': pnlPercentage,
      if (riskRewardRatio != null) 'risk_reward_ratio': riskRewardRatio,
      if (strategy != null) 'strategy': strategy,
      if (emotion != null) 'emotion': emotion,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (screenshotPath != null) 'screenshot_path': screenshotPath,
      if (entryDate != null) 'entry_date': entryDate,
      if (exitDate != null) 'exit_date': exitDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  JournalEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String?>? transactionId,
      Value<String>? symbol,
      Value<String>? side,
      Value<double>? entryPrice,
      Value<double?>? exitPrice,
      Value<double>? quantity,
      Value<double?>? pnl,
      Value<double?>? pnlPercentage,
      Value<double?>? riskRewardRatio,
      Value<String?>? strategy,
      Value<String>? emotion,
      Value<String?>? notes,
      Value<String>? tags,
      Value<String?>? screenshotPath,
      Value<DateTime>? entryDate,
      Value<DateTime?>? exitDate,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return JournalEntriesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      quantity: quantity ?? this.quantity,
      pnl: pnl ?? this.pnl,
      pnlPercentage: pnlPercentage ?? this.pnlPercentage,
      riskRewardRatio: riskRewardRatio ?? this.riskRewardRatio,
      strategy: strategy ?? this.strategy,
      emotion: emotion ?? this.emotion,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (entryPrice.present) {
      map['entry_price'] = Variable<double>(entryPrice.value);
    }
    if (exitPrice.present) {
      map['exit_price'] = Variable<double>(exitPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (pnl.present) {
      map['pnl'] = Variable<double>(pnl.value);
    }
    if (pnlPercentage.present) {
      map['pnl_percentage'] = Variable<double>(pnlPercentage.value);
    }
    if (riskRewardRatio.present) {
      map['risk_reward_ratio'] = Variable<double>(riskRewardRatio.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(strategy.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (screenshotPath.present) {
      map['screenshot_path'] = Variable<String>(screenshotPath.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<DateTime>(entryDate.value);
    }
    if (exitDate.present) {
      map['exit_date'] = Variable<DateTime>(exitDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('entryPrice: $entryPrice, ')
          ..write('exitPrice: $exitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('pnl: $pnl, ')
          ..write('pnlPercentage: $pnlPercentage, ')
          ..write('riskRewardRatio: $riskRewardRatio, ')
          ..write('strategy: $strategy, ')
          ..write('emotion: $emotion, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $JournalTagsTable extends JournalTags
    with TableInfo<$JournalTagsTable, JournalTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JournalTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _usageCountMeta =
      const VerificationMeta('usageCount');
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
      'usage_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, name, color, usageCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_tags';
  @override
  VerificationContext validateIntegrity(Insertable<JournalTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
          _usageCountMeta,
          usageCount.isAcceptableOrUnknown(
              data['usage_count']!, _usageCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      usageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}usage_count'])!,
    );
  }

  @override
  $JournalTagsTable createAlias(String alias) {
    return $JournalTagsTable(attachedDatabase, alias);
  }
}

class JournalTag extends DataClass implements Insertable<JournalTag> {
  /// Unique identifier (auto-generated)
  final int id;

  /// Tag name (unique)
  final String name;

  /// Color value for UI display
  final int color;

  /// Number of times this tag has been used
  final int usageCount;
  const JournalTag(
      {required this.id,
      required this.name,
      required this.color,
      required this.usageCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['usage_count'] = Variable<int>(usageCount);
    return map;
  }

  JournalTagsCompanion toCompanion(bool nullToAbsent) {
    return JournalTagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      usageCount: Value(usageCount),
    );
  }

  factory JournalTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JournalTag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'usageCount': serializer.toJson<int>(usageCount),
    };
  }

  JournalTag copyWith({int? id, String? name, int? color, int? usageCount}) =>
      JournalTag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        usageCount: usageCount ?? this.usageCount,
      );
  JournalTag copyWithCompanion(JournalTagsCompanion data) {
    return JournalTag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      usageCount:
          data.usageCount.present ? data.usageCount.value : this.usageCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JournalTag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('usageCount: $usageCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, usageCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JournalTag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.usageCount == this.usageCount);
}

class JournalTagsCompanion extends UpdateCompanion<JournalTag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> usageCount;
  const JournalTagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.usageCount = const Value.absent(),
  });
  JournalTagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
    this.usageCount = const Value.absent(),
  })  : name = Value(name),
        color = Value(color);
  static Insertable<JournalTag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? usageCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (usageCount != null) 'usage_count': usageCount,
    });
  }

  JournalTagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? color,
      Value<int>? usageCount}) {
    return JournalTagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JournalTagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('usageCount: $usageCount')
          ..write(')'))
        .toString();
  }
}

class $TradingStatsTable extends TradingStats
    with TableInfo<$TradingStatsTable, TradingStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradingStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
      'period', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
      'period_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _totalTradesMeta =
      const VerificationMeta('totalTrades');
  @override
  late final GeneratedColumn<int> totalTrades = GeneratedColumn<int>(
      'total_trades', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _winCountMeta =
      const VerificationMeta('winCount');
  @override
  late final GeneratedColumn<int> winCount = GeneratedColumn<int>(
      'win_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lossCountMeta =
      const VerificationMeta('lossCount');
  @override
  late final GeneratedColumn<int> lossCount = GeneratedColumn<int>(
      'loss_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _winRateMeta =
      const VerificationMeta('winRate');
  @override
  late final GeneratedColumn<double> winRate = GeneratedColumn<double>(
      'win_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalPnlMeta =
      const VerificationMeta('totalPnl');
  @override
  late final GeneratedColumn<double> totalPnl = GeneratedColumn<double>(
      'total_pnl', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _averageRRMeta =
      const VerificationMeta('averageRR');
  @override
  late final GeneratedColumn<double> averageRR = GeneratedColumn<double>(
      'average_r_r', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _largestWinMeta =
      const VerificationMeta('largestWin');
  @override
  late final GeneratedColumn<double> largestWin = GeneratedColumn<double>(
      'largest_win', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _largestLossMeta =
      const VerificationMeta('largestLoss');
  @override
  late final GeneratedColumn<double> largestLoss = GeneratedColumn<double>(
      'largest_loss', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _profitFactorMeta =
      const VerificationMeta('profitFactor');
  @override
  late final GeneratedColumn<double> profitFactor = GeneratedColumn<double>(
      'profit_factor', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        period,
        periodStart,
        periodEnd,
        totalTrades,
        winCount,
        lossCount,
        winRate,
        totalPnl,
        averageRR,
        largestWin,
        largestLoss,
        profitFactor,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trading_stats';
  @override
  VerificationContext validateIntegrity(Insertable<TradingStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period')) {
      context.handle(_periodMeta,
          period.isAcceptableOrUnknown(data['period']!, _periodMeta));
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('total_trades')) {
      context.handle(
          _totalTradesMeta,
          totalTrades.isAcceptableOrUnknown(
              data['total_trades']!, _totalTradesMeta));
    } else if (isInserting) {
      context.missing(_totalTradesMeta);
    }
    if (data.containsKey('win_count')) {
      context.handle(_winCountMeta,
          winCount.isAcceptableOrUnknown(data['win_count']!, _winCountMeta));
    } else if (isInserting) {
      context.missing(_winCountMeta);
    }
    if (data.containsKey('loss_count')) {
      context.handle(_lossCountMeta,
          lossCount.isAcceptableOrUnknown(data['loss_count']!, _lossCountMeta));
    } else if (isInserting) {
      context.missing(_lossCountMeta);
    }
    if (data.containsKey('win_rate')) {
      context.handle(_winRateMeta,
          winRate.isAcceptableOrUnknown(data['win_rate']!, _winRateMeta));
    } else if (isInserting) {
      context.missing(_winRateMeta);
    }
    if (data.containsKey('total_pnl')) {
      context.handle(_totalPnlMeta,
          totalPnl.isAcceptableOrUnknown(data['total_pnl']!, _totalPnlMeta));
    } else if (isInserting) {
      context.missing(_totalPnlMeta);
    }
    if (data.containsKey('average_r_r')) {
      context.handle(
          _averageRRMeta,
          averageRR.isAcceptableOrUnknown(
              data['average_r_r']!, _averageRRMeta));
    } else if (isInserting) {
      context.missing(_averageRRMeta);
    }
    if (data.containsKey('largest_win')) {
      context.handle(
          _largestWinMeta,
          largestWin.isAcceptableOrUnknown(
              data['largest_win']!, _largestWinMeta));
    } else if (isInserting) {
      context.missing(_largestWinMeta);
    }
    if (data.containsKey('largest_loss')) {
      context.handle(
          _largestLossMeta,
          largestLoss.isAcceptableOrUnknown(
              data['largest_loss']!, _largestLossMeta));
    } else if (isInserting) {
      context.missing(_largestLossMeta);
    }
    if (data.containsKey('profit_factor')) {
      context.handle(
          _profitFactorMeta,
          profitFactor.isAcceptableOrUnknown(
              data['profit_factor']!, _profitFactorMeta));
    } else if (isInserting) {
      context.missing(_profitFactorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradingStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradingStat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      period: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end'])!,
      totalTrades: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_trades'])!,
      winCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}win_count'])!,
      lossCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}loss_count'])!,
      winRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}win_rate'])!,
      totalPnl: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_pnl'])!,
      averageRR: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}average_r_r'])!,
      largestWin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}largest_win'])!,
      largestLoss: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}largest_loss'])!,
      profitFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}profit_factor'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TradingStatsTable createAlias(String alias) {
    return $TradingStatsTable(attachedDatabase, alias);
  }
}

class TradingStat extends DataClass implements Insertable<TradingStat> {
  /// Unique identifier (auto-generated)
  final int id;

  /// Time period: "daily", "weekly", "monthly", "allTime"
  final String period;

  /// Period start date
  final DateTime periodStart;

  /// Period end date
  final DateTime periodEnd;

  /// Total number of trades
  final int totalTrades;

  /// Number of winning trades
  final int winCount;

  /// Number of losing trades
  final int lossCount;

  /// Win rate as percentage
  final double winRate;

  /// Total profit/loss
  final double totalPnl;

  /// Average risk/reward ratio
  final double averageRR;

  /// Largest winning trade
  final double largestWin;

  /// Largest losing trade
  final double largestLoss;

  /// Profit factor (gross profit / gross loss)
  final double profitFactor;

  /// Last update timestamp
  final DateTime updatedAt;
  const TradingStat(
      {required this.id,
      required this.period,
      required this.periodStart,
      required this.periodEnd,
      required this.totalTrades,
      required this.winCount,
      required this.lossCount,
      required this.winRate,
      required this.totalPnl,
      required this.averageRR,
      required this.largestWin,
      required this.largestLoss,
      required this.profitFactor,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period'] = Variable<String>(period);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['total_trades'] = Variable<int>(totalTrades);
    map['win_count'] = Variable<int>(winCount);
    map['loss_count'] = Variable<int>(lossCount);
    map['win_rate'] = Variable<double>(winRate);
    map['total_pnl'] = Variable<double>(totalPnl);
    map['average_r_r'] = Variable<double>(averageRR);
    map['largest_win'] = Variable<double>(largestWin);
    map['largest_loss'] = Variable<double>(largestLoss);
    map['profit_factor'] = Variable<double>(profitFactor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TradingStatsCompanion toCompanion(bool nullToAbsent) {
    return TradingStatsCompanion(
      id: Value(id),
      period: Value(period),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      totalTrades: Value(totalTrades),
      winCount: Value(winCount),
      lossCount: Value(lossCount),
      winRate: Value(winRate),
      totalPnl: Value(totalPnl),
      averageRR: Value(averageRR),
      largestWin: Value(largestWin),
      largestLoss: Value(largestLoss),
      profitFactor: Value(profitFactor),
      updatedAt: Value(updatedAt),
    );
  }

  factory TradingStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradingStat(
      id: serializer.fromJson<int>(json['id']),
      period: serializer.fromJson<String>(json['period']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      totalTrades: serializer.fromJson<int>(json['totalTrades']),
      winCount: serializer.fromJson<int>(json['winCount']),
      lossCount: serializer.fromJson<int>(json['lossCount']),
      winRate: serializer.fromJson<double>(json['winRate']),
      totalPnl: serializer.fromJson<double>(json['totalPnl']),
      averageRR: serializer.fromJson<double>(json['averageRR']),
      largestWin: serializer.fromJson<double>(json['largestWin']),
      largestLoss: serializer.fromJson<double>(json['largestLoss']),
      profitFactor: serializer.fromJson<double>(json['profitFactor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'period': serializer.toJson<String>(period),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'totalTrades': serializer.toJson<int>(totalTrades),
      'winCount': serializer.toJson<int>(winCount),
      'lossCount': serializer.toJson<int>(lossCount),
      'winRate': serializer.toJson<double>(winRate),
      'totalPnl': serializer.toJson<double>(totalPnl),
      'averageRR': serializer.toJson<double>(averageRR),
      'largestWin': serializer.toJson<double>(largestWin),
      'largestLoss': serializer.toJson<double>(largestLoss),
      'profitFactor': serializer.toJson<double>(profitFactor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TradingStat copyWith(
          {int? id,
          String? period,
          DateTime? periodStart,
          DateTime? periodEnd,
          int? totalTrades,
          int? winCount,
          int? lossCount,
          double? winRate,
          double? totalPnl,
          double? averageRR,
          double? largestWin,
          double? largestLoss,
          double? profitFactor,
          DateTime? updatedAt}) =>
      TradingStat(
        id: id ?? this.id,
        period: period ?? this.period,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        totalTrades: totalTrades ?? this.totalTrades,
        winCount: winCount ?? this.winCount,
        lossCount: lossCount ?? this.lossCount,
        winRate: winRate ?? this.winRate,
        totalPnl: totalPnl ?? this.totalPnl,
        averageRR: averageRR ?? this.averageRR,
        largestWin: largestWin ?? this.largestWin,
        largestLoss: largestLoss ?? this.largestLoss,
        profitFactor: profitFactor ?? this.profitFactor,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  TradingStat copyWithCompanion(TradingStatsCompanion data) {
    return TradingStat(
      id: data.id.present ? data.id.value : this.id,
      period: data.period.present ? data.period.value : this.period,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      totalTrades:
          data.totalTrades.present ? data.totalTrades.value : this.totalTrades,
      winCount: data.winCount.present ? data.winCount.value : this.winCount,
      lossCount: data.lossCount.present ? data.lossCount.value : this.lossCount,
      winRate: data.winRate.present ? data.winRate.value : this.winRate,
      totalPnl: data.totalPnl.present ? data.totalPnl.value : this.totalPnl,
      averageRR: data.averageRR.present ? data.averageRR.value : this.averageRR,
      largestWin:
          data.largestWin.present ? data.largestWin.value : this.largestWin,
      largestLoss:
          data.largestLoss.present ? data.largestLoss.value : this.largestLoss,
      profitFactor: data.profitFactor.present
          ? data.profitFactor.value
          : this.profitFactor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradingStat(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('totalTrades: $totalTrades, ')
          ..write('winCount: $winCount, ')
          ..write('lossCount: $lossCount, ')
          ..write('winRate: $winRate, ')
          ..write('totalPnl: $totalPnl, ')
          ..write('averageRR: $averageRR, ')
          ..write('largestWin: $largestWin, ')
          ..write('largestLoss: $largestLoss, ')
          ..write('profitFactor: $profitFactor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      period,
      periodStart,
      periodEnd,
      totalTrades,
      winCount,
      lossCount,
      winRate,
      totalPnl,
      averageRR,
      largestWin,
      largestLoss,
      profitFactor,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradingStat &&
          other.id == this.id &&
          other.period == this.period &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.totalTrades == this.totalTrades &&
          other.winCount == this.winCount &&
          other.lossCount == this.lossCount &&
          other.winRate == this.winRate &&
          other.totalPnl == this.totalPnl &&
          other.averageRR == this.averageRR &&
          other.largestWin == this.largestWin &&
          other.largestLoss == this.largestLoss &&
          other.profitFactor == this.profitFactor &&
          other.updatedAt == this.updatedAt);
}

class TradingStatsCompanion extends UpdateCompanion<TradingStat> {
  final Value<int> id;
  final Value<String> period;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<int> totalTrades;
  final Value<int> winCount;
  final Value<int> lossCount;
  final Value<double> winRate;
  final Value<double> totalPnl;
  final Value<double> averageRR;
  final Value<double> largestWin;
  final Value<double> largestLoss;
  final Value<double> profitFactor;
  final Value<DateTime> updatedAt;
  const TradingStatsCompanion({
    this.id = const Value.absent(),
    this.period = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.totalTrades = const Value.absent(),
    this.winCount = const Value.absent(),
    this.lossCount = const Value.absent(),
    this.winRate = const Value.absent(),
    this.totalPnl = const Value.absent(),
    this.averageRR = const Value.absent(),
    this.largestWin = const Value.absent(),
    this.largestLoss = const Value.absent(),
    this.profitFactor = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TradingStatsCompanion.insert({
    this.id = const Value.absent(),
    required String period,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int totalTrades,
    required int winCount,
    required int lossCount,
    required double winRate,
    required double totalPnl,
    required double averageRR,
    required double largestWin,
    required double largestLoss,
    required double profitFactor,
    required DateTime updatedAt,
  })  : period = Value(period),
        periodStart = Value(periodStart),
        periodEnd = Value(periodEnd),
        totalTrades = Value(totalTrades),
        winCount = Value(winCount),
        lossCount = Value(lossCount),
        winRate = Value(winRate),
        totalPnl = Value(totalPnl),
        averageRR = Value(averageRR),
        largestWin = Value(largestWin),
        largestLoss = Value(largestLoss),
        profitFactor = Value(profitFactor),
        updatedAt = Value(updatedAt);
  static Insertable<TradingStat> custom({
    Expression<int>? id,
    Expression<String>? period,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? totalTrades,
    Expression<int>? winCount,
    Expression<int>? lossCount,
    Expression<double>? winRate,
    Expression<double>? totalPnl,
    Expression<double>? averageRR,
    Expression<double>? largestWin,
    Expression<double>? largestLoss,
    Expression<double>? profitFactor,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (period != null) 'period': period,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (totalTrades != null) 'total_trades': totalTrades,
      if (winCount != null) 'win_count': winCount,
      if (lossCount != null) 'loss_count': lossCount,
      if (winRate != null) 'win_rate': winRate,
      if (totalPnl != null) 'total_pnl': totalPnl,
      if (averageRR != null) 'average_r_r': averageRR,
      if (largestWin != null) 'largest_win': largestWin,
      if (largestLoss != null) 'largest_loss': largestLoss,
      if (profitFactor != null) 'profit_factor': profitFactor,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TradingStatsCompanion copyWith(
      {Value<int>? id,
      Value<String>? period,
      Value<DateTime>? periodStart,
      Value<DateTime>? periodEnd,
      Value<int>? totalTrades,
      Value<int>? winCount,
      Value<int>? lossCount,
      Value<double>? winRate,
      Value<double>? totalPnl,
      Value<double>? averageRR,
      Value<double>? largestWin,
      Value<double>? largestLoss,
      Value<double>? profitFactor,
      Value<DateTime>? updatedAt}) {
    return TradingStatsCompanion(
      id: id ?? this.id,
      period: period ?? this.period,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      totalTrades: totalTrades ?? this.totalTrades,
      winCount: winCount ?? this.winCount,
      lossCount: lossCount ?? this.lossCount,
      winRate: winRate ?? this.winRate,
      totalPnl: totalPnl ?? this.totalPnl,
      averageRR: averageRR ?? this.averageRR,
      largestWin: largestWin ?? this.largestWin,
      largestLoss: largestLoss ?? this.largestLoss,
      profitFactor: profitFactor ?? this.profitFactor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (totalTrades.present) {
      map['total_trades'] = Variable<int>(totalTrades.value);
    }
    if (winCount.present) {
      map['win_count'] = Variable<int>(winCount.value);
    }
    if (lossCount.present) {
      map['loss_count'] = Variable<int>(lossCount.value);
    }
    if (winRate.present) {
      map['win_rate'] = Variable<double>(winRate.value);
    }
    if (totalPnl.present) {
      map['total_pnl'] = Variable<double>(totalPnl.value);
    }
    if (averageRR.present) {
      map['average_r_r'] = Variable<double>(averageRR.value);
    }
    if (largestWin.present) {
      map['largest_win'] = Variable<double>(largestWin.value);
    }
    if (largestLoss.present) {
      map['largest_loss'] = Variable<double>(largestLoss.value);
    }
    if (profitFactor.present) {
      map['profit_factor'] = Variable<double>(profitFactor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradingStatsCompanion(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('totalTrades: $totalTrades, ')
          ..write('winCount: $winCount, ')
          ..write('lossCount: $lossCount, ')
          ..write('winRate: $winRate, ')
          ..write('totalPnl: $totalPnl, ')
          ..write('averageRR: $averageRR, ')
          ..write('largestWin: $largestWin, ')
          ..write('largestLoss: $largestLoss, ')
          ..write('profitFactor: $profitFactor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$PortfolioDatabase extends GeneratedDatabase {
  _$PortfolioDatabase(QueryExecutor e) : super(e);
  $PortfolioDatabaseManager get managers => $PortfolioDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $JournalEntriesTable journalEntries = $JournalEntriesTable(this);
  late final $JournalTagsTable journalTags = $JournalTagsTable(this);
  late final $TradingStatsTable tradingStats = $TradingStatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [transactions, journalEntries, journalTags, tradingStats];
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

class $$TransactionsTableFilterComposer
    extends Composer<_$PortfolioDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feeAsset => $composableBuilder(
      column: $table.feeAsset, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$PortfolioDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fee => $composableBuilder(
      column: $table.fee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feeAsset => $composableBuilder(
      column: $table.feeAsset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$PortfolioDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get fee =>
      $composableBuilder(column: $table.fee, builder: (column) => column);

  GeneratedColumn<String> get feeAsset =>
      $composableBuilder(column: $table.feeAsset, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$PortfolioDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$PortfolioDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(
      _$PortfolioDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$PortfolioDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$PortfolioDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$JournalEntriesTableCreateCompanionBuilder = JournalEntriesCompanion
    Function({
  Value<int> id,
  Value<String?> transactionId,
  required String symbol,
  required String side,
  required double entryPrice,
  Value<double?> exitPrice,
  required double quantity,
  Value<double?> pnl,
  Value<double?> pnlPercentage,
  Value<double?> riskRewardRatio,
  Value<String?> strategy,
  required String emotion,
  Value<String?> notes,
  required String tags,
  Value<String?> screenshotPath,
  required DateTime entryDate,
  Value<DateTime?> exitDate,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$JournalEntriesTableUpdateCompanionBuilder = JournalEntriesCompanion
    Function({
  Value<int> id,
  Value<String?> transactionId,
  Value<String> symbol,
  Value<String> side,
  Value<double> entryPrice,
  Value<double?> exitPrice,
  Value<double> quantity,
  Value<double?> pnl,
  Value<double?> pnlPercentage,
  Value<double?> riskRewardRatio,
  Value<String?> strategy,
  Value<String> emotion,
  Value<String?> notes,
  Value<String> tags,
  Value<String?> screenshotPath,
  Value<DateTime> entryDate,
  Value<DateTime?> exitDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$JournalEntriesTableFilterComposer
    extends Composer<_$PortfolioDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get exitPrice => $composableBuilder(
      column: $table.exitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pnl => $composableBuilder(
      column: $table.pnl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pnlPercentage => $composableBuilder(
      column: $table.pnlPercentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riskRewardRatio => $composableBuilder(
      column: $table.riskRewardRatio,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strategy => $composableBuilder(
      column: $table.strategy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emotion => $composableBuilder(
      column: $table.emotion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get exitDate => $composableBuilder(
      column: $table.exitDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$JournalEntriesTableOrderingComposer
    extends Composer<_$PortfolioDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionId => $composableBuilder(
      column: $table.transactionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get side => $composableBuilder(
      column: $table.side, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get exitPrice => $composableBuilder(
      column: $table.exitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pnl => $composableBuilder(
      column: $table.pnl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pnlPercentage => $composableBuilder(
      column: $table.pnlPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riskRewardRatio => $composableBuilder(
      column: $table.riskRewardRatio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strategy => $composableBuilder(
      column: $table.strategy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emotion => $composableBuilder(
      column: $table.emotion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get entryDate => $composableBuilder(
      column: $table.entryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get exitDate => $composableBuilder(
      column: $table.exitDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$JournalEntriesTableAnnotationComposer
    extends Composer<_$PortfolioDatabase, $JournalEntriesTable> {
  $$JournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
      column: $table.transactionId, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<double> get entryPrice => $composableBuilder(
      column: $table.entryPrice, builder: (column) => column);

  GeneratedColumn<double> get exitPrice =>
      $composableBuilder(column: $table.exitPrice, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get pnl =>
      $composableBuilder(column: $table.pnl, builder: (column) => column);

  GeneratedColumn<double> get pnlPercentage => $composableBuilder(
      column: $table.pnlPercentage, builder: (column) => column);

  GeneratedColumn<double> get riskRewardRatio => $composableBuilder(
      column: $table.riskRewardRatio, builder: (column) => column);

  GeneratedColumn<String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath, builder: (column) => column);

  GeneratedColumn<DateTime> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<DateTime> get exitDate =>
      $composableBuilder(column: $table.exitDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JournalEntriesTableTableManager extends RootTableManager<
    _$PortfolioDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$PortfolioDatabase, $JournalEntriesTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()> {
  $$JournalEntriesTableTableManager(
      _$PortfolioDatabase db, $JournalEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> side = const Value.absent(),
            Value<double> entryPrice = const Value.absent(),
            Value<double?> exitPrice = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double?> pnl = const Value.absent(),
            Value<double?> pnlPercentage = const Value.absent(),
            Value<double?> riskRewardRatio = const Value.absent(),
            Value<String?> strategy = const Value.absent(),
            Value<String> emotion = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String?> screenshotPath = const Value.absent(),
            Value<DateTime> entryDate = const Value.absent(),
            Value<DateTime?> exitDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              JournalEntriesCompanion(
            id: id,
            transactionId: transactionId,
            symbol: symbol,
            side: side,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            quantity: quantity,
            pnl: pnl,
            pnlPercentage: pnlPercentage,
            riskRewardRatio: riskRewardRatio,
            strategy: strategy,
            emotion: emotion,
            notes: notes,
            tags: tags,
            screenshotPath: screenshotPath,
            entryDate: entryDate,
            exitDate: exitDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> transactionId = const Value.absent(),
            required String symbol,
            required String side,
            required double entryPrice,
            Value<double?> exitPrice = const Value.absent(),
            required double quantity,
            Value<double?> pnl = const Value.absent(),
            Value<double?> pnlPercentage = const Value.absent(),
            Value<double?> riskRewardRatio = const Value.absent(),
            Value<String?> strategy = const Value.absent(),
            required String emotion,
            Value<String?> notes = const Value.absent(),
            required String tags,
            Value<String?> screenshotPath = const Value.absent(),
            required DateTime entryDate,
            Value<DateTime?> exitDate = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              JournalEntriesCompanion.insert(
            id: id,
            transactionId: transactionId,
            symbol: symbol,
            side: side,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            quantity: quantity,
            pnl: pnl,
            pnlPercentage: pnlPercentage,
            riskRewardRatio: riskRewardRatio,
            strategy: strategy,
            emotion: emotion,
            notes: notes,
            tags: tags,
            screenshotPath: screenshotPath,
            entryDate: entryDate,
            exitDate: exitDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalEntriesTableProcessedTableManager = ProcessedTableManager<
    _$PortfolioDatabase,
    $JournalEntriesTable,
    JournalEntry,
    $$JournalEntriesTableFilterComposer,
    $$JournalEntriesTableOrderingComposer,
    $$JournalEntriesTableAnnotationComposer,
    $$JournalEntriesTableCreateCompanionBuilder,
    $$JournalEntriesTableUpdateCompanionBuilder,
    (
      JournalEntry,
      BaseReferences<_$PortfolioDatabase, $JournalEntriesTable, JournalEntry>
    ),
    JournalEntry,
    PrefetchHooks Function()>;
typedef $$JournalTagsTableCreateCompanionBuilder = JournalTagsCompanion
    Function({
  Value<int> id,
  required String name,
  required int color,
  Value<int> usageCount,
});
typedef $$JournalTagsTableUpdateCompanionBuilder = JournalTagsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> color,
  Value<int> usageCount,
});

class $$JournalTagsTableFilterComposer
    extends Composer<_$PortfolioDatabase, $JournalTagsTable> {
  $$JournalTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnFilters(column));
}

class $$JournalTagsTableOrderingComposer
    extends Composer<_$PortfolioDatabase, $JournalTagsTable> {
  $$JournalTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => ColumnOrderings(column));
}

class $$JournalTagsTableAnnotationComposer
    extends Composer<_$PortfolioDatabase, $JournalTagsTable> {
  $$JournalTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
      column: $table.usageCount, builder: (column) => column);
}

class $$JournalTagsTableTableManager extends RootTableManager<
    _$PortfolioDatabase,
    $JournalTagsTable,
    JournalTag,
    $$JournalTagsTableFilterComposer,
    $$JournalTagsTableOrderingComposer,
    $$JournalTagsTableAnnotationComposer,
    $$JournalTagsTableCreateCompanionBuilder,
    $$JournalTagsTableUpdateCompanionBuilder,
    (
      JournalTag,
      BaseReferences<_$PortfolioDatabase, $JournalTagsTable, JournalTag>
    ),
    JournalTag,
    PrefetchHooks Function()> {
  $$JournalTagsTableTableManager(
      _$PortfolioDatabase db, $JournalTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JournalTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JournalTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JournalTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<int> usageCount = const Value.absent(),
          }) =>
              JournalTagsCompanion(
            id: id,
            name: name,
            color: color,
            usageCount: usageCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int color,
            Value<int> usageCount = const Value.absent(),
          }) =>
              JournalTagsCompanion.insert(
            id: id,
            name: name,
            color: color,
            usageCount: usageCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$JournalTagsTableProcessedTableManager = ProcessedTableManager<
    _$PortfolioDatabase,
    $JournalTagsTable,
    JournalTag,
    $$JournalTagsTableFilterComposer,
    $$JournalTagsTableOrderingComposer,
    $$JournalTagsTableAnnotationComposer,
    $$JournalTagsTableCreateCompanionBuilder,
    $$JournalTagsTableUpdateCompanionBuilder,
    (
      JournalTag,
      BaseReferences<_$PortfolioDatabase, $JournalTagsTable, JournalTag>
    ),
    JournalTag,
    PrefetchHooks Function()>;
typedef $$TradingStatsTableCreateCompanionBuilder = TradingStatsCompanion
    Function({
  Value<int> id,
  required String period,
  required DateTime periodStart,
  required DateTime periodEnd,
  required int totalTrades,
  required int winCount,
  required int lossCount,
  required double winRate,
  required double totalPnl,
  required double averageRR,
  required double largestWin,
  required double largestLoss,
  required double profitFactor,
  required DateTime updatedAt,
});
typedef $$TradingStatsTableUpdateCompanionBuilder = TradingStatsCompanion
    Function({
  Value<int> id,
  Value<String> period,
  Value<DateTime> periodStart,
  Value<DateTime> periodEnd,
  Value<int> totalTrades,
  Value<int> winCount,
  Value<int> lossCount,
  Value<double> winRate,
  Value<double> totalPnl,
  Value<double> averageRR,
  Value<double> largestWin,
  Value<double> largestLoss,
  Value<double> profitFactor,
  Value<DateTime> updatedAt,
});

class $$TradingStatsTableFilterComposer
    extends Composer<_$PortfolioDatabase, $TradingStatsTable> {
  $$TradingStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTrades => $composableBuilder(
      column: $table.totalTrades, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get winCount => $composableBuilder(
      column: $table.winCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lossCount => $composableBuilder(
      column: $table.lossCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get winRate => $composableBuilder(
      column: $table.winRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPnl => $composableBuilder(
      column: $table.totalPnl, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageRR => $composableBuilder(
      column: $table.averageRR, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get largestWin => $composableBuilder(
      column: $table.largestWin, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get largestLoss => $composableBuilder(
      column: $table.largestLoss, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get profitFactor => $composableBuilder(
      column: $table.profitFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TradingStatsTableOrderingComposer
    extends Composer<_$PortfolioDatabase, $TradingStatsTable> {
  $$TradingStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get period => $composableBuilder(
      column: $table.period, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTrades => $composableBuilder(
      column: $table.totalTrades, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get winCount => $composableBuilder(
      column: $table.winCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lossCount => $composableBuilder(
      column: $table.lossCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get winRate => $composableBuilder(
      column: $table.winRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPnl => $composableBuilder(
      column: $table.totalPnl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageRR => $composableBuilder(
      column: $table.averageRR, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get largestWin => $composableBuilder(
      column: $table.largestWin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get largestLoss => $composableBuilder(
      column: $table.largestLoss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get profitFactor => $composableBuilder(
      column: $table.profitFactor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TradingStatsTableAnnotationComposer
    extends Composer<_$PortfolioDatabase, $TradingStatsTable> {
  $$TradingStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get totalTrades => $composableBuilder(
      column: $table.totalTrades, builder: (column) => column);

  GeneratedColumn<int> get winCount =>
      $composableBuilder(column: $table.winCount, builder: (column) => column);

  GeneratedColumn<int> get lossCount =>
      $composableBuilder(column: $table.lossCount, builder: (column) => column);

  GeneratedColumn<double> get winRate =>
      $composableBuilder(column: $table.winRate, builder: (column) => column);

  GeneratedColumn<double> get totalPnl =>
      $composableBuilder(column: $table.totalPnl, builder: (column) => column);

  GeneratedColumn<double> get averageRR =>
      $composableBuilder(column: $table.averageRR, builder: (column) => column);

  GeneratedColumn<double> get largestWin => $composableBuilder(
      column: $table.largestWin, builder: (column) => column);

  GeneratedColumn<double> get largestLoss => $composableBuilder(
      column: $table.largestLoss, builder: (column) => column);

  GeneratedColumn<double> get profitFactor => $composableBuilder(
      column: $table.profitFactor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TradingStatsTableTableManager extends RootTableManager<
    _$PortfolioDatabase,
    $TradingStatsTable,
    TradingStat,
    $$TradingStatsTableFilterComposer,
    $$TradingStatsTableOrderingComposer,
    $$TradingStatsTableAnnotationComposer,
    $$TradingStatsTableCreateCompanionBuilder,
    $$TradingStatsTableUpdateCompanionBuilder,
    (
      TradingStat,
      BaseReferences<_$PortfolioDatabase, $TradingStatsTable, TradingStat>
    ),
    TradingStat,
    PrefetchHooks Function()> {
  $$TradingStatsTableTableManager(
      _$PortfolioDatabase db, $TradingStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradingStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradingStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradingStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> period = const Value.absent(),
            Value<DateTime> periodStart = const Value.absent(),
            Value<DateTime> periodEnd = const Value.absent(),
            Value<int> totalTrades = const Value.absent(),
            Value<int> winCount = const Value.absent(),
            Value<int> lossCount = const Value.absent(),
            Value<double> winRate = const Value.absent(),
            Value<double> totalPnl = const Value.absent(),
            Value<double> averageRR = const Value.absent(),
            Value<double> largestWin = const Value.absent(),
            Value<double> largestLoss = const Value.absent(),
            Value<double> profitFactor = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TradingStatsCompanion(
            id: id,
            period: period,
            periodStart: periodStart,
            periodEnd: periodEnd,
            totalTrades: totalTrades,
            winCount: winCount,
            lossCount: lossCount,
            winRate: winRate,
            totalPnl: totalPnl,
            averageRR: averageRR,
            largestWin: largestWin,
            largestLoss: largestLoss,
            profitFactor: profitFactor,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String period,
            required DateTime periodStart,
            required DateTime periodEnd,
            required int totalTrades,
            required int winCount,
            required int lossCount,
            required double winRate,
            required double totalPnl,
            required double averageRR,
            required double largestWin,
            required double largestLoss,
            required double profitFactor,
            required DateTime updatedAt,
          }) =>
              TradingStatsCompanion.insert(
            id: id,
            period: period,
            periodStart: periodStart,
            periodEnd: periodEnd,
            totalTrades: totalTrades,
            winCount: winCount,
            lossCount: lossCount,
            winRate: winRate,
            totalPnl: totalPnl,
            averageRR: averageRR,
            largestWin: largestWin,
            largestLoss: largestLoss,
            profitFactor: profitFactor,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TradingStatsTableProcessedTableManager = ProcessedTableManager<
    _$PortfolioDatabase,
    $TradingStatsTable,
    TradingStat,
    $$TradingStatsTableFilterComposer,
    $$TradingStatsTableOrderingComposer,
    $$TradingStatsTableAnnotationComposer,
    $$TradingStatsTableCreateCompanionBuilder,
    $$TradingStatsTableUpdateCompanionBuilder,
    (
      TradingStat,
      BaseReferences<_$PortfolioDatabase, $TradingStatsTable, TradingStat>
    ),
    TradingStat,
    PrefetchHooks Function()>;

class $PortfolioDatabaseManager {
  final _$PortfolioDatabase _db;
  $PortfolioDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$JournalEntriesTableTableManager get journalEntries =>
      $$JournalEntriesTableTableManager(_db, _db.journalEntries);
  $$JournalTagsTableTableManager get journalTags =>
      $$JournalTagsTableTableManager(_db, _db.journalTags);
  $$TradingStatsTableTableManager get tradingStats =>
      $$TradingStatsTableTableManager(_db, _db.tradingStats);
}
