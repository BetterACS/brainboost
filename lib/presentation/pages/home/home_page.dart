import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:brainboost/component/circular_page_chart.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/cards/profile_header.dart';
import 'package:brainboost/component/history_item.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/presentation/bloc/auth/auth_bloc.dart';
import 'package:brainboost/presentation/bloc/auth/auth_state.dart';
import 'package:brainboost/presentation/bloc/home/home_bloc.dart';
import 'package:brainboost/presentation/bloc/home/home_event.dart';
import 'package:brainboost/presentation/bloc/home/home_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Cloud circles
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 1.2), 114, paint);
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.95), 45, paint);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 1.15), 77, paint);
    canvas.drawCircle(Offset(size.width * 0.79, size.height * 1.5), 83, paint);
    canvas.drawCircle(Offset(size.width * 1, size.height * 0.98), 95, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _MouseScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<HomeBloc>().add(
            LoadUserDataEvent(email: authState.user.email),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        final isDarkMode = currentTheme == ThemeMode.dark;
        
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppColors.backgroundDarkmode
              : AppColors.mainColor,
          body: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is HomeError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              
              return ScrollConfiguration(
                behavior: _MouseScrollBehavior(),
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadUserData();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        const ProfileContainer(),
                        const SizedBox(height: 20),
                        _buildPerformanceChart(context, state),
                        const SizedBox(height: 10),
                        _buildCreateSection(context),
                        _buildCreateButtons(context),
                        _buildHistorySection(context, state),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart(BuildContext context, HomeState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    int totalGames = 0;
    int correctAnswers = 0;
    bool isLoaded = false;
    
    if (state is GamePerformanceLoaded) {
      totalGames = state.totalGames;
      correctAnswers = state.correctAnswers;
      isLoaded = state.isLoaded;
    } else if (state is HomeLoadComplete) {
      totalGames = state.totalGames;
      correctAnswers = state.correctAnswers;
      isLoaded = true;
    }
    
    return SizedBox(
      height: 330,
      width: 300,
      child: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(285, 285),
                painter: CircularChartPainter(
                  totalGames > 0 ? (correctAnswers / totalGames) * 100 : 0,
                  isDarkMode,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isLoaded || totalGames == 0)
                    Text(
                      AppLocalizations.of(context)!.completeGame,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.successRate,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (!isLoaded || totalGames == 0)
                    Text(
                      AppLocalizations.of(context)!.seeProgress,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontSize: 17.59,
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          "${((correctAnswers / totalGames) * 100).toStringAsFixed(2)}%",
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.textPrimary
                                : AppColors.buttonText,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)!.outOfQuestions(totalGames),
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.textPrimary
                                : AppColors.buttonText,
                            fontSize: 17.59,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.start,
          style: TextStyle(
            color: isDarkMode ? AppColors.textPrimary : AppColors.gradient1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.buttonGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: SizedBox(
                  child: CustomPaint(
                    size: const Size(double.infinity, 100),
                    painter: CloudPainter(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.expianedmaincreategame,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the games page and show the "Add Game" card
                            GoRouter.of(context).go(Routes.gamePage, extra: {'showAddGame': true});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.createGame,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002654),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(
                        'assets/images/rockety.png',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, HomeState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final authState = context.read<AuthBloc>().state;
    final String? email = authState is Authenticated ? authState.user.email : null;
    
    List<Map<String, dynamic>> historyItems = [];
    bool isPerformanceLoaded = false;
    int totalGames = 0;
    
    if (state is HistoryLoaded) {
      historyItems = state.historyItems;
    } else if (state is HomeLoadComplete) {
      historyItems = state.historyItems;
      isPerformanceLoaded = true;
      totalGames = state.totalGames;
    } else if (state is GamePerformanceLoaded) {
      isPerformanceLoaded = state.isLoaded;
      totalGames = state.totalGames;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.buttonText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPerformanceLoaded && totalGames > 0)
                GestureDetector(
                  onTap: () {
                    context.push(Routes.historyPage, extra: email);
                  },
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.viewAll,
                        style: TextStyle(
                          color: AppColors.gray2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.gray2,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (state is HomeLoading)
            const Center(child: CircularProgressIndicator())
          else if (!isPerformanceLoaded || totalGames == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.backgroundDarkmode : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Text(
                    AppLocalizations.of(context)!.historyWillAppearHere,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.buttonText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.completeGameToSeeHistory,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : AppColors.buttonText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else if (historyItems.isEmpty)
            Center(
              child: Text(
                AppLocalizations.of(context)!.noHistoryFound,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.buttonText,
                ),
              ),
            )
          else
            Column(
              children: historyItems
                  .take(2) // Show only the first 2 history items
                  .map((game) => HistoryItem(
                        title: game['game_name'] ?? 'Unknown',
                        date: DateFormat('dd MMM yyyy').format(
                          (game['played_at'] as Timestamp).toDate(),
                        ),
                        imagePath: "assets/${game['icon'] ?? 'animations/map1.GIF'}", 
                        bestScore: game['best_score'] ?? 0,
                        documentReference: game['game_id'],
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}