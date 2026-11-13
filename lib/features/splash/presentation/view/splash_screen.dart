import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/startup/app_startup_cubit.dart';
import '../../../../common/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  bool _dataReady = false;
  bool _minTimeElapsed = false;
  bool _finishing = false;

  StreamSubscription<AppStartupState>? _startupSub;
  Timer? _minTimeTimer;
  Timer? _safetyTimeoutTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _opacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();

    _minTimeTimer = Timer(const Duration(milliseconds: 1100), () {
      _minTimeElapsed = true;
      _checkAndFinish();
    });

    final cubit = context.read<AppStartupCubit>();
    if (cubit.state.isDone) {
      _dataReady = true;
      _checkAndFinish();
    } else {
      _startupSub = cubit.stream.listen((state) {
        if (state.isDone) {
          _dataReady = true;
          _startupSub?.cancel();
          _checkAndFinish();
        }
      });
    }

    _safetyTimeoutTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && !_finishing) {
        _dataReady = true;
        _checkAndFinish();
      }
    });
  }

  void _checkAndFinish() {
    if (!_minTimeElapsed || !_dataReady || _finishing || !mounted) return;
    _finishing = true;

    _fadeController.reverse().then((_) {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _minTimeTimer?.cancel();
    _safetyTimeoutTimer?.cancel();
    _startupSub?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = AppColors.racingBlue;
    const bg = Color(0xFF0F0F14);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -450,
              right: -430,
              width: 800,
              height: 800,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        red.withValues(alpha: 0.32),
                        red.withValues(alpha: 0.15),
                        red.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -420,
              left: -350,
              width: 800,
              height: 800,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        red.withValues(alpha: 0.22),
                        red.withValues(alpha: 0.08),
                        red.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Image.asset(
                  'assets/images/logo_v2.png',
                  width: 170,
                  height: 170,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
