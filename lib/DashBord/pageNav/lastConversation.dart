
import 'package:flutter/material.dart';

import '../DashBoard_widget/navBar_ListViwe_Widget.dart';
import '../DataBase/DataBase.dart';
import '../HomeScreen.dart';

class ConversationsListPage extends StatefulWidget {
  @override
  _ConversationsListPageState createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  late Future<List<Map<String, dynamic>>> conversationsData;

  @override
  void initState() {
    super.initState();
    conversationsData = _fetchUniqueConversation();
  }

  Future<List<Map<String, dynamic>>> _fetchUniqueConversation() async {
    try {
      final allMessages = await DatabaseHelper.instance.queryAllRows();
      final Map<int, Map<String, dynamic>> uniqueConversations = {};

      for (var message in allMessages) {
        final id = int.parse(message[DatabaseHelper.columnConversationId].toString());
        if (!uniqueConversations.containsKey(id)) {
          uniqueConversations[id] = {
            'id': id,
            'firstMessage': message[DatabaseHelper.columnText]
          };
        }
      }

      return uniqueConversations.values.toList();
    } catch (e) {
      // Handle any errors here
      print('Error fetching conversations: $e');
      return [];
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('قائمة المحادثات السابقة'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            DatabaseHelper dbHelper = DatabaseHelper.instance;
            int? latestConversationId = await dbHelper.getLatestConversationId();
            // Navigate back to the previous screen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => ChatterScreen(conversationId:latestConversationId)));          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: conversationsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              // Handle the error case
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data![index];
                  final id = data['id'];
                  final firstMessage = data['firstMessage'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: listViewpro(
                      icon: Icon(Icons.message, color: Colors.blue),
                      title: 'المحادثة $id - $firstMessage',
                      onTap: () {

                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => ChatterScreen(conversationId: id)));
                      },
                    ),
                  );
                },
              );
            } else {
              // Handle the case when there are no conversations
              return Center(child: Text('No Conversations Found'));
            }
          } else {
            // Show a loading indicator while waiting for the data
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
