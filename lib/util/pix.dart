String _campo(String id, String valor) {
  return '$id${valor.length.toString().padLeft(2, '0')}$valor';
}

const _acentos = {
  'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

String _sanearNome(String texto, int max) {
  final lower = texto.toLowerCase().trim();
  final semAcento =
      lower.split('').map((c) => _acentos[c] ?? c).join();
  final limpo = semAcento
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final resultado = limpo.isEmpty ? 'RECEBEDOR' : limpo;
  return resultado.length > max ? resultado.substring(0, max) : resultado;
}

int _crc16(String dados) {
  var crc = 0xFFFF;
  for (var i = 0; i < dados.length; i++) {
    crc ^= dados.codeUnitAt(i) << 8;
    for (var j = 0; j < 8; j++) {
      crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
      crc &= 0xFFFF;
    }
  }
  return crc;
}

String gerarPixCopiaECola({
  required String chave,
  required double valor,
  String nome = 'FATURAS APP',
  String cidade = 'BRASIL',
  String txid = 'FATURA',
}) {
  final chaveLimpa = chave.trim();
  final merchant = _campo('00', 'br.gov.bcb.pix') + _campo('01', chaveLimpa);
  final payload = _campo('00', '01') +
      _campo('26', merchant) +
      _campo('52', '0000') +
      _campo('53', '986') +
      _campo('54', valor.toStringAsFixed(2)) +
      _campo('58', 'BR') +
      _campo('59', _sanearNome(nome, 25)) +
      _campo('60', _sanearNome(cidade, 15)) +
      _campo('62', _campo('05', _sanearNome(txid, 25).replaceAll(' ', ''))) +
      '6304';
  final crc = _crc16(payload).toRadixString(16).toUpperCase().padLeft(4, '0');
  return payload + crc;
}
