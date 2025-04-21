import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/local_data_source.dart';

class SqliteDataSource {
  static final SqliteDataSource _instance = SqliteDataSource._internal();
  factory SqliteDataSource() => _instance;
  SqliteDataSource._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chat_messages.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        text TEXT,
        isMe INTEGER,
        createdAt INTEGER,
        type TEXT,
        mediaUrl TEXT,
        fileName TEXT,
        fileSize INTEGER,
        replyToMessageId TEXT,
        senderName TEXT
      );
    ''');

    // جدول الريأكشنات
    await db.execute('''
      CREATE TABLE reactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        messageId TEXT,
        reaction TEXT,
        userId TEXT
      );
    ''');

    // إضافة رسائل تجريبية كما طلبت
    final now = DateTime.now();

    final demoMessages = [
      {
        'id': "sys1",
        'text': "تم تفعيل ميزة إرسال الصور والصوتيات!",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
        'type': 'system',
        'mediaUrl': null,
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "msg1",
        'text': "مرحباً بك في محادثة العينة 🎉",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 28)).millisecondsSinceEpoch,
        'type': 'text',
        'mediaUrl': null,
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "img1",
        'text': "",
        'isMe': 1,
        'createdAt':
            now.subtract(const Duration(minutes: 27)).millisecondsSinceEpoch,
        'type': 'image',
        'mediaUrl':
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "img2",
        'text': "",
        'isMe': 1,
        'createdAt':
            now.subtract(const Duration(minutes: 27)).millisecondsSinceEpoch,
        'type': 'image',
        'mediaUrl':
            "https://images.unsplash.com/photo-1519125323398-675f0ddb6308",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "img3",
        'text': "",
        'isMe': 1,
        'createdAt':
            now.subtract(const Duration(minutes: 27)).millisecondsSinceEpoch,
        'type': 'image',
        'mediaUrl':
            "https://images.unsplash.com/photo-1465101046530-73398c7f28ca",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "img4",
        'text': "",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 25)).millisecondsSinceEpoch,
        'type': 'image',
        'mediaUrl':
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "voice1",
        'text': "",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 24)).millisecondsSinceEpoch,
        'type': 'voice',
        'mediaUrl':
            "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "vid1",
        'text': "",
        'isMe': 1,
        'createdAt':
            now.subtract(const Duration(minutes: 23)).millisecondsSinceEpoch,
        'type': 'video',
        'mediaUrl':
            "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "file1",
        'text': "",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 22)).millisecondsSinceEpoch,
        'type': 'file',
        'mediaUrl': null,
        'fileName': "وثيقة.pdf",
        'fileSize': 204800,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "code1",
        'text': "```dart\nvoid main() {\n  print('Hello, World!');\n}\n```",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 21)).millisecondsSinceEpoch,
        'type': 'code',
        'mediaUrl': null,
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "longtext",
        'text':
            "هذه رسالة نصية طويلة للاختبار. الهدف منها التأكد من عرض الرسائل الطويلة بشكل صحيح دون مشاكل.",
        'isMe': 1,
        'createdAt':
            now.subtract(const Duration(minutes: 20)).millisecondsSinceEpoch,
        'type': 'text',
        'mediaUrl': null,
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': null,
        'senderName': null,
      },
      {
        'id': "reply1",
        'text': "👍 شكراً على الرسالة السابقة!",
        'isMe': 0,
        'createdAt':
            now.subtract(const Duration(minutes: 19)).millisecondsSinceEpoch,
        'type': 'text',
        'mediaUrl': null,
        'fileName': null,
        'fileSize': null,
        'replyToMessageId': "longtext",
        'senderName': null,
      },
    ];

    for (final msg in demoMessages) {
      await db.insert('messages', msg);
    }
  }

  // Insert or update a message
  Future<void> upsertMessage(ChatMessage msg) async {
    final db = await database;
    await db.insert(
      'messages',
      _msgToMap(msg),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert or update multiple messages
  Future<void> upsertMessages(List<ChatMessage> messages) async {
    final db = await database;
    final batch = db.batch();
    for (final msg in messages) {
      batch.insert(
        'messages',
        _msgToMap(msg),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // Get all messages (optionally by replyToMessageId, or custom order/filters)
  Future<List<ChatMessage>> getAllMessages({String? replyToMessageId}) async {
    final db = await database;
    String whereStr = '';
    List<dynamic> whereArgs = [];
    if (replyToMessageId != null) {
      whereStr = 'replyToMessageId = ?';
      whereArgs = [replyToMessageId];
    }
    final maps = await db.query(
      'messages',
      where: whereStr.isNotEmpty ? whereStr : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'createdAt ASC',
      limit: 1,
    );
    List<ChatMessage> msgs = [];
    for (final map in maps) {
      final msg = _msgFromMap(map);
      final reactions = await getReactions(msg.id);
      msgs.add(msg.copyWith(reactions: reactions));
    }
    return msgs;
  }

  // Paging: تحميل رسائل محدودة مع دعم beforeId
  Future<List<ChatMessage>> getMessages({
    required int limit,
    String? beforeId,
  }) async {
    final db = await database;

    String where = "";
    List<dynamic> whereArgs = [];
    int? beforeMillis;

    if (beforeId != null) {
      // جلب تاريخ الرسالة المرجعية
      final result = await db.query(
        'messages',
        where: 'id = ?',
        whereArgs: [beforeId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        beforeMillis = result.first['createdAt'] as int;
      }
      where = 'createdAt < ?';
      whereArgs = [beforeMillis];
    }

    final result = await db.query(
      'messages',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'createdAt ASC',
      limit: limit,
    );

    List<ChatMessage> msgs = [];
    for (final map in result) {
      final msg = _msgFromMap(map);
      final reactions = await getReactions(msg.id);
      msgs.add(msg.copyWith(reactions: reactions));
    }

    return msgs;
  }

  // جلب الريأكشنات لرسالة واحدة
  Future<Map<String, List<String>>> getReactions(String messageId) async {
    final db = await database;
    final rows = await db.query(
      'reactions',
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
    final Map<String, List<String>> result = {};
    for (var row in rows) {
      final reaction = row['reaction'] as String;
      final userId = row['userId'] as String;
      result.putIfAbsent(reaction, () => []).add(userId);
    }
    return result;
  }

  // Get message by id
  Future<ChatMessage?> getMessageById(String id) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _msgFromMap(maps.first);
  }

  // Delete message by id
  Future<void> deleteMessageById(String id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all messages
  Future<void> deleteAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  // Update a message
  Future<void> updateMessage(ChatMessage msg) async {
    final db = await database;
    await db.update(
      'messages',
      _msgToMap(msg),
      where: 'id = ?',
      whereArgs: [msg.id],
    );
  }

  // Count messages
  Future<int> countMessages() async {
    final db = await database;
    final x = await db.rawQuery('SELECT COUNT(*) FROM messages');
    return Sqflite.firstIntValue(x) ?? 0;
  }

  // Helpers
  Map<String, dynamic> _msgToMap(ChatMessage msg) => {
    'id': msg.id,
    'text': msg.text,
    'isMe': msg.isMe ? 1 : 0,
    'createdAt': msg.createdAt.millisecondsSinceEpoch,
    'type': msg.type.toString().split('.').last,
    'mediaUrl': msg.mediaUrl,
    'fileName': msg.fileName,
    'fileSize': msg.fileSize,
    'replyToMessageId': msg.replyToMessageId,
    'senderName': msg.sender,
  };

  ChatMessage _msgFromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'],
    text: map['text'],
    isMe: map['isMe'] == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    type: _parseType(map['type']),
    mediaUrl: map['mediaUrl'],
    fileName: map['fileName'],
    fileSize: map['fileSize'],
    replyToMessageId: map['replyToMessageId'],
    sender: map['senderName'],
  );

  // إضافة رد فعل
  Future<void> addReaction(
    String messageId,
    String reaction,
    String userId,
  ) async {
    final db = await database;
    await db.insert('reactions', {
      'messageId': messageId,
      'reaction': reaction,
      'userId': userId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // إزالة رد فعل
  Future<void> removeReaction(
    String messageId,
    String reaction,
    String userId,
  ) async {
    final db = await database;
    await db.delete(
      'reactions',
      where: 'messageId = ? AND reaction = ? AND userId = ?',
      whereArgs: [messageId, reaction, userId],
    );
  }

  MessageType _parseType(String? str) {
    switch (str) {
      case 'image':
        return MessageType.image;
      case 'voice':
        return MessageType.voice;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}
