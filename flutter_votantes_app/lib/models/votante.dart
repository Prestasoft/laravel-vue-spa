class Votante {
  final int? id;
  final String cedula;
  final int dirigenteId;
  final int? colegioId;
  final String? mesa;
  final String? telefono;
  final String? direccion;
  final String? observaciones;
  final DateTime? fechaRegistro;
  final bool activo;
  final PadronData? padronData;
  final String? colegioNombre;

  Votante({
    this.id,
    required this.cedula,
    required this.dirigenteId,
    this.colegioId,
    this.mesa,
    this.telefono,
    this.direccion,
    this.observaciones,
    this.fechaRegistro,
    this.activo = true,
    this.padronData,
    this.colegioNombre,
  });

  factory Votante.fromJson(Map<String, dynamic> json) {
    return Votante(
      id: json['id'],
      cedula: json['cedula'],
      dirigenteId: json['dirigente_id'],
      colegioId: json['colegio_id'],
      mesa: json['mesa'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      observaciones: json['observaciones'],
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null,
      activo: json['activo'] ?? true,
      padronData: json['padron_data'] != null
          ? PadronData.fromJson(json['padron_data'])
          : null,
      colegioNombre: json['colegio_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cedula': cedula,
      'dirigente_id': dirigenteId,
      'colegio_id': colegioId,
      'mesa': mesa,
      'telefono': telefono,
      'direccion': direccion,
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  String get nombreCompleto {
    if (padronData != null) {
      return '${padronData!.nombres} ${padronData!.apellido1} ${padronData!.apellido2}'.trim();
    }
    return 'Sin nombre';
  }
}

class PadronData {
  final String cedula;
  final String nombres;
  final String? apellido1;
  final String? apellido2;
  final DateTime? fechaNacimiento;
  final String? lugarNacimiento;
  final String? nacionalidad;
  final String? sexo;
  final String? estadoCivil;
  final String? colegio;
  final int? colegioId;
  final String? municipio;
  final String? provincia;

  PadronData({
    required this.cedula,
    required this.nombres,
    this.apellido1,
    this.apellido2,
    this.fechaNacimiento,
    this.lugarNacimiento,
    this.nacionalidad,
    this.sexo,
    this.estadoCivil,
    this.colegio,
    this.colegioId,
    this.municipio,
    this.provincia,
  });

  factory PadronData.fromJson(Map<String, dynamic> json) {
    return PadronData(
      cedula: json['Cedula'],
      nombres: json['Nombres'],
      apellido1: json['Apellido1'],
      apellido2: json['Apellido2'],
      fechaNacimiento: json['FechaNacimiento'] != null
          ? DateTime.parse(json['FechaNacimiento'])
          : null,
      lugarNacimiento: json['LugarNacimiento'],
      nacionalidad: json['nacionalidad'],
      sexo: json['sexo'],
      estadoCivil: json['estado_civil'],
      colegio: json['colegio'],
      colegioId: json['colegio_id'],
      municipio: json['municipio'],
      provincia: json['provincia'],
    );
  }
}