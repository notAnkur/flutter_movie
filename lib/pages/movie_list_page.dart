import 'package:flutter/material.dart';
import 'package:yellowclass_movie/helpers/database_helper.dart';
import 'package:yellowclass_movie/helpers/image_helper.dart';
import 'package:yellowclass_movie/models/movie_model.dart';
import 'package:yellowclass_movie/pages/add_movie_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({Key? key}) : super(key: key);

  @override
  _MovieListPageState createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  Future<List<Movie>>? _movieList;

  @override
  void initState() {
    super.initState();
    _updateMovieList();
  }

  _updateMovieList() {
    setState(() {
      _movieList = DatabaseHelper.instance.getMovieList();
    });
  }

  Widget _buildMovie(Movie movie) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  movie.title ?? '',
                  style: TextStyle(fontSize: 20.0),
                ),
                subtitle: Text(
                  '${movie.directorName}',
                  style: TextStyle(fontSize: 15.0),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.yellow[600],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddMoviePage(
                                      updateMovieList: _updateMovieList,
                                      movie: movie,
                                    )));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded,
                          color: Theme.of(context).primaryColor),
                      onPressed: () {
                        if (movie.id != null) {
                          DatabaseHelper.instance.deleteMovie(movie.id!);
                          _updateMovieList();
                        }
                      },
                    )
                  ],
                ),
              ),
              ImageHelper.imageFromBase64String(
                  movie.photo ?? ImageHelper.defaultB64Image),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddMoviePage(
                      updateMovieList: _updateMovieList,
                    ))),
      ),
      body: FutureBuilder(
        future: _movieList,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Scrollbar(
            thickness: 10,
            radius: Radius.circular(10.0),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 80.0),
              itemCount: snapshot.data.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('My Movies',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 40,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${snapshot.data.length} movies',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  );
                }

                return _buildMovie(snapshot.data[index - 1]);
              },
            ),
          );
        },
      ),
    );
  }
}
