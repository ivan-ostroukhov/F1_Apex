import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../../../common/localization/generated/app_localizations.dart';
import '../../../../common/network/local_storage_service.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';
import '../../../schedule/domain/models/race_model.dart';
import '../../services/desktop_widget_channel.dart';
import '../widgets/race_schedule_glass_widget.dart';

class DesktopWidgetApp extends StatelessWidget {
  const DesktopWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const _DesktopWidgetHome(),
    );
  }
}

class _DesktopWidgetHome extends StatefulWidget {
  const _DesktopWidgetHome();

  @override
  State<_DesktopWidgetHome> createState() => _DesktopWidgetHomeState();
}

class _DesktopWidgetHomeState extends State<_DesktopWidgetHome> {
  RaceModel? _race;
  bool _is24Hour = true;
  bool _isPinned = false;
  bool _isHovered = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _is24Hour = LocalStorageService.getString('is_24_hour') != 'false';
    _isPinned = LocalStorageService.getString('desktop_widget_pinned') == 'true';
    _fetchSchedule();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) => _fetchSchedule());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSchedule() async {
    try {
      final repo = ScheduleRepository();
      final races = await repo.getSeasonSchedule();
      final now = DateTime.now();

      RaceModel? target;
      for (final r in races) {
        if (!r.isCompleted || (r.date != null && r.date!.isAfter(now.subtract(const Duration(days: 2))))) {
          target = r;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _race = target ?? races.where((r) => r.round == '21').firstOrNull ?? (races.isNotEmpty ? races.last : null);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onPanStart: _isPinned ? null : (_) => DesktopWidgetChannel.startDragging(),
          child: Stack(
            children: [
              Positioned.fill(
                child: RaceScheduleGlassWidget(
                  race: _race,
                  is24Hour: _is24Hour,
                  width: double.infinity,
                  showShadow: false,
                  borderRadius: 24,
                ),
              ),
              if (_isHovered)
                Positioned(
                  top: 10,
                  right: 14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildControlButton(
                        icon: _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: _isPinned ? const Color(0xFF00D2BE) : Colors.white70,
                        onTap: () {
                          final newVal = !_isPinned;
                          setState(() => _isPinned = newVal);
                          LocalStorageService.setString('desktop_widget_pinned', newVal.toString());
                        },
                      ),
                      const SizedBox(width: 6),
                      _buildControlButton(
                        icon: Icons.close,
                        color: Colors.white70,
                        onTap: () => DesktopWidgetChannel.closeWidget(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
