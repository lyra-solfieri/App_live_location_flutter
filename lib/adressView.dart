import 'package:flutter/material.dart';
import 'package:user_location/adress_model.dart';

class AdresView extends StatefulWidget {
  const AdresView({Key? key}) : super(key: key);

  @override
  _AdresViewState createState() => _AdresViewState();
}

class _AdresViewState extends State<AdresView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Endereços e dados da rota '),
        ),
        body: Container(
          child: FutureBuilder<List<Adress>>(
            future: AdressProvider.instance.getAdress(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Adress>> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                children: snapshot.data!.map((adress) {
                  return Center(
                    child: ListTile(
                      title: Text(adress.toMap().toString()),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ));
  }
}
