import 'package:flutter/material.dart';

class IconesCatalogo {
  static const List<String> CHAVES_ESCOLHA = [
    'account_balance_wallet',
    'credit_card',
    'rocket_launch',
    'diamond',
    'storefront',
    'savings',
    'shopping_bag',
    'currency_bitcoin',
    'flight_takeoff',
    'local_gas_station',
    'set_meal',
    'agriculture',
    'pets',
    'bolt',
  ];

  static const Map<String, IconData> CHAVE_PARA_ICONE = {
    'account_balance_wallet': Icons.account_balance_wallet,
    'credit_card': Icons.credit_card,
    'rocket_launch': Icons.rocket_launch,
    'diamond': Icons.diamond_outlined,
    'storefront': Icons.storefront,
    'savings': Icons.savings,
    'shopping_bag': Icons.shopping_bag,
    'currency_bitcoin': Icons.currency_bitcoin,
    'flight_takeoff': Icons.flight_takeoff,
    'local_gas_station': Icons.local_gas_station,
    'set_meal': Icons.set_meal,
    'agriculture': Icons.agriculture,
    'pets': Icons.pets,
    'bolt': Icons.bolt,
    'account_balance': Icons.account_balance,
    'wifi': Icons.wifi,
    'lightbulb': Icons.lightbulb,
    'water_drop': Icons.water_drop,
    'home_work': Icons.home_work,
  };

  static IconData? iconePorChave(String? chave) =>
      chave == null ? null : CHAVE_PARA_ICONE[chave];

  static const Map<String, String> ROTULOS = {
    'account_balance_wallet': 'Carteira',
    'credit_card': 'Cartão',
    'rocket_launch': 'Foguete',
    'diamond': 'Diamante',
    'storefront': 'Loja',
    'savings': 'Cofre',
    'shopping_bag': 'Compras',
    'currency_bitcoin': 'Bitcoin',
    'flight_takeoff': 'Viagem',
    'local_gas_station': 'Posto',
    'set_meal': 'Comida',
    'agriculture': 'Fazenda',
    'pets': 'Pet',
    'bolt': 'Energia',
    'account_balance': 'Banco',
    'wifi': 'Wi-Fi',
    'lightbulb': 'Luz',
    'water_drop': 'Água',
    'home_work': 'Casa',
  };

  static String rotulo(String chave) => ROTULOS[chave] ?? chave;
}
