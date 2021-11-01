import 'package:flutter/material.dart';
import 'package:movie_flix/models/application_model.dart';
import 'package:movie_flix/now_playing_screen.dart';
import 'package:movie_flix/top_rated_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool darkTheme = prefs.getBool("darkTheme") ?? false;

  ApplicationModel applicationModel = ApplicationModel(darkThemeForCompleteApp: darkTheme);

  runApp(
    ChangeNotifierProvider.value(
      value: applicationModel,
      child: MyApp(
        darkTheme: darkTheme,
        prefs: prefs,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool darkTheme;
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.darkTheme, required this.prefs}) : super(key: key);

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
    return Consumer<ApplicationModel>(builder: (context, pr, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.amber,
          scaffoldBackgroundColor: Colors.amber,
          appBarTheme: AppBarTheme.of(context).copyWith(
            backgroundColor: Colors.amber,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: pr.darkThemeForCompleteApp ? ThemeMode.dark : ThemeMode.light,
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
              activeColorPrimary: pr.darkThemeForCompleteApp?Colors.white:Colors.black,
              inactiveColorPrimary: Colors.grey,
            ),
            PersistentBottomNavBarItem(
              icon: const Icon(
                Icons.star_border,
              ),
              title: "Top Rated",
              activeColorPrimary: pr.darkThemeForCompleteApp?Colors.white:Colors.black,
              inactiveColorPrimary: Colors.grey,
            ),
          ],
          confineInSafeArea: true,
          backgroundColor: pr.darkThemeForCompleteApp ? Colors.black : Colors.amber,
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
    });
  }
}
