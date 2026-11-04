import http from 'node:http';

const PORT = Number(process.env.PORT || 8787);
const PLUGGY_URL = 'https://api.pluggy.ai';
const CLIENT_ID = process.env.PLUGGY_CLIENT_ID || '';
const CLIENT_SECRET = process.env.PLUGGY_CLIENT_SECRET || '';
const ITEM_ID = process.env.PLUGGY_ITEM_ID || '';

let apiKey = '';
let apiKeyExpiraEm = 0;

function enviar(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
  });
  res.end(JSON.stringify(body));
}

function mockInvoices() {
  const hoje = new Date();
  const mes = hoje.getMonth() + 1;
  const ano = hoje.getFullYear();
  return {
    source: 'mock',
    invoices: [
      {
        institutionName: 'Nubank',
        accountId: 'mock-nubank',
        cardLast4: '4821',
        dueDate: new Date(ano, mes - 1, 10).toISOString(),
        closingDate: new Date(ano, mes - 1, 3).toISOString(),
        total: 1234.56,
      },
      {
        institutionName: 'Mercado Pago',
        accountId: 'mock-mercado-pago',
        cardLast4: '7310',
        dueDate: new Date(ano, mes - 1, 15).toISOString(),
        closingDate: new Date(ano, mes - 1, 8).toISOString(),
        total: 890.12,
      },
      {
        institutionName: 'PicPay',
        accountId: 'mock-picpay',
        cardLast4: '2055',
        dueDate: new Date(ano, mes - 1, 20).toISOString(),
        closingDate: new Date(ano, mes - 1, 13).toISOString(),
        total: 456.78,
      },
    ],
  };
}

async function obterApiKey() {
  if (apiKey && Date.now() < apiKeyExpiraEm) return apiKey;
  const resposta = await fetch(`${PLUGGY_URL}/auth`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      clientId: CLIENT_ID,
      clientSecret: CLIENT_SECRET,
    }),
  });
  if (!resposta.ok) {
    throw new Error(`Pluggy auth ${resposta.status}: ${await resposta.text()}`);
  }
  const dados = await resposta.json();
  apiKey = dados.apiKey;
  apiKeyExpiraEm = Date.now() + 100 * 60 * 1000;
  return apiKey;
}

async function pluggyGet(path) {
  const chave = await obterApiKey();
  const resposta = await fetch(`${PLUGGY_URL}${path}`, {
    headers: { 'X-API-KEY': chave, Accept: 'application/json' },
  });
  if (!resposta.ok) {
    throw new Error(`Pluggy ${path} ${resposta.status}: ${await resposta.text()}`);
  }
  return resposta.json();
}

async function faturasPluggy() {
  const item = await pluggyGet(`/items/${encodeURIComponent(ITEM_ID)}`);
  const banco =
    item?.connector?.name || item?.connector?.primaryUrl || 'Banco';
  const contas = await pluggyGet(
    `/accounts?itemId=${encodeURIComponent(ITEM_ID)}`,
  );
  const cartoes = (contas?.results || []).filter(
    (c) =>
      String(c.type).toUpperCase() === 'CREDIT' &&
      (!c.subtype || String(c.subtype).toUpperCase() === 'CREDIT_CARD'),
  );

  const faturas = [];
  for (const conta of cartoes) {
    const bills = await pluggyGet(
      `/bills?accountId=${encodeURIComponent(conta.id)}&pageSize=24`,
    );
    for (const bill of bills?.results || []) {
      faturas.push({
        institutionName: banco,
        accountId: conta.id,
        cardLast4: conta.number ? String(conta.number).slice(-4) : null,
        dueDate: bill.dueDate,
        closingDate: bill.billClosingDate || null,
        // A Pluggy devolve valores monetários em centavos.
        total: Number(bill.totalAmount || 0) / 100,
      });
    }
  }
  return { source: 'pluggy', invoices: faturas };
}

const servidor = http.createServer(async (req, res) => {
  const url = new URL(req.url || '/', `http://localhost:${PORT}`);
  try {
    if (req.method === 'GET' && url.pathname === '/health') {
      return enviar(res, 200, {
        ok: true,
        mode: CLIENT_ID && CLIENT_SECRET && ITEM_ID ? 'pluggy' : 'mock',
      });
    }
    if (req.method === 'GET' && url.pathname === '/api/invoices') {
      if (!CLIENT_ID || !CLIENT_SECRET || !ITEM_ID) {
        return enviar(res, 200, mockInvoices());
      }
      return enviar(res, 200, await faturasPluggy());
    }
    return enviar(res, 404, { error: 'Rota não encontrada' });
  } catch (e) {
    return enviar(res, 500, { error: String(e?.message || e) });
  }
});

servidor.listen(PORT, '0.0.0.0', () => {
  console.log(`Open Finance POC em http://0.0.0.0:${PORT}`);
  console.log(
    CLIENT_ID && CLIENT_SECRET && ITEM_ID
      ? 'Modo: Pluggy'
      : 'Modo: mock (configure PLUGGY_CLIENT_ID, PLUGGY_CLIENT_SECRET e PLUGGY_ITEM_ID)',
  );
});
