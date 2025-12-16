import 'package:first_flutter/data/models/sentence.dart';
import 'package:first_flutter/data/repositories/authentication_repository.dart';
import 'package:first_flutter/data/repositories/sentence_repository.dart';
import 'package:first_flutter/data/services/authentication_service.dart';
import 'package:first_flutter/data/services/sentence_service.dart';
import 'package:first_flutter/presentation/viewmodels/login_vm.dart';
import 'package:first_flutter/presentation/viewmodels/profile_vm.dart';
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
        Provider<IAuthenticationService>(
          create: (context) =>
              AuthenticationService(), // IAuthenticationService instance
        ),
        Provider<IAuthenticationRepository>(
          create: (context) => AuthenticationRepository(
            authenticationService: context.read(),
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SentenceVM(sentenceRepository: context.read()),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginVM(
            authenticationRepository: context.read<IAuthenticationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileVM(
            authenticationRepository: context.read<IAuthenticationRepository>(),
          ),
        ),
      ],
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
      case 1:
        page = FavoritesPage();
      case 2:
        page = LoginPage();
      case 3:
        page = ProfilePage();
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
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
                NavigationDestination(icon: Icon(Icons.login), label: 'Login'),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
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
                      NavigationRailDestination(
                        icon: Icon(Icons.person),
                        label: Text('Profile'),
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
  LoginPage({super.key});

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<String?> _created = ValueNotifier<String?>(null);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginVM>();

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
                controller: _userController,
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = await vm.validateLogin(
                      _userController.text,
                      _passwordController.text,
                    );
                    _created.value = user.username;
                  } catch (e) {
                    _created.value = 'Login failed';
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String?>(
                valueListenable: _created,
                builder: (context, value, child) {
                  if (value == null || value.isEmpty) {
                    return const SizedBox.shrink();
                  }
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

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final loginVM = context.read<LoginVM>();
        if (loginVM.currentUser.authenticated) {
          context.read<ProfileVM>().loadProfile(loginVM.currentUser);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = context.watch<LoginVM>();
    final profileVM = context.watch<ProfileVM>();

    if (!loginVM.currentUser.authenticated) {
      return Center(child: Text('Please login to view your profile.'));
    }

    if (profileVM.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (profileVM.errorMessage != null) {
      return Center(
        child: Text(
          'Error loading profile: ${profileVM.errorMessage}',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final profile = profileVM.profile;
    if (profile == null) {
      return Center(child: Text('No profile data available.'));
    }

    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                child: Text(
                  profile.firstname.isNotEmpty
                      ? profile.firstname[0].toUpperCase() +
                            profile.lastname[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${profile.firstname} ${profile.lastname}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 10),
              Text('@${profile.username}'),
              SizedBox(height: 10),
              Text(profile.email),
              SizedBox(height: 10),
              Text('Born: ${profile.birthdate}'),
            ],
          ),
        ),
      ),
    );
  }
}
