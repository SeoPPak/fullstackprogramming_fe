class Mart {
  final String martName;
  final String martAddress;
  final String tel;
  final String? businessNumber;
  final String? ownerName;

  Mart({
    required this.martName,
    required this.martAddress,
    required this.tel,
    this.businessNumber,
    this.ownerName,
  });

  factory Mart.fromJson(Map<String, dynamic> json) {
    return Mart(
      martName: json['martName'],
      martAddress: json['martAddress'],
      tel: json['tel'],
      businessNumber: json['businessNumber'],
      ownerName: json['ownerName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'martName': martName,
      'martAddress': martAddress,
      'tel': tel,
    };

    if (businessNumber != null) data['businessNumber'] = businessNumber;
    if (ownerName != null) data['ownerName'] = ownerName;

    return data;
  }

  Mart copyWith({
    String? martName,
    String? martAddress,
    String? tel,
    String? businessNumber,
    String? ownerName,
  }) {
    return Mart(
      martName: martName ?? this.martName,
      martAddress: martAddress ?? this.martAddress,
      tel: tel ?? this.tel,
      businessNumber: businessNumber ?? this.businessNumber,
      ownerName: ownerName ?? this.ownerName,
    );
  }
}

class MartUpdateRequest {
  final String rid;
  final String? newMartName;
  final String? newMartAddress;
  final String? newTel;

  MartUpdateRequest({
    required this.rid,
    this.newMartName,
    this.newMartAddress,
    this.newTel,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'rid': rid,
    };

    if (newMartName != null) data['newMartName'] = newMartName;
    if (newMartAddress != null) data['newMartAddress'] = newMartAddress;
    if (newTel != null) data['newTel'] = newTel;

    return data;
  }
}