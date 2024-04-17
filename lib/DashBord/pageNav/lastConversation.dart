import 'package:flutter/material.dart';
import 'package:idea_chatbot/DashBord/style.dart';
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
    refreshConversations();
  }

  void refreshConversations() {
    // Update conversationsData with the latest data from the database
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

      // Convert the map to a list of conversations
      var conversationsList = uniqueConversations.values.toList();

      // Sort the list in descending order of conversation IDs (assuming higher IDs are newer)
      conversationsList.sort((a, b) => b['id'].compareTo(a['id']));

      return conversationsList;
    } catch (e) {
      // Handle any errors here
      print('Error fetching conversations: $e');
      return [];
    }
  }

  void _deleteConversation(int conversationId) async {
    await DatabaseHelper.instance.deleteConversation(conversationId);
    refreshConversations(); // Refresh the list of conversations
    setState(() {}); // Trigger a rebuild to update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightDarkColor,
      appBar: AppBar(
        backgroundColor: kLightDarkColor,
        title: Center(
          child: Text('قائمة المحادثات السابقة', style: TextStyle(color: kOrangeColor)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kOrangeColor),
          onPressed: () async {
            DatabaseHelper dbHelper = DatabaseHelper.instance;
            int? latestConversationId = await dbHelper.getLatestConversationId();
            // Navigate back to the previous screen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => ChatterScreen(conversationId:latestConversationId)));                 },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: conversationsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
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
                    child: ListViewpro(
                      icon: Icon(Icons.message, color: kOrangeColor),
                      title: '$firstMessage',
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ChatterScreen(conversationId: id), // Assuming ChatterScreen is defined elsewhere
                          ),
                        );                      },
                      onDelete: () => _deleteConversation(id),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No Conversations Found'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
