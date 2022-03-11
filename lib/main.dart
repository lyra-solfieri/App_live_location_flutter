import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as Geocoding;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_location/adressView.dart';
import 'adress_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'User Location ',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Home());
  }
}

//// Classe principal

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Permições do dispositivo
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  //Localização do usuário
  LocationData? _userLocation;

  double? lat;
  double? lng;
  String? street;
  String? country;
  String? postalCode;
  String? subAdmArea;

  Future<void> _getUserLocation() async {
    Location location = Location();

    //1. verificar se o serviço de localização está ativado
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    //2. solicitar a permissão para o app acessar a localização
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();

    Future<List<Geocoding.Placemark>> places;

    setState(() {
      _userLocation = _locationData;
      lat = _userLocation!.latitude;
      lng = _userLocation!.longitude;
      places = Geocoding.placemarkFromCoordinates(lat!, lng!,
          localeIdentifier: "pt_BR");
      places.then((value) {
        Geocoding.Placemark place = value[0];
        street = place.street.toString();
        country = place.country.toString();
        postalCode = place.postalCode.toString();
        subAdmArea = place.subAdministrativeArea.toString();

        print(_locationData.accuracy);
      });
    });
  }

  // Função para abrir o google maps
  void googleMap() async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw ('Não conseguiu abrir o google maps ');
    }
  }

  saveAdress() {
    var adress = Adress(
      rua: street,
      pais: country,
      cidade: subAdmArea,
      cartaoPostal: postalCode,
    );
    AdressProvider.instance.initDb();
    AdressProvider.instance.insert(adress);
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    return Scaffold(
        appBar: AppBar(
          title: Text('User Location '),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_pin,
              color: Colors.green,
              size: 35,
            ),
            SizedBox(height: 30),
            Text(
              'Pegar localização do usuário',
              style: TextStyle(
                fontSize: 15,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 30),
            Text(
              _userLocation.toString(),
              style: TextStyle(
                color: Colors.green,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: style,
              child: Text('pegar localização'),
              onPressed: () {
                _getUserLocation();
                print(_userLocation);
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: style,
              child: Text('Abrir google maps'),
              onPressed: () {
                googleMap();
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                saveAdress();
              },
              child: Text('Salvar endereço'),
              style: style,
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      new MaterialPageRoute(builder: (context) => AdresView()));
                },
                child: Text(
                  'Acessar lista de endereços',
                )),
          ],
        )));
  }
}
