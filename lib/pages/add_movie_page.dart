import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yellowclass_movie/helpers/database_helper.dart';
import 'package:yellowclass_movie/models/movie_model.dart';
import 'package:yellowclass_movie/helpers/image_helper.dart';

class AddMoviePage extends StatefulWidget {
  final Function? updateMovieList;
  final Movie? movie;

  AddMoviePage({this.updateMovieList, this.movie});

  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  String? _title = '';
  String? _directorName = '';
  String? _photo;
  bool photoError = false;

  @override
  void initState() {
    super.initState();

    if (widget.movie != null) {
      _title = widget.movie!.title;
      _directorName = widget.movie!.directorName;
      _photo = widget.movie!.photo;
    }
  }

  pickImageFromGallery() {
    ImagePicker().pickImage(source: ImageSource.gallery).then((imgFile) {
      File file = File(imgFile!.path);
      String imgString = ImageHelper.base64String(file.readAsBytesSync());
      setState(() {
        photoError = false;
        _photo = imgString;
      });
    });
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print(_photo);
      if (_photo == null) {
        setState(() {
          photoError = true;
        });
        return;
      }

      // insert
      Movie movie =
          Movie(title: _title, directorName: _directorName, photo: _photo);
      if (widget.movie == null) {
        DatabaseHelper.instance.insertMovie(movie);
      } else {
        movie.id = widget.movie!.id;
        DatabaseHelper.instance.updateMovie(movie);
      }

      widget.updateMovieList!();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back,
                    size: 30.0, color: Theme.of(context).primaryColor),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                '${widget.movie != null ? 'Edit Movie' : 'Add Movie'}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            labelText: 'Movie Name',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: (input) =>
                            input != null && input.trim().isEmpty
                                ? 'Please input a movie name'
                                : null,
                        onSaved: (input) => _title = input,
                        initialValue: _title,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: TextFormField(
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                            labelText: 'Director\'s Name',
                            labelStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        validator: (input) =>
                            input != null && input.trim().isEmpty
                                ? 'Please input a name'
                                : null,
                        onSaved: (input) => _directorName = input,
                        initialValue: _directorName,
                      ),
                    ),
                    if (_photo != null)
                      Stack(
                        children: [
                          Image.memory(
                            ImageHelper.dataFromBase64String(_photo!),
                            fit: BoxFit.fill,
                          ),
                          Center(
                            child: TextButton(
                              child: Text(
                                'Tap to replace',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    backgroundColor: Colors.white),
                              ),
                              onPressed: pickImageFromGallery,
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                            ),
                          ),
                        ],
                        alignment: Alignment.center,
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: IconButton(
                            icon: Icon(Icons.upload_file),
                            onPressed: pickImageFromGallery,
                          ),
                        ),
                      ),
                    Visibility(
                      visible: photoError,
                      child: Text(
                        'Please select a valid image',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
                      height: 60.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: TextButton(
                        child: Text(
                          '${widget.movie != null ? 'Update' : 'Add'}',
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        onPressed: _submit,
                      ),
                    )
                  ]))
            ],
          ),
        ),
      ),
    ));
  }
}
