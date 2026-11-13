import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/startup/app_startup_cubit.dart';

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

  bool _dataReady = false;
  bool _minTimeElapsed = false;
  bool _finishing = false;

  StreamSubscription<AppStartupState>? _startupSub;
  Timer? _minTimeTimer;
  Timer? _safetyTimeoutTimer;

  @override
  void initState() {
    super.initState();

    // Fade-in animation: 500ms
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    // Minimum display time for logo (1000ms), so it acts as a smooth screen, not a glitch
    _minTimeTimer = Timer(const Duration(milliseconds: 1000), () {
      _minTimeElapsed = true;
      _checkAndFinish();
    });

    // Check current state or subscribe to AppStartupCubit
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

    // Safety timeout (12s): in case of total network offline / severe hang
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

    // Smooth fade out: 350ms
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
    return Scaffold(
      backgroundColor: const Color(0xFF15151E),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Image.asset(
            'assets/images/logo_v2.png',
            width: 180,
            height: 180,
          ),
        ),
      ),
    );
  }
}
