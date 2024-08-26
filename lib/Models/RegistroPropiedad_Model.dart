// ignore_for_file: file_names

class RegistroPropiedad {
  String propiedadRol;
  String propiedadEscritura;
  String propiedadRegistroCivil;
  String sitio;
  String propiedadDescripcion;
  String propiedadImagen;
  String propiedaddireccion;

  RegistroPropiedad({
    required this.propiedadRol,
    required this.propiedadEscritura,
    required this.propiedadRegistroCivil,
    required this.sitio,
    required this.propiedaddireccion,
    required this.propiedadDescripcion,
    required this.propiedadImagen,
  });

  factory RegistroPropiedad.fromJson(Map<String, dynamic> json) {
    return RegistroPropiedad(
      propiedaddireccion: json['propiedad_direccion'],
      propiedadRol: json['propiedad_rol'],
      propiedadEscritura: json['propiedad_escritura'],
      propiedadRegistroCivil: json['propiedad_registro_civil'],
      sitio: json['sitio'],
      propiedadDescripcion: json['propiedad_descripcion'],
      // propiedadImagen: json['propiedad_imagen'], // No incluir la imagen en la respuesta JSON
      propiedadImagen:
          json['propiedad_imagen'], // Reemplazar con la ruta de la imagen
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propiedad_direccion': propiedaddireccion,
      'propiedad_rol': propiedadRol,
      'propiedad_escritura': propiedadEscritura,
      'propiedad_registro_civil': propiedadRegistroCivil,
      'sitio': sitio,
      'propiedad_descripcion': propiedadDescripcion,
      'propiedad_imagen':
          propiedadImagen, // No incluir la imagen en la solicitud JSON
    };
  }
}
