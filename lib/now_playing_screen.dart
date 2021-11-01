import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_flix/models/application_model.dart';
import 'package:movie_flix/models/constants.dart';
import 'package:movie_flix/models/now_playing_response_model.dart';
import 'package:movie_flix/movie_description_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool apiCalledOnce = false;
  late Future<NowPlayingResponseModel> fetchNowPlayingList;

  bool initializedOnce = false;
  late NowPlayingResponseModel _nowPlayingResponseModel;

  final TextEditingController _searchedTextController = TextEditingController();
  String _searchedText = "";

  @override
  Widget build(BuildContext context) {
    if (!apiCalledOnce) {
      apiCalledOnce = true;
      fetchNowPlayingList = Provider.of<ApplicationModel>(context, listen: false).getNowPlayingList();
    }

    return Consumer<ApplicationModel>(builder: (context, pr, _) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight;
          double screenWidth = constraints.maxWidth;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: FutureBuilder<NowPlayingResponseModel>(
                  future: fetchNowPlayingList,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Cannot fetch the \"Now Playing\" list. Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      if (!initializedOnce) {
                        initializedOnce = true;
                        _nowPlayingResponseModel = snapshot.data!;
                      }
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                              ),
                              Switch(
                                  value: pr.darkThemeForCompleteApp,
                                  onChanged: (value) async {
                                    pr.saveTheme(!pr.darkThemeForCompleteApp, await SharedPreferences.getInstance());
                                  }),
                              const Icon(
                                Icons.nightlight,
                              )
                            ],
                          ),
                          Container(
                            height: 50,
                            width: screenWidth,
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: TextField(
                              controller: _searchedTextController,
                              decoration: InputDecoration(
                                fillColor: pr.darkThemeForCompleteApp ? Colors.black54 : Colors.white,
                                filled: true,
                                hintText: "Search",
                                prefixIcon: const Icon(
                                  Icons.search,
                                ),
                                enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                suffixIcon: (_searchedTextController.text.isNotEmpty)
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchedTextController.text = "";
                                          setState(() {
                                            _searchedText = "";
                                          });
                                          FocusScope.of(context).unfocus(); // dismisses soft keyboard.
                                        },
                                        child: const Icon(
                                          Icons.cancel,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchedText = value;
                                });
                              },
                            ),
                          ),
                          const Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () {
                                setState(() {
                                  apiCalledOnce = false;
                                  initializedOnce = false;
                                });
                                return Future.value();
                              },
                              color: Colors.redAccent,
                              backgroundColor: pr.darkThemeForCompleteApp ? Colors.black54 : Colors.amber,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var result = _nowPlayingResponseModel.results[index];

                                  Key key = UniqueKey();

                                  if (_searchedText.isNotEmpty) {
                                    if (result.title.toLowerCase().contains(_searchedText.toLowerCase())) {
                                      return _NowPlayingListTile(
                                        screenHeight: screenHeight,
                                        screenWidth: screenWidth,
                                        result: result,
                                        onDismissed: (direction) {
                                          setState(() {
                                            _nowPlayingResponseModel.results.removeAt(index);
                                          });
                                        },
                                        dismissKey: key,
                                      );
                                    }
                                    return Container();
                                  } else {
                                    return _NowPlayingListTile(
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth,
                                      result: result,
                                      dismissKey: key,
                                      onDismissed: (direction) {
                                        setState(() {
                                          _nowPlayingResponseModel.results.removeAt(index);
                                        });
                                      },
                                    );
                                  }
                                },
                                itemCount: _nowPlayingResponseModel.results.length,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return LoadingMoviesIndicator(screenWidth: screenWidth, screenHeight: screenHeight);
                  }),
            ),
          );
        },
      );
    });
  }
}

class _NowPlayingListTile extends StatelessWidget {
  const _NowPlayingListTile({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
    required this.result,
    required this.dismissKey,
    required this.onDismissed,
  }) : super(key: key);

  final double screenHeight;
  final double screenWidth;
  final Results result;
  final Key dismissKey;
  final Function(DismissDirection dismissDirection) onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: dismissKey,
      background: Container(
        color: Colors.red,
        child: const Center(
          child: Text(
            "Removed",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      onDismissed: onDismissed,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MovieDescriptionScreen(
                        overview: result.overview,
                        movieTitle: result.title,
                        releaseDate: result.releaseDate,
                        voteAverage: double.parse(result.voteAverage),
                        moviePosterUrl: result.posterPath,
                      )));
        },
        child: Container(
          height: screenHeight * 0.2,
          width: screenWidth,
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Image.network(
                imageBaseUrlSmallSize + result.posterPath,
                fit: BoxFit.cover,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      result.title,
                      style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      result.overview,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    const SizedBox(
                      height: 10,
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
}

class LoadingMoviesIndicator extends StatelessWidget {
  const LoadingMoviesIndicator({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
        ),
        width: screenWidth * 0.4,
        height: screenHeight * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Theme(
              data: ThemeData(cupertinoOverrideTheme: const CupertinoThemeData(brightness: Brightness.dark)),
              child: const CupertinoActivityIndicator(
                radius: 20,
              ),
            ),
            const Text(
              "Loading Movies...",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
