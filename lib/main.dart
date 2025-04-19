import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Presentation/driver_app/driver_screen.dart';
import 'Presentation/parent_app/parent_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87,
        ),
      ),
      home: const SelectApp(),
    );
  }
}

enum AppType { driver, parent }

class SelectApp extends StatefulWidget {
  const SelectApp({super.key});

  @override
  State<SelectApp> createState() => _SelectAppState();
}

class _SelectAppState extends State<SelectApp> {
  AppType? _selectedApp;

  void _navigate(AppType? value) async {
    setState(() {
      _selectedApp = value;
    });

    // Push new screen, wait for it to return
    if (value == AppType.driver) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DriverScreen()),
      );
    } else if (value == AppType.parent) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentScreen()),
      );
    }

    // Reset radio selection when returning back
    setState(() {
      _selectedApp = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Parent & Driver App", style: TextStyle(
        color: Colors.white
      ),),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      //backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text('Choose App',style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.green
              ),),
              SizedBox(height: 20,),
              ListTile(
                title: const Text('Driver App', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),),
                leading: Radio<AppType>(
                  value: AppType.driver,
                  groupValue: _selectedApp,
                  onChanged: _navigate,
                ),
              ),
            ],
          ),
          ListTile(
            title: const Text('Parent App', style: TextStyle(
              color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold
            ),),
            leading: Radio<AppType>(
              value: AppType.parent,
              groupValue: _selectedApp,
              onChanged: _navigate,
            ),
          ),
        ],
      ),
    );
  }
}
