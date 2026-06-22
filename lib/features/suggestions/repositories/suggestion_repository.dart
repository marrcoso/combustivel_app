import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/suggestion_model.dart';

class SuggestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSuggestion({
    required String stationId,
    required String stationName,
    required String userId,
    required String fuelType,
    required double suggestedPrice,
  }) async {
    await _firestore.collection('price_suggestions').add({
      'stationId': stationId,
      'stationName': stationName,
      'userId': userId,
      'fuelType': fuelType,
      'suggestedPrice': suggestedPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<SuggestionModel>> getPendingSuggestions() {
    return _firestore
        .collection('price_suggestions')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SuggestionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateSuggestionStatus(String suggestionId, String status) async {
    await _firestore.collection('price_suggestions').doc(suggestionId).update({
      'status': status,
    });
  }
}
