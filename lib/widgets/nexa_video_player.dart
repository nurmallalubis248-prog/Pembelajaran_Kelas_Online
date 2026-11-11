import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../screens/profile/nexa_tokens.dart';

/// Satu sumber video dengan label kualitasnya (mis. "360p", "720p", "Asli").
/// Untuk file lokal cukup satu sumber. Untuk server isi beberapa sumber
/// (satu URL per kualitas) supaya pilihan kualitas di pemutar berfungsi.
class NexaVideoSource {
  final String label;
  final String? filePath;
  final String? url;

  const NexaVideoSource.file(this.label, this.filePath) : url = null;
  const NexaVideoSource.network(this.label, this.url) : filePath = null;
}

/// Mengurus VideoPlayerController + status kontrol. Dipakai bersama oleh
/// pemutar biasa dan layar penuh, jadi putaran tidak putus saat pindah layar.
class NexaPlayerController extends ChangeNotifier {
  NexaPlayerController(this.sources, {int initialQuality = 0})
      : assert(sources.isNotEmpty),
        _quality = initialQuality.clamp(0, sources.length - 1);

  final List<NexaVideoSource> sources;
  int _quality;

  VideoPlayerController? video;
  bool loading = true;
  bool started = false; // sudah pernah diputar (poster hilang setelah ini)
  bool controlsVisible = true;
  String? error;
  double speed = 1.0;
  double? scrubMs; // posisi geser slider (ms) saat jari masih menahan

  Timer? _hideTimer;
  bool _disposed = false;

  int get quality => _quality;
  bool get playing => video?.value.isPlaying ?? false;
  bool get buffering => video?.value.isBuffering ?? false;
  Duration get position => video?.value.position ?? Duration.zero;
  Duration get duration => video?.value.duration ?? Duration.zero;
  double get aspectRatio {
    final a = video?.value.aspectRatio ?? 0;
    return a > 0 ? a : 16 / 9;
  }

  Future<void> init() => _open(sources[_quality]);

  Future<void> _open(
    NexaVideoSource s, {
    Duration? resume,
    bool autoplay = false,
  }) async {
    loading = true;
    error = null;
    _safeNotify();

    final c = s.filePath != null
        ? VideoPlayerController.file(File(s.filePath!))
        : VideoPlayerController.networkUrl(Uri.parse(s.url!));
    try {
      await c.initialize();
    } catch (e) {
      debugPrint('VIDEO ERROR: $e');
      await c.dispose();
      if (_disposed) return;
      loading = false;
      error = 'Video tidak dapat diputar.';
      _safeNotify();
      return;
    }
    if (_disposed) {
      await c.dispose();
      return;
    }

    await c.setPlaybackSpeed(speed);
    if (resume != null) await c.seekTo(resume);

    final old = video;
    old?.removeListener(_onTick);
    c.addListener(_onTick);
    video = c;
    loading = false;
    if (autoplay) {
      await c.play();
      started = true;
    }
    _safeNotify();
    if (autoplay) _scheduleHide();
    // Buang pengendali lama setelah frame ini, supaya tidak dipakai lagi.
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  Future<void> retry() => _open(sources[_quality]);

  void _onTick() {
    final v = video?.value;
    if (v == null) return;
    if (v.hasError && error == null) error = 'Video tidak dapat diputar.';
    if (v.isCompleted && !controlsVisible) controlsVisible = true;
    _safeNotify();
  }

  Future<void> togglePlay() async {
    final v = video;
    if (v == null) return;
    if (v.value.isPlaying) {
      await v.pause();
      _hideTimer?.cancel();
      controlsVisible = true;
    } else {
      if (v.value.isCompleted) await v.seekTo(Duration.zero);
      await v.play();
      started = true;
      _scheduleHide();
    }
    _safeNotify();
  }

  Future<void> pause() async {
    await video?.pause();
    controlsVisible = true;
    _safeNotify();
  }

  Future<void> seekTo(Duration d) async {
    final v = video;
    if (v == null) return;
    final max = v.value.duration;
    final clamped = d < Duration.zero ? Duration.zero : (d > max ? max : d);
    await v.seekTo(clamped);
  }

  Future<void> seekBy(Duration delta) => seekTo(position + delta);

  void scrub(double ms) {
    scrubMs = ms;
    _hideTimer?.cancel();
    _safeNotify();
  }

  Future<void> endScrub(double ms) async {
    scrubMs = null;
    await seekTo(Duration(milliseconds: ms.round()));
    _scheduleHide();
    _safeNotify();
  }

  Future<void> setQuality(int i) async {
    if (i == _quality || i < 0 || i >= sources.length) return;
    final pos = position;
    final wasPlaying = playing;
    _quality = i;
    await _open(sources[i], resume: pos, autoplay: wasPlaying);
  }

  Future<void> setSpeed(double s) async {
    speed = s;
    await video?.setPlaybackSpeed(s);
    _safeNotify();
  }

  void toggleControls() {
    controlsVisible = !controlsVisible;
    if (controlsVisible) _scheduleHide();
    _safeNotify();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (playing && scrubMs == null) {
        controlsVisible = false;
        _safeNotify();
      }
    });
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _hideTimer?.cancel();
    video?.removeListener(_onTick);
    video?.dispose();
    super.dispose();
  }
}

/// Pemutar video kustom NeXa: putar/jeda, geser (seek), ketuk dua kali untuk
/// maju/mundur 10 detik, kecepatan, pilihan kualitas, layar penuh, dan tombol
/// putar potret/lanskap di layar penuh.
class NexaVideoPlayer extends StatefulWidget {
  const NexaVideoPlayer({
    super.key,
    required this.sources,
    this.poster,
    this.initialQuality = 0,
    this.borderRadius = 14,
  });

  final List<NexaVideoSource> sources;
  final Widget? poster; // tampil sebelum video pertama kali diputar
  final int initialQuality;
  final double borderRadius;

  @override
  State<NexaVideoPlayer> createState() => _NexaVideoPlayerState();
}

class _NexaVideoPlayerState extends State<NexaVideoPlayer>
    with WidgetsBindingObserver {
  late final NexaPlayerController _c;

  @override
  void initState() {
    super.initState();
    _c = NexaPlayerController(
      widget.sources,
      initialQuality: widget.initialQuality,
    )..init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _c.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _PlayerView(
          ctrl: _c,
          fullscreen: false,
          poster: widget.poster,
          onFullscreen: () => openNexaFullscreen(context, _c),
        ),
      ),
    );
  }
}

const _portrait = [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
const _landscape = [
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
];

/// Buka layar penuh. Video lebar -> lanskap, video tegak -> potret.
/// Aplikasi ini hanya potret, jadi orientasi dikembalikan ke potret saat keluar.
Future<void> openNexaFullscreen(
  BuildContext context,
  NexaPlayerController c,
) async {
  Future<void> restore() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(_portrait);
  }

  final nav = Navigator.of(context, rootNavigator: true);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
    c.aspectRatio >= 1 ? _landscape : _portrait,
  );
  try {
    await nav.push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, _, _) => _FullscreenPage(ctrl: c),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  } finally {
    await restore();
  }
}

class _FullscreenPage extends StatelessWidget {
  const _FullscreenPage({required this.ctrl});
  final NexaPlayerController ctrl;

  void _rotate(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    SystemChrome.setPreferredOrientations(isLandscape ? _portrait : _landscape);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _PlayerView(
        ctrl: ctrl,
        fullscreen: true,
        onFullscreen: () => Navigator.of(context).maybePop(),
        onRotate: () => _rotate(context),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAMPILAN PEMUTAR (dipakai inline dan layar penuh)
// ---------------------------------------------------------------------------
class _PlayerView extends StatelessWidget {
  const _PlayerView({
    required this.ctrl,
    required this.fullscreen,
    required this.onFullscreen,
    this.onRotate,
    this.poster,
  });

  final NexaPlayerController ctrl;
  final bool fullscreen;
  final VoidCallback onFullscreen;
  final VoidCallback? onRotate;
  final Widget? poster;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final v = ctrl.video;
        final ready = v != null && v.value.isInitialized;
        final busy = ctrl.loading || ctrl.buffering;

        return ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ready)
                Center(
                  child: AspectRatio(
                    aspectRatio: ctrl.aspectRatio,
                    child: VideoPlayer(v),
                  ),
                ),
              if (!ctrl.started && poster != null)
                Positioned.fill(child: poster!),
              Positioned.fill(child: _GestureLayer(ctrl: ctrl)),
              if (ctrl.error != null)
                _ErrorOverlay(message: ctrl.error!, onRetry: ctrl.retry)
              else ...[
                _controls(context, ready, busy),
                if (busy)
                  const Center(
                    child: IgnorePointer(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _controls(BuildContext context, bool ready, bool busy) {
    final dur = ctrl.duration.inMilliseconds.toDouble();
    final maxV = dur > 0 ? dur : 1.0;
    final cur =
        (ctrl.scrubMs ?? ctrl.position.inMilliseconds.toDouble())
            .clamp(0.0, maxV)
            .toDouble();
    final completed = ctrl.video?.value.isCompleted ?? false;

    return AnimatedOpacity(
      opacity: ctrl.controlsVisible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !ctrl.controlsVisible,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bayangan atas & bawah agar ikon terbaca di atas video terang.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0, 0.3, 0.55, 1],
                  ),
                ),
              ),
            ),
            if (fullscreen)
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: IconButton(
                    onPressed: onFullscreen,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            if (ready && !busy)
              Center(
                child: GestureDetector(
                  onTap: ctrl.togglePlay,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Icon(
                        completed
                            ? Icons.replay_rounded
                            : (ctrl.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                        key: ValueKey(completed ? 2 : (ctrl.playing ? 1 : 0)),
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 8,
              right: 4,
              bottom: fullscreen ? 10 : 2,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Text(_fmt(Duration(milliseconds: cur.round())),
                        style: nexaText(11, color: Colors.white)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14),
                        ),
                        child: Slider(
                          value: cur,
                          min: 0,
                          max: maxV,
                          onChanged: ready ? ctrl.scrub : null,
                          onChangeEnd: ready ? ctrl.endScrub : null,
                        ),
                      ),
                    ),
                    Text(_fmt(ctrl.duration),
                        style: nexaText(11, color: Colors.white)),
                    const SizedBox(width: 2),
                    PopupMenuButton<double>(
                      tooltip: 'Kecepatan',
                      initialValue: ctrl.speed,
                      onSelected: ctrl.setSpeed,
                      itemBuilder: (_) => [
                        for (final s in _speeds)
                          PopupMenuItem(
                              value: s,
                              child: Text(_speedLabel(s),
                                  style: nexaText(13))),
                      ],
                      child: SizedBox(
                        width: 38,
                        height: 36,
                        child: Center(
                          child: Text(_speedLabel(ctrl.speed),
                              style: nexaText(11,
                                  weight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    PopupMenuButton<int>(
                      tooltip: 'Kualitas',
                      initialValue: ctrl.quality,
                      onSelected: ctrl.setQuality,
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      itemBuilder: (_) => [
                        for (var i = 0; i < ctrl.sources.length; i++)
                          PopupMenuItem(
                            value: i,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  child: i == ctrl.quality
                                      ? const Icon(Icons.check,
                                          size: 18, color: kMaroon)
                                      : null,
                                ),
                                Text(ctrl.sources[i].label,
                                    style: nexaText(13)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (fullscreen && onRotate != null)
                      _IconBtn(
                          icon: Icons.screen_rotation_rounded,
                          onTap: onRotate!),
                    _IconBtn(
                      icon: fullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      onTap: onFullscreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _speedLabel(double s) =>
      s == s.roundToDouble() ? '${s.toInt()}x' : '${s}x';

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 22),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        visualDensity: VisualDensity.compact,
      );
}

/// Ketuk = tampil/sembunyi kontrol. Ketuk dua kali di kiri/kanan = mundur/maju 10 dtk.
class _GestureLayer extends StatefulWidget {
  const _GestureLayer({required this.ctrl});
  final NexaPlayerController ctrl;

  @override
  State<_GestureLayer> createState() => _GestureLayerState();
}

class _GestureLayerState extends State<_GestureLayer> {
  Offset _down = Offset.zero;
  String? _hint;
  Timer? _timer;

  void _flash(String text) {
    setState(() => _hint = text);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hint = null);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final left = _down.dx < box.maxWidth / 2;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.ctrl.toggleControls,
          onDoubleTapDown: (d) => _down = d.localPosition,
          onDoubleTap: () {
            widget.ctrl.seekBy(Duration(seconds: left ? -10 : 10));
            _flash(left ? '-10 dtk' : '+10 dtk');
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_hint != null)
                Align(
                  alignment:
                      left ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(_hint!,
                          style: nexaText(12,
                              weight: FontWeight.w500, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  const _ErrorOverlay({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 32),
          const SizedBox(height: 8),
          Text(message, style: nexaText(12, color: Colors.white)),
          TextButton(
            onPressed: onRetry,
            child: Text('Coba lagi',
                style: nexaText(12,
                    weight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
