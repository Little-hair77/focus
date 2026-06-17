import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Gerencia a criação, migração e acesso ao banco SQLite local.
class DatabaseHelper {
  /// Instância única usada pelos repositórios SQLite.
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Banco em cache para evitar múltiplas aberturas.
  static Database? _database;

  DatabaseHelper._init();

  /// Retorna o banco aberto ou cria a instância quando necessário.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('focus.db');
    return _database!;
  }

  /// Inicializa o arquivo físico do banco.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Abre o banco e define a versão (conforme seu planejamento do Sprint 1)
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Cria as tabelas iniciais do banco.
  Future _createDB(Database db, int version) async {
    // Tabela de Categorias
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        icon TEXT,
        created_at TEXT NOT NULL,
        deleted_at TEXT
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
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');
  }

  /// Aplica migrações incrementais entre versões do banco.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN deleted_at TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN deleted_at TEXT');
    }
  }

  /// Fecha o banco local com segurança.
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
