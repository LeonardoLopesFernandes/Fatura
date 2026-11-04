import 'dart:convert';
import 'dart:io';

import '../models/mes.dart';

class OpenFinanceInvoice {
  final String institutionName;
  final String accountId;
  final String? cardLast4;
  final DateTime dueDate;
  final DateTime? closingDate;
  final double total;

  const OpenFinanceInvoice({
    required this.institutionName,
    required this.accountId,
    required this.dueDate,
    required this.total,
    this.cardLast4,
    this.closingDate,
  });

  Mes get mesFatura => Mes(dueDate.year, dueDate.month);

  factory OpenFinanceInvoice.fromJson(Map<String, dynamic> json) {
    final due = DateTime.tryParse(
          (json['dueDate'] ?? json['due_date'] ?? '').toString(),
        ) ??
        DateTime.now();
    final closing = DateTime.tryParse(
      (json['closingDate'] ?? json['closing_date'] ?? '').toString(),
    );
    return OpenFinanceInvoice(
      institutionName: (json['institutionName'] ??
              json['bankName'] ??
              json['name'] ??
              'Banco')
          .toString(),
      accountId: (json['accountId'] ?? json['account_id'] ?? '').toString(),
      cardLast4:
          (json['cardLast4'] ?? json['card_last4'])?.toString(),
      dueDate: due,
      closingDate: closing,
      total: ((json['total'] ?? json['totalAmount'] ?? 0) as num).toDouble(),
    );
  }
}

abstract class OpenFinanceService {
  Future<List<OpenFinanceInvoice>> fetchInvoices();
}

class MockOpenFinanceService implements OpenFinanceService {
  @override
  Future<List<OpenFinanceInvoice>> fetchInvoices() async {
    final hoje = DateTime.now();
    return [
      OpenFinanceInvoice(
        institutionName: 'Nubank',
        accountId: 'mock-nubank',
        cardLast4: '4821',
        dueDate: DateTime(hoje.year, hoje.month, 10),
        closingDate: DateTime(hoje.year, hoje.month, 3),
        total: 1234.56,
      ),
      OpenFinanceInvoice(
        institutionName: 'Mercado Pago',
        accountId: 'mock-mercado-pago',
        cardLast4: '7310',
        dueDate: DateTime(hoje.year, hoje.month, 15),
        closingDate: DateTime(hoje.year, hoje.month, 8),
        total: 890.12,
      ),
      OpenFinanceInvoice(
        institutionName: 'PicPay',
        accountId: 'mock-picpay',
        cardLast4: '2055',
        dueDate: DateTime(hoje.year, hoje.month, 20),
        closingDate: DateTime(hoje.year, hoje.month, 13),
        total: 456.78,
      ),
    ];
  }
}

class HttpOpenFinanceService implements OpenFinanceService {
  final String baseUrl;

  const HttpOpenFinanceService(this.baseUrl);

  @override
  Future<List<OpenFinanceInvoice>> fetchInvoices() async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);
    try {
      final uri = Uri.parse('$baseUrl/api/invoices');
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Open Finance respondeu ${response.statusCode}: $body');
      }
      final decoded = jsonDecode(body);
      final lista = decoded is List
          ? decoded
          : (decoded is Map ? decoded['invoices'] : null);
      if (lista is! List) return [];
      return lista
          .whereType<Map<String, dynamic>>()
          .map(OpenFinanceInvoice.fromJson)
          .toList();
    } finally {
      client.close(force: true);
    }
  }
}

const String openFinanceApiBase =
    String.fromEnvironment('OPEN_FINANCE_API', defaultValue: '');

bool get openFinanceUsandoMock => openFinanceApiBase.trim().isEmpty;

OpenFinanceService criarOpenFinanceService() {
  final base = openFinanceApiBase.trim().replaceAll(RegExp(r'/+$'), '');
  if (base.isEmpty) return MockOpenFinanceService();
  return HttpOpenFinanceService(base);
}
