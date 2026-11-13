import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/navigation/app_router.dart';
import 'common/theme/app_theme.dart';
import 'common/theme/theme_cubit.dart';
import 'common/localization/locale_cubit.dart';
import 'common/startup/app_startup_cubit.dart';
import 'features/driver/data/driver_repository.dart';
import 'features/driver/domain/i_driver_repository.dart';
import 'features/driver/presentation/bloc/list/driver_list_cubit.dart';
import 'common/network/dio_client.dart';
import 'features/driver/data/api/driver_api.dart';
import 'features/driver/data/data_sources/network_driver_data_source.dart';
import 'package:f1_app/common/localization/generated/app_localizations.dart';

import 'features/constructor/data/constructor_repository.dart';
import 'features/constructor/data/data_sources/constructor_remote_data_source.dart';
import 'features/constructor/domain/constructor_repository.dart';

import 'features/schedule/data/data_sources/schedule_remote_data_source.dart';
import 'features/schedule/data/schedule_repository.dart';
import 'features/schedule/domain/schedule_repository.dart';

class F1App extends StatelessWidget {
  const F1App({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.create();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IDriverRepository>(
          create: (_) {
            final api = DriverApi(dio);
            final dataSource = NetworkDriverDataSource(api);
            return DriverRepository(dataSource);
          },
        ),

        RepositoryProvider<IConstructorRepository>(
          create: (_) => ConstructorRepository(
            ConstructorRemoteDataSource(dio),
          ),
        ),

        RepositoryProvider<IScheduleRepository>(
          create: (_) => ScheduleRepository(
            ScheduleRemoteDataSource(dio),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => DriverListCubit(ctx.read<IDriverRepository>())..loadDrivers(),
          ),
          BlocProvider(
            create: (ctx) => AppStartupCubit(
              driverRepo: ctx.read<IDriverRepository>(),
              constructorRepo: ctx.read<IConstructorRepository>(),
            )..initialize(),
          ),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LocaleCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  routerConfig: appRouter,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
