import 'package:flutter/material.dart';
import 'package:movie_flix/models/application_model.dart';
import 'package:movie_flix/now_playing_screen.dart';
import 'package:movie_flix/top_rated_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) => ApplicationModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PersistentTabController _controller;

  @override
  void initState() {
    _controller = PersistentTabController(initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PersistentTabView(
        context,
        controller: _controller,
        screens: const [
          NowPlayingScreen(),
          TopRatedScreen(),
        ],
        items: [
          PersistentBottomNavBarItem(
            icon: const Icon(
              Icons.movie_creation_outlined,
            ),
            title: "Now Playing",
            activeColorPrimary: Colors.black,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(
              Icons.star_border,
            ),
            title: "Top Rated",
            activeColorPrimary: Colors.black,
            inactiveColorPrimary: Colors.grey,
          ),
        ],
        confineInSafeArea: true,
        backgroundColor: Colors.amber,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle: NavBarStyle.style6,
      ),
    );
  }
}
