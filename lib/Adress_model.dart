import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final String adressTable = 'adress';
final String columnId = '_id';
final String columnrua = 'rua';
final String columnPais = 'pais';
final String columnCartaoPostal = 'cartão';
final String columnCidade = 'cidade';

class Adress {
  int? id;
  String? rua;
  String? pais;
  String? cartaoPostal;
  String? cidade;

  Adress({
    this.id,
    this.rua,
    this.pais,
    this.cartaoPostal,
    this.cidade,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnrua: rua,
      columnPais: pais,
      columnCartaoPostal: cartaoPostal,
      columnCidade: cidade,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Adress.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    rua = map[columnrua];
    pais = map[columnPais];
    cartaoPostal = map[columnCartaoPostal];
    cidade = map[columnCidade];
  }
}

class AdressProvider {
  AdressProvider._privateConstructor();
  static final AdressProvider instance = AdressProvider._privateConstructor();
  Database? db;
  Future<Database> get database async => db ??= await initDb();

  Future initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'adress.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
        create table $adressTable(
          $columnId integer primary key autoincrement,
          $columnrua text not null,
          $columnPais text not null,
          $columnCartaoPostal text not null,
          $columnCidade text not null)''');
      },
    );
  }

  Future<Adress> insert(Adress adress) async {
    adress.id = await db?.insert(adressTable, adress.toMap());
    return adress;
  }

  Future<List<Adress>> getAdress() async {
    Database db = await instance.database;
    var adress = await db.query('adress', orderBy: '$columnId');
    List<Adress> adressList =
        adress.isNotEmpty ? adress.map((e) => Adress.fromMap(e)).toList() : [];
    return adressList;
  }

  /* List<Map<String, dynamic>> maps = await db!.query(adressTable,
        columns: [
          columnId,
          columnrua,
          columnPais,
          columnCartaoPostal,
          columnCidade,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Adress.fromMap(maps.first);
    }
    return false;*/

  Future<int> delete(int id) async {
    return await db!.delete(
      adressTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> update(Adress adress) async {
    return await db!.update(adressTable, adress.toMap(),
        where: '$columnId = ?', whereArgs: [adress.id]);
  }

  Future close() async => db!.close();
}
