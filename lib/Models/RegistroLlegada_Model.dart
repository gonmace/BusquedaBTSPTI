// To parse this JSON data, do
//
//     final registrollegada = registrollegadaFromJson(jsonString);

import 'dart:convert';

Registrollegada registrollegadaFromJson(String str) =>
    Registrollegada.fromJson(json.decode(str));

String registrollegadaToJson(Registrollegada data) =>
    json.encode(data.toJson());

class Registrollegada {
  Candidato candidato;
  String fechaLlegada;
  double latLlegada;
  double lonLlegada;
  dynamic imagenLlegada;
  dynamic observaciones;
  bool status;

  Registrollegada({
    required this.candidato,
    required this.fechaLlegada,
    required this.latLlegada,
    required this.lonLlegada,
    required this.imagenLlegada,
    required this.observaciones,
    required this.status,
  });

  factory Registrollegada.fromJson(Map<String, dynamic> json) =>
      Registrollegada(
        candidato: Candidato.fromJson(json["candidato"]),
        fechaLlegada: json["fecha_llegada"],
        status: json["status"],
        latLlegada: json["lat_llegada"]?.toDouble(),
        lonLlegada: json["lon_llegada"]?.toDouble(),
        imagenLlegada: json["imagen_llegada"],
        observaciones: json["observaciones"],
      );

  Map<String, dynamic> toJson() => {
        "candidato": candidato.toJson(),
        "fecha_llegada": fechaLlegada,
        "lat_llegada": latLlegada,
        "status": status,
        "lon_llegada": lonLlegada,
        "imagen_llegada": imagenLlegada,
        "observaciones": observaciones,
      };
}

class Candidato {
  String sitio;
  String usuario;
  int candidato;

  Candidato({
    required this.sitio,
    required this.usuario,
    required this.candidato,
  });

  factory Candidato.fromJson(Map<String, dynamic> json) => Candidato(
        sitio: json["sitio"],
        usuario: json["usuario"],
        candidato: json["candidato"],
      );

  Map<String, dynamic> toJson() => {
        "sitio": sitio,
        "usuario": usuario,
        "candidato": candidato,
      };
}
