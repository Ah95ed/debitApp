import 'package:appwrite/appwrite.dart';
import 'package:appwrite/appwrite.dart' as models;
import 'package:appwrite/models.dart' as models;
import '../models/debt_model.dart';

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '68a4a94c001e0da9adf2';
  static const String collectionId = '68a4b70d00127804e331';
  static const String databaseId = '68a4ac840021bea45f4d';

  late Client client;
  late Databases databases;
  late Realtime realtime;

  AppwriteService() {
    client = Client().setEndpoint(endpoint).setProject(projectId);
    databases = Databases(client);
    realtime = Realtime(client);
  }

  Stream<models.RealtimeMessage> subscribeToDebtChanges() {
    return realtime.subscribe(['databases.${databaseId}.collections.${collectionId}.documents']).stream;
  }

  Future<void> addOrUpdateDebt(Debt debt) async {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: debt.phoneNumber, // Using phone number as document ID
        data: debt.toMap(),
      );
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        // Document already exists, so update it
        await databases.updateDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: debt.phoneNumber,
          data: debt.toMap(),
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteDebt(String phoneNumber) async {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: phoneNumber,
    );
  }

  Future<List<Debt>> getDebts({int limit = 20, int offset = 0}) async {
    final models.DocumentList result = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: [Query.limit(limit), Query.offset(offset)],
    );

    return result.documents.map((doc) => Debt.fromMap(doc.data)).toList();
  }

  Future<List<Debt>> getAllDebts() async {
    List<Debt> debts = [];
    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final models.DocumentList result = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.limit(100), Query.offset(offset)],
      );

      if (result.documents.isNotEmpty) {
        debts.addAll(result.documents.map((doc) => Debt.fromMap(doc.data)));
        offset += result.documents.length;
      } else {
        hasMore = false;
      }
    }

    return debts;
  }
}