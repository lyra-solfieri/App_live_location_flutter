import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;

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

  Adress();

  Adress.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    rua = map[columnrua];
    pais = map[columnPais];
    cartaoPostal = map[columnCartaoPostal];
    cidade = map[columnCidade];
  }
}

class AdressProvider {
  Database? db;

  Future initDb(String path) async {
    db = await openDatabase(
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
    adress.id = await db!.insert(adressTable, adress.toMap());
    return adress;
  }
}
