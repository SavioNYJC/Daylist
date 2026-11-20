import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/sign_up_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://owhfuqhpuoluyapbuhge.supabase.co',
    publishableKey: 'sb_publishable_GXA7TxGejB3-uTXAI00gbQ_PVVXVrKl',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Todos', home: SignUpPage(),);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.todos});

  final Future<List<Map<String, dynamic>>>? todos;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Map<String, dynamic>>> _todos =
      widget.todos ?? Supabase.instance.client.from('todos').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _todos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load todos: ${snapshot.error}'),
              ),
            );
          }

          final todos = snapshot.data ?? const [];
          if (todos.isEmpty) {
            return const Center(child: Text('No todos found.'));
          }

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo['name'] as String? ?? 'Untitled todo'),
              );
            },
          );
        },
      ),
    );
  }
}
