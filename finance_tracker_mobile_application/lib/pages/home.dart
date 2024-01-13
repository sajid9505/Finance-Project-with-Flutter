import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello Sajid',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Your finances are looking not so good...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle search button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        margin: const EdgeInsets.all(16.0),
        child: Card(
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
                // top: 16, // Adjust the top position as needed
                // left: 55, // Adjust the left position as needed
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16), // Add margin at the top
                      ClipOval(
                        child: Image.asset(
                          'assets/Avatar.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit
                              .cover, // Ensure the image covers the circular area
                        ),
                      ),
                      const SizedBox(height: 16), // Add margin at the top
                      const Text(
                        'Your available balance is',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        '20,983 TK',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'By this time last month you spent slightly higher (22,719 TK)',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16), // Add margin at the top
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Recent Transactions',
                                style: TextStyle(fontStyle: FontStyle.italic),
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
                        rows: const <DataRow>[
                          DataRow(
                            cells: <DataCell>[
                              DataCell(Text('Bkash')),
                              DataCell(Text('12,000 TK')),
                            ],
                          ),
                          DataRow(
                            cells: <DataCell>[
                              DataCell(Text('Maa Pharmacy')),
                              DataCell(Text('1,245 TK')),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              // Add more widgets on top as needed
            ],
          ),
        ),
      ),
    );
  }
}
