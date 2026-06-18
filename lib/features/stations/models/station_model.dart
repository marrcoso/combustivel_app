import 'price_model.dart';

class StationModel {
  final String id;
  final String name;
  final String brand;
  final String address;
  final double latitude;
  final double longitude;
  final List<PriceModel> prices;

  StationModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.prices,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'prices': prices.map((x) => x.toMap()).toList(),
    };
  }

  factory StationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StationModel(
      id: documentId,
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      prices: List<PriceModel>.from(map['prices']?.map((x) => PriceModel.fromMap(x)) ?? []),
    );
  }
}
