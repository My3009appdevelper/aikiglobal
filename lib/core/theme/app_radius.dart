import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const xs = Radius.circular(10);
  static const sm = Radius.circular(16);
  static const md = Radius.circular(22);
  static const lg = Radius.circular(30);
  static const xl = Radius.circular(38);
  static const pill = Radius.circular(999);

  static BorderRadius get small => BorderRadius.all(sm);
  static BorderRadius get medium => BorderRadius.all(md);
  static BorderRadius get large => BorderRadius.all(lg);
  static BorderRadius get extraLarge => BorderRadius.all(xl);
  static BorderRadius get full => BorderRadius.all(pill);
}
