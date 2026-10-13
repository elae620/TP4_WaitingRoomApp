import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waiting_room_app/models/client.dart';

// Fonction permettant de simuler l'ajout pendant les tests.
typedef InsertClient = Future<void> Function(String name);

class QueueProvider extends ChangeNotifier {
  // Client Supabase utilisé par l'application réelle.
  final SupabaseClient? _supabase;

  // Fonction utilisée uniquement pendant les tests.
  final InsertClient? _testInsertClient;

  final List<Client> _clients = [];

  List<Client> get clients => List.unmodifiable(_clients);

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  // Constructeur normal : utilisé par l'application Flutter.
  QueueProvider()
    : _supabase = Supabase.instance.client,
      _testInsertClient = null {
    _listenToClients();
  }

  // Constructeur spécial pour les tests unitaires.
  // Il ne nécessite aucune connexion à Supabase.
  QueueProvider.forTesting({required InsertClient insertClient})
    : _supabase = null,
      _testInsertClient = insertClient;

  // Recevoir les données initiales et les changements en temps réel.
  void _listenToClients() {
    _subscription = _supabase!
        .from('clients')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen(
          (data) {
            _clients
              ..clear()
              ..addAll(data.map((row) => Client.fromMap(row)));

            notifyListeners();
          },
          onError: (error) {
            debugPrint('Erreur de synchronisation Supabase : $error');
          },
        );
  }

  // Ajouter un client dans la base de données.
  Future<void> addClient(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return;
    }

    // Pendant les tests, utiliser la fonction simulée.
    if (_testInsertClient != null) {
      await _testInsertClient(trimmedName);
      return;
    }

    // Dans l'application réelle, enregistrer dans Supabase.
    await _supabase!.from('clients').insert({'name': trimmedName});
  }

  // Supprimer un client à partir de son identifiant.
  Future<void> removeClient(String id) async {
    await _supabase!.from('clients').delete().eq('id', id);
  }

  // Faire passer le client suivant.
  Future<void> nextClient() async {
    if (_clients.isEmpty) {
      return;
    }

    final firstClient = _clients.first;
    await removeClient(firstClient.id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
