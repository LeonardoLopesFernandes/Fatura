import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/fatura_view_model.dart';
import 'ui/navegacao/app.dart';
import 'ui/temas.dart';
import 'util/formatadores.dart';
import 'util/notificacoes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final vm = FaturaViewModel();
  await vm.carregar();
  final tema = TemaProvider();
  await tema.carregar();
  await inicializarNotificacoes();
  if (vm.lembretesAtivos) {
    await agendarLembretes(true);
    final proximos = vm.vencimentosProximos();
    if (proximos.isNotEmpty) {
      await notificarVencimentos([
        for (final b in proximos)
          '${b.nome} vence dia ${b.diaVencimento}: ${formatarMoeda(vm.faturaDoBancoNoMes(b.id, vm.mesSelecionado))}',
      ]);
    }
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: vm),
        ChangeNotifierProvider.value(value: tema),
      ],
      child: Consumer<TemaProvider>(
        builder: (_, temaProv, __) {
          final cores = temaProv.cores;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness:
                  cores.claro ? Brightness.light : Brightness.dark,
              scaffoldBackgroundColor: Colors.transparent,
              primaryColor: cores.primaria,
              colorScheme: (cores.claro
                      ? const ColorScheme.light()
                      : const ColorScheme.dark())
                  .copyWith(
                primary: cores.primaria,
                surface: cores.superficie,
                onSurface: cores.texto,
              ),
              useMaterial3: true,
            ),
            home: Consumer<TemaProvider>(
              builder: (_, __, ___) => const AppNavegacao(),
            ),
          );
        },
      ),
    ),
  );
}
