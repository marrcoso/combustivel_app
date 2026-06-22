import 'package:cloud_firestore/cloud_firestore.dart';
import 'suggestion_status.dart';

class SuggestionModel {
  final String id;
  final String stationId;
  final String stationName;
  final String userId;
  final String fuelType;
  final double suggestedPrice;
  final SuggestionStatus status;
  final DateTime createdAt;

  SuggestionModel({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.userId,
    required this.fuelType,
    required this.suggestedPrice,
    required this.status,
    required this.createdAt,
  });

  factory SuggestionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SuggestionModel(
      id: documentId,
      stationId: map['stationId'] ?? '',
      stationName: map['stationName'] ?? '',
      userId: map['userId'] ?? '',
      fuelType: map['fuelType'] ?? '',
      suggestedPrice: (map['suggestedPrice'] ?? 0.0).toDouble(),
      status: SuggestionStatusExtension.fromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId,
      'stationName': stationName,
      'userId': userId,
      'fuelType': fuelType,
      'suggestedPrice': suggestedPrice,
      'status': status.value,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
