import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String _canalId = 'lembretes_fatura';
const String _canalNome = 'Lembretes de fatura';
const int _idNotificacao = 0;

final FlutterLocalNotificationsPlugin _plugin =
    FlutterLocalNotificationsPlugin();

Future<void> inicializarNotificacoes() async {
  try {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  } catch (_) {}
}

Future<void> agendarLembretes(bool ativo) async {
  try {
    if (!ativo) {
      await _plugin.cancel(_idNotificacao);
      return;
    }
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await _plugin.periodicallyShow(
      _idNotificacao,
      'Lembretes de fatura',
      'Não esqueça de conferir as faturas do mês.',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          _canalNome,
          channelDescription: 'Avisos sobre as faturas cadastradas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
  } catch (_) {}
}

Future<void> cancelarLembretes() => agendarLembretes(false);

Future<void> notificarVencimentos(List<String> linhas) async {
  try {
    if (linhas.isEmpty) return;
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await _plugin.show(
      1,
      'Vencimento próximo',
      linhas.join('\n'),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          _canalNome,
          channelDescription: 'Avisos sobre as faturas cadastradas',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  } catch (_) {}
}
