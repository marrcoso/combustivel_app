import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      return UserModel.fromMap(doc.data() ?? {}, credential.user!.uid);
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<UserModel> signUp({required String email, required String password}) async {
    try {
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        isAdmin: false,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(userModel.toMap());
      return userModel;
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> checkSession() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() ?? {}, currentUser.uid);
  }

  Future<void> updateFavoriteFuelType(String? fuelType) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;
    await _firestore.collection('users').doc(currentUser.uid).update({
      'favoriteFuelType': fuelType,
    });
  }

  Future<void> updateFavoriteStation(String? stationId) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;
    await _firestore.collection('users').doc(currentUser.uid).update({
      'favoriteStationId': stationId,
    });
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'user-not-found':
          return 'Nenhum usuário encontrado para esse e-mail.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'email-already-in-use':
          return 'A conta já existe para esse e-mail.';
        case 'weak-password':
          return 'A senha fornecida é muito fraca.';
        default:
          return e.message ?? 'Ocorreu um erro desconhecido.';
      }
    }
    return e.toString();
  }
}
