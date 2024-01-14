import 'package:flutter/material.dart';

class BudgetWeek extends StatelessWidget {
  const BudgetWeek({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height: MediaQuery.of(context).size.height * 0.25,
      margin: const EdgeInsets.all(16.0),
      child: Card(
        color: const Color.fromARGB(255, 2, 54, 97),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0), // Set the desired margin
              child: Positioned(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2), // Add margin at the top
                      const Text(
                        'This week transactions',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12), // Add margin at the top
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Transactions',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              '',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        rows: const <DataRow>[
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
            ),
            // Add more widgets on top as needed
          ],
        ),
      ),
    );
  }
}
