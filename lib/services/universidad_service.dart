import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/universidad.dart';

class UniversidadService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('universidades');

  Stream<List<Universidad>> getUniversidades() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            Universidad.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addUniversidad(Universidad universidad) async {
    await _collection.add(universidad.toMap());
  }
}
