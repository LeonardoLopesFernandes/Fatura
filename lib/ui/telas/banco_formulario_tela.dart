import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/fatura_view_model.dart';
import '../../data/catalogo_icones.dart';
import '../../models/banco.dart';
import '../../models/mes.dart';
import '../../ui/tema.dart';
import '../../ui/temas.dart';
import '../../ui/componentes/campo.dart';
import '../../util/formatadores.dart';
import '../../util/currency_input_formatter.dart';

class BancoFormulario extends StatefulWidget {
  final Banco? bancoExistente;
  final VoidCallback onVoltar;

  const BancoFormulario({
    super.key,
    this.bancoExistente,
    required this.onVoltar,
  });

  @override
  State<BancoFormulario> createState() => _BancoFormularioState();
}

class _BancoFormularioState extends State<BancoFormulario> {
  final _nome = TextEditingController();
  final _fatura = TextEditingController();
  final _pix = TextEditingController();
  final _vencimento = TextEditingController();
  final _focoNome = FocusNode();
  final _focoFatura = FocusNode();
  final _focoPix = FocusNode();
  final _focoVencimento = FocusNode();
  String? _iconeSelecionado;
  int _corSelecionada = 0;
  String? _imagemSelecionada;
  String? _aviso;
  bool _extraindoCor = false;
  bool _pickerAberto = false;
  late final bool _editando;

  List<String> get _iconesDisponiveis =>
      Provider.of<FaturaViewModel>(context, listen: false)
          .iconesDisponiveisPara(widget.bancoExistente?.id);

  List<int> get _coresDisponiveis =>
      Provider.of<FaturaViewModel>(context, listen: false)
          .coresDisponiveisPara(widget.bancoExistente?.id);

  @override
  void initState() {
    super.initState();
    _editando = widget.bancoExistente != null;
    _nome.text = widget.bancoExistente?.nome ?? '';
    _pix.text = widget.bancoExistente?.chavePix ?? '';
    final dia = widget.bancoExistente?.diaVencimento;
    _vencimento.text = dia != null ? '$dia' : '';
    _iconeSelecionado = widget.bancoExistente?.iconeChave;
    _corSelecionada = widget.bancoExistente?.cor ?? 0;
    _imagemSelecionada = widget.bancoExistente?.iconeArquivo;
    if (_editando) {
      final vm = Provider.of<FaturaViewModel>(context, listen: false);
      final f = vm.faturaInformadaDoBancoNoMes(
          widget.bancoExistente!.id, hojeMes());
      _fatura.text = f > 0 ? formatarMoeda(f) : '';
    } else {
      final icones = _iconesDisponiveis;
      final cores = _coresDisponiveis;
      if (icones.isNotEmpty) _iconeSelecionado = icones.first;
      if (cores.isNotEmpty) _corSelecionada = cores.first;
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _fatura.dispose();
    _pix.dispose();
    _vencimento.dispose();
    _focoNome.dispose();
    _focoFatura.dispose();
    _focoPix.dispose();
    _focoVencimento.dispose();
    super.dispose();
  }

  Future<void> _escolherImagem() async {
    try {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(source: ImageSource.gallery);
      if (imagem == null) return;
      final dir =
          Directory('${(await getApplicationDocumentsDirectory()).path}/icones');
      await dir.create(recursive: true);
      final ext = imagem.path.split('.').last;
      final destino = '${dir.path}/logo_${DateTime.now().microsecondsSinceEpoch}.$ext';
      await File(imagem.path).copy(destino);
      setState(() {
        _imagemSelecionada = destino;
        _iconeSelecionado = null;
      });
    } catch (_) {
      setState(() => _aviso = 'Não foi possível abrir a galeria.');
    }
  }

  Future<void> _usarCorDoLogo() async {
    if (_imagemSelecionada == null) return;
    setState(() {
      _extraindoCor = true;
      _aviso = null;
    });
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(File(_imagemSelecionada!)),
        maximumColorCount: 20,
      );
      final cor =
          palette.dominantColor?.color ?? palette.vibrantColor?.color;
      if (cor == null) {
        setState(() {
          _extraindoCor = false;
          _aviso = 'Não foi possível extrair a cor do logo.';
        });
        return;
      }
      setState(() {
        _corSelecionada = cor.toARGB32();
        _extraindoCor = false;
      });
    } catch (_) {
      setState(() {
        _extraindoCor = false;
        _aviso = 'Não foi possível extrair a cor do logo.';
      });
    }
  }

  Future<void> _abrirPickerCor() async {
    if (_pickerAberto) return;
    _pickerAberto = true;
    try {
      Color temp = Color(_corSelecionada);
      final escolhida = await showDialog<Color>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: context.cores.superficie,
          title: Text('Cor personalizada',
              style: TextStyle(color: context.cores.texto)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: temp,
              onColorChanged: (c) => temp = c,
              enableAlpha: false,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child:
                  Text('Cancelar', style: TextStyle(color: context.cores.textoSuave)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(temp),
          child: Text('Usar cor',
                style: TextStyle(color: context.cores.azulClaro)),
            ),
          ],
        ),
      );
      if (escolhida != null && mounted) {
        setState(() => _corSelecionada = escolhida.toARGB32());
      }
    } finally {
      _pickerAberto = false;
    }
  }

  void _salvar() {
    final vm = Provider.of<FaturaViewModel>(context, listen: false);
    if (_nome.text.trim().isEmpty) {
      setState(() => _aviso = 'Informe o nome do banco.');
      return;
    }
    if (_imagemSelecionada == null && _iconeSelecionado == null) {
      setState(() => _aviso = 'Escolha um ícone ou uma imagem da galeria.');
      return;
    }
    try {
      if (_editando) {
        vm.atualizarBanco(
          id: widget.bancoExistente!.id,
          nome: _nome.text.trim(),
          cor: _corSelecionada,
          iconeChave: _iconeSelecionado,
          caminhoImagem: _imagemSelecionada,
          chavePix: _pix.text,
          diaVencimento: int.tryParse(_vencimento.text.trim()),
        );
        final v = valorDeEntradaBr(_fatura.text);
        if (v > 0) {
          vm.definirFaturaDoBancoNoMes(
              widget.bancoExistente!.id, hojeMes(), v);
        }
      } else {
        vm.adicionarBanco(
          nome: _nome.text.trim(),
          cor: _corSelecionada,
          iconeChave: _iconeSelecionado,
          caminhoImagem: _imagemSelecionada,
          chavePix: _pix.text,
          diaVencimento: int.tryParse(_vencimento.text.trim()),
        );
      }
      widget.onVoltar();
    } catch (_) {
      setState(() => _aviso = 'Ícone ou cor já utilizados por outro banco.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final temImagem = _imagemSelecionada != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: context.cores.gradienteA,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: widget.onVoltar,
          icon: Icon(Icons.arrow_back, color: context.cores.texto),
        ),
        title: Text(
          _editando ? 'Editar ${widget.bancoExistente!.nome}' : 'Novo Banco',
          maxLines: 1,
          style: TextStyle(
            color: context.cores.texto,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AppBackground(
        child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Campo(
                    'Nome do banco',
                    TextField(
                      controller: _nome,
                      focusNode: _focoNome,
                      style: TextStyle(color: context.cores.texto, fontSize: 16),
                      textCapitalization: TextCapitalization.words,
                      decoration: campoCores(''),
                    ),
                    hint: 'Ex.: Nubank, PicPay…',
                    focusNode: _focoNome,
                  ),
                  const SizedBox(height: 12),
                  Text('Logo do banco',
                      style: TextStyle(
                        color: context.cores.textoMedio,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (temImagem) ...[
                        Image.file(
                          File(_imagemSelecionada!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              setState(() => _imagemSelecionada = null),
                          icon: Icon(Icons.close, color: context.cores.textoSuave),
                        ),
                        const SizedBox(width: 4),
                      ],
                      OutlinedButton(
                        onPressed: _escolherImagem,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.cores.texto,
                          side: BorderSide(color: context.cores.texto.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library, size: 18),
                            SizedBox(width: 6),
                            Text('Escolher da galeria'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!temImagem) ...[
                    const SizedBox(height: 12),
                    Text('Ícone (sem repetições)',
                        style: TextStyle(
                          color: context.cores.textoMedio,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 6),
                    if (_iconesDisponiveis.isEmpty)
                      Text(
                          'Todos os ícones disponíveis já foram usados.',
                          style: TextStyle(color: context.cores.textoSuave, fontSize: 13))
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _iconesDisponiveis.map((chave) {
                          final selecionado = chave == _iconeSelecionado;
                          final icone = IconesCatalogo.iconePorChave(chave);
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _iconeSelecionado = chave),
                            child: SizedBox(
                              width: 60,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: selecionado
                                          ? context.cores.primaria
                                          : context.cores.superficieElevada,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selecionado
                                            ? context.cores.primaria
                                            : context.cores.texto.withOpacity(0.12),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: icone != null
                                          ? Icon(icone,
                                              color: selecionado
                                                  ? context.cores.texto
                                                  : context.cores.textoMedio,
                                              size: 22)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    IconesCatalogo.rotulo(chave),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selecionado ? context.cores.texto : context.cores.textoSuave,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                  const SizedBox(height: 12),
                  Campo(
                    'Chave Pix (para cobrança)',
                    TextField(
                      controller: _pix,
                      focusNode: _focoPix,
                      style: TextStyle(color: context.cores.texto, fontSize: 16),
                      keyboardType: TextInputType.text,
                      decoration: campoCores(''),
                    ),
                    hint: 'CPF, e-mail, telefone ou aleatória',
                    focusNode: _focoPix,
                  ),
                  const SizedBox(height: 12),
                  Campo(
                    'Dia do vencimento',
                    TextField(
                      controller: _vencimento,
                      focusNode: _focoVencimento,
                      style: TextStyle(color: context.cores.texto, fontSize: 16),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: campoCores(''),
                    ),
                    hint: 'Ex.: 10',
                    focusNode: _focoVencimento,
                  ),
                  const SizedBox(height: 12),
                  Text('Cor característica',
                      style: TextStyle(
                        color: context.cores.textoMedio,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 6),
                  if (_coresDisponiveis.isEmpty)
                    Text(
                        'Todas as cores disponíveis já foram usadas.',
                        style: TextStyle(color: context.cores.textoSuave, fontSize: 13))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _coresDisponiveis.map((cor) {
                        final selecionado = cor == _corSelecionada;
                        return GestureDetector(
                          onTap: () => setState(() => _corSelecionada = cor),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(cor),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selecionado ? context.cores.texto : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: selecionado
                                ? Center(
                                    child: Icon(Icons.check,
                                        color: context.cores.texto, size: 20))
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(_corSelecionada),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: context.cores.texto.withOpacity(0.3)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Cor atual',
                          style: TextStyle(
                              color: context.cores.textoMedio, fontSize: 13)),
                      const Spacer(),
                      if (temImagem)
                        TextButton.icon(
                          onPressed: _extraindoCor
                              ? null
                              : _usarCorDoLogo,
                          icon: _extraindoCor
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.cores.azulClaro),
                                )
                              : Icon(Icons.auto_awesome,
                                  color: context.cores.azulClaro, size: 16),
                          label: Text('Cor do logo',
                              style: TextStyle(
                                  color: context.cores.azulClaro, fontSize: 13)),
                        ),
                        TextButton.icon(
                          onPressed: _abrirPickerCor,
                          icon: Icon(Icons.palette,
                              color: context.cores.azulClaro, size: 16),
                          label: Text('Personalizada',
                              style: TextStyle(
                                  color: context.cores.azulClaro, fontSize: 13)),
                      ),
                    ],
                  ),
                  if (_editando) ...[
                    const SizedBox(height: 16),
                    Text('FATURA DO MÊS ATUAL',
                        style: TextStyle(
                          color: context.cores.tituloSecao,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 6),
                    Campo(
                      'Valor total da fatura (R\$)',
                      TextField(
                        controller: _fatura,
                        focusNode: _focoFatura,
                        style: TextStyle(color: context.cores.texto, fontSize: 16),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          BrazilianCurrencyInputFormatter(),
                        ],
                        decoration: campoCores(''),
                      ),
                      hint: 'R\$ 0,00',
                      focusNode: _focoFatura,
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final vm = Provider.of<FaturaViewModel>(context);
                      final mesAtual = hojeMes();
                      final informada = vm.faturaInformadaDoBancoNoMes(
                          widget.bancoExistente!.id, mesAtual);
                      final devedores = vm.faturaDoBancoBrutoNoMes(
                          widget.bancoExistente!.id, mesAtual);
                      final restante = informada > 0
                          ? (informada - devedores)
                          : vm.faturaDoBancoNoMes(
                              widget.bancoExistente!.id, mesAtual);
                      return Text(
                        informada > 0
                            ? 'Devedores: ${formatarMoeda(devedores)} · resta: ${formatarMoeda(restante)}'
                            : 'Compras dos devedores: ${formatarMoeda(devedores)}',
                        style: TextStyle(color: context.cores.textoSuave, fontSize: 12),
                      );
                    }),
                  ],
                    const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nome.text.trim().isEmpty
                          ? null
                          : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.cores.primaria,
                        foregroundColor: context.cores.texto,
                        disabledForegroundColor: context.cores.textoSuave,
                        disabledBackgroundColor: context.cores.superficieElevada,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                          _editando ? 'Salvar Alterações' : 'Salvar Banco',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_aviso != null) ...[
                    const SizedBox(height: 8),
                    Text(_aviso!,
                        style: TextStyle(color: context.cores.textoMedio, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class NovoBancoScreen extends StatelessWidget {
  final VoidCallback onVoltar;
  const NovoBancoScreen({super.key, required this.onVoltar});
  @override
  Widget build(BuildContext context) =>
      BancoFormulario(bancoExistente: null, onVoltar: onVoltar);
}

class EditarBancoScreen extends StatelessWidget {
  final String bancoId;
  final VoidCallback onVoltar;
  const EditarBancoScreen(
      {super.key, required this.bancoId, required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<FaturaViewModel>(context);
    final banco = vm.bancoPorId(bancoId);
    if (banco == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => onVoltar());
      return Scaffold(backgroundColor: context.cores.gradienteA);
    }
    return BancoFormulario(bancoExistente: banco, onVoltar: onVoltar);
  }
}
