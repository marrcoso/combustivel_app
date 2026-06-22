import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';

class StationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StationModel>> getStationsStream() {
    return _firestore.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StationModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addStation(StationModel station) async {
    await _firestore.collection('stations').add(station.toMap());
  }

  Future<void> updateStationPrices(String stationId, List<dynamic> newPricesMap) async {
    await _firestore.collection('stations').doc(stationId).update({
      'prices': newPricesMap,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }
}
