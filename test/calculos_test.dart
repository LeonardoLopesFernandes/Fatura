import 'package:fatura/data/fatura_view_model.dart';
import 'package:fatura/models/compra.dart';
import 'package:fatura/models/mes.dart';
import 'package:fatura/ui/telas/open_finance_tela.dart';
import 'package:fatura/ui/temas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('compra calcula total, parcela e valor pendente', () {
    final compra = Compra(
      id: 'c1',
      compradorId: 'p1',
      bancoId: 'b1',
      descricao: 'Compra',
      valorIndividual: 33.34,
      quantidadeParcelas: 3,
      data: Mes(2026, 1),
      pagasPorMes: {Mes(2026, 1).indice()},
    );

    expect(compra.valorTotal, closeTo(100.02, 0.000001));
    expect(compra.valorPendente, closeTo(66.68, 0.000001));
    expect(compra.parcelaNoMes(Mes(2026, 2)), 2);
    expect(compra.parcelaNoMes(Mes(2026, 4)), 0);
  });

  test('conta fixa materializa todos os meses pulados', () async {
    SharedPreferences.setMockInitialValues({});
    final vm = FaturaViewModel();
    await vm.carregar();
    vm.definirMesSelecionado(Mes(2026, 1));

    final banco = vm.bancos.first;
    final comprador = vm.adicionarComprador('Teste');
    vm.adicionarCompra(
      compradorId: comprador.id,
      bancoId: banco.id,
      descricao: 'Conta fixa',
      valorIndividual: 100,
      quantidadeParcelas: 1,
      data: Mes(2026, 1),
      fixaMensal: true,
    );

    vm.definirMesSelecionado(Mes(2026, 3));

    final geradas =
        vm.compras.where((c) => c.origemFixaId != null).toList();
    expect(geradas.length, 3);
    expect(
      geradas.map((c) => c.data).toSet(),
      {Mes(2026, 1), Mes(2026, 2), Mes(2026, 3)},
    );
  });

  test('editar data mantem o pagamento pela parcela', () async {
    SharedPreferences.setMockInitialValues({});
    final vm = FaturaViewModel();
    await vm.carregar();

    final banco = vm.bancos.first;
    final comprador = vm.adicionarComprador('Teste');
    vm.adicionarCompra(
      compradorId: comprador.id,
      bancoId: banco.id,
      descricao: 'Parcelada',
      valorIndividual: 50,
      quantidadeParcelas: 3,
      data: Mes(2026, 1),
    );
    final compra = vm.compras.last;
    vm.marcarPaga(compra.id, Mes(2026, 1), true);

    vm.editarCompra(
      compra.id,
      data: Mes(2026, 2),
      quantidadeParcelas: 3,
    );
    final atualizada = vm.compras.firstWhere((c) => c.id == compra.id);

    expect(atualizada.pagaNoMes(Mes(2026, 1)), isFalse);
    expect(atualizada.pagaNoMes(Mes(2026, 2)), isTrue);
    expect(vm.faturaDoCompradorNoMes(comprador.id, Mes(2026, 2)), 0);
    expect(vm.faturaDoCompradorNoMes(comprador.id, Mes(2026, 3)), 50);
  });

  testWidgets('POC Open Finance monta com dados simulados', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final vm = FaturaViewModel();
    await vm.carregar();
    final tema = TemaProvider();
    await tema.carregar();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FaturaViewModel>.value(value: vm),
          ChangeNotifierProvider<TemaProvider>.value(value: tema),
        ],
        child: const MaterialApp(home: OpenFinanceScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open Finance (POC)'), findsOneWidget);
    expect(find.text('Nubank'), findsOneWidget);

    final botao = find.textContaining('APLICAR');
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    final hoje = DateTime.now();
    expect(
      vm.faturaInformadaDoBancoNoMes(
        'banco_nubank',
        Mes(hoje.year, hoje.month),
      ),
      closeTo(1234.56, 0.000001),
    );
  });
}
