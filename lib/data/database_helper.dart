import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter que verifica se o banco já existe ou se precisa ser criado
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('focus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Abre o banco e define a versão (conforme seu planejamento do Sprint 1)
    return await openDatabase(
      path,
      version: 1, 
      onCreate: _createDB,
    );
  }

  // Scripts de criação extraídos de acordo com a documentação
  Future _createDB(Database db, int version) async {
    // Tabela de Categorias 
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        icon TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de Tarefas com Relacionamentos 
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 0,
        category_id TEXT REFERENCES categories (id) ON DELETE SET NULL,
        photo_path TEXT,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Método para fechar o banco com segurança 
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}