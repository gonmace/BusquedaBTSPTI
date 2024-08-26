// To parse this JSON data, do
//
//     final sitio = sitioFromJson(jsonString);

import 'dart:convert';

Sitio sitioFromJson(String str) => Sitio.fromJson(json.decode(str));

String sitioToJson(Sitio data) => json.encode(data.toJson());

class Sitio {
  dynamic ptiCellId;
  dynamic nombre;
  dynamic latNominal;
  dynamic lonNominal;
  dynamic altura;
  dynamic provincia;
  dynamic municipio;
  dynamic localidad;

  Sitio({
    required this.ptiCellId,
    required this.nombre,
    required this.latNominal,
    required this.lonNominal,
    required this.altura,
    required this.provincia,
    required this.municipio,
    required this.localidad,
  });

  factory Sitio.fromJson(Map<String, dynamic> json) => Sitio(
        ptiCellId: json["PTICellID"],
        nombre: json["nombre"],
        latNominal: json["lat_nominal"],
        lonNominal: json["lon_nominal"],
        altura: json["altura"],
        provincia: json["provincia"],
        municipio: json["municipio"],
        localidad: json["localidad"],
      );

  Map<String, dynamic> toJson() => {
        "PTICellID": ptiCellId,
        "nombre": nombre,
        "lat_nominal": latNominal,
        "lon_nominal": lonNominal,
        "altura": altura,
        "provincia": provincia,
        "municipio": municipio,
        "localidad": localidad,
      };
}
