class RegistroSitioImagenes {
  String sitio;
  String sitioDescripcion;
  String sitioImagenes;
  String usuario;

  RegistroSitioImagenes({
    required this.sitio,
    required this.sitioDescripcion,
    required this.usuario,
    required this.sitioImagenes,
  });
  factory RegistroSitioImagenes.fromJson(Map<String, dynamic> json) {
    return RegistroSitioImagenes(
      sitio: json['sitio'],
      usuario: json['usuario'],
      sitioDescripcion: json['sitio_descripcion'],
      // Recuperar el archivo de la ruta almacenada en JSON
      sitioImagenes: json['sitio_imagen'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'sitio': sitio,
      'usuario': usuario,
      'sitio_descripcion': sitioDescripcion,
      'sitio_imagen': sitioImagenes,
    };
  }
}
