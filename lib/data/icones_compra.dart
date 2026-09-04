import 'package:flutter/material.dart';

class IconesCompra {
  static const List<Map<String, dynamic>> DISPONIVEIS = [
    {'chave': 'padrao', 'icone': Icons.shopping_bag, 'label': 'Padrão'},
    {'chave': 'uber', 'icone': Icons.directions_car, 'label': 'Uber'},
    {'chave': '99', 'icone': Icons.local_taxi, 'label': '99'},
    {'chave': 'tiktok', 'icone': Icons.music_note, 'label': 'TikTok'},
    {'chave': 'ifood', 'icone': Icons.restaurant, 'label': 'iFood'},
    {'chave': 'netflix', 'icone': Icons.movie, 'label': 'Netflix'},
    {'chave': 'spotify', 'icone': Icons.music_note, 'label': 'Spotify'},
    {'chave': 'youtube', 'icone': Icons.play_circle, 'label': 'YouTube'},
    {'chave': 'amazon', 'icone': Icons.shopping_bag, 'label': 'Amazon'},
    {'chave': 'mercado', 'icone': Icons.shopping_cart, 'label': 'Mercado'},
    {'chave': 'celular', 'icone': Icons.phone_android, 'label': 'Celular'},
    {'chave': 'internet', 'icone': Icons.wifi, 'label': 'Internet'},
    {'chave': 'luz', 'icone': Icons.lightbulb, 'label': 'Luz'},
    {'chave': 'agua', 'icone': Icons.water_drop, 'label': 'Água'},
    {'chave': 'gas', 'icone': Icons.local_gas_station, 'label': 'Gás'},
    {'chave': 'aluguel', 'icone': Icons.home, 'label': 'Aluguel'},
    {'chave': 'escola', 'icone': Icons.school, 'label': 'Escola'},
    {'chave': 'academia', 'icone': Icons.fitness_center, 'label': 'Academia'},
    {'chave': 'farmacia', 'icone': Icons.local_pharmacy, 'label': 'Farmácia'},
    {'chave': 'hospital', 'icone': Icons.local_hospital, 'label': 'Hospital'},
    {'chave': 'supermercado', 'icone': Icons.shopping_cart, 'label': 'Supermercado'},
    {'chave': 'padaria', 'icone': Icons.bakery_dining, 'label': 'Padaria'},
    {'chave': 'posto', 'icone': Icons.local_gas_station, 'label': 'Posto'},
    {'chave': 'frete', 'icone': Icons.local_shipping, 'label': 'Frete'},
    {'chave': 'delivery', 'icone': Icons.local_shipping, 'label': 'Delivery'},
    {'chave': 'motoboy', 'icone': Icons.two_wheeler, 'label': 'Motoboy'},
    {'chave': 'estacionamento', 'icone': Icons.local_parking, 'label': 'Estacionamento'},
    {'chave': 'pedagio', 'icone': Icons.toll, 'label': 'Pedágio'},
    {'chave': 'seguro', 'icone': Icons.security, 'label': 'Seguro'},
    {'chave': 'cinema', 'icone': Icons.movie, 'label': 'Cinema'},
    {'chave': 'show', 'icone': Icons.music_note, 'label': 'Show'},
    {'chave': 'festa', 'icone': Icons.celebration, 'label': 'Festa'},
    {'chave': 'presente', 'icone': Icons.card_giftcard, 'label': 'Presente'},
    {'chave': 'roupa', 'icone': Icons.checkroom, 'label': 'Roupa'},
    {'chave': 'calcado', 'icone': Icons.shopping_bag, 'label': 'Calçado'},
    {'chave': 'tenis', 'icone': Icons.shopping_bag, 'label': 'Tênis'},
    {'chave': 'livro', 'icone': Icons.menu_book, 'label': 'Livro'},
    {'chave': 'curso', 'icone': Icons.school, 'label': 'Curso'},
    {'chave': 'remedio', 'icone': Icons.local_pharmacy, 'label': 'Remédio'},
    {'chave': 'musculacao', 'icone': Icons.fitness_center, 'label': 'Musculação'},
    {'chave': 'barber', 'icone': Icons.content_cut, 'label': 'Barber'},
    {'chave': 'cabelo', 'icone': Icons.content_cut, 'label': 'Cabelo'},
    {'chave': 'salao', 'icone': Icons.content_cut, 'label': 'Salão'},
    {'chave': 'pet', 'icone': Icons.pets, 'label': 'Pet'},
    {'chave': 'veterinario', 'icone': Icons.pets, 'label': 'Veterinário'},
    {'chave': 'jardim', 'icone': Icons.yard, 'label': 'Jardim'},
    {'chave': 'decoracao', 'icone': Icons.home, 'label': 'Decoração'},
    {'chave': 'moveis', 'icone': Icons.chair, 'label': 'Móveis'},
    {'chave': 'eletro', 'icone': Icons.devices, 'label': 'Eletrônico'},
    {'chave': 'computador', 'icone': Icons.computer, 'label': 'Computador'},
    {'chave': 'notebook', 'icone': Icons.laptop, 'label': 'Notebook'},
    {'chave': 'tablet', 'icone': Icons.tablet, 'label': 'Tablet'},
    {'chave': 'camera', 'icone': Icons.camera_alt, 'label': 'Câmera'},
    {'chave': 'fone', 'icone': Icons.headphones, 'label': 'Fone'},
    {'chave': 'tv', 'icone': Icons.tv, 'label': 'TV'},
    {'chave': 'jogo', 'icone': Icons.sports_esports, 'label': 'Jogo'},
    {'chave': 'apple', 'icone': Icons.phone_iphone, 'label': 'Apple'},
    {'chave': 'samsung', 'icone': Icons.phone_iphone, 'label': 'Samsung'},
    {'chave': '-airpods', 'icone': Icons.headphones, 'label': 'AirPods'},
    {'chave': 'applewatch', 'icone': Icons.watch, 'label': 'Apple Watch'},
    {'chave': 'imac', 'icone': Icons.computer, 'label': 'iMac'},
  ];

  static final Map<String, IconData> _mapa = {
    'uber': Icons.directions_car,
    '99': Icons.local_taxi,
    'tiktok': Icons.music_note,
    'ifood': Icons.restaurant,
    'netflix': Icons.movie,
    'spotify': Icons.music_note,
    'youtube': Icons.play_circle,
    'amazon': Icons.shopping_bag,
    'mercado': Icons.shopping_cart,
    'celular': Icons.phone_android,
    'internet': Icons.wifi,
    'luz': Icons.lightbulb,
    'agua': Icons.water_drop,
    'gas': Icons.local_gas_station,
    'aluguel': Icons.home,
    'escola': Icons.school,
    'academia': Icons.fitness_center,
    'farmacia': Icons.local_pharmacy,
    'hospital': Icons.local_hospital,
    'supermercado': Icons.shopping_cart,
    'padaria': Icons.bakery_dining,
    'posto': Icons.local_gas_station,
    'frete': Icons.local_shipping,
    'delivery': Icons.local_shipping,
    'motoboy': Icons.two_wheeler,
    'estacionamento': Icons.local_parking,
    'pedagio': Icons.toll,
    'seguro': Icons.security,
    'cinema': Icons.movie,
    'show': Icons.music_note,
    'festa': Icons.celebration,
    'presente': Icons.card_giftcard,
    'roupa': Icons.checkroom,
    'calcado': Icons.shopping_bag,
    'tenis': Icons.shopping_bag,
    'livro': Icons.menu_book,
    'curso': Icons.school,
    'remedio': Icons.local_pharmacy,
    'musculacao': Icons.fitness_center,
    'barber': Icons.content_cut,
    'cabelo': Icons.content_cut,
    'salao': Icons.content_cut,
    'pet': Icons.pets,
    'veterinario': Icons.pets,
    'jardim': Icons.yard,
    'decoracao': Icons.home,
    'moveis': Icons.chair,
    'eletro': Icons.devices,
    'computador': Icons.computer,
    'notebook': Icons.laptop,
    'tablet': Icons.tablet,
    'camera': Icons.camera_alt,
    'fone': Icons.headphones,
    'tv': Icons.tv,
    'jogo': Icons.sports_esports,
    'apple': Icons.phone_iphone,
    'samsung': Icons.phone_iphone,
    'airpods': Icons.headphones,
    'applewatch': Icons.watch,
    'imac': Icons.computer,
  };

  static IconData iconePorChave(String? chave) {
    if (chave == null || chave == 'padrao') return Icons.shopping_bag;
    return _mapa[chave] ?? Icons.shopping_bag;
  }

  static IconData iconePorDescricao(String descricao) {
    final lower = descricao.toLowerCase().trim();
    for (final entry in _mapa.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.shopping_bag;
  }

  static String? chavePorDescricao(String descricao) {
    final lower = descricao.toLowerCase().trim();
    for (final entry in _mapa.entries) {
      if (lower.contains(entry.key)) {
        return entry.key;
      }
    }
    return null;
  }
}
