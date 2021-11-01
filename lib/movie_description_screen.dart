import 'package:flutter/material.dart';
import 'package:movie_flix/models/constants.dart';

class MovieDescriptionScreen extends StatefulWidget {
  final String movieTitle;
  final String releaseDate;
  final double voteAverage;
  final String overview;
  final String moviePosterUrl;

  const MovieDescriptionScreen({
    Key? key,
    required this.overview,
    required this.movieTitle,
    required this.releaseDate,
    required this.voteAverage,
    required this.moviePosterUrl,
  }) : super(key: key);

  @override
  _MovieDescriptionScreenState createState() => _MovieDescriptionScreenState();
}

class _MovieDescriptionScreenState extends State<MovieDescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.grey,
                    ),
                    Text(
                      "Back",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leadingWidth: 70,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Image.network(
                  imageBaseUrlLargeSize + widget.moviePosterUrl,
                  fit: BoxFit.cover,
                  height: screenHeight,
                ),
                ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                      height: screenHeight * 0.7,
                    ),
                    Container(
                      color: Colors.black.withAlpha(150),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movieTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20
                            ),
                          ),
                          const SizedBox(height: 20,),
                          Text(
                            widget.releaseDate,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rate,
                                color: Colors.white,
                              ),
                              Text(
                                (widget.voteAverage * 10).toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Text(
                            widget.overview,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
