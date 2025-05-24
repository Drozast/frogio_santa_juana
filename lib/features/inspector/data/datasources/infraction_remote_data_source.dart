import 'dart:io';

import '../models/infraction_model.dart';

abstract class InfractionRemoteDataSource {
  /// Obtiene todas las infracciones del inspector
  Future<List<InfractionModel>> getInfractionsByInspector(String inspectorId);
  
  /// Obtiene una infracción por ID
  Future<InfractionModel> getInfractionById(String infractionId);
  
  /// Crea una nueva infracción
  Future<InfractionModel> createInfraction(InfractionModel infraction);
  
  /// Actualiza una infracción existente
  Future<InfractionModel> updateInfraction(InfractionModel infraction);
  
  /// Actualiza el estado de una infracción
  Future<void> updateInfractionStatus(String infractionId, String status);
  
  /// Sube una imagen de evidencia
  Future<String> uploadEvidenceImage(String infractionId, File image);
  
  /// Sube la firma del infractor
  Future<String> uploadSignature(String infractionId, String signatureData);
  
  /// Elimina una infracción
  Future<void> deleteInfraction(String infractionId);
}