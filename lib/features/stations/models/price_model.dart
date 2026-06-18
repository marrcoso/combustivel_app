class PriceModel {
  final String fuelType;
  final double price;
  final DateTime updatedAt;

  PriceModel({
    required this.fuelType,
    required this.price,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fuelType': fuelType,
      'price': price,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PriceModel.fromMap(Map<String, dynamic> map) {
    return PriceModel(
      fuelType: map['fuelType'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
