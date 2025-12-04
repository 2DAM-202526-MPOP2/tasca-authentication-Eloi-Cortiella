import 'package:first_flutter/data/models/sentence.dart';
import 'package:first_flutter/data/repositories/sentence_repository.dart';
import 'package:first_flutter/data/services/sentence_service.dart';
import 'package:first_flutter/presentation/viewmodels/login_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/viewmodels/sentence_vm.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ISentenceService>(
          create: (context) => SentenceService(), // ISentenceService instance
        ),
        Provider<ISentenceRepository>(
          create: (context) => SentenceRepository(
            sentenceService: context.read(),
          ), //ISentenceRepository instance
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SentenceVM(sentenceRepository: context.read()),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = LoginPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Scaffold(
            body: Row(children: [MainArea(page: page)]),
            bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home), 
                  label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: Icon(Icons.login),
                  label: 'Login',
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          );
        } else {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 800, // ← Here.
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.login),
                        label: Text('Login'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                MainArea(page: page),
              ],
            ),
          );
        }
      },
    );
  }
}

class MainArea extends StatelessWidget {
  const MainArea({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SentenceVM>();

    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    var sentence = vm.current;
    IconData icon;
    if (vm.isFavorite(sentence)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, //Main axis is vertical for Column
        children: [
          Expanded(
            child: ListView(
              children: [
                for (var word in vm.history)
                  ListTile(
                    leading: Icon(
                      vm.isFavorite(word)
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    title: Text(word.text),
                  ),
              ],
            ),
          ),
          Text('A random AWESOME  idea:'),
          BigCard(pair: sentence),
          // ↓ Add this.
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min, // ← Add this.
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  vm.toggleCurrentFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 20), // ← Add some spacing between buttons.
              ElevatedButton(
                onPressed: () {
                  vm.next();
                },
                child: Text('Next'),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var vm = context.watch<SentenceVM>();

    if (vm.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${vm.favorites.length} favorites:',
          ),
        ),
        for (var word in vm.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.favorite),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                vm.toggleFavorite(word);
              },
              tooltip: 'Remove from favorites',
            ),
            title: Text(word.text),
          ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {

  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String?> _created = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<LoginVM>();

    vm.currentUser;
    final maxWidth = MediaQuery.of(context).size.width;
    final contentWidth = maxWidth > 800 ? 600.0 : maxWidth * 0.8;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  vm.validateLogin(_controller.text, _controller.text);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Login'),
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<String?>(
                valueListenable: _created,
                builder: (context, value, child) {
                  if (value == null || value.isEmpty) return SizedBox.shrink();
                  return Text(
                    'You are logged in as: $value',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final Sentence pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      shadows: [
        Shadow(color: theme.colorScheme.primaryContainer, blurRadius: 10),
      ],
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.text, style: style),
      ),
    );
  }
}
