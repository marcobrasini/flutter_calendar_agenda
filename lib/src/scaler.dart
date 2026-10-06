import 'package:flutter/widgets.dart';


class CalendarScaler extends ChangeNotifier {
  CalendarScaler({
    double ratio = 0.0,
    this.minRatio = 0.5,
    this.maxRatio = 2.0,
  }) : _ratio = ratio;

  final double minRatio;
  final double maxRatio;

  double _ratio;
  bool _pinching = false;
  ScrollController? _slider;

  final Map<int, Offset> _pointers = {};
  double _spanStart = 0.0;
  double _ratioStart = 0.0;
  double _anchor = 0.0; // minuti sotto il punto focale a inizio pinch

  double get ratio => _ratio;
  bool get pinching => _pinching;
  bool get zoomable => _ratio > 0;

  void attach(ScrollController slider) => _slider = slider;
  void detach() => _slider = null;

  /// Reimposta il rapporto senza notificare: da usare in didUpdateWidget,
  /// dove un rebuild è già in corso.
  void reset(double ratio) {
    _ratio = ratio;
    _pointers.clear();
    _pinching = false;
  }

  double get _span {
    final p = _pointers.values.toList();
    return (p[0].dy - p[1].dy).abs().clamp(24.0, double.infinity);
  }

  double get _focal =>
      (_pointers.values.first.dy + _pointers.values.last.dy) / 2;

  // ── Eventi dei puntatori ────────────────────────────────────────────────

  void down(PointerDownEvent event, double bodyTop) {
    _pointers[event.pointer] = event.localPosition;
    final slider = _slider;
    if (_pointers.length != 2 || !zoomable) return;
    if (slider == null || !slider.hasClients) return;
    _spanStart = _span;
    _ratioStart = _ratio;
    _anchor = (slider.offset + _focal - bodyTop) / _ratio;
    _pinching = true;
    notifyListeners();
  }

  void move(PointerMoveEvent event, double bodyTop) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;
    if (!_pinching || _pointers.length != 2) return;

    final ratio = (_ratioStart * _span / _spanStart).clamp(minRatio, maxRatio);
    // Mantiene sotto le dita lo stesso minuto, anche se le dita si spostano
    final target = _anchor * ratio - (_focal - bodyTop);
    if (ratio != _ratio) {
      _ratio = ratio;
      notifyListeners();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _jump(target));
  }

  void up(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pinching && _pointers.length < 2) {
      _pinching = false;
      notifyListeners();
    }
  }

  void _jump(double target) {
    final slider = _slider;
    if (slider == null || !slider.hasClients) return;
    final position = slider.position;
    slider.jumpTo(
      target.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  @override
  void dispose() {
    _slider = null;
    _pointers.clear();
    super.dispose();
  }
}
