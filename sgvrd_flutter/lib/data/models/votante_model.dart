class VotanteModel {
  final int? id;
  final String cedula;
  final int? dirigenteId;
  final int? colegioId;
  final String? mesa;
  final String? telefono;
  final String? direccion;
  final double? latitud;
  final double? longitud;
  final String? direccionGps;
  final DateTime? gpsCapturadoEn;
  final String? observaciones;
  final DateTime? fechaRegistro;
  final bool activo;

  // Datos del padrón
  final String? nombres;
  final String? apellido1;
  final String? apellido2;
  final String? sexo;
  final DateTime? fechaNacimiento;
  final String? nacionalidad;
  final String? estadoCivil;
  final String? colegioNombre;
  final String? municipio;
  final String? provincia;

  // Datos del dirigente
  final String? dirigenteNombre;
  final int? dirigenteTipo;

  // Foto en base64
  final String? fotoBase64;

  // Para control local
  bool? sincronizado;
  DateTime? ultimaSincronizacion;

  VotanteModel({
    this.id,
    required this.cedula,
    this.dirigenteId,
    this.colegioId,
    this.mesa,
    this.telefono,
    this.direccion,
    this.latitud,
    this.longitud,
    this.direccionGps,
    this.gpsCapturadoEn,
    this.observaciones,
    this.fechaRegistro,
    this.activo = true,
    this.nombres,
    this.apellido1,
    this.apellido2,
    this.sexo,
    this.fechaNacimiento,
    this.nacionalidad,
    this.estadoCivil,
    this.colegioNombre,
    this.municipio,
    this.provincia,
    this.dirigenteNombre,
    this.dirigenteTipo,
    this.fotoBase64,
    this.sincronizado = true,
    this.ultimaSincronizacion,
  });

  String get nombreCompleto {
    final parts = [
      if (nombres != null) nombres!,
      if (apellido1 != null) apellido1!,
      if (apellido2 != null) apellido2!,
    ];
    return parts.join(' ').trim();
  }

  bool get tieneGps => latitud != null && longitud != null;

  bool get tieneTelefono => telefono != null && telefono!.isNotEmpty;

  factory VotanteModel.fromJson(Map<String, dynamic> json) {
    // Manejar los datos anidados del padrón
    Map<String, dynamic>? padronData;
    if (json['padron_data'] != null) {
      padronData = json['padron_data'];
    }

    return VotanteModel(
      id: json['id'],
      cedula: json['cedula'],
      dirigenteId: json['dirigente_id'],
      colegioId: json['colegio_id'],
      mesa: json['mesa'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
      direccionGps: json['direccion_gps'],
      gpsCapturadoEn: json['gps_capturado_en'] != null
          ? DateTime.parse(json['gps_capturado_en'])
          : null,
      observaciones: json['observaciones'],
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : null,
      activo: json['activo'] ?? true,

      // Datos del padrón
      nombres: padronData?['nombres'] ?? json['nombres'],
      apellido1: padronData?['apellido1'] ?? json['apellido1'],
      apellido2: padronData?['apellido2'] ?? json['apellido2'],
      sexo: padronData?['sexo'] ?? json['sexo'],
      fechaNacimiento: padronData?['FechaNacimiento'] != null
          ? DateTime.parse(padronData!['FechaNacimiento'])
          : null,
      nacionalidad: padronData?['nacionalidad'] ?? json['nacionalidad'],
      estadoCivil: padronData?['estado_civil'] ?? json['estado_civil'],
      colegioNombre: json['colegio_nombre'] ?? padronData?['colegio_nombre'],
      municipio: padronData?['municipio'] ?? json['municipio'],
      provincia: padronData?['provincia'] ?? json['provincia'],

      // Datos del dirigente
      dirigenteNombre: json['dirigente']?['name'] ?? json['dirigente_nombre'],
      dirigenteTipo: json['dirigente']?['type'] ?? json['dirigente_tipo'],

      // Foto
      fotoBase64: json['foto_base64'],

      // Control local
      sincronizado: json['sincronizado'] ?? true,
      ultimaSincronizacion: json['ultima_sincronizacion'] != null
          ? DateTime.parse(json['ultima_sincronizacion'])
          : null,
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
      'latitud': latitud,
      'longitud': longitud,
      'direccion_gps': direccionGps,
      'gps_capturado_en': gpsCapturadoEn?.toIso8601String(),
      'observaciones': observaciones,
      'fecha_registro': fechaRegistro?.toIso8601String(),
      'activo': activo,
      'sincronizado': sincronizado,
      'ultima_sincronizacion': ultimaSincronizacion?.toIso8601String(),
    };
  }

  // Para SQLite local
  Map<String, dynamic> toLocalDb() {
    return {
      'id': id,
      'cedula': cedula,
      'dirigente_id': dirigenteId,
      'colegio_id': colegioId,
      'mesa': mesa,
      'telefono': telefono,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'direccion_gps': direccionGps,
      'gps_capturado_en': gpsCapturadoEn?.millisecondsSinceEpoch,
      'observaciones': observaciones,
      'fecha_registro': fechaRegistro?.millisecondsSinceEpoch,
      'activo': activo ? 1 : 0,
      'nombres': nombres,
      'apellido1': apellido1,
      'apellido2': apellido2,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento?.millisecondsSinceEpoch,
      'nacionalidad': nacionalidad,
      'estado_civil': estadoCivil,
      'colegio_nombre': colegioNombre,
      'municipio': municipio,
      'provincia': provincia,
      'dirigente_nombre': dirigenteNombre,
      'dirigente_tipo': dirigenteTipo,
      'foto_base64': fotoBase64,
      'sincronizado': (sincronizado ?? true) ? 1 : 0,
      'ultima_sincronizacion': ultimaSincronizacion?.millisecondsSinceEpoch,
    };
  }

  factory VotanteModel.fromLocalDb(Map<String, dynamic> map) {
    return VotanteModel(
      id: map['id'],
      cedula: map['cedula'],
      dirigenteId: map['dirigente_id'],
      colegioId: map['colegio_id'],
      mesa: map['mesa'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      direccionGps: map['direccion_gps'],
      gpsCapturadoEn: map['gps_capturado_en'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['gps_capturado_en'])
          : null,
      observaciones: map['observaciones'],
      fechaRegistro: map['fecha_registro'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha_registro'])
          : null,
      activo: map['activo'] == 1,
      nombres: map['nombres'],
      apellido1: map['apellido1'],
      apellido2: map['apellido2'],
      sexo: map['sexo'],
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['fecha_nacimiento'])
          : null,
      nacionalidad: map['nacionalidad'],
      estadoCivil: map['estado_civil'],
      colegioNombre: map['colegio_nombre'],
      municipio: map['municipio'],
      provincia: map['provincia'],
      dirigenteNombre: map['dirigente_nombre'],
      dirigenteTipo: map['dirigente_tipo'],
      fotoBase64: map['foto_base64'],
      sincronizado: map['sincronizado'] == 1,
      ultimaSincronizacion: map['ultima_sincronizacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['ultima_sincronizacion'])
          : null,
    );
  }

  VotanteModel copyWith({
    int? id,
    String? cedula,
    int? dirigenteId,
    int? colegioId,
    String? mesa,
    String? telefono,
    String? direccion,
    double? latitud,
    double? longitud,
    String? direccionGps,
    DateTime? gpsCapturadoEn,
    String? observaciones,
    DateTime? fechaRegistro,
    bool? activo,
    String? nombres,
    String? apellido1,
    String? apellido2,
    String? sexo,
    DateTime? fechaNacimiento,
    String? nacionalidad,
    String? estadoCivil,
    String? colegioNombre,
    String? municipio,
    String? provincia,
    String? dirigenteNombre,
    int? dirigenteTipo,
    String? fotoBase64,
    bool? sincronizado,
    DateTime? ultimaSincronizacion,
  }) {
    return VotanteModel(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      dirigenteId: dirigenteId ?? this.dirigenteId,
      colegioId: colegioId ?? this.colegioId,
      mesa: mesa ?? this.mesa,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccionGps: direccionGps ?? this.direccionGps,
      gpsCapturadoEn: gpsCapturadoEn ?? this.gpsCapturadoEn,
      observaciones: observaciones ?? this.observaciones,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
      nombres: nombres ?? this.nombres,
      apellido1: apellido1 ?? this.apellido1,
      apellido2: apellido2 ?? this.apellido2,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      colegioNombre: colegioNombre ?? this.colegioNombre,
      municipio: municipio ?? this.municipio,
      provincia: provincia ?? this.provincia,
      dirigenteNombre: dirigenteNombre ?? this.dirigenteNombre,
      dirigenteTipo: dirigenteTipo ?? this.dirigenteTipo,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
      sincronizado: sincronizado ?? this.sincronizado,
      ultimaSincronizacion: ultimaSincronizacion ?? this.ultimaSincronizacion,
    );
  }
}