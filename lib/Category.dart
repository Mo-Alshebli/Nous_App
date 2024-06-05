import 'package:flutter/material.dart';

import 'DashBord/ReaitimeData.dart';
import 'DashBord/style.dart';
import 'choose.dart';


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int? selectedCardIndex;
  Future<int> printCategoryCount() async {
    final List<String> categories = await getCategories(); // Wait for the list to be obtained
    return categories.length;
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  // Asynchronous method to load preferences
  Future<void> loadPreferences() async {

    // If you need to use `onboardingShown` to rebuild the widget, call `setState`
    setState(() {
      // This will trigger a rebuild with the updated value
    });
  }


  Future<String?> username=getUserUser();
  final Future<List<String>> listData = getCategories();
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: kBlueDarkColor,
      body: SafeArea(
        child: Column(
          children: [
             SizedBox(
              height: 50,
            ),
             Padding(
              padding: EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  FutureBuilder<String?>(
                    future: getUserUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Row(
                            children: [
                              Text(
                                "مــرحـبـا ",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),

                              Text(
                                snapshot.data ?? 'No Username',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          );

                        }
                      }
                    },
                  ),
                  // CircleAvatar(
                  //   backgroundImage: AssetImage("assets/images/pr.jpg"),
                  //   radius: 30,
                  // ),
                ],
              ),
            ),
             SizedBox(
              height: 20,
            ),
             Text(
              'انا روبوت محادثة متخصص بخدمة العملاء بالذكاء الاصطناعي  ',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 40,
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "اختر الفئة المراد الاستفسار عنها   ",
              style: TextStyle(color: kOrangeColor, fontSize: 20),
            ),
            Column(
              children: [
            FutureBuilder<List<String>>(
            future: getCategories(), // the Future<List<String>> you want to work with
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for the data
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle any errors that occur during the future execution
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Once the data is available, build a widget for each category
                  return SingleChildScrollView( // Added to ensure your list is scrollable
                    child: Column(
                      children: [
                        for (int index = 0; index < snapshot.data!.length; index += 2) Row(
                          children: [
                            Expanded(child: _buildCard(index, snapshot.data![index])),
                            if (index + 1 < snapshot.data!.length)
                              Expanded(child: _buildCard(index + 1, snapshot.data![index + 1])),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  // Handle the case where you have no data
                  return Text('No categories found');
                }
              },
      ),


      ],
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildCard(int index, String categoryName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,40,20,0),
      child: SizedBox(
        width:150,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Choose(CategoryName: categoryName,)));
          },
          child: Card(
            color:kOrangeColor,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Center(
                    child: Icon(
                      Icons.co_present_sharp, // Example icon, replace with your desired icon
                      color: Colors.black,
                      size: 23,
                    ),
                  ),
                  SizedBox(width: 80),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      categoryName, // Use the categoryName passed to _buildCard
                      style: TextStyle(color: Colors.black, fontSize: 16), // Adjusted for visibility
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class ColumnButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const ColumnButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 70,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(
                Icons.add, // Replace with your desired icon
                size: 24.0, // Adjust icon size as needed
              ),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                primary: kOrangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ...



