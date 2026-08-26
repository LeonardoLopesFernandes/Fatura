import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/fatura_view_model.dart';
import '../../ui/tema.dart';
import '../../ui/componentes/elementos.dart';
import '../../ui/telas/resumo_tela.dart';
import '../../ui/telas/devedores_tela.dart';
import '../../ui/telas/comprador_detalhe_tela.dart';
import '../../ui/telas/bancos_tela.dart';
import '../../ui/telas/nova_compra_tela.dart';
import '../../ui/telas/fatura_banco_tela.dart';
import '../../ui/telas/banco_formulario_tela.dart';

Route<dynamic> _rotaAnimada(RouteSettings settings, WidgetBuilder builder) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.06);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 260),
  );
}

class AppNavegacao extends StatefulWidget {
  const AppNavegacao({super.key});

  @override
  State<AppNavegacao> createState() => _AppNavegacaoState();
}

class _AppNavegacaoState extends State<AppNavegacao> {
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();
  final List<String> _abas = ['resumo', 'devedores', 'bancos'];
  String _rotaAtual = 'resumo';
  int _indice = 0;

  bool _ehAba(String rota) => _abas.contains(rota);

  String get _tituloAba {
    switch (_indice) {
      case 0:
        return 'Resumo';
      case 1:
        return 'Devedores';
      case 2:
        return 'Bancos';
      default:
        return 'Fatura';
    }
  }

  void _push(String rota, {Object? arguments}) {
    _navigatorKey.currentState!.pushNamed(rota, arguments: arguments);
  }

  void _irParaAba(int i) {
    setState(() => _indice = i);
    _navigatorKey.currentState!
        .pushNamedAndRemoveUntil(_abas[i], (route) => false);
  }

  void _onMudancaRota(Route<dynamic> route) {
    final nome = route.settings.name;
    if (nome != null) {
      setState(() {
        _rotaAtual = nome;
        final idx = _abas.indexOf(nome);
        if (idx >= 0) _indice = idx;
      });
    }
  }

  Future<bool> _aoVoltar() async {
    final nav = _navigatorKey.currentState!;
    if (nav.canPop()) {
      nav.pop();
      return false;
    }
    if (_ehAba(_rotaAtual)) {
      final sair = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Superficie,
          title: const Text('Sair do Faturas?',
              style: TextStyle(color: Branco)),
          content: const Text('Deseja sair do aplicativo',
              style: TextStyle(color: Branco54)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: VermelhoBotao,
                foregroundColor: Branco,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('NÃO',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Correto,
                foregroundColor: Branco,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('SIM',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (sair == true) {
        SystemNavigator.pop();
      }
      return false;
    }
    return false;
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    switch (settings.name) {
      case 'resumo':
        return _rotaAnimada(
          settings,
          (_) => ResumoScreen(
            onAdicionarCompra: (nome) => _push('novaCompra', arguments: nome),
            onDetalharComprador: (id) => _push('detalhe', arguments: id),
            onEditarFaturaBanco: (id) => _push('faturaBanco', arguments: id),
          ),
        );
      case 'devedores':
        return _rotaAnimada(
          settings,
          (_) => DevedoresScreen(
            onAdicionarCompra: (nome) => _push('novaCompra', arguments: nome),
            onDetalharComprador: (id) => _push('detalhe', arguments: id),
          ),
        );
      case 'bancos':
        return _rotaAnimada(
          settings,
          (_) => BancosScreen(
            onNovoBanco: () => _push('novoBanco'),
            onEditarBanco: (id) => _push('editarBanco', arguments: id),
          ),
        );
      case 'detalhe':
        return _rotaAnimada(
          settings,
          (_) => CompradorDetalheScreen(
            compradorId: settings.arguments as String,
            onAdicionarCompra: (nome) => _push('novaCompra', arguments: nome),
            onVoltar: () => _navigatorKey.currentState!.pop(),
          ),
        );
      case 'novaCompra':
        return _rotaAnimada(
          settings,
          (_) => NovaCompraScreen(
            nomePadrao: settings.arguments as String?,
            onNovoBanco: () => _push('novoBanco'),
            onVoltar: () => _navigatorKey.currentState!.pop(),
          ),
        );
      case 'faturaBanco':
        return _rotaAnimada(
          settings,
          (_) => FaturaBancoScreen(
            bancoId: settings.arguments as String,
            mes: vm.mesSelecionado,
            onVoltar: () => _navigatorKey.currentState!.pop(),
          ),
        );
      case 'novoBanco':
        return _rotaAnimada(
          settings,
          (_) => NovoBancoScreen(
            onVoltar: () => _navigatorKey.currentState!.pop(),
          ),
        );
      case 'editarBanco':
        return _rotaAnimada(
          settings,
          (_) => EditarBancoScreen(
            bancoId: settings.arguments as String,
            onVoltar: () => _navigatorKey.currentState!.pop(),
          ),
        );
      default:
        return _rotaAnimada(
          settings,
          (_) => ResumoScreen(
            onAdicionarCompra: (nome) => _push('novaCompra', arguments: nome),
            onDetalharComprador: (id) => _push('detalhe', arguments: id),
            onEditarFaturaBanco: (id) => _push('faturaBanco', arguments: id),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _aoVoltar,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _ehAba(_rotaAtual)
            ? AppBar(
                backgroundColor: FundoInicio,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  _tituloAba,
                  style: const TextStyle(
                    color: Branco,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        body: AppBackground(
          child: Navigator(
            key: _navigatorKey,
            initialRoute: 'resumo',
            observers: [
              _Observer(_onMudancaRota),
            ],
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
        bottomNavigationBar: _ehAba(_rotaAtual)
            ? NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (states) => TextStyle(
                      color: states.contains(WidgetState.selected)
                          ? Branco
                          : Branco54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                child: NavigationBar(
                  backgroundColor: NavBar,
                  indicatorColor: CorPrimaria.withOpacity(0.25),
                  selectedIndex: _indice,
                  onDestinationSelected: _irParaAba,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined, color: Branco54),
                      selectedIcon: Icon(Icons.dashboard, color: Branco),
                      label: 'Resumo',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outlined, color: Branco54),
                      selectedIcon: Icon(Icons.people, color: Branco),
                      label: 'Devedores',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.account_balance_outlined, color: Branco54),
                      selectedIcon: Icon(Icons.account_balance, color: Branco),
                      label: 'Bancos',
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

class _Observer extends NavigatorObserver {
  final void Function(Route<dynamic>) onMudanca;
  _Observer(this.onMudanca);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) =>
      onMudanca(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) onMudanca(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previous) {
    if (previous != null) onMudanca(previous);
  }
}
