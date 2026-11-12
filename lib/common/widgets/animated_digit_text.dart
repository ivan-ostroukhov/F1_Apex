import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedDigitText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AnimatedDigitText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final chars = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: List.generate(chars.length, (index) {
        final char = chars[index];
        return _SingleRollingDigit(
          key: ValueKey(index),
          targetChar: char,
          style: style,
        );
      }),
    );
  }
}

class _SingleRollingDigit extends StatefulWidget {
  final String targetChar;
  final TextStyle? style;

  const _SingleRollingDigit({
    super.key,
    required this.targetChar,
    this.style,
  });

  @override
  State<_SingleRollingDigit> createState() => _SingleRollingDigitState();
}

class _SingleRollingDigitState extends State<_SingleRollingDigit> {
  late String _currentChar;
  String? _finalTargetChar;
  int _stepsRemaining = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _currentChar = widget.targetChar;
  }

  @override
  void didUpdateWidget(_SingleRollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetChar != widget.targetChar) {
      _startRollingTo(widget.targetChar);
    }
  }

  void _startRollingTo(String newTarget) {
    _stepTimer?.cancel();
    _finalTargetChar = newTarget;

    final oldNum = int.tryParse(_currentChar);
    final newNum = int.tryParse(newTarget);

    if (oldNum == null || newNum == null) {
      setState(() {
        _currentChar = newTarget;
      });
      return;
    }

    _stepsRemaining = 2;
    _triggerNextRollStep();
  }

  void _triggerNextRollStep() {
    if (!mounted) return;

    if (_stepsRemaining <= 0) {
      if (_finalTargetChar != null && _currentChar != _finalTargetChar) {
        setState(() {
          _currentChar = _finalTargetChar!;
        });
      }
      return;
    }

    final currNum = int.tryParse(_currentChar) ?? 0;
    final nextNum = (currNum + 1) % 10;
    _stepsRemaining--;

    setState(() {
      _currentChar = nextNum.toString();
    });

    _stepTimer = Timer(const Duration(milliseconds: 100), () {
      _triggerNextRollStep();
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = ValueKey(_currentChar);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isNew = (child.key == key);

        final slideAnimation = Tween<Offset>(
          begin: isNew ? const Offset(0.0, -0.80) : const Offset(0.0, 0.0),
          end: isNew ? const Offset(0.0, 0.0) : const Offset(0.0, 0.80),
        ).animate(CurvedAnimation(
          parent: animation,
          curve: isNew ? Curves.easeOutCubic : Curves.easeInCubic,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        _currentChar,
        key: key,
        style: widget.style,
      ),
    );
  }
}