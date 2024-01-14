import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_mobile_application/controller/form_controller.dart';
import 'package:finance_tracker_mobile_application/model/form.dart';

class HomeCardPage extends StatefulWidget {
  const HomeCardPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _HomeCardPageState createState() => _HomeCardPageState();
}

class _HomeCardPageState extends State<HomeCardPage> {
  FeedbackForm? feedback;

  @override
  void initState() {
    super.initState();

    FormController().getFeedback().then((feedback) {
      setState(() {
        this.feedback = feedback;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 2, 54, 97),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SvgPicture.asset(
                'assets/BackgroundCard.svg',
                fit: BoxFit.cover,
                color: Colors.black,
              ),
            ),
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ClipOval(
                      child: Image.asset(
                        'assets/Avatar.jpg',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your available balance is',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${feedback?.actualBalance ?? 0} TK',
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        'By this time last month you spent slightly higher (22,719 TK)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              'Recent Transactions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              '',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                      rows: const [
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text(
                              'Bkash',
                              style: TextStyle(color: Colors.white70),
                            )),
                            DataCell(Text(
                              '12,000 TK',
                              style: TextStyle(color: Colors.white70),
                            )),
                          ],
                        ),
                        DataRow(
                          cells: <DataCell>[
                            DataCell(Text(
                              'Maa Pharmacy',
                              style: TextStyle(color: Colors.white70),
                            )),
                            DataCell(Text(
                              '1,245 TK',
                              style: TextStyle(color: Colors.white70),
                            )),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
