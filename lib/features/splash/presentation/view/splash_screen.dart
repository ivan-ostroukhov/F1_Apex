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

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    _minTimeTimer = Timer(const Duration(milliseconds: 1000), () {
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
