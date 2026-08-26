import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/fatura_view_model.dart';
import 'ui/navegacao/app.dart';
import 'ui/tema.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vm = FaturaViewModel();
  await vm.carregar();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: StatusBar,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: StatusBar,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider.value(
      value: vm,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppNavegacao(),
      ),
    ),
  );
}
