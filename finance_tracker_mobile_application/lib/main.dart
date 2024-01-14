// import 'package:finance_tracker_mobile_application/pages/home.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(fontFamily: 'Inter'),
//         home: const HomePage()
//       // title: 'Flutter Demo',

//       // theme: ThemeData(
//       //   // This is the theme of your application.
//       //   //
//       //   // TRY THIS: Try running your application with "flutter run". You'll see
//       //   // the application has a purple toolbar. Then, without quitting the app,
//       //   // try changing the seedColor in the colorScheme below to Colors.green
//       //   // and then invoke "hot reload" (save your changes or press the "hot
//       //   // reload" button in a Flutter-supported IDE, or press "r" if you used
//       //   // the command line to start the app).
//       //   //
//       //   // Notice that the counter didn't reset back to zero; the application
//       //   // state is not lost during the reload. To reset the state, use hot
//       //   // restart instead.
//       //   //
//       //   // This works for code too, not just values: Most code changes can be
//       //   // tested with just a hot reload.
//       //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       //   useMaterial3: true,
//       // ),

//     );
//   }
// }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});

// //   // This widget is the home page of your application. It is stateful, meaning
// //   // that it has a State object (defined below) that contains fields that affect
// //   // how it looks.

// //   // This class is the configuration for the state. It holds the values (in this
// //   // case the title) provided by the parent (in this case the App widget) and
// //   // used by the build method of the State. Fields in a Widget subclass are
// //   // always marked "final".

// //   final String title;

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   int _counter = 0;

// //   void _incrementCounter() {
// //     setState(() {
// //       // This call to setState tells the Flutter framework that something has
// //       // changed in this State, which causes it to rerun the build method below
// //       // so that the display can reflect the updated values. If we changed
// //       // _counter without calling setState(), then the build method would not be
// //       // called again, and so nothing would appear to happen.
// //       _counter++;
// //     });
// //   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   // This method is rerun every time setState is called, for instance as done
//   //   // by the _incrementCounter method above.
//   //   //
//   //   // The Flutter framework has been optimized to make rerunning build methods
//   //   // fast, so that you can just rebuild anything that needs updating rather
//   //   // than having to individually change instances of widgets.
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       // TRY THIS: Try changing the color here to a specific color (to
//   //       // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//   //       // change color while the other colors stay the same.
//   //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//   //       // Here we take the value from the MyHomePage object that was created by
//   //       // the App.build method, and use it to set our appbar title.
//   //       title: Text(widget.title),
//   //     ),
//   //     body: Center(
//   //       // Center is a layout widget. It takes a single child and positions it
//   //       // in the middle of the parent.
//   //       child: Column(
//   //         // Column is also a layout widget. It takes a list of children and
//   //         // arranges them vertically. By default, it sizes itself to fit its
//   //         // children horizontally, and tries to be as tall as its parent.
//   //         //
//   //         // Column has various properties to control how it sizes itself and
//   //         // how it positions its children. Here we use mainAxisAlignment to
//   //         // center the children vertically; the main axis here is the vertical
//   //         // axis because Columns are vertical (the cross axis would be
//   //         // horizontal).
//   //         //
//   //         // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//   //         // action in the IDE, or press "p" in the console), to see the
//   //         // wireframe for each widget.
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: <Widget>[
//   //           const Text(
//   //             'You have pushed the button this many times:',
//   //           ),
//   //           Text(
//   //             '$_counter',
//   //             style: Theme.of(context).textTheme.headlineMedium,
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //     floatingActionButton: FloatingActionButton(
//   //       onPressed: _incrementCounter,
//   //       tooltip: 'Increment',
//   //       child: const Icon(Icons.add),
//   //     ), // This trailing comma makes auto-formatting nicer for build methods.
//   //   );
//   // }
// // }

/// * Tester Main file

import 'package:flutter/material.dart';
import 'controller/form_controller.dart';
import 'model/form.dart';
import 'package:finance_tracker_mobile_application/pages/feedback_list.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Sheet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Google Sheet Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed.
      FeedbackForm feedbackForm = FeedbackForm(
          nameController.text,
          emailController.text,
          mobileNoController.text,
          feedbackController.text);

      FormController formController = FormController();

      showSnackBar(context, 'Submitting Feedback');

      // Submit 'feedbackForm' and save it in Google Sheets.
      formController.submitForm(feedbackForm, (String response) {
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          // Feedback is saved succesfully in Google Sheets.
          showSnackBar(context, 'Feedback Submitted');
        } else {
          // Error Occurred while saving data in Google Sheets.
          showSnackBar(context, 'Error Occurred!');
        }
      });
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  // Method to show snackbar with 'message'.
  // _showSnackbar(String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   _scaffoldKey.currentState.showSnackBar(snackBar);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Valid Name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (!value!.contains("@")) {
                            return 'Enter Valid Email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextFormField(
                        controller: mobileNoController,
                        validator: (value) {
                          if (value!.trim().length != 10) {
                            return 'Enter 10 Digit Mobile Number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                        ),
                      ),
                      TextFormField(
                        controller: feedbackController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Valid Feedback';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.multiline,
                        decoration:
                            const InputDecoration(labelText: 'Feedback'),
                      ),
                    ],
                  ),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // text color
              ),
              onPressed: _submitForm,
              child: const Text('Submit Feedback'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // text color
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeedbackListScreen(),
                    ));
              },
              child: const Text('View Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
