// ignore_for_file: depend_on_referenced_packages, file_names, empty_catches, duplicate_ignore

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:busquedabtspti/Models/MainDataModel.dart';
import 'package:busquedabtspti/Models/RegistroCandidato.dart';
import 'package:busquedabtspti/Models/RegistroElectrico_model.dart';
import 'package:busquedabtspti/Models/RegistroLlegada_Model.dart';
import 'package:busquedabtspti/Models/RegistroLocalidad.dart';
import 'package:busquedabtspti/Models/RegistroPropiedad_Model.dart';
import 'package:busquedabtspti/Models/RegistroSitioImagenesModel.dart';
import 'package:busquedabtspti/Models/RegistroSitioModel.dart';
import 'package:busquedabtspti/Models/Sitio_Models.dart';
import 'package:busquedabtspti/Models/UserModel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String backendurl = 'https://sar.btspti.com/api';

//________________________________________________________________INICIO DE SESION Y CARGADO DE DATOS INICIALES________________________________________________________________________________________________________

Future<UserModel?> login(String username, String password) async {
  // URL de la solicitud
  String url = '$backendurl/login/';

  // Datos del cuerpo de la solicitud en formato JSON
  Map<String, String> body = {
    'username': username,
    'password': password,
  };

  // Encabezados de la solicitud
  Map<String, String> headers = {
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json',
  };

  try {
    // Realizar la solicitud POST
    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    // Verificar el código de estado de la respuesta
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      log(data['data'].toString());
      /* // Parsear la respuesta JSON y devolver los datos
      return jsonDecode(response.body); */
      return UserModel(
          empresaId: data['data']['empresa_id'],
          password: password,
          token: data['data']['token'],
          user: username,
          userId: data['data']['user_id']);
    } else {
      // Si la solicitud falló, imprimir el código de estado de la respuesta
      print('Código de estado de respuesta: ${response.statusCode}');
      print('Código de estado de respuesta: ${response.body}');
      return null;
    }
  } catch (e) {
    // Si se produce un error durante la solicitud, imprimir el error
    print('Error en la solicitud: $e');
    return null;
  }
}

Future<void> saveUserData(UserModel userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String data = jsonEncode(userData.toJson());
  await prefs.setString('user_id', data);
}

UserModel? dataUser;
Future<UserModel?> loadData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString('user_id');
  if (data != null) {
    var tempdata = jsonDecode(data);
    return UserModel.fromJson(tempdata);
  } else {
    return null;
  }
}

Future<void> clearUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('user_id');
  await prefs.remove('pais_empresa_id');
}

Future<List<Sitio>?> fetchSitios(int empresa, String token) async {
  String url = '$backendurl/sitios/$empresa';
  try {
    // Define los headers que deseas incluir en la solicitud
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Authorization': 'token $token', // Ejemplo de token
    };

    // Realiza la solicitud HTTP con los headers definidos
    http.Response response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Sitio> sitios = data.map((sitio) => Sitio.fromJson(sitio)).toList();
      return sitios;
    } else {
      // Manejar otros códigos de estado si es necesario
    }
  } catch (e) {
    // Manejar errores de solicitud
    print('Error: $e');
  }
}

Future<void> saveSitiosInPrefs(List<Sitio> sitios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> sitiosJson =
      sitios.map((sitio) => jsonEncode(sitio.toJson())).toList();
  prefs.setStringList('sitios', sitiosJson);
}

Future<void> deletesitios() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.remove('sitios');
}

Future<List<Sitio>> loadSitiosFromPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? sitiosJson = prefs.getStringList('sitios');
  if (sitiosJson != null) {
    List<Sitio> sitios =
        sitiosJson.map((json) => Sitio.fromJson(jsonDecode(json))).toList();
    return sitios;
  } else {
    return [];
  }
}

Future<bool> verificarConexionInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.mobile);
}

Future<void> guardarDatoLocalmente(String nombre, String dato) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(nombre, dato);
}

Future<dynamic> obtenerDatoLocalmente(String nombre) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  dynamic dato = prefs.get(nombre);
  return dato;
}

Future<void> eliminarDatoLocalmente(String nombre) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(nombre);
}

Future<void> guardarListaLocalmente(List<RegistroSitioImagenes> lista) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jsonLista = jsonEncode(convertirListaAJson(lista));
  log(jsonLista);
  await prefs.setString('registroSitioLista', jsonLista);
}

Future<List<RegistroSitioImagenes>> obtenerListaLocalmente() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jsonLista = prefs.getString('registroSitioLista');
  if (jsonLista != null) {
    List<dynamic> jsonMapList = jsonDecode(jsonLista);
    return jsonMapList
        .map((jsonMap) => RegistroSitioImagenes.fromJson(jsonMap))
        .toList();
  }
  return [];
}

List<Map<String, dynamic>> convertirListaAJson(
    List<RegistroSitioImagenes> lista) {
  return lista.map((registro) => registro.toJson()).toList();
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO LLEGADA API_________________________________________________________________________________
Future<MainData?> enviarDatos(Registrollegada registro) async {
  String url = '$backendurl/registrollegada/';
  var request = http.MultipartRequest('POST', Uri.parse(url));

  request.fields['candidato.sitio'] = registro.candidato.sitio.toString();
  request.fields['usuario'] = registro.candidato.usuario;
  request.fields['observaciones'] = registro.observaciones;
  request.fields['fecha_llegada'] = registro.fechaLlegada;
  request.fields['lat_llegada'] = "${registro.latLlegada}";
  request.fields['status_llegada'] = registro.status.toString();
  request.fields['lon_llegada'] = "${registro.lonLlegada}";

  // Ruta de la imagen
  String imagePath = registro.imagenLlegada!;
  File imageFile = File(imagePath);

  // Agregar imagen al cuerpo de la solicitud
  var stream = http.ByteStream(imageFile.openRead());
  var length = await imageFile.length();
  var multipartFile = http.MultipartFile('imagen_llegada', stream, length,
      filename: imagePath.split('/').last);

  request.files.add(multipartFile);

  // Encabezados de la solicitud
  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'Accept': '*/*',
    'Authorization': 'token ${dataUser!.token}'
  });
  try {
    // Enviar solicitud y manejar la respuesta
    http.Response response =
        await http.Response.fromStream(await request.send());

    // Verificar el código de estado de la respuesta
    log(response.body);
    log(response.statusCode.toString());
    if (response.statusCode == 201) {
      Map<String, dynamic> responseData = json.decode(response.body);

      // Utilizar el ID como necesites
      print('ID del candidato: $responseData');
      return MainData(success: true, data: Data.fromJson(responseData));
    } else if (response.statusCode == 500 || response.statusCode == 400) {
      return MainData(
          success: false,
          message: "Lo lamento ya existe un registro con ese candidato");
    } else if (response.statusCode == 401) {
      return MainData(
          success: false,
          message: "Error de servidor, intenta reiniciar sesión");
    }
  } catch (e) {
    log("AAAAA: $e");
    return MainData(
        success: false, message: "Lo lamento, hay un error en el servidor");
  }
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO LOCALIDAD API_________________________________________________________________________________
Future<void> enviarDatosLocalidad(Localidad localidad) async {
  String url = '$backendurl/registrolocalidad/';

  // Define los headers que deseas incluir en la solicitud
  Map<String, String> headers = {
    'Accept-Type': '*/*',
    'Content-Type': 'application/json',
    'Authorization': 'token ${dataUser!.token}', // Ejemplo de token
  };
  log(jsonEncode(localidad.toJson()));
  try {
    // Realizar la solicitud POST
    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(localidad.toJson()),
    );

    // Verificar el código de estado de la respuesta
    if (response.statusCode == 201) {
      log(response.body);
      // Si la solicitud fue exitosa, imprimir la respuesta
    } else {
      // Si la solicitud falló, imprimir el código de estado de la respuesta
    }
  } catch (e) {
    // Si se produce un error durante la solicitud, imprimir el error
  }
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO CANDIDATO API_________________________________________________________________________________
Future<void> enviarDatosCANDIDATO(Registrocandidato candidato) async {
  String url = '$backendurl/registropropietario/';

  // Define los headers que deseas incluir en la solicitud
  Map<String, String> headers = {
    'Accept-Type': '*/*',
    'Content-Type': 'application/json',
    'Authorization': 'token ${dataUser!.token}',
  };
  try {
    // Realizar la solicitud POST
    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(candidato.toJson()),
    );
    log(response.body.toString());
    // Verificar el código de estado de la respuesta
    if (response.statusCode == 201) {
      // Si la solicitud fue exitosa, imprimir la respuesta
    } else {
      // Si la solicitud falló, imprimir el código de estado de la respuesta
    }
  } catch (e) {
    log(e.toString());
    // Si se produce un error durante la solicitud, imprimir el error
  }
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO PROPIEDAD API_________________________________________________________________________________

Future<void> enviarDatosPropiedad(RegistroPropiedad propiedad) async {
  String url = '$backendurl/registropropiedad/';

  // Datos del cuerpo de la solicitud
  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.fields['propiedad_rol'] = propiedad.propiedadRol;
  request.fields['propiedad_escritura'] = propiedad.propiedadEscritura;
  request.fields['propiedad_registro_civil'] = propiedad.propiedadRegistroCivil;
  request.fields['sitio'] = propiedad.sitio;
  request.fields['usuario'] = dataUser!.userId.toString();
  request.fields['propiedad_descripcion'] = propiedad.propiedadDescripcion;
  request.fields['propiedad_direccion'] = propiedad.propiedaddireccion;

  // Ruta de la imagen
  String imagePath = propiedad.propiedadImagen;
  File imageFile = File(imagePath);

  // Agregar imagen al cuerpo de la solicitud
  var stream = http.ByteStream(imageFile.openRead());
  var length = await imageFile.length();
  var multipartFile = http.MultipartFile('propiedad_imagen', stream, length,
      filename: imagePath.split('/').last);

  request.files.add(multipartFile);

  // Encabezados de la solicitud
  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'Accept': '*/*',
    'Authorization': 'token ${dataUser!.token}'
  });

  try {
    // Enviar solicitud y manejar la respuesta
    http.Response response =
        await http.Response.fromStream(await request.send());
    log(response.body);
    // Verificar el código de estado de la respuesta
    if (response.statusCode == 201) {
      // Si la solicitud fue exitosa, imprimir la respuesta
    } else {
      // Si la solicitud falló, imprimir el código de estado de la respuesta
    }
  } catch (e) {
    // Si se produce un error durante la solicitud, imprimir el error
  }
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO PROPIEDAD API_________________________________________________________________________________

Future<void> enviarDatosRegistroSitio(
    List<RegistroSitioImagenes> registros, RegistroSitios regsitio) async {
  String urlSitio = '$backendurl/registrositio/';
  String urlSitioImagenes = '$backendurl/registrositioimagen/';
// Define los headers que deseas incluir en la solicitud
  Map<String, String> headers = {
    'Accept-Type': '*/*',
    'Content-Type': 'application/json',
    'Authorization': 'token ${dataUser!.token}', // Ejemplo de token
  };

  try {
    // Realizar la solicitud POST
    http.Response responseSitio = await http.post(
      Uri.parse(urlSitio),
      headers: headers,
      body: jsonEncode(regsitio.toJson()),
    );
    if (responseSitio.statusCode == 201) {
      print("Datos sitio exitosos;");
    } else {}
    log(responseSitio.body);

    for (var registro in registros) {
      var request = http.MultipartRequest('POST', Uri.parse(urlSitioImagenes));
      request.fields['sitio'] = registro.sitio;
      request.fields['descripcion'] = registro.sitioDescripcion;
      request.fields['usuario'] = dataUser!.userId.toString();
// Ruta de la imagen
      String imagePath = registro.sitioImagenes;
      File imageFile = File(imagePath);

      // Agregar imagen al cuerpo de la solicitud
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('pic', stream, length,
          filename: imagePath.split('/').last);

      request.files.add(multipartFile);
      /* // Convertir la imagen a una cadena base64
      String imagePath = registro.sitioImagenes;
      File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Adjuntar la imagen como una cadena base64 a la solicitud
      request.fields['sitio_imagen'] = base64Image; */

      // Encabezados de la solicitud
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': '*/*',
        'Authorization': 'token ${dataUser!.token}'
      });

      var response = await http.Response.fromStream(await request.send());
      log("Response envio imagenes: ${response.body}");
      if (response.statusCode == 201) {
      } else {}
    }
    // ignore: empty_catches
  } catch (e) {
    log("REGISTRO SITIO IMAGENES ERROR: $e");
  }
}

//_________________________________________________________________________ENVIAR DATA A REGISTRO ELECTRICO API_________________________________________________________________________________

Future<void> enviarDatosRegistroElectrico(RegistroElectrico registro) async {
  String url = '$backendurl/registroelectrico/';

  // Crear una solicitud multipart
  var request = http.MultipartRequest('POST', Uri.parse(url));

  request.fields['sitio'] = registro.sitio;
  request.fields['electrico_lat'] = registro.electricoLat.toString();
  request.fields['electrico_lon'] = registro.electricoLon.toString();
  request.fields['electrico_no_poste'] = registro.electricoNoPoste;
  request.fields['electrico_comentario'] = registro.electricoComentario;
  request.fields['usuario'] = dataUser!.userId.toString();
  // Agregar la imagen codificada en base64 al cuerpo de la solicitud

  String imagePath = registro.electricoImagen;
  File imageFile = File(imagePath);

  // Agregar imagen al cuerpo de la solicitud
  var stream = http.ByteStream(imageFile.openRead());
  var length = await imageFile.length();
  var multipartFile = http.MultipartFile('electrico_imagen1', stream, length,
      filename: imagePath.split('/').last);

  request.files.add(multipartFile);

  // Agregar la imagen 2 solo si está presente
  if (registro.electricoImagen2 != null) {
    String imagePath2 = registro.electricoImagen2!;
    File imageFile2 = File(imagePath2);
    var stream2 = http.ByteStream(imageFile2.openRead());
    var length2 = await imageFile2.length();
    var multipartFile2 = http.MultipartFile(
        'electrico_imagen2', stream2, length2,
        filename: imagePath2.split('/').last);
    request.files.add(multipartFile2);
  }

  // Encabezados de la solicitud
  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'Accept': '*/*',
    'Authorization': 'token ${dataUser!.token}'
  });
  // Enviar la solicitud y manejar la respuesta
  await Future.delayed(Duration(seconds: 2));
  try {
    var response = await http.Response.fromStream(await request.send());
    log(response.body);
    if (response.statusCode == 201) {
      log(response.body);
    } else {}
  } catch (e) {}
}

Future<String?> enviarDatosFirebase() async {
  // URL de tu función en Firebase
  const url = 'https://us-central1-borhood-6bb25.cloudfunctions.net/postData';

  // Datos que deseas enviar
  final Map<String, dynamic> data = {
    'campo1': 'valor1',
    'campo2': 'valor2',
    // Agrega más campos según sea necesario
  };

  try {
    // Realizar la solicitud POST
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    // Verificar si la solicitud fue exitosa
    if (response.statusCode == 200) {
      // Convertir la respuesta JSON a un mapa
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Obtener el mensaje de la respuesta
      final String message = responseData['message'];

      // Devolver el mensaje
      return message;
    } else {
      // Si la solicitud no fue exitosa, imprimir el código de estado
      print('Error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    // Manejar errores
    print('Error al enviar datos a Firebase: $e');
    return null;
  }
}
