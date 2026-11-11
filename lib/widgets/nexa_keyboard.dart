import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ---------------------------------------------------------------------------
// WARNA & UKURAN diambil dari aset Figma "Dark - Alphabetic" (390 x 291):
//   latar papan  #1F1F1F   | tombol huruf & spasi #434343
//   tombol fungsi (shift, hapus, 123, Go) #242424 | ikon bawah #9C9C9C
// ---------------------------------------------------------------------------
const Color _kBoardBg = Color(0xFF1F1F1F);
const Color _kLetterKey = Color(0xFF434343);
const Color _kFuncKey = Color(0xFF242424);
const Color _kKeyPressed = Color(0xFF5B5B5B);
const Color _kAccessoryIcon = Color(0xFF9C9C9C);

const double _kKeyHeight = 43;
const double _kKeyGap = 5;
const double _kRowGap = 11;
const double _kKeyRadius = 6;

enum _Layer { letters, numbers, symbols }

enum _Shift { off, once, caps }

// ===========================================================================
// CONTROLLER (satu keyboard untuk seluruh aplikasi)
// ===========================================================================

/// Menghubungkan keyboard dengan kolom teks yang sedang fokus.
class NexaKeyboard extends ChangeNotifier {
  NexaKeyboard._();
  static final NexaKeyboard instance = NexaKeyboard._();

  TextEditingController? _controller;
  FocusNode? _focus;
  VoidCallback? _onGo;
  bool _multiline = false;
  bool _numeric = false;
  bool _autoShift = true;
  int _attachTick = 0;
  List<TextInputFormatter> _formatters = const [];
  TextCapitalization _cap = TextCapitalization.none;

  bool get isVisible => _controller != null;

  /// Naik tiap kolom baru mendapat fokus (keyboard kembali ke keadaan awal).
  int get attachTick => _attachTick;

  /// true -> huruf pertama otomatis kapital (seperti tampilan Figma).
  bool get autoShift => _autoShift;
  bool get multiline => _multiline;

  /// true -> tampilkan papan angka (kolom nominal / angka).
  bool get numeric => _numeric;

  void attach(
    TextEditingController controller,
    FocusNode focus, {
    VoidCallback? onGo,
    bool multiline = false,
    bool numeric = false,
    bool autoShift = true,
    List<TextInputFormatter> formatters = const [],
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    _autoShift = autoShift;
    _attachTick++;
    _controller = controller;
    _focus = focus;
    _onGo = onGo;
    _multiline = multiline;
    _numeric = numeric;
    _formatters = formatters;
    _cap = capitalization;
    notifyListeners();
  }

  /// Sembunyikan hanya bila [focus] masih pemilik keyboard (hindari
  /// kolom lama menutup keyboard milik kolom baru).
  void detach(FocusNode focus) {
    if (!identical(_focus, focus)) return;
    _controller = null;
    _focus = null;
    _onGo = null;
    _numeric = false;
    _formatters = const [];
    _cap = TextCapitalization.none;
    notifyListeners();
  }

  /// Ketikan dari keyboard kustom tidak lewat inputFormatters bawaan
  /// TextField, jadi formatter dijalankan di sini.
  void _commit(TextEditingValue old, TextEditingValue next) {
    var v = next;
    for (final f in _formatters) {
      v = f.formatEditUpdate(old, v);
    }
    _controller?.value = v;
  }

  /// TextCapitalization.sentences: huruf pertama kolom / kalimat jadi kapital.
  String _autoCapital(String text, int start, String s) {
    if (_cap != TextCapitalization.sentences || s.length != 1) return s;
    if (s.toLowerCase() == s.toUpperCase()) return s; // bukan huruf
    final before = text.substring(0, start);
    final sentenceStart =
        before.trim().isEmpty || RegExp(r'[.!?]\s+$').hasMatch(before);
    return sentenceStart ? s.toUpperCase() : s;
  }

  void insert(String s) {
    final c = _controller;
    if (c == null) return;
    final v = c.value;
    final sel = v.selection;
    final start = sel.isValid ? sel.start : v.text.length;
    final end = sel.isValid ? sel.end : v.text.length;
    final ch = _autoCapital(v.text, start, s);
    final text = v.text.replaceRange(start, end, ch);
    _commit(
      v,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: start + ch.length),
      ),
    );
  }

  void backspace() {
    final c = _controller;
    if (c == null) return;
    final v = c.value;
    final sel = v.selection;
    if (!sel.isValid) return;
    if (!sel.isCollapsed) {
      _commit(
        v,
        TextEditingValue(
          text: v.text.replaceRange(sel.start, sel.end, ''),
          selection: TextSelection.collapsed(offset: sel.start),
        ),
      );
      return;
    }
    if (sel.start == 0) return;
    var from = sel.start - 1;
    // pasangan surrogate (emoji) dihapus utuh
    final unit = v.text.codeUnitAt(from);
    if (unit >= 0xDC00 && unit <= 0xDFFF && from > 0) from -= 1;
    _commit(
      v,
      TextEditingValue(
        text: v.text.replaceRange(from, sel.start, ''),
        selection: TextSelection.collapsed(offset: from),
      ),
    );
  }

  // ----- Dikte suara: hasil rekaman ditulis ke kolom yang sedang fokus -----
  int _dictStart = 0;
  int _dictEnd = 0;
  bool _dictSpace = false;

  void dictationBegin() {
    final c = _controller;
    if (c == null) return;
    final v = c.value;
    final sel = v.selection;
    _dictStart = sel.isValid ? sel.start : v.text.length;
    _dictEnd = sel.isValid ? sel.end : v.text.length;
    _dictSpace = _dictStart > 0 && !RegExp(r'\s').hasMatch(v.text[_dictStart - 1]);
  }

  /// Ganti hasil dikte sebelumnya dengan [words] terbaru (hasil sementara
  /// maupun akhir), tanpa menimpa teks yang sudah ada di kolom.
  void dictationUpdate(String words) {
    final c = _controller;
    if (c == null || words.isEmpty) return;
    final v = c.value;
    final start = _dictStart.clamp(0, v.text.length);
    final end = _dictEnd.clamp(start, v.text.length);
    final ins = (_dictSpace ? ' ' : '') + words;
    _commit(
      v,
      TextEditingValue(
        text: v.text.replaceRange(start, end, ins),
        selection: TextSelection.collapsed(offset: start + ins.length),
      ),
    );
    _dictEnd = start + ins.length;
  }

  /// Tombol "Go": kolom satu baris -> selesai/kirim; multibaris -> baris baru.
  void go() {
    if (_multiline) {
      insert('\n');
      return;
    }
    final cb = _onGo;
    final f = _focus;
    cb?.call();
    f?.unfocus();
  }
}

// ===========================================================================
// HOST: letakkan SEKALI di atas Navigator (MaterialApp.builder)
// ===========================================================================

/// Menempatkan keyboard di dasar layar. Isi aplikasi otomatis mengecil
/// sehingga kolom yang sedang diketik tidak tertutup.
///
///   MaterialApp(builder: (context, child) =>
///       NexaKeyboardHost(child: child ?? const SizedBox.shrink()), ...)
class NexaKeyboardHost extends StatelessWidget {
  const NexaKeyboardHost({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NexaKeyboard.instance,
      builder: (context, _) {
        final show = NexaKeyboard.instance.isVisible;
        // Isi aplikasi tidak perlu menambah padding bawah lagi karena
        // kita yang memakan ruang; hapus viewInsets bawaan OS.
        final mq = MediaQuery.of(context);
        return Column(
          children: [
            Expanded(
              child: MediaQuery(
                data: show
                    ? mq.copyWith(
                        viewPadding: mq.viewPadding.copyWith(bottom: 0),
                        padding: mq.padding.copyWith(bottom: 0),
                      )
                    : mq,
                child: child,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: show
                  ? const _NexaKeyboardView()
                  : const SizedBox(width: double.infinity),
            ),
          ],
        );
      },
    );
  }
}

// ===========================================================================
// FIELD: pengganti TextFormField yang memakai keyboard kustom
// ===========================================================================

class NexaKeyboardField extends StatefulWidget {
  const NexaKeyboardField({
    super.key,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.validator,
    this.style,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
    this.onFieldSubmitted,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.numeric = false,
    this.autoShift = true,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextStyle? style;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  /// Formatter (mis. hanya angka / titik ribuan) tetap berlaku di keyboard kustom.
  final List<TextInputFormatter>? inputFormatters;

  /// true -> papan angka (untuk nominal, harga, dsb).
  final bool numeric;

  /// false -> huruf pertama tidak otomatis kapital (e-mail, kata sandi).
  final bool autoShift;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool enabled;

  @override
  State<NexaKeyboardField> createState() => _NexaKeyboardFieldState();
}

class _NexaKeyboardFieldState extends State<NexaKeyboardField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;

  TextEditingController get _c =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _f => widget.focusNode ?? (_ownFocus ??= FocusNode());

  bool get _multiline => widget.maxLines == null || (widget.maxLines ?? 1) > 1;

  @override
  void initState() {
    super.initState();
    _f.addListener(_onFocus);
  }

  void _onFocus() {
    if (_f.hasFocus) {
      NexaKeyboard.instance.attach(
        _c,
        _f,
        multiline: _multiline,
        numeric: widget.numeric,
        autoShift: widget.autoShift,
        formatters: widget.inputFormatters ?? const [],
        capitalization: widget.textCapitalization,
        onGo: () => widget.onFieldSubmitted?.call(_c.text),
      );
    } else {
      NexaKeyboard.instance.detach(_f);
    }
  }

  @override
  void dispose() {
    _f.removeListener(_onFocus);
    NexaKeyboard.instance.detach(_f);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      focusNode: _f,
      obscureText: widget.obscureText,
      validator: widget.validator,
      style: widget.style,
      decoration: widget.decoration,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      onChanged: widget.onChanged,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      enabled: widget.enabled,
      // kunci: sembunyikan keyboard OS, kita pakai keyboard sendiri
      keyboardType: TextInputType.none,
      showCursor: true,
      enableInteractiveSelection: true,
      contextMenuBuilder: (_, _) => const SizedBox.shrink(),
    );
  }
}

// ===========================================================================
// TAMPILAN KEYBOARD
// ===========================================================================

class _NexaKeyboardView extends StatefulWidget {
  const _NexaKeyboardView();

  @override
  State<_NexaKeyboardView> createState() => _NexaKeyboardViewState();
}

class _NexaKeyboardViewState extends State<_NexaKeyboardView> {
  _Layer _layer = _Layer.letters;
  _Shift _shift = _Shift.off;
  DateTime _lastShiftTap = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _repeat;
  bool _lastNumeric = false;
  int _lastTick = -1;

  // emoji & suara
  bool _emoji = false;
  bool _listening = false;
  bool _speechReady = false;
  String? _micMsg;
  String? _localeId;
  final SpeechToText _speech = SpeechToText();

  static const _row1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _row2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  static const _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  static const _num1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _num2 = ['-', '/', ':', ';', '(', ')', '\$', '&', '@', '"'];
  static const _num3 = ['.', ',', '?', '!', '\''];

  static const _sym1 = ['[', ']', '{', '}', '#', '%', '^', '*', '+', '='];
  static const _sym2 = ['_', '\\', '|', '~', '<', '>', '€', '£', '¥', '•'];
  static const _sym3 = ['.', ',', '?', '!', '\''];

  @override
  void dispose() {
    _repeat?.cancel();
    _speech.cancel();
    super.dispose();
  }

  bool get _upper => _shift != _Shift.off;

  void _type(String ch) {
    HapticFeedback.selectionClick();
    NexaKeyboard.instance.insert(
        _layer == _Layer.letters && _upper ? ch.toUpperCase() : ch);
    if (_shift == _Shift.once) setState(() => _shift = _Shift.off);
  }

  void _shiftTap() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    final dbl = now.difference(_lastShiftTap).inMilliseconds < 350;
    _lastShiftTap = now;
    setState(() {
      if (_layer != _Layer.letters) {
        _layer = _layer == _Layer.numbers ? _Layer.symbols : _Layer.numbers;
        return;
      }
      if (dbl) {
        _shift = _Shift.caps;
      } else {
        _shift = _shift == _Shift.off ? _Shift.once : _Shift.off;
      }
    });
  }

  void _backspaceDown() {
    HapticFeedback.selectionClick();
    NexaKeyboard.instance.backspace();
    _repeat?.cancel();
    _repeat = Timer(const Duration(milliseconds: 420), () {
      _repeat = Timer.periodic(const Duration(milliseconds: 60), (_) {
        NexaKeyboard.instance.backspace();
      });
    });
  }

  void _backspaceUp() {
    _repeat?.cancel();
    _repeat = null;
  }

  // Dengarkan NexaKeyboard supaya papan ikut berubah (huruf <-> angka,
  // Go <-> return) saat fokus pindah ke kolom lain tanpa keyboard menutup.
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: NexaKeyboard.instance,
        builder: (context, _) => _buildBoard(context),
      );

  void _flashMsg(String m) {
    setState(() {
      _listening = false;
      _micMsg = m;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _micMsg == m) setState(() => _micMsg = null);
    });
  }

  /// Ikon mikrofon: ketuk -> mulai merekam & menulis hasilnya ke kolom;
  /// ketuk lagi -> berhenti.
  Future<void> _toggleMic() async {
    HapticFeedback.selectionClick();
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_speechReady) {
      try {
        _speechReady = await _speech.initialize(
          onStatus: (st) {
            if ((st == 'done' || st == 'notListening') && mounted) {
              setState(() => _listening = false);
            }
          },
          onError: (_) {
            if (mounted) _flashMsg('Suara tidak terdengar, coba lagi');
          },
        );
        if (_speechReady) {
          final ls = await _speech.locales();
          for (final l in ls) {
            if (l.localeId.toLowerCase().startsWith('id')) {
              _localeId = l.localeId;
              break;
            }
          }
        }
      } catch (_) {
        _speechReady = false;
      }
    }
    if (!_speechReady) {
      if (mounted) _flashMsg('Izin mikrofon / pengenal suara tidak tersedia');
      return;
    }
    NexaKeyboard.instance.dictationBegin();
    setState(() {
      _listening = true;
      _micMsg = null;
    });
    await _speech.listen(
      onResult: (r) => NexaKeyboard.instance.dictationUpdate(r.recognizedWords),
      listenOptions: SpeechListenOptions(
        localeId: _localeId,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Widget _accessoryRow() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _emoji = !_emoji);
              },
              child: Icon(
                _emoji
                    ? Icons.keyboard_alt_outlined
                    : Icons.emoji_emotions_outlined,
                color: _kAccessoryIcon,
                size: 28,
              ),
            ),
            Expanded(
              child: Text(
                _listening ? 'Mendengarkan…' : (_micMsg ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: _listening
                      ? const Color(0xFFFF453A)
                      : _kAccessoryIcon,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleMic,
              child: Icon(
                _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color:
                    _listening ? const Color(0xFFFF453A) : _kAccessoryIcon,
                size: 28,
              ),
            ),
          ],
        ),
      );

  /// Panel emoji: ketuk emoji -> masuk ke kolom ketik.
  Widget _emojiPanel(BoxConstraints box) {
    const gridH = _kKeyHeight * 4 + _kRowGap * 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: gridH,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisExtent: 46,
            ),
            itemCount: _kEmojis.length,
            itemBuilder: (_, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                NexaKeyboard.instance.insert(_kEmojis[i]);
              },
              child: Center(
                child: Text(_kEmojis[i],
                    style: const TextStyle(
                        fontSize: 26, decoration: TextDecoration.none)),
              ),
            ),
          ),
        ),
        const SizedBox(height: _kRowGap),
        Row(
          children: [
            _Key(
              width: 90,
              color: _kFuncKey,
              label: 'ABC',
              fontSize: 17,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _emoji = false);
              },
            ),
            const Spacer(),
            _Key(
              width: 90,
              color: _kFuncKey,
              onDown: _backspaceDown,
              onUp: _backspaceUp,
              child: const Icon(Icons.backspace_outlined,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _accessoryRow(),
        const SizedBox(height: 4),
      ],
    );
  }

  /// Papan angka sesuai Figma "Dark - Numbers": 3 kolom (tombol 122x47,
  /// jarak 6), angka tebal + huruf kecil di bawahnya, baris terakhir hanya
  /// "0" di tengah dan ikon hapus di kanan (tanpa tombol return).
  Widget _numericPad(BoxConstraints box) {
    const gapN = 6.0;
    final keyW = (box.maxWidth - 3 - gapN * 2 - 3) / 3;
    const letters = {
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
    };
    Widget digit(String d) => _Key(
          width: keyW,
          height: 47,
          color: _kLetterKey,
          onTap: () => _type(d),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(d,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none)),
              if (letters.containsKey(d))
                Text(letters[d]!,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 8,
                        height: 1,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none)),
            ],
          ),
        );
    Widget row(List<String> ds) => Row(
          children: [
            const SizedBox(width: 3),
            for (var i = 0; i < ds.length; i++) ...[
              if (i > 0) const SizedBox(width: gapN),
              digit(ds[i]),
            ],
          ],
        );
    const rowGap = SizedBox(height: 6);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 0),
        row(['1', '2', '3']),
        rowGap,
        row(['4', '5', '6']),
        rowGap,
        row(['7', '8', '9']),
        rowGap,
        Row(
          children: [
            const SizedBox(width: 3),
            SizedBox(width: keyW),
            const SizedBox(width: gapN),
            digit('0'),
            const SizedBox(width: gapN),
            // ikon hapus tanpa latar tombol, seperti di Figma
            _Key(
              width: keyW,
              height: 47,
              color: Colors.transparent,
              plain: true,
              onDown: _backspaceDown,
              onUp: _backspaceUp,
              child: const Icon(Icons.backspace_outlined,
                  color: Colors.white, size: 26),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBoard(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    final k = NexaKeyboard.instance;
    if (k.attachTick != _lastTick) {
      // kolom baru fokus -> keyboard kembali ke tampilan awal Figma (huruf kapital)
      _lastTick = k.attachTick;
      _layer = _Layer.letters;
      _emoji = false;
      _shift = k.autoShift ? _Shift.once : _Shift.off;
      if (_listening) {
        _speech.stop();
        _listening = false;
      }
    }
    if (k.numeric != _lastNumeric) {
      _lastNumeric = k.numeric;
      _layer = _Layer.letters;
      _shift = _Shift.off;
    }
    final r1 = _layer == _Layer.letters
        ? _row1
        : _layer == _Layer.numbers
            ? _num1
            : _sym1;
    final r2 = _layer == _Layer.letters
        ? _row2
        : _layer == _Layer.numbers
            ? _num2
            : _sym2;
    final r3 = _layer == _Layer.letters
        ? _row3
        : _layer == _Layer.numbers
            ? _num3
            : _sym3;

    return ExcludeFocus(
      child: Container(
        width: double.infinity,
        color: _kBoardBg,
        padding: EdgeInsets.fromLTRB(3, 8, 3, 6 + bottom),
        child: LayoutBuilder(builder: (context, box) {
          // lebar satu tombol huruf: 10 tombol + 9 jarak mengisi lebar
          final w = box.maxWidth;
          final keyW = (w - _kKeyGap * 9) / 10;
          const funcW = 44.0; // shift & hapus (Figma 44 / 43)
          const bottomFuncW = 90.0; // 123 & Go (Figma 89 / 91)

          Widget letterRow(List<String> keys, {double indent = 0}) => Padding(
                padding: EdgeInsets.symmetric(horizontal: indent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < keys.length; i++) ...[
                      if (i > 0) const SizedBox(width: _kKeyGap),
                      _Key(
                        width: keyW,
                        color: _kLetterKey,
                        // panah shift: ketuk -> huruf kapital / huruf kecil
                        label: _layer == _Layer.letters && _upper
                            ? keys[i].toUpperCase()
                            : keys[i],
                        onTap: () => _type(keys[i]),
                      ),
                    ],
                  ],
                ),
              );

          if (k.numeric) return _numericPad(box);
          if (_emoji) return _emojiPanel(box);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              letterRow(r1),
              const SizedBox(height: _kRowGap),
              // baris 2 (9 tombol) menjorok setengah tombol di kiri-kanan
              letterRow(r2, indent: r2.length == 9 ? (keyW + _kKeyGap) / 2 : 0),
              const SizedBox(height: _kRowGap),
              Row(
                children: [
                  _Key(
                    width: funcW,
                    color: _kFuncKey,
                    onTap: _shiftTap,
                    highlight: _layer == _Layer.letters && _shift != _Shift.off,
                    child: _layer == _Layer.letters
                        ? CustomPaint(
                            size: const Size(22, 22),
                            painter: _ShiftPainter(
                                filled: _shift != _Shift.off,
                                bar: _shift == _Shift.caps),
                          )
                        : Text(
                            _layer == _Layer.numbers ? '#+=' : '123',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                decoration: TextDecoration.none),
                          ),
                  ),
                  Expanded(
                    child: letterRow(r3),
                  ),
                  _Key(
                    width: funcW,
                    color: _kFuncKey,
                    onDown: _backspaceDown,
                    onUp: _backspaceUp,
                    child: const Icon(Icons.backspace_outlined,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: _kRowGap),
              Row(
                children: [
                  _Key(
                    width: bottomFuncW,
                    color: _kFuncKey,
                    label: _layer == _Layer.letters ? '123' : 'ABC',
                    fontSize: 17,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _layer = _layer == _Layer.letters
                          ? _Layer.numbers
                          : _Layer.letters);
                    },
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _Key(
                      color: _kLetterKey,
                      label: 'space',
                      fontSize: 17,
                      onTap: () => _type(' '),
                    ),
                  ),
                  const SizedBox(width: 7),
                  _Key(
                    width: bottomFuncW,
                    color: _kFuncKey,
                    label: 'Go',
                    fontSize: 17,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      k.go();
                    },
                  ),
                ],
              ),
              // baris aksesori: emoji (kiri), rekam suara (kanan) seperti di Figma
              const SizedBox(height: 14),
              _accessoryRow(),
              const SizedBox(height: 4),
            ],
          );
        }),
      ),
    );
  }
}

/// Satu tombol: ditekan -> warna berubah, bisa menerima onTap atau
/// onDown/onUp (untuk hapus yang menahan).
class _Key extends StatefulWidget {
  const _Key({
    this.width,
    required this.color,
    this.label,
    this.child,
    this.onTap,
    this.onDown,
    this.onUp,
    this.fontSize = 22,
    this.highlight = false,
    this.height = _kKeyHeight,
    this.plain = false,
  });

  final double? width;
  final Color color;
  final String? label;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onDown;
  final VoidCallback? onUp;
  final double fontSize;
  final bool highlight;
  final double height;

  /// true = tanpa latar/bayangan tombol (ikon hapus papan angka).
  final bool plain;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.plain
        ? Colors.transparent
        : _down
        ? _kKeyPressed
        : widget.highlight
            ? _kLetterKey
            : widget.color;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _down = true);
        widget.onDown?.call();
      },
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onUp?.call();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _down = false);
        widget.onUp?.call();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_kKeyRadius),
          boxShadow: widget.plain
              ? null
              : const [
                  BoxShadow(color: Color(0x66000000), offset: Offset(0, 1)),
                ],
        ),
        child: widget.child ??
            Text(
              widget.label ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
      ),
    );
  }
}

/// Ikon shift berisi (putih) seperti di Figma; [bar] = garis bawah saat Caps Lock.
class _ShiftPainter extends CustomPainter {
  _ShiftPainter({required this.bar, required this.filled});
  final bool bar;

  /// true = panah penuh (huruf kapital aktif); false = panah garis (huruf kecil).
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final top = bar ? h * .02 : h * .08;
    final path = Path()
      ..moveTo(w * .5, top)
      ..lineTo(w * .98, h * .52)
      ..lineTo(w * .72, h * .52)
      ..lineTo(w * .72, h * (bar ? .74 : .90))
      ..lineTo(w * .28, h * (bar ? .74 : .90))
      ..lineTo(w * .28, h * .52)
      ..lineTo(w * .02, h * .52)
      ..close();
    final paint = Paint()
      ..color = Colors.white
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    if (bar) {
      canvas.drawRect(Rect.fromLTWH(w * .28, h * .82, w * .44, h * .13), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShiftPainter old) =>
      old.bar != bar || old.filled != filled;
}

const List<String> _kEmojis = [
  '😀','😃','😄','😁','😆','😅','😂','🤣','😊','😇','🙂','🙃','😉','😌','😍','🥰',
  '😘','😗','😙','😚','😋','😛','😝','😜','🤪','🤨','🧐','🤓','😎','🥳','😏','😒',
  '😞','😔','😟','😕','🙁','😣','😖','😫','😩','🥺','😢','😭','😤','😠','😡','🤬',
  '🤯','😳','🥵','🥶','😱','😨','😰','😥','😓','🤗','🤔','🤭','🤫','😶','😐','😑',
  '😬','🙄','😯','😦','😧','😮','😲','🥱','😴','🤤','😪','😵','🤐','🥴','🤢','🤮',
  '🤧','😷','🤒','🤕','🤑','🤠','😈','👿','🤡','💩','👻','💀','👽','🤖','🎃','😺',
  '👍','👎','👊','✊','🤛','🤜','👏','🙌','👐','🤲','🤝','🙏','🤞','🤟','🤘','👌',
  '👈','👉','👆','👇','👋','🤚','✋','🖖','💪','👀','🧠','👂','👃','👄','🦷','👅',
  '💔','💕','💞','💓','💗','💖','💘','💝','💟','💙','💚','💛','🧡','💜','🖤','🤍',
  '🔥','✨','⭐','🌟','💫','💥','💯','🎉','🎊','🎁','🎈','🎂','🍕','🍔','🍟','🍿',
  '🍩','🍪','☕','🍺','🍎','🍌','🍉','🍓','🌹','🌸','🌞','🌙','⚡','🌈','🐶','🐱',
  '🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊',
  '🐔','🐧','🐦','🐤','🦄','🚀','🚗','📱','💻','📚','📌','✅','❌','❓','❗','🔒',
  '🔑','🎵','🎶','📷','🎮','⚽','🏀','🏆',
];
