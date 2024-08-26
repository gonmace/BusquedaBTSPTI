// To parse this JSON data, do
//
//     final registrocandidato = registrocandidatoFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

String registrocandidatoToJson(Registrocandidato data) =>
    json.encode(data.toJson());
Registrocandidato registrocandidatoFromJson(String str) =>
    Registrocandidato.fromJson(json.decode(str));

class Registrocandidato {
  String propietarioNombreApellido;
  String propietarioBorn;
  String propietarioCi;
  String propietarioTelf;
  String propietarioDireccion;
  bool propietarioEstadoCivil;
  String propietario_email;
  String sitio;
  int usuario;
  String direccion;
  String? contacto_nombre;
  String? contacto_tel;
  String? contacto_email;
  String? contacto_relacion;
  String? propietario_tipo_persona;
  Registrocandidato({
    required this.propietarioNombreApellido,
    required this.propietario_email,
    required this.propietarioBorn,
    required this.propietarioCi,
    required this.propietarioTelf,
    required this.propietarioDireccion,
    required this.propietarioEstadoCivil,
    required this.usuario,
    required this.sitio,
    required this.direccion,
    required this.propietario_tipo_persona,
    this.contacto_nombre,
    this.contacto_tel,
    this.contacto_email,
    this.contacto_relacion,
  });
  factory Registrocandidato.fromJson(Map<String, dynamic> json) =>
      Registrocandidato(
        propietarioNombreApellido: json["propietario_nombre_apellido"],
        propietario_email: json["propietario_email"],
        propietario_tipo_persona: json["propietario_tipo_persona"],
        propietarioBorn: json["propietario_born"],
        propietarioCi: json["propietario_ci"],
        propietarioTelf: json["propietario_telf"],
        usuario: json["usuario"],
        contacto_nombre: json['contacto_nombre'],
        contacto_tel: json['contacto_tel'],
        contacto_email: json['contacto_email'],
        contacto_relacion: json['contacto_relacion'],
        propietarioDireccion: json["propietario_direccion"],
        propietarioEstadoCivil: json["propietario_estado_civil"],
        sitio: json["sitio"],
        direccion: json["propietario_direccion"],
      );
  Map<String, dynamic> toJson() => {
        "propietario_nombre_apellido": propietarioNombreApellido,
        "propietario_born": propietarioBorn,
        "propietario_email": propietario_email,
        "propietario_ci": propietarioCi,
        "propietario_telf": propietarioTelf,
        "contacto_nombre": contacto_nombre,
        "contacto_tel": contacto_tel,
        "contacto_email": contacto_email,
        "contacto_relacion": contacto_relacion,
        "propietario_tipo_persona": propietario_tipo_persona,
        "propietario_direccion": propietarioDireccion,
        "propietario_estado_civil": propietarioEstadoCivil,
        "sitio": sitio,
        "usuario": usuario,
        // ignore: equal_keys_in_map
        "propietario_direccion": direccion,
      };
}
