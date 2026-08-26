import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/banco.dart';
import '../models/comprador.dart';
import '../models/compra.dart';
import '../models/mes.dart';
import '../models/grupo.dart';
import 'catalogo_cores.dart';
import 'catalogo_icones.dart';
import '../util/formatadores.dart';

class FaturaViewModel extends ChangeNotifier {
  FaturaViewModel() {
    _mesSelecionado = hojeMes();
  }

  late Mes _mesSelecionado;
  List<Banco> _bancos = [];
  List<Comprador> _compradores = [];
  List<Compra> _compras = [];
  Map<String, double> _faturas = {};

  int _sequencia = 0;

  Mes get mesSelecionado => _mesSelecionado;
  List<Banco> get bancos => _bancos;
  List<Comprador> get compradores => _compradores;
  List<Compra> get compras => _compras;
  Map<String, double> get faturas => _faturas;

  void definirMesSelecionado(Mes mes) {
    _mesSelecionado = mes;
    notifyListeners();
  }

  String _chaveFatura(String bancoId, Mes mes) =>
      '$bancoId|${mes.ano}-${mes.mes}';

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final texto = prefs.getString('fatura.dados.v1');
    if (texto == null || texto.isEmpty) {
      _bancos = _bancosPadrao();
      _persistir();
      notifyListeners();
      return;
    }
    try {
      final json = jsonDecode(texto) as Map<String, dynamic>;
      final listaBancos = json['bancos'] as List?;
      if (listaBancos == null || listaBancos.isEmpty) {
        _bancos = _bancosPadrao();
      } else {
        _bancos = listaBancos
            .map((e) => Banco.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _compradores = (json['compradores'] as List? ?? [])
          .map((e) => Comprador.fromJson(e as Map<String, dynamic>))
          .toList();
      _compras = (json['compras'] as List? ?? [])
          .map((e) => Compra.fromJson(e as Map<String, dynamic>))
          .toList();
      _faturas = {};
      final fat = json['faturas'] as Map<String, dynamic>? ?? {};
      fat.forEach((k, v) => _faturas[k] = (v as num).toDouble());
    } catch (_) {
      _bancos = _bancosPadrao();
    }
    notifyListeners();
  }

  List<Banco> _bancosPadrao() {
    return [
      Banco(
        id: 'banco_nubank',
        nome: 'Nubank',
        cor: 0xFF8A05BE,
        iconeRes: 'ic_nubank',
      ),
      Banco(
        id: 'banco_mercado_pago',
        nome: 'Mercado Pago',
        cor: 0xFF00B1EA,
        iconeRes: 'ic_mercado_pago',
        corDoIcone: 0xFF00B1EA,
      ),
      Banco(
        id: 'banco_picpay',
        nome: 'PicPay',
        cor: 0xFF11C76F,
        iconeRes: 'ic_picpay',
      ),
      Banco(
        id: 'banco_santander',
        nome: 'Santander',
        cor: 0xFFCC0000,
        iconeRes: 'ic_santander',
      ),
      Banco(
        id: 'banco_inter',
        nome: 'Inter',
        cor: 0xFFFF7A00,
        iconeChave: 'account_balance',
      ),
      Banco(
        id: 'banco_brasilcard',
        nome: 'BrasilCard',
        cor: 0xFF00542B,
        iconeRes: 'ic_brasilcard',
      ),
      Banco(
        id: 'cobranca_internet',
        nome: 'Internet',
        cor: 0xFF06B6D4,
        iconeChave: 'wifi',
      ),
      Banco(
        id: 'cobranca_luz',
        nome: 'Luz',
        cor: 0xFFFACC15,
        iconeChave: 'lightbulb',
      ),
      Banco(
        id: 'cobranca_agua',
        nome: 'Água',
        cor: 0xFF22D3EE,
        iconeChave: 'water_drop',
      ),
      Banco(
        id: 'cobranca_aluguel',
        nome: 'Aluguel',
        cor: 0xFFC084FC,
        iconeChave: 'home_work',
      ),
    ];
  }

  String novoId(String prefixo) {
    _sequencia += 1;
    return '${prefixo}_${DateTime.now().microsecondsSinceEpoch}_$_sequencia';
  }

  void _alterado() {
    _persistir();
    notifyListeners();
  }

  void _persistir() {
    try {
      final prefs = SharedPreferences.getInstance();
      prefs.then((p) {
        p.setString('fatura.dados.v1', exportarJson());
      });
    } catch (_) {}
  }

  Map<String, dynamic> montarJson() {
    return {
      'bancos': _bancos.map((b) => b.toJson()).toList(),
      'compradores': _compradores.map((c) => c.toJson()).toList(),
      'compras': _compras.map((c) => c.toJson()).toList(),
      'faturas': _faturas,
    };
  }

  String exportarJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(montarJson());
  }

  bool importarJson(String jsonTexto) {
    try {
      final json = jsonDecode(jsonTexto) as Map<String, dynamic>;
      _bancos = (json['bancos'] as List? ?? [])
          .map((e) => Banco.fromJson(e as Map<String, dynamic>))
          .toList();
      _compradores = (json['compradores'] as List? ?? [])
          .map((e) => Comprador.fromJson(e as Map<String, dynamic>))
          .toList();
      _compras = (json['compras'] as List? ?? [])
          .map((e) => Compra.fromJson(e as Map<String, dynamic>))
          .toList();
      _faturas = {};
      final fat = json['faturas'] as Map<String, dynamic>? ?? {};
      fat.forEach((k, v) => _faturas[k] = (v as num).toDouble());
      _alterado();
      return true;
    } catch (_) {
      return false;
    }
  }

  Banco? bancoPorId(String id) =>
      _bancos.where((b) => b.id == id).firstOrNull;

  Comprador? compradorPorId(String id) =>
      _compradores.where((c) => c.id == id).firstOrNull;

  Comprador? compradorPorNome(String nome) {
    final n = nome.trim().toLowerCase();
    for (final c in _compradores) {
      if (c.nome.trim().toLowerCase() == n) return c;
    }
    return null;
  }

  double faturaInformadaDoBancoNoMes(String bancoId, Mes mes) =>
      _faturas[_chaveFatura(bancoId, mes)] ?? 0.0;

  void definirFaturaDoBancoNoMes(String bancoId, Mes mes, double valor) {
    final chave = _chaveFatura(bancoId, mes);
    if (valor <= 0) {
      _faturas.remove(chave);
    } else {
      _faturas[chave] = valor;
    }
    _alterado();
  }

  double totalComprasDoBancoNoMes(String bancoId, Mes mes) {
    return _compras
        .where((c) =>
            c.bancoId == bancoId && c.ativaNoMes(mes))
        .fold(0.0, (s, c) => s + c.valorIndividual);
  }

  double saldoDoBancoNoMes(String bancoId, Mes mes) {
    final fatura = faturaInformadaDoBancoNoMes(bancoId, mes);
    final compras = totalComprasDoBancoNoMes(bancoId, mes);
    if (fatura <= 0) return compras;
    final saldo = fatura - compras;
    return saldo < 0 ? 0.0 : saldo;
  }

  List<String> get iconesDisponiveis {
    final usados = _bancos.map((b) => b.iconeChave).whereType<String>().toSet();
    return IconesCatalogo.CHAVES_ESCOLHA
        .where((c) => !usados.contains(c))
        .toList();
  }

  List<String> iconesDisponiveisPara(String? ignorarBancoId) {
    final usados = _bancos
        .where((b) => b.id != ignorarBancoId)
        .map((b) => b.iconeChave)
        .whereType<String>()
        .toSet();
    return IconesCatalogo.CHAVES_ESCOLHA
        .where((c) => !usados.contains(c))
        .toList();
  }

  List<int> get coresDisponiveis {
    final usadas = _bancos.map((b) => b.cor).toSet();
    return CoresCatalogo.CORES.where((c) => !usadas.contains(c)).toList();
  }

  List<int> coresDisponiveisPara(String? ignorarBancoId) {
    final usadas = _bancos
        .where((b) => b.id != ignorarBancoId)
        .map((b) => b.cor)
        .toSet();
    final resultado = CoresCatalogo.CORES.where((c) => !usadas.contains(c)).toList();
    final atual = bancoPorId(ignorarBancoId!);
    if (atual != null && !resultado.contains(atual.cor)) {
      resultado.insert(0, atual.cor);
    }
    return resultado;
  }

  List<Compra> comprasDoComprador(String id) =>
      _compras.where((c) => c.compradorId == id).toList();

  List<Compra> comprasDoCompradorNoMes(String id, Mes mes) =>
      _compras
          .where((c) => c.compradorId == id && c.ativaNoMes(mes))
          .toList();

  List<Compra> comprasDoBanco(String id) =>
      _compras.where((c) => c.bancoId == id).toList();

  List<Compra> comprasDoBancoNoMes(String id, Mes mes) =>
      _compras
          .where((c) => c.bancoId == id && c.ativaNoMes(mes))
          .toList();

  List<Compra> comprasNoMes(Mes mes) =>
      _compras.where((c) => c.ativaNoMes(mes)).toList();

  double faturaDoComprador(String id) => comprasDoComprador(id)
      .fold(0.0, (s, c) => s + c.valorTotal);

  double faturaDoCompradorNoMes(String id, Mes mes) =>
      comprasDoCompradorNoMes(id, mes)
          .fold(0.0, (s, c) => s + c.valorIndividual);

  double faturaDoBanco(String id) =>
      comprasDoBanco(id).fold(0.0, (s, c) => s + c.valorTotal);

  double faturaDoBancoNoMes(String id, Mes mes) =>
      comprasDoBancoNoMes(id, mes)
          .fold(0.0, (s, c) => s + c.valorIndividual);

  double get totalCartao =>
      _compras.fold(0.0, (s, c) => s + c.valorTotal);

  double totalCartaoNoMes(Mes mes) => _compras
      .where((c) => c.ativaNoMes(mes))
      .fold(0.0, (s, c) => s + c.valorIndividual);

  double diferencaDoCompradorNoMes(String id, Mes mes) =>
      totalCartaoNoMes(mes) - faturaDoCompradorNoMes(id, mes);

  Banco? bancoPrincipalDoComprador(String id) {
    final lista = comprasDoComprador(id);
    if (lista.isEmpty) return null;
    return bancoPorId(lista.last.bancoId);
  }

  bool temFaturaInformada(String bancoId) => _faturas.keys
      .any((k) => k.startsWith('$bancoId|') && _faturas[k]! > 0);

  Banco adicionarBanco({
    required String nome,
    required int cor,
    String? iconeChave,
    String? caminhoImagem,
  }) {
    if (_bancos.any((b) => b.iconeChave == iconeChave && iconeChave != null)) {
      throw ArgumentError('Ícone já utilizado');
    }
    if (_bancos.any((b) => b.cor == cor)) {
      throw ArgumentError('Cor já utilizada');
    }
    final banco = Banco(
      id: novoId('banco'),
      nome: nome,
      cor: cor,
      iconeChave: iconeChave,
      iconeArquivo: caminhoImagem,
    );
    _bancos.add(banco);
    _alterado();
    return banco;
  }

  bool removerBanco(String id) {
    if (comprasDoBanco(id).isNotEmpty) return false;
    _bancos.removeWhere((b) => b.id == id);
    _alterado();
    return true;
  }

  void atualizarBanco({
    required String id,
    required String nome,
    required int cor,
    String? iconeChave,
    String? caminhoImagem,
  }) {
    final atual = bancoPorId(id);
    if (atual == null) return;
    if (_bancos.any((b) =>
        b.id != id && b.iconeChave == iconeChave && iconeChave != null)) {
      throw ArgumentError('Ícone já utilizado');
    }
    if (_bancos.any((b) => b.id != id && b.cor == cor)) {
      throw ArgumentError('Cor já utilizada');
    }
    _bancos = _bancos.map((b) {
      if (b.id != id) return b;
      return b.copyWith(
        nome: nome,
        cor: cor,
        iconeChave: iconeChave,
        iconeArquivo: caminhoImagem ?? atual.iconeArquivo,
        iconeRes: atual.iconeRes,
        corDoIcone: atual.corDoIcone,
      );
    }).toList();
    _alterado();
  }

  void reordenarBancos(int indiceAntigo, int indiceNovo) {
    if (indiceNovo == indiceAntigo) return;
    final banco = _bancos.removeAt(indiceAntigo);
    var novo = indiceNovo;
    if (novo > indiceAntigo) novo -= 1;
    _bancos.insert(novo, banco);
    _alterado();
  }

  Comprador obterOuCriarComprador({required String nome}) {
    final existente = compradorPorNome(nome);
    if (existente != null) return existente;
    return adicionarComprador(nome);
  }

  Comprador adicionarComprador(String nome) {
    final comprador =
        Comprador(id: novoId('comprador'), nome: nome);
    _compradores.add(comprador);
    _alterado();
    return comprador;
  }

  bool removerComprador(String id) {
    _compradores.removeWhere((c) => c.id == id);
    _compras.removeWhere((c) => c.compradorId == id);
    _alterado();
    return true;
  }

  void adicionarCompra({
    required String compradorId,
    required String bancoId,
    required String descricao,
    required double valorIndividual,
    required int quantidadeParcelas,
    required Mes data,
  }) {
    _compras.add(Compra(
      id: novoId('compra'),
      compradorId: compradorId,
      bancoId: bancoId,
      descricao: descricao,
      valorIndividual: valorIndividual,
      quantidadeParcelas: quantidadeParcelas,
      data: data,
    ));
    _alterado();
  }

  void removerCompra(String id) {
    _compras.removeWhere((c) => c.id == id);
    _alterado();
  }

  List<Grupo> agruparPorBanco(List<Compra> compras) {
    final mapa = <String, Grupo>{};
    for (final compra in compras) {
      final banco = bancoPorId(compra.bancoId);
      if (banco == null) continue;
      if (mapa.containsKey(banco.id)) {
        mapa[banco.id]!.compras.add(compra);
      } else {
        mapa[banco.id] = Grupo(banco, [compra]);
      }
    }
    return mapa.values.toList();
  }
}
