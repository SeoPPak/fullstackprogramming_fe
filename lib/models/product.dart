class Product {
  final String pname;
  final int originalPrice;
  final int discountPrice;
  final int finalPrice;
  final int amount;
  final String category;

  Product({
    required this.pname,
    required this.originalPrice,
    required this.discountPrice,
    required this.finalPrice,
    required this.amount,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      pname: json['pname'],
      originalPrice: json['originalPrice'],
      discountPrice: json['discountPrice'],
      finalPrice: json['finalPrice'],
      amount: json['amount'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pname': pname,
      'originalPrice': originalPrice,
      'discountPrice': discountPrice,
      'finalPrice': finalPrice,
      'amount': amount,
      'category': category,
    };
  }

  Product copyWith({
    String? pname,
    int? originalPrice,
    int? discountPrice,
    int? finalPrice,
    int? amount,
    String? category,
  }) {
    return Product(
      pname: pname ?? this.pname,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}

class ProductUpdateRequest {
  final String rid;
  final String pname;
  final int? newPrice;
  final int? newAmount;
  final String? newCategory;

  ProductUpdateRequest({
    required this.rid,
    required this.pname,
    this.newPrice,
    this.newAmount,
    this.newCategory,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'rid': rid,
      'pname': pname,
    };

    if (newPrice != null) data['newPrice'] = newPrice;
    if (newAmount != null) data['newAmount'] = newAmount;
    if (newCategory != null) data['newCategory'] = newCategory;

    return data;
  }
}
