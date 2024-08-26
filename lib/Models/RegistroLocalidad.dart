// To parse this JSON data, do
//
//     final localidad = localidadFromJson(jsonString);

import 'dart:convert';

Localidad localidadFromJson(String str) => Localidad.fromJson(json.decode(str));

String localidadToJson(Localidad data) => json.encode(data.toJson());

class Localidad {
  String provincia;
  String municipio;
  String localidad;
  bool energiaLocalidad;
  String sitio;
  int usuario;

  Localidad({
    required this.provincia,
    required this.municipio,
    required this.localidad,
    required this.energiaLocalidad,
    required this.sitio,
    required this.usuario,
  });

  factory Localidad.fromJson(Map<String, dynamic> json) => Localidad(
        provincia: json["provincia"],
        municipio: json["municipio"],
        localidad: json["localidad"],
        energiaLocalidad: json["energia"],
        sitio: json["sitio"],
        usuario: json["usuario"],
      );

  Map<String, dynamic> toJson() => {
        "provincia": provincia,
        "municipio": municipio,
        "localidad": localidad,
        "energia": energiaLocalidad,
        "sitio": sitio,
        "usuario": usuario,
      };
}
