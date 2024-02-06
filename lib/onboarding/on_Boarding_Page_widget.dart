import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/size.dart';
import 'on_boarding_controller.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({
    super.key,
    required this.model,
  });

  final OnBoardingModel model;

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  Map<String, String> companyNamesAndIds = {};
  String? selectedCompanyName;
  String? selectedCompanyid;
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getCompanyNames();
  }

  Future<void> getCompanyNames() async {
    DataSnapshot snapshot = await databaseReference.child('CompanyInformation')
        .get();
    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> companies = snapshot.value as Map<dynamic, dynamic>;
      Map<String, String> namesAndIds = {};
      companies.forEach((key, value) {
        if (value is Map && value['Name'] != null) {
          namesAndIds[value['Name']] = key;
          // Access the first key
          // حفظ الاسم مع الـ ID
        }
      });
      setState(() {
        companyNamesAndIds = namesAndIds;
        var keysList = companies.keys.toList();
        selectedCompanyid = keysList[0] ;
        print(selectedCompanyid);});
    } else {
      print('No data available.');
    }
  }

  Future<void> saveCompanyId(String? companyname,String? companyId) async {
    if (companyname != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_name', companyname);
      await prefs.setString('company_id', companyId!);
      print('Saved Company ID: $companyId');
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(tDefualtsize),
      color: widget.model.bgcolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
         Lottie.asset(widget.model.image, height: size.height * 0.5,
             width: size.width * 0.9,),

          Column(
            children: [
              if(widget.model.num==4)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                    child: DropdownButton<String>(
                      isExpanded: true, // Expands to fit the Container
                      hint: Center(child: Text('اختر شركة')),
                      value: selectedCompanyName,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCompanyName = newValue;
                          saveCompanyId(selectedCompanyName,selectedCompanyid);
                        });
                      },
                      items: companyNamesAndIds.entries.map<DropdownMenuItem<String>>((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Center(child: Text(entry.key)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              SizedBox(
                height: 50.0,
              ),
              Text(
                widget.model.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                widget.model.subtitle,
                textAlign: TextAlign.center,
              )
            ],
          ),

          Text(
            widget.model.numPage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 120.0,
          ),
        ],
      ),
    );
  }
}
