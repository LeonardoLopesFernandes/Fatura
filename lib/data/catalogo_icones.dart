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
}
