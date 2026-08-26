import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fatura/data/fatura_view_model.dart';
import 'package:fatura/ui/telas/banco_formulario_tela.dart';

void main() {
  testWidgets('BancoFormulario (novo) monta sem erro', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final vm = FaturaViewModel();
    await vm.carregar();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FaturaViewModel>.value(
          value: vm,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: BancoFormulario(bancoExistente: null, onVoltar: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Novo Banco'), findsWidgets);
  });

  testWidgets('BancoFormulario (edicao) monta sem erro', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final vm = FaturaViewModel();
    await vm.carregar();
    final banco = vm.bancos.first;
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FaturaViewModel>.value(
          value: vm,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: BancoFormulario(bancoExistente: banco, onVoltar: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Editar'), findsWidgets);
  });
}
