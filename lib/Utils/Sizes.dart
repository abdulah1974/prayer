import 'package:flutter/cupertino.dart';

class Sizes {
  var size;
  var context;

  Sizes(context) {
    this.context = context;
    size = MediaQuery.of(context).size;
  }

  double GetWidth() {
    return  size.width *  0.01;
  }

  double GetHeight() {
    return (size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom) *0.01;
  }
}