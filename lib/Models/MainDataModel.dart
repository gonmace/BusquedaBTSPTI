// To parse this JSON data, do
//
//     final mainData = mainDataFromJson(jsonString);

import 'dart:convert';

MainData mainDataFromJson(String str) => MainData.fromJson(json.decode(str));

String mainDataToJson(MainData data) => json.encode(data.toJson());

class MainData {
  bool success;
  Data? data;
  String? message;
  MainData({required this.success, this.data, this.message});

  factory MainData.fromJson(Map<String, dynamic> json) => MainData(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data != null ? data!.toJson() : {},
      };
}

class Data {
  Candidatos candidato;
  DateTime fechaLlegada;
  double latLlegada;
  double lonLlegada;
  String statusLlegada;
  String imagenLlegada;
  dynamic observaciones;

  Data({
    required this.candidato,
    required this.fechaLlegada,
    required this.latLlegada,
    required this.lonLlegada,
    required this.statusLlegada,
    required this.imagenLlegada,
    required this.observaciones,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        candidato: Candidatos.fromJson(json["candidato"]),
        fechaLlegada: DateTime.parse(json["fecha_llegada"]),
        latLlegada: json["lat_llegada"]?.toDouble(),
        lonLlegada: json["lon_llegada"]?.toDouble(),
        statusLlegada: json["status_llegada"],
        imagenLlegada: json["imagen_llegada"],
        observaciones: json["observaciones"],
      );

  Map<String, dynamic> toJson() => {
        "candidato": candidato.toJson(),
        "fecha_llegada": fechaLlegada.toIso8601String(),
        "lat_llegada": latLlegada,
        "lon_llegada": lonLlegada,
        "status_llegada": statusLlegada,
        "imagen_llegada": imagenLlegada,
        "observaciones": observaciones,
      };
}

class Candidatos {
  String sitio;
  String fecha_creacion;
  String candidato;

  Candidatos({
    required this.fecha_creacion,
    required this.sitio,
    required this.candidato,
  });

  factory Candidatos.fromJson(Map<String, dynamic> json) => Candidatos(
        sitio: json["sitio"],
        fecha_creacion: json["fecha_creacion"],
        candidato: json["candidato"],
      );

  Map<String, dynamic> toJson() => {
        "sitio": sitio,
        "fecha_creacion": fecha_creacion,
        "candidato": candidato,
      };
}
