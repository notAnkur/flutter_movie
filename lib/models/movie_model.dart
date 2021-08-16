class Movie {
  int? id;
  String? title;
  String? directorName;
  String? photo;

  Movie({this.title, this.directorName, this.photo});
  Movie.withId({this.id, this.title, this.directorName, this.photo});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['directorName'] = directorName;
    map['photo'] = photo;
    return map;
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie.withId(
        id: map['id'],
        title: map['title'],
        directorName: map['directorName'],
        photo: map['photo']);
  }
}
