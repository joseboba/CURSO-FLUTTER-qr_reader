import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:qr_reader/models/scan_model.dart';
export 'package:qr_reader/models/scan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    // Path de donde almacenaremos la base de datos
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'ScansDB.db');
    print('Hoola $path');

    //Crear base de datos
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(''' 
          CREATE TABLE Scans(
            id INTEGER PRIMARY KEY,
            tipo TEXT,
            valor TEXT 
          ) 
          ''');
    });
  }

  // Future<int> nuevoScanRaw(ScanModel nuevoScan) async{
  //
  //   final id = nuevoScan.id;
  //   final tipo = nuevoScan.tipo;
  //   final valor = nuevoScan.valor;
  //
  //   //Verificar la base de datos
  //   final db = await database;
  //
  //   final res = await db.rawInsert('''
  //     INSERT INTO Scans(id, tipo, valor)
  //       VALUES($id, '$tipo', '$valor')
  //   ''');
  //
  //   return res;
  // }

  Future<int> nuevoScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.insert('Scans', nuevoScan.toJson());
    return res;
  }

  Future<ScanModel> getScanById(int id) async {
    final db = await database;
    final resp = await db.query('Scans', where: 'id = ?', whereArgs: [id]);

    return resp.isNotEmpty ? ScanModel.fromJson(resp.first) : null;
  }

  Future<List<ScanModel>> getTodosLosScans() async {
    final db = await database;
    final resp = await db.query('Scans');
    List<dynamic> list =
        resp.isNotEmpty ? resp.map((s) => ScanModel.fromJson(s)).toList() : [];

    return List.castFrom<dynamic, ScanModel>(list);
  }

  Future<List<ScanModel>> getScanByTipo(String tipo) async {
    final db = await database;
    final resp =
        await db.rawQuery(''' SELECT *FROM Scans WHERE tipo = '$tipo' ''');
    List<dynamic> list =
        resp.isNotEmpty ? resp.map((s) => ScanModel.fromJson(s)).toList() : [];

    return List.castFrom<dynamic, ScanModel>(list);
  }

  Future<int> updateScan(ScanModel nuevoScan) async{
    final db = await database;
    final res = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?', whereArgs: [nuevoScan.id]);

    return res;
  }

  Future<int> deleteScan(int id) async{
    final db = await database;
    final res = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);

    return res;
  }

  Future<int> deleteAllScans() async{
    final db = await database;
    final res = await db.rawDelete(''' 
       DELETE FROM Scans
    ''');
    return res;
  }

}
