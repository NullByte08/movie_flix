import 'package:flutter/material.dart';
import 'package:movie_flix/models/top_rated_response_model.dart';
import 'package:provider/provider.dart';

import 'models/application_model.dart';
import 'models/constants.dart';
import 'movie_description_screen.dart';
import 'now_playing_screen.dart' as nps;

class TopRatedScreen extends StatefulWidget {
  const TopRatedScreen({Key? key}) : super(key: key);

  @override
  _TopRatedScreenState createState() => _TopRatedScreenState();
}

class _TopRatedScreenState extends State<TopRatedScreen> {
  bool apiCalledOnce = false;
  late Future<TopRatedResponseModel> fetchTopRatedList;

  bool initializedOnce = false;
  late TopRatedResponseModel _topRatedResponseModel;

  final TextEditingController _searchedTextController = TextEditingController();
  String _searchedText = "";

  @override
  Widget build(BuildContext context) {
    if (!apiCalledOnce) {
      apiCalledOnce = true;
      fetchTopRatedList = Provider.of<ApplicationModel>(context, listen: false).getTopRatedList();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;
        return Consumer<ApplicationModel>(builder: (context, pr, _) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: FutureBuilder<TopRatedResponseModel>(
                future: fetchTopRatedList,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Cannot fetch the \"Top Rated\" list. Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    if (!initializedOnce) {
                      initializedOnce = true;
                      _topRatedResponseModel = snapshot.data!;
                    }
                    return Column(
                      children: [
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
                                var result = _topRatedResponseModel.results[index];

                                Key key = UniqueKey();

                                if (_searchedText.isNotEmpty) {
                                  if (result.title.toLowerCase().contains(_searchedText.toLowerCase())) {
                                    return _TopRatedListTile(
                                      screenHeight: screenHeight,
                                      screenWidth: screenWidth,
                                      result: result,
                                      onDismissed: (DismissDirection dismissDirection) {
                                        setState(() {
                                          _topRatedResponseModel.results.removeAt(index);
                                        });
                                      },
                                      dismissKey: key,
                                    );
                                  }
                                  return Container();
                                } else {
                                  return _TopRatedListTile(
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    result: result,
                                    onDismissed: (DismissDirection dismissDirection) {
                                      setState(() {
                                        _topRatedResponseModel.results.removeAt(index);
                                      });
                                    },
                                    dismissKey: key,
                                  );
                                }
                              },
                              itemCount: _topRatedResponseModel.results.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return nps.LoadingMoviesIndicator(screenWidth: screenWidth, screenHeight: screenHeight);
                },
              ),
            ),
          );
        });
      },
    );
  }
}

class _TopRatedListTile extends StatelessWidget {
  const _TopRatedListTile({
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
    );
  }
}
