import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/localization/generated/app_localizations.dart';
import '../../../../common/network/local_storage_service.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';
import '../../../schedule/domain/models/race_model.dart';
import '../../services/android_widget_service.dart';
import '../../services/desktop_widget_service.dart';
import '../widgets/race_schedule_glass_widget.dart';

class WidgetsGalleryScreen extends StatefulWidget {
  const WidgetsGalleryScreen({super.key});

  @override
  State<WidgetsGalleryScreen> createState() => _WidgetsGalleryScreenState();
}

class _WidgetsGalleryScreenState extends State<WidgetsGalleryScreen> {
  RaceModel? _currentRace;
  bool _isLoading = true;
  int _selectedBackgroundIndex = 0;
  bool _is24Hour = true;

  final List<List<Color>> _previewBackgrounds = [
    [const Color(0xFF18181C), const Color(0xFF0F0E11)],
    [const Color(0xFF2E0854), const Color(0xFF0F0B18)],
    [const Color(0xFF1E293B), const Color(0xFF0F172A)],
    [const Color(0xFF3B0707), const Color(0xFF120303)],
  ];

  @override
  void initState() {
    super.initState();
    _is24Hour = LocalStorageService.getString('is_24_hour') != 'false';
    _loadCurrentRace();
  }

  Future<void> _loadCurrentRace() async {
    try {
      final scheduleRepo = ScheduleRepository();
      final races = await scheduleRepo.getSeasonSchedule();
      final now = DateTime.now();

      RaceModel? targetRace;
      for (final r in races) {
        if (!r.isCompleted || (r.date != null && r.date!.isAfter(now.subtract(const Duration(days: 2))))) {
          targetRace = r;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _currentRace = targetRace ?? races.where((r) => r.round == '21').firstOrNull ?? (races.isNotEmpty ? races.last : null);
          _isLoading = false;
        });
        if (Platform.isAndroid) {
          AndroidWidgetService.updateWidget(race: _currentRace, is24Hour: _is24Hour);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.widgetsTitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.previewWidget,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _previewBackgrounds[_selectedBackgroundIndex],
                ),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  else
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: RaceScheduleGlassWidget(
                        race: _currentRace,
                        is24Hour: _is24Hour,
                        width: 520,
                      ),
                    ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_previewBackgrounds.length, (index) {
                      final isSelected = _selectedBackgroundIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedBackgroundIndex = index),
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _previewBackgrounds[index],
                            ),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white24,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE10600).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.desktop_windows, color: Color(0xFFE10600), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentGrandPrixWidget,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Liquid Glass | Windows Desktop & Android',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: theme.dividerColor, height: 1),
                  const SizedBox(height: 16),

                  _buildFeatureBullet(theme, Icons.blur_on, 'Эффект жидкого стекла (Frosted Glass Blur + Specular Borders)'),
                  const SizedBox(height: 10),
                  _buildFeatureBullet(theme, Icons.schedule, 'Расписание 5 сессий уикенда (FP1, FP2, FP3/Sprint, Quali, Race)'),
                  const SizedBox(height: 10),
                  _buildFeatureBullet(theme, Icons.sports_motorsports_outlined, 'Схема трассы с водяным знаком этапа'),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _handlePinWidget,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE10600),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.pin_drop_outlined, size: 20),
                      label: Text(
                        l10n.pinToDesktop,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePinWidget() async {
    try {
      if (Platform.isWindows) {
        final success = await DesktopWidgetService.createRaceScheduleWidget();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF231F20),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  Icon(
                    success ? Icons.check_circle : Icons.error_outline,
                    color: success ? const Color(0xFF00D2BE) : Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      success
                          ? 'Виджет F1 успешно появился на рабочем столе Windows!'
                          : 'Не удалось активировать виджет.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else if (Platform.isAndroid) {
        await AndroidWidgetService.updateWidget(
          race: _currentRace,
          is24Hour: _is24Hour,
        );
        final pinned = await AndroidWidgetService.requestPinWidget();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF231F20),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00D2BE)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(pinned
                        ? 'Запрос на добавление виджета отправлен на главный экран!'
                        : 'Виджет обновлен! Зажмите экран "Домой", выберите Виджеты -> f1_app.'),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF231F20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text('Ошибка активации виджета: $e'),
          ),
        );
      }
    }
  }

  Widget _buildFeatureBullet(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF00D2BE)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
