class RecordInput {
  final String uid;
  final DBRecord record;
  final DBMart mart;
  final List<DBProduct> product;
  final int totalPrice;

  RecordInput({
    required this.uid,
    required this.record,
    required this.mart,
    required this.product,
    required this.totalPrice,
  });

  factory RecordInput.fromJson(Map<String, dynamic> json) {
    return RecordInput(
      uid: json['uid'],
      record: DBRecord.fromJson(json['record']),
      mart: DBMart.fromJson(json['mart']),
      product: (json['product'] as List)
          .map((p) => DBProduct.fromJson(p))
          .toList(),
      totalPrice: json['totalPrice'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'record': record.toJson(),
    'mart': mart.toJson(),
    'product': product.map((p) => p.toJson()).toList(),
    'totalPrice': totalPrice,
  };
}

class DBRecord {
  final String rid;
  final String rname;
  final String timeStamp;

  DBRecord({
    required this.rid,
    required this.rname,
    required this.timeStamp,
  });

  factory DBRecord.fromJson(Map<String, dynamic> json) => DBRecord(
    rid: json['rid'],
    rname: json['rname'],
    timeStamp: json['timeStamp'],
  );

  Map<String, dynamic> toJson() => {
    'rid': rid,
    'rname': rname,
    'timeStamp': timeStamp,
  };
}

class DBProduct {
  final String pname;
  final int price;
  final int amount;

  DBProduct({
    required this.pname,
    required this.price,
    required this.amount,
  });

  factory DBProduct.fromJson(Map<String, dynamic> json) => DBProduct(
    pname: json['pname'],
    price: json['price'],
    amount: json['amount'],
  );

  Map<String, dynamic> toJson() => {
    'pname': pname,
    'price': price,
    'amount': amount,
  };
}

class DBMart {
  final String martAddress;
  final String martName;
  final String tel;

  DBMart({
    required this.martAddress,
    required this.martName,
    required this.tel,
  });

  factory DBMart.fromJson(Map<String, dynamic> json) => DBMart(
    martAddress: json['martAddress'],
    martName: json['martName'],
    tel: json['tel'],
  );

  Map<String, dynamic> toJson() => {
    'martAddress': martAddress,
    'martName': martName,
    'tel': tel,
  };
}

class RecordList {
  final String uid;
  final DBRecord record;
  final SimpleMart mart;
  final int totalPrice;

  RecordList({
    required this.uid,
    required this.record,
    required this.mart,
    required this.totalPrice,
  });

  factory RecordList.fromJson(Map<String, dynamic> json) => RecordList(
    uid: json['uid'],
    record: DBRecord.fromJson(json['record']),
    mart: SimpleMart.fromJson(json['mart']),
    totalPrice: json['totalPrice'],
  );
}

class SimpleMart {
  final String martName;

  SimpleMart({required this.martName});

  factory SimpleMart.fromJson(Map<String, dynamic> json) => SimpleMart(
    martName: json['martName'],
  );
}