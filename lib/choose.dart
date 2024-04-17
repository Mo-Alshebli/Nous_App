import 'package:flutter/material.dart';
import 'package:idea_chatbot/global/common/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashBord/HomeScreen.dart';
import 'DashBord/style.dart';
import 'DashBord/ReaitimeData.dart';
class Choose extends StatefulWidget {
  final String CategoryName; // Ensure this is the correct type for your data

  const Choose({super.key, required this.CategoryName});

  @override
  State<Choose> createState() => _ChooseState();
}

class _ChooseState extends State<Choose> {
  int? selectedCardIndex;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<String>? namesList; // To store the names fetched by FutureBuilder

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: kBlueDarkColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                ),
                 Text(
                  widget.CategoryName, // Use CategoryName from the widget
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),

                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "اختر للجهة للبدء في المحادثة",
                  style: TextStyle(color: kOrangeColor, fontSize: 20),
                ),
                const SizedBox(
                  height: 20,
                ),
      FutureBuilder<List<String>>(
        future: getNamesByCategory(widget.CategoryName),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            // Store the names list for later use
            namesList = snapshot.data;
            return Column(
              children: List.generate(snapshot.data!.length, (index) {
                return _buildCard(index, snapshot.data![index]);
              }),
            );
          } else {
            return Text('No data found');
          }
        },
      ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (selectedCardIndex != null && namesList != null) {
                          String selectedName = namesList![selectedCardIndex!];
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('Selected_name', selectedName);
                          var idcompany =await getIdByName(selectedName);
                          await prefs.setString('company_id', idcompany!);
                          UserData();
                          // Navigation or other logic goes here
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ChatterScreen(),
                            ),
                          );
                        }
                        else{
                          showToast(message: "قم بتحديد الجهة المراد الاستفسار عنها");
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("ابدأ"),
                      ),
                 ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index,String name) {
    bool isSelected = selectedCardIndex == index;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedCardIndex = index;
          });

        },
        child: Card(
          color: Colors.white.withOpacity(0.07),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(isSelected ? Icons.check : Icons.circle,
                color: isSelected ? Colors.orange : Colors.grey),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${name} ',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
