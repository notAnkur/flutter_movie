import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yellowclass_movie/models/movie_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _db;

  DatabaseHelper._instance();

  String movieTable = 'movie_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDirectorName = 'directorName';
  String colPhoto = 'photo';

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDb();
    }

    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();

    String path = dir.path + 'movies.db';
    final movieDb = await openDatabase(path, version: 1, onCreate: _createDb);

    return movieDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $movieTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDirectorName TEXT, $colPhoto TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getMovieMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(movieTable);
    return result;
  }

  Future<List<Movie>> getMovieList() async {
    final List<Map<String, dynamic>> movieMapList = await getMovieMapList();
    final List<Movie> movieList = [];
    movieMapList.forEach((movieMap) {
      movieList.add(Movie.fromMap(movieMap));
    });

    return movieList;
  }

  Future<int> insertMovie(Movie movie) async {
    Database? db = await this.db;
    final int result = await db!.insert(movieTable, movie.toMap());
    return result;
  }

  Future<int> updateMovie(Movie movie) async {
    Database? db = await this.db;
    final result = await db!.update(movieTable, movie.toMap(),
        where: '$colId = ?', whereArgs: [movie.id]);

    return result;
  }

  Future<int> deleteMovie(int id) async {
    Database? db = await this.db;
    final int result =
        await db!.delete(movieTable, where: '$colId = ?', whereArgs: [id]);

    return result;
  }
}
