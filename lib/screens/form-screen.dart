import 'package:demo_projects/screens/quize-view.dart';
import 'package:demo_projects/utils/comman-screen.dart';
import 'package:demo_projects/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  Widget build(BuildContext context) {
    return commanScreen(
      context: context,
      screenTitle: 'Form',
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(1.5.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Enter Your First Name',
                          labelText: 'First Name',
                          fillColor: Colors.grey,
                          border: OutlineInputBorder()),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.0.w,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Enter Your Last Name',
                          labelText: 'Last Name',
                          fillColor: Colors.grey,
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 1.5.h),
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Enter a Email',
                      labelText: 'Email',
                      fillColor: Colors.grey,
                      border: OutlineInputBorder()),
                ),
              ),
              textButton(
                  buttonName: 'START INTERVIEW',
                  context: context,
                  onTapFunction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizViewScreen(),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
