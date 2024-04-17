import 'package:flutter/material.dart';

import 'HomeScreen.dart';
import 'style.dart';



// كود الصفحة
class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlueDarkColor,  // لون الخلفية
      appBar: AppBar(
        title: Center(child: Text('من نحن',style: TextStyle(color: kOrangeColor,fontSize: 30),)),
        backgroundColor: kLightDarkColor,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ChatterScreen()));

            }
        ),
// لون خلفية الشريط العلوي
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/idea.png',  // شعار الشركة
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'فكر بذكاء، فكر بأيديا',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  'من نحن - شركة IDEA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kGreen,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'تُعد شركة IDEA رائدة في مجال الذكاء الاصطناعي والتكنولوجيا الرقمية، حيث تأسست برؤية تهدف إلى تحويل كيفية حياتنا، عملنا، وتعلمنا. نحن نستثمر في تكنولوجيا متقدمة لبناء مستقبل يُمكن الأفراد والمؤسسات من تحقيق التميز والاستدامة.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'رؤيتنا',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kOrangeColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'تتمحور حول أن نكون الداعم الأساسي لعصر جديد من التطورات الذكية، مما يعزز من قدراتنا لمواجهة تحديات الغد.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'مهمتنا',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kOrangeColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'تكمن في تمكين عملائنا من خلال الجمع بين الخبرة البشرية والابتكارات التكنولوجية لإنشاء حلول مبتكرة تعزز من فعالية الأداء وتعمق الفهم.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: <Widget>[
                //     CircleAvatar(
                //       backgroundImage: AssetImage('assets/founder1.jpg'),
                //       radius: 40,
                //     ),
                //     CircleAvatar(
                //       backgroundImage: AssetImage('assets/founder2.jpg'),
                //       radius: 40,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
