import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget commanScreen({context, body, screenTitle}) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark
        .copyWith(statusBarColor: Theme.of(context).primaryColor),
    child: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenTitle),
        ),
        body: body,
      ),
    ),
  );
}
