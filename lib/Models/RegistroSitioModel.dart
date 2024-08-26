class RegistroSitios {
  double sitioLat;
  double sitioLon;
  String sitio;
  String sitioDescripcion;
  int usuario;
  String sitio_fecha;
  String sitio_propuesta_negociacion;
  String sitio_espacio_negociado;

  RegistroSitios({
    required this.sitioLat,
    required this.sitio_propuesta_negociacion,
    required this.sitio_espacio_negociado,
    required this.sitio_fecha,
    required this.sitioLon,
    required this.usuario,
    required this.sitio,
    required this.sitioDescripcion,
  });
  factory RegistroSitios.fromJson(Map<String, dynamic> json) {
    return RegistroSitios(
      sitioLat: json['sitio_lat'],
      sitio_propuesta_negociacion: json['sitio_propuesta_negociacion'],
      sitio_espacio_negociado: json['sitio_espacio_negociado'],
      usuario: json['usuario'],
      sitio_fecha: json['sitio_fecha'],
      sitioLon: json['sitio_lon'],
      sitio: json['sitio'],
      sitioDescripcion: json['sitio_descripcion'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'sitio_lat': sitioLat,
      'sitio_fecha': sitio_fecha,
      'usuario': usuario,
      'sitio_propuesta_negociacion': sitio_propuesta_negociacion,
      'sitio_espacio_negociado': sitio_espacio_negociado,
      'sitio_lon': sitioLon,
      'sitio': sitio,
      'sitio_descripcion': sitioDescripcion,
    };
  }
}
