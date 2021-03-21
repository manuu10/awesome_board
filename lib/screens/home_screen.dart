import 'package:awesome_board/bloc/theme_bloc.dart';
import 'package:awesome_board/models/custom_theme.dart';
import 'package:awesome_board/screens/create_problem_screen.dart';
import 'package:awesome_board/screens/overview_screen.dart';
import 'package:awesome_board/screens/settings_screen.dart';
import 'package:awesome_board/widgets/gradient_icon.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _selectedIndex = 1;

  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _pages = [
      CreateProblemScreen(),
      OverviewScreen(),
      SettingsScreen(),
    ];
  }

  @override
  void dispose() async {
    _pageController.dispose();
    await Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, CustomTheme>(
      builder: (context, _theme) {
        return Scaffold(
          backgroundColor: _theme.background,
          extendBody: true,
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
              },
              children: _pages,
            ),
          ),
          bottomNavigationBar: BottomNavyBar(
            iconSize: 24,
            backgroundColor: _theme.secondBackground,
            selectedIndex: _selectedIndex,
            showElevation: true, // use this to remove appBar's elevation
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
              _pageController.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.ease);
            },
            items: [
              BottomNavyBarItem(
                icon: GradientIcon(
                  Icons.add_box_outlined,
                  24,
                  _theme.linearGradient,
                ),
                title: Text('Create'),
                activeColor: _theme.selectionForeground,
              ),
              BottomNavyBarItem(
                icon: GradientIcon(
                  Icons.dashboard_outlined,
                  24,
                  _theme.linearGradient,
                ),
                title: Text('Overview'),
                activeColor: _theme.selectionForeground,
              ),
              BottomNavyBarItem(
                icon: GradientIcon(
                  Icons.settings,
                  24,
                  _theme.linearGradient,
                ),
                title: Text('Settings'),
                activeColor: _theme.selectionForeground,
              ),
            ],
          ),
        );
      },
    );
  }
}
