import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _moviesCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return _firestore.collection('users').doc(user.uid).collection('movies');
  }

  Future<void> addMovieToList(
    Map<String, dynamic> movie,
    String listName,
  ) async {
    final movieRef = _moviesCollection.doc(movie['id'].toString());

    final doc = await movieRef.get();

    if (doc.exists) {
      final data = doc.data()!;

      final List<String> lists = List<String>.from(data['lists'] ?? []);

      if (!lists.contains(listName)) {
        lists.add(listName);
      }

      await movieRef.update({'lists': lists});
    } else {
      await movieRef.set({
        ...movie,
        'lists': [listName],
      });
    }
  }

  Future<void> removeMovieFromList(int movieId, String listName) async {
    final movieRef = _moviesCollection.doc(movieId.toString());

    final doc = await movieRef.get();

    if (!doc.exists) {
      return;
    }

    final data = doc.data()!;

    final List<String> lists = List<String>.from(data['lists'] ?? []);

    lists.remove(listName);

    if (lists.isEmpty) {
      await movieRef.delete();
    } else {
      await movieRef.update({'lists': lists});
    }
  }

  Future<List<Map<String, dynamic>>> getMoviesByList(String listName) async {
    final snapshot = await _moviesCollection
        .where('lists', arrayContains: listName)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
