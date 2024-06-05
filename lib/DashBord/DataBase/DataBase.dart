import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "chat.db";
  static final _databaseVersion = 2;

  // Table names
  static final tableMessages = "messages";
  static final tableConversations = "conversations";

  // Columns for messages
  static final columnId = "_id";
  static final columnText = "text";
  static final columnSender = "sender";
  static final columnConversationId = "conversation_id";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) {
          db.execute("PRAGMA foreign_keys = ON");
        });
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableConversations (
            $columnConversationId INTEGER PRIMARY KEY
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableMessages (
            $columnId INTEGER PRIMARY KEY,
            $columnText TEXT NOT NULL,
            $columnSender TEXT NOT NULL,
            $columnConversationId INTEGER,
            FOREIGN KEY ($columnConversationId) 
              REFERENCES $tableConversations($columnConversationId) ON DELETE CASCADE
          )
          ''');
    db.execute("PRAGMA foreign_keys = ON");  // Enable foreign key constraints
  }
  Future<int?> getHighestConversationId() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT MAX($columnConversationId) as max_id FROM $tableConversations');
    if (result.isNotEmpty && result.first['max_id'] != null) {
      return result.first['max_id'] as int;
    }
    return null;
  }


  Future<void> deleteMessagePair(String userMessage, String chatbotMessage, int conversationId) async {
    try {
      Database db = await database;
      await db.delete(
        tableMessages,
        where: '($columnText = ? OR $columnText = ?) AND $columnConversationId = ?',
        whereArgs: [userMessage, chatbotMessage, conversationId],
      );
    } catch (e) {
      throw e; // rethrow the exception to handle it in the calling method
    }
  }
  Future<int?> getLatestConversationId() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT MAX($columnConversationId) as latest_id FROM $tableConversations');
    if (result.isNotEmpty) {
      return result.first['latest_id'] as int?;
    }
    return null;
  }


  Future<List<Map<String, dynamic>>> getMessagesForConversation(int conversationId) async {
    Database db = await database;
    return await db.query(
        'messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
    );
  }



  Future<int> insertMessage(Map<String, dynamic> message, int conversationId) async {
    Database db = await database;
    message[columnConversationId] = conversationId;

    return await db.insert(tableMessages, message);
  }
  Future<String?> getFirstMessageForConversation(int conversationId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      DatabaseHelper.tableMessages,
      where: '${DatabaseHelper.columnConversationId} = ?',
      whereArgs: [conversationId],
      orderBy: '${DatabaseHelper.columnId} ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first[DatabaseHelper.columnText].toString();
    }
    return null;
  }

  Future<void> deleteConversation(int conversationId) async {
    Database db = await database;
    try {
      // First, manually delete messages associated with the conversation
      await db.delete(
        tableMessages,
        where: '$columnConversationId = ?',
        whereArgs: [conversationId],
      );

      // Then, delete the conversation itself
      await db.delete(
        tableConversations,
        where: '$columnConversationId = ?',
        whereArgs: [conversationId],
      );

    } catch (e) {
      throw e; // Allow handling it outside this function
    }
  }

  Future<int> createNewConversation([int? id]) async {
    Database db = await database;
    if (id != null) {
      return await db.insert(tableConversations, {columnConversationId: id});
    } else {
      return await db.insert(tableConversations, <String, dynamic>{}, nullColumnHack: columnConversationId);
    }
  }




  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await database;
    return await db.query(tableMessages);
  }

  Future<int> deleteAll() async {
    Database db = await database;
    return await db.delete(tableMessages);
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      // Handle database upgrades here
      // For now, this simply drops existing tables and recreates them
      await db.execute('DROP TABLE IF EXISTS $tableMessages');
      await db.execute('DROP TABLE IF EXISTS $tableConversations');
      _onCreate(db, newVersion);
    }
  }
}

