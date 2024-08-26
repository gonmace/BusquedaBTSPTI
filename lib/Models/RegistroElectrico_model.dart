// ignore_for_file: file_names

import 'dart:convert';

RegistroElectrico registroElectricoFromJson(String str) =>
    RegistroElectrico.fromJson(json.decode(str));

class RegistroElectrico {
  String sitio;
  double electricoLat;
  double electricoLon;
  String electricoNoPoste;
  String electricoComentario;
  String electricoImagen;
  String? electricoImagen2;

  RegistroElectrico({
    required this.sitio,
    required this.electricoLat,
    required this.electricoLon,
    required this.electricoNoPoste,
    required this.electricoComentario,
    required this.electricoImagen,
    this.electricoImagen2,
  });
  factory RegistroElectrico.fromJson(Map<String, dynamic> json) =>
      RegistroElectrico(
        sitio: json["sitio"],
        electricoImagen2: json["electrico_imagen2"],
        electricoLat: json["electrico_lat"].toDouble(),
        electricoLon: json["electrico_lon"].toDouble(),
        electricoNoPoste: json["electrico_no_poste"],
        electricoComentario: json["electrico_comentario"],
        electricoImagen: json["electrico_imagen"],
      );
  Map<String, dynamic> toJson() {
    return {
      'sitio': sitio,
      'electrico_lat': electricoLat,
      'electrico_lon': electricoLon,
      'electrico_imagen2': electricoImagen2,
      'electrico_no_poste': electricoNoPoste,
      'electrico_comentario': electricoComentario,
      'electrico_imagen': electricoImagen,
    };
  }
}
