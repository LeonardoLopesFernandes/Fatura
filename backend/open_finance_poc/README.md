# Open Finance POC (Pluggy)

Backend mínimo do POC do Fatura. Ele entrega as faturas normalizadas em:

```json
{
  "source": "mock",
  "invoices": [
    {
      "institutionName": "Nubank",
      "accountId": "uuid",
      "cardLast4": "4821",
      "dueDate": "2026-11-10T00:00:00.000Z",
      "closingDate": "2026-11-03T00:00:00.000Z",
      "total": 1234.56
    }
  ]
}
```

## Rodar com dados simulados

```bash
cd backend/open_finance_poc
node server.mjs
```

O app usa mock por padrão. Para consumir este backend no emulador Android:

```bash
flutter build apk --debug \
  --dart-define=OPEN_FINANCE_API=http://10.0.2.2:8787
```

Ou, em um dispositivo físico, use o IP da máquina na rede e libere a porta.

## Rodar com Pluggy

Variáveis necessárias:

```bash
export PLUGGY_CLIENT_ID="..."
export PLUGGY_CLIENT_SECRET="..."
export PLUGGY_ITEM_ID="..."
node server.mjs
```

O `PLUGGY_ITEM_ID` é o item criado depois do consentimento no Pluggy Connect.
O backend consulta:

1. `POST /auth` para obter a API key.
2. `GET /items/{itemId}` para identificar a instituição.
3. `GET /accounts?itemId=...` para localizar contas `CREDIT`/`CREDIT_CARD`.
4. `GET /bills?accountId=...` para obter as faturas e usar `totalAmount`.

A Pluggy retorna valores monetários em centavos; o backend converte para reais.

## Próximos passos do POC

- Criar o item via Pluggy Connect Widget (backend gera o `connect_token`).
- Salvar `itemId` e consentimento no backend.
- Agendar sincronização e webhooks de atualização.
- Trocar o mock pelo backend no app e validar 2–3 bancos reais.
