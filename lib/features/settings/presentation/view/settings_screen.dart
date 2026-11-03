import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/localization/generated/app_localizations.dart';
import '../../../../common/localization/locale_cubit.dart';
import '../../../../common/network/local_storage_service.dart';
import '../../../../common/theme/theme_cubit.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../../driver/domain/i_driver_repository.dart';
import '../../../driver/domain/driver_model.dart';
import '../../../constructor/domain/constructor_repository.dart';
import '../../../constructor/domain/constructor_model.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _favDriver1 = 'verstappen';
  String _favDriver2 = 'piastri';
  String _favTeam = 'red_bull';

  String _unitSystem = 'Метрика';
  bool _is24Hour = true;
  bool _isDetailedResults = true;

  List<DriverModel> _allDrivers = [];
  List<ConstructorModel> _allTeams = [];

  @override
  void initState() {
    super.initState();
    _loadLocalSettings();
    _fetchDriversAndTeams();
  }

  void _loadLocalSettings() {
    setState(() {
      _favDriver1 = LocalStorageService.getString('fav_driver_1') ?? 'verstappen';
      _favDriver2 = LocalStorageService.getString('fav_driver_2') ?? 'piastri';
      _favTeam = LocalStorageService.getString('fav_team') ?? 'red_bull';

      _unitSystem = LocalStorageService.getString('unit_system') ?? 'Метрика';
      _is24Hour = LocalStorageService.getString('is_24_hour') != 'false';
      _isDetailedResults = LocalStorageService.getString('is_detailed_results') != 'false';
    });
  }

  Future<void> _fetchDriversAndTeams() async {
    try {
      final driverRepo = context.read<IDriverRepository>();
      final teamRepo = context.read<IConstructorRepository>();

      final drivers = await driverRepo.getDrivers();
      final teams = await teamRepo.getConstructors();

      if (mounted) {
        setState(() {
          _allDrivers = drivers;
          _allTeams = teams;
        });
      }
    } catch (_) {}
  }

  String _getDriverNum(String driverId) {
    final d = _allDrivers.where((element) => element.id == driverId).firstOrNull;
    if (d != null && d.permanentNumber > 0) {
      return d.permanentNumber.toString().padLeft(2, '0');
    }
    switch (driverId.toLowerCase()) {
      case 'verstappen': return '01';
      case 'norris': return '04';
      case 'leclerc': return '16';
      case 'piastri': return '81';
      case 'sainz': return '55';
      case 'russell': return '63';
      case 'hamilton': return '44';
      case 'alonso': return '14';
      case 'gasly': return '10';
      case 'albon': return '23';
      case 'tsunoda': return '22';
      case 'stroll': return '18';
      case 'bearman': return '38';
      case 'hulkenberg': return '27';
      case 'lawson': return '30';
      case 'colapinto': return '43';
      case 'hadjar': return '06';
      case 'lindblad': return '41';
      case 'bortoleto': return '05';
      case 'ocon': return '31';
      case 'antonelli': return '12';
      default: return '01';
    }
  }

  String _getDriverTeam(String driverId) {
    final d = _allDrivers.where((element) => element.id == driverId).firstOrNull;
    if (d != null && d.teamName.isNotEmpty) {
      return d.teamName;
    }
    return F1Colors.getTeamColor('', driverId) != Colors.white54 ? driverId : 'Red Bull';
  }

  void _openSelectDriverSheet(int driverSlot) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectDriverModal(
        drivers: _allDrivers,
        getDriverNum: _getDriverNum,
        getDriverTeam: _getDriverTeam,
      ),
    );

    if (selectedId != null && selectedId.isNotEmpty) {
      setState(() {
        if (driverSlot == 1) {
          _favDriver1 = selectedId;
          LocalStorageService.setString('fav_driver_1', selectedId);
        } else {
          _favDriver2 = selectedId;
          LocalStorageService.setString('fav_driver_2', selectedId);
        }
      });
    }
  }

  void _openSelectTeamSheet() async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SelectTeamModal(
        teams: _allTeams,
        currentSelected: _favTeam,
      ),
    );

    if (selectedId != null && selectedId.isNotEmpty) {
      setState(() {
        _favTeam = selectedId;
        LocalStorageService.setString('fav_team', selectedId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = context.watch<ThemeCubit>().state;
    final currentLocale = context.watch<LocaleCubit>().state;
    final theme = Theme.of(context);

    final team1Name = _getDriverTeam(_favDriver1);
    final team1Color = F1Colors.getTeamColor(team1Name, _favDriver1);

    final team2Name = _getDriverTeam(_favDriver2);
    final team2Color = F1Colors.getTeamColor(team2Name, _favDriver2);

    final favTeamColor = F1Colors.getTeamColor(_favTeam);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.favoritesSection,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openSelectDriverSheet(1),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: team1Color,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDriverNum(_favDriver1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.unfold_more,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: () => _openSelectDriverSheet(2),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: team2Color,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDriverNum(_favDriver2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.unfold_more,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: _openSelectTeamSheet,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: favTeamColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TeamBadge(
                      teamId: _favTeam,
                      teamName: _favTeam,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.unfold_more,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              l10n.generalSection,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.notifications_none_outlined,
                    title: l10n.notifications,
                    trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    onTap: () {},
                  ),
                  _buildDivider(theme),

                  _buildSettingRow(
                    icon: Icons.contrast,
                    title: l10n.appTheme,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentTheme == ThemeMode.system
                              ? l10n.themeSystem
                              : (currentTheme == ThemeMode.dark ? l10n.themeDark : l10n.themeLight),
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.unfold_more, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 16),
                      ],
                    ),
                    onTap: () => context.read<ThemeCubit>().toggleTheme(),
                  ),
                  _buildDivider(theme),

                  _buildSettingRow(
                    icon: Icons.speed,
                    title: l10n.unitSystem,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _unitSystem,
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.unfold_more, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 16),
                      ],
                    ),
                    onTap: () {
                      final newSys = _unitSystem == 'Метрика' ? 'Имперская' : 'Метрика';
                      setState(() => _unitSystem = newSys);
                      LocalStorageService.setString('unit_system', newSys);
                    },
                  ),
                  _buildDivider(theme),

                  _buildSettingRow(
                    icon: Icons.access_time,
                    title: l10n.timeFormat24,
                    trailing: Switch(
                      value: _is24Hour,
                      activeTrackColor: Colors.redAccent,
                      onChanged: (val) {
                        setState(() => _is24Hour = val);
                        LocalStorageService.setString('is_24_hour', val.toString());
                      },
                    ),
                  ),
                  _buildDivider(theme),

                  _buildSettingRow(
                    icon: Icons.view_agenda_outlined,
                    title: l10n.detailedResults,
                    trailing: Switch(
                      value: _isDetailedResults,
                      activeTrackColor: Colors.redAccent,
                      onChanged: (val) {
                        setState(() => _isDetailedResults = val);
                        LocalStorageService.setString('is_detailed_results', val.toString());
                      },
                    ),
                  ),
                  _buildDivider(theme),

                  _buildSettingRow(
                    icon: Icons.translate,
                    title: l10n.language,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentLocale.languageCode == 'ru' ? 'Русский' : 'English',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                      ],
                    ),
                    onTap: () => context.read<LocaleCubit>().toggleLocale(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurface, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(color: theme.dividerColor, height: 1);
  }
}

class _TeamBadge extends StatelessWidget {
  final String teamId;
  final String teamName;

  const _TeamBadge({
    required this.teamId,
    required this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    final lower = '$teamId $teamName'.toLowerCase();
    String code = 'F1';
    if (lower.contains('red_bull') || lower.contains('red bull')) {
      code = 'RB';
    } else if (lower.contains('ferrari')) {
      code = 'SF';
    } else if (lower.contains('mercedes')) {
      code = 'MB';
    } else if (lower.contains('mclaren')) {
      code = 'MC';
    } else if (lower.contains('aston')) {
      code = 'AM';
    } else if (lower.contains('alpine')) {
      code = 'AP';
    } else if (lower.contains('williams')) {
      code = 'FW';
    } else if (lower.contains('haas')) {
      code = 'VF';
    } else if (lower.contains('sauber') || lower.contains('kick')) {
      code = 'C4';
    } else if (lower.contains('audi')) {
      code = 'AU';
    } else if (lower.contains('cadillac')) {
      code = 'CD';
    }

    return Text(
      code,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _SelectDriverModal extends StatefulWidget {
  final List<DriverModel> drivers;
  final String Function(String) getDriverNum;
  final String Function(String) getDriverTeam;

  const _SelectDriverModal({
    required this.drivers,
    required this.getDriverNum,
    required this.getDriverTeam,
  });

  @override
  State<_SelectDriverModal> createState() => _SelectDriverModalState();
}

class _SelectDriverModalState extends State<_SelectDriverModal> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final displayDrivers = widget.drivers.where((d) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return d.name.toLowerCase().contains(q) || d.teamName.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.selectDriver,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
              Divider(color: theme.dividerColor, height: 1),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = displayDrivers[index];
                    final num = widget.getDriverNum(driver.id);
                    final team = widget.getDriverTeam(driver.id);
                    final teamColor = F1Colors.getTeamColor(team);

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(driver.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  child: Text(
                                    num,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: teamColor,
                                      fontStyle: FontStyle.italic,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    driver.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: theme.dividerColor, height: 1),
                      ],
                    );
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.searchDriver,
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectTeamModal extends StatefulWidget {
  final List<ConstructorModel> teams;
  final String currentSelected;

  const _SelectTeamModal({
    required this.teams,
    required this.currentSelected,
  });

  @override
  State<_SelectTeamModal> createState() => _SelectTeamModalState();
}

class _SelectTeamModalState extends State<_SelectTeamModal> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final displayTeams = widget.teams.where((t) {
      if (_search.isEmpty) return true;
      final q = _search.toLowerCase();
      return t.name.toLowerCase().contains(q) || t.id.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.selectTeam,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 60),
                  ],
                ),
              ),
              Divider(color: theme.dividerColor, height: 1),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: displayTeams.length,
                  itemBuilder: (context, index) {
                    final team = displayTeams[index];
                    final isSelected = team.id.toLowerCase() == widget.currentSelected.toLowerCase();

                    return Column(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(team.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                _TeamBadge(
                                  teamId: team.id,
                                  teamName: team.name,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    team.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: theme.dividerColor, height: 1),
                      ],
                    );
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l10n.searchTeam,
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  onChanged: (val) => setState(() => _search = val),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}