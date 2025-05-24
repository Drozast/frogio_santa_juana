import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

import '../models/infraction_model.dart';
import 'infraction_remote_data_source.dart';

class InfractionRemoteDataSourceImpl implements InfractionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  InfractionRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<InfractionModel>> getInfractionsByInspector(String inspectorId) async {
    try {
      final querySnapshot = await firestore
          .collection('infractions')
          .where('inspectorId', isEqualTo: inspectorId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InfractionModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener infracciones: $e');
    }
  }

  @override
  Future<InfractionModel> getInfractionById(String infractionId) async {
    try {
      final doc = await firestore
          .collection('infractions')
          .doc(infractionId)
          .get();

      if (!doc.exists) {
        throw Exception('Infracción no encontrada');
      }

      return InfractionModel.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Error al obtener infracción: $e');
    }
  }

  @override
  Future<InfractionModel> createInfraction(InfractionModel infraction) async {
    try {
      final docRef = await firestore.collection('infractions').add(
        infraction.toJson()..remove('id'),
      );

      return infraction.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Error al crear infracción: $e');
    }
  }

  @override
  Future<InfractionModel> updateInfraction(InfractionModel infraction) async {
    try {
      await firestore
          .collection('infractions')
          .doc(infraction.id)
          .update(infraction.toJson()..remove('id'));

      return infraction;
    } catch (e) {
      throw Exception('Error al actualizar infracción: $e');
    }
  }

  @override
  Future<void> updateInfractionStatus(String infractionId, String status) async {
    try {
      await firestore.collection('infractions').doc(infractionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }

  @override
  Future<String> uploadEvidenceImage(String infractionId, File image) async {
    try {
      // Comprimir imagen
      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es necesario (max 1920px)
      final resized = decodedImage.width > 1920 || decodedImage.height > 1920
          ? img.copyResize(decodedImage, width: 1920)
          : decodedImage;

      // Comprimir a JPEG con calidad del 85%
      final compressed = img.encodeJpg(resized, quality: 85);

      // Subir a Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final ref = storage.ref().child('infractions/$infractionId/evidence/$fileName');
      
      final uploadTask = await ref.putData(compressed);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Actualizar el documento con la nueva URL
      await firestore.collection('infractions').doc(infractionId).update({
        'evidence': FieldValue.arrayUnion([downloadUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  @override
  Future<String> uploadSignature(String infractionId, String signatureData) async {
    try {
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = storage.ref().child('infractions/$infractionId/signatures/$fileName');
      
      // Convertir base64 a bytes y subir
      final bytes = Uri.parse(signatureData).data!.contentAsBytes();
      final uploadTask = await ref.putData(bytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Actualizar el documento
      await firestore.collection('infractions').doc(infractionId).update({
        'signatures': FieldValue.arrayUnion([downloadUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir firma: $e');
    }
  }

  @override
  Future<void> deleteInfraction(String infractionId) async {
    try {
      await firestore.collection('infractions').doc(infractionId).delete();
    } catch (e) {
      throw Exception('Error al eliminar infracción: $e');
    }
  }
}