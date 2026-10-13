import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waiting_room_app/queue_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Charger les variables du fichier .env
  await dotenv.load(fileName: '.env');

  // 2. Lire les informations de connexion
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseKey == null ||
      supabaseKey.isEmpty) {
    throw Exception(
      'Configuration Supabase manquante. Vérifiez le fichier .env.',
    );
  }

  // 3. Initialiser Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // 4. Lancer l'application
  runApp(const WaitingRoomApp());
}

class WaitingRoomApp extends StatelessWidget {
  const WaitingRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QueueProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WaitingRoomScreen(),
      ),
    );
  }
}

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({super.key});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addClient() async {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le nom du client.')),
      );
      return;
    }

    try {
      await context.read<QueueProvider>().addClient(name);
      _controller.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur lors de l’ajout : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = context.watch<QueueProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Waiting Room'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Champ de saisie et bouton Add
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addClient(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addClient, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 16),

            // Nombre de clients en attente
            Text(
              'Clients in Queue: ${queueProvider.clients.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Liste des clients
            Expanded(
              child: queueProvider.clients.isEmpty
                  ? const Center(child: Text('No one in queue yet...'))
                  : ListView.builder(
                      itemCount: queueProvider.clients.length,
                      itemBuilder: (context, index) {
                        final client = queueProvider.clients[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.indigo,
                            ),
                            title: Text(client.name),
                            subtitle: Text(
                              client.createdAt.toLocal().toString(),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Remove client',
                              onPressed: () async {
                                try {
                                  await context
                                      .read<QueueProvider>()
                                      .removeClient(client.id);
                                } catch (e) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur lors de la suppression : $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Passer au client suivant
      floatingActionButton: FloatingActionButton(
        key: const Key('nextClientButton'),
        onPressed: () async {
          try {
            await context.read<QueueProvider>().nextClient();
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Erreur : $e')));
          }
        },
        tooltip: 'Next Client',
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
