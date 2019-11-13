
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DBCreator{
  static const table='userTable';
  static const id = 'id';
  static const userName='userName';
  static const lat = 'lat';
  static const long = 'long';
  static const img = 'img';

  Future <void> createUserTable (Database db) async {
    final sql = 'CREATE TABLE $table ($id INTEGER PRIMARY KEY,$userName TEXT,$lat REAL,$long REAL,$img TEXT)';
    await db.execute(sql);
  }

  Future <String> getDBPath (String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,dbName);

    if (await Directory(dirname(path)).exists()){

    }else{
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future <void> initDB() async {
    final path = await getDBPath('users');
    db = await openDatabase(path,version: 1,onCreate: onCreate);
    print(db);
  }
  Future <void> onCreate(Database db,int version,) async {
    await createUserTable(db);


  }
}