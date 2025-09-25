import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sgvrd/core/theme/app_theme.dart';
import 'package:sgvrd/data/datasources/api_service.dart';
import 'package:sgvrd/presentation/providers/auth_provider.dart';
import 'package:sgvrd/presentation/providers/votante_provider.dart';
import 'package:sgvrd/presentation/providers/location_provider.dart';
import 'package:sgvrd/core/utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Permitir certificados autofirmados para desarrollo
  ApiService.allowSelfSignedCertificate();

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  runApp(const SGVRDApp());
}

class SGVRDApp extends StatelessWidget {
  const SGVRDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VotanteProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp.router(
        title: 'SGVRD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}