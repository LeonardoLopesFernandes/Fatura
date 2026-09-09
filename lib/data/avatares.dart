import 'package:flutter/material.dart';

class Avatares {
  static const List<Map<String, dynamic>> DISPONIVEIS = [
    {'chave': 'pessoa', 'icone': Icons.person, 'label': 'Pessoa'},
    {'chave': 'rosto', 'icone': Icons.face, 'label': 'Rosto'},
    {'chave': 'casal', 'icone': Icons.people, 'label': 'Casal'},
    {'chave': 'familia', 'icone': Icons.family_restroom, 'label': 'Família'},
    {'chave': 'amigo', 'icone': Icons.emoji_people, 'label': 'Amigo'},
    {'chave': 'trabalho', 'icone': Icons.badge, 'label': 'Trabalho'},
    {'chave': 'estudante', 'icone': Icons.school, 'label': 'Estudante'},
    {'chave': 'saude', 'icone': Icons.medical_services, 'label': 'Saúde'},
    {'chave': 'esporte', 'icone': Icons.sports_soccer, 'label': 'Esporte'},
    {'chave': 'musica', 'icone': Icons.music_note, 'label': 'Música'},
    {'chave': 'viagem', 'icone': Icons.flight, 'label': 'Viagem'},
    {'chave': 'casa', 'icone': Icons.home, 'label': 'Casa'},
  ];

  static IconData iconePorChave(String? chave) {
    if (chave == null) return Icons.person;
    for (final item in DISPONIVEIS) {
      if (item['chave'] == chave) return item['icone'] as IconData;
    }
    return Icons.person;
  }
}
