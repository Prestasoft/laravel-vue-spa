class UserModel {
  final int id;
  final String name;
  final String email;
  final String? cedula;
  final int type;
  final int? candidatoId;
  final String? photoUrl;
  final DateTime? emailVerifiedAt;

  // Permisos
  final bool canViewVotantes;
  final bool canAddVotantes;
  final bool canEditVotantes;
  final bool canDeleteVotantes;
  final bool canViewUsers;
  final bool canAddUsers;
  final bool canEditUsers;
  final bool canDeleteUsers;
  final bool canViewReports;
  final bool canExportData;
  final bool canViewAllVotantes;
  final bool canManageCoordinadores;

  // Token JWT
  String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.cedula,
    required this.type,
    this.candidatoId,
    this.photoUrl,
    this.emailVerifiedAt,
    this.canViewVotantes = true,
    this.canAddVotantes = true,
    this.canEditVotantes = true,
    this.canDeleteVotantes = true,
    this.canViewUsers = false,
    this.canAddUsers = false,
    this.canEditUsers = false,
    this.canDeleteUsers = false,
    this.canViewReports = false,
    this.canExportData = false,
    this.canViewAllVotantes = false,
    this.canManageCoordinadores = false,
    this.token,
  });

  // Tipos de usuario
  static const int typeAdmin = 1;
  static const int typeGuest = 2;
  static const int typeCoordinador = 3;
  static const int typeCandidato = 4;

  bool get isAdmin => type == typeAdmin;
  bool get isGuest => type == typeGuest;
  bool get isCoordinador => type == typeCoordinador;
  bool get isCandidato => type == typeCandidato;

  String get typeName {
    switch (type) {
      case typeAdmin:
        return 'Administrador';
      case typeCoordinador:
        return 'Coordinador';
      case typeCandidato:
        return 'Candidato';
      case typeGuest:
        return 'Invitado';
      default:
        return 'Usuario';
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      cedula: json['cedula'],
      type: json['type'] is String ? int.parse(json['type']) : json['type'],
      candidatoId: json['candidato_id'],
      photoUrl: json['photo_url'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      canViewVotantes: json['can_view_votantes'] ?? true,
      canAddVotantes: json['can_add_votantes'] ?? true,
      canEditVotantes: json['can_edit_votantes'] ?? true,
      canDeleteVotantes: json['can_delete_votantes'] ?? true,
      canViewUsers: json['can_view_users'] ?? false,
      canAddUsers: json['can_add_users'] ?? false,
      canEditUsers: json['can_edit_users'] ?? false,
      canDeleteUsers: json['can_delete_users'] ?? false,
      canViewReports: json['can_view_reports'] ?? false,
      canExportData: json['can_export_data'] ?? false,
      canViewAllVotantes: json['can_view_all_votantes'] ?? false,
      canManageCoordinadores: json['can_manage_coordinadores'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cedula': cedula,
      'type': type,
      'candidato_id': candidatoId,
      'photo_url': photoUrl,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'can_view_votantes': canViewVotantes,
      'can_add_votantes': canAddVotantes,
      'can_edit_votantes': canEditVotantes,
      'can_delete_votantes': canDeleteVotantes,
      'can_view_users': canViewUsers,
      'can_add_users': canAddUsers,
      'can_edit_users': canEditUsers,
      'can_delete_users': canDeleteUsers,
      'can_view_reports': canViewReports,
      'can_export_data': canExportData,
      'can_view_all_votantes': canViewAllVotantes,
      'can_manage_coordinadores': canManageCoordinadores,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? cedula,
    int? type,
    int? candidatoId,
    String? photoUrl,
    DateTime? emailVerifiedAt,
    bool? canViewVotantes,
    bool? canAddVotantes,
    bool? canEditVotantes,
    bool? canDeleteVotantes,
    bool? canViewUsers,
    bool? canAddUsers,
    bool? canEditUsers,
    bool? canDeleteUsers,
    bool? canViewReports,
    bool? canExportData,
    bool? canViewAllVotantes,
    bool? canManageCoordinadores,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cedula: cedula ?? this.cedula,
      type: type ?? this.type,
      candidatoId: candidatoId ?? this.candidatoId,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      canViewVotantes: canViewVotantes ?? this.canViewVotantes,
      canAddVotantes: canAddVotantes ?? this.canAddVotantes,
      canEditVotantes: canEditVotantes ?? this.canEditVotantes,
      canDeleteVotantes: canDeleteVotantes ?? this.canDeleteVotantes,
      canViewUsers: canViewUsers ?? this.canViewUsers,
      canAddUsers: canAddUsers ?? this.canAddUsers,
      canEditUsers: canEditUsers ?? this.canEditUsers,
      canDeleteUsers: canDeleteUsers ?? this.canDeleteUsers,
      canViewReports: canViewReports ?? this.canViewReports,
      canExportData: canExportData ?? this.canExportData,
      canViewAllVotantes: canViewAllVotantes ?? this.canViewAllVotantes,
      canManageCoordinadores: canManageCoordinadores ?? this.canManageCoordinadores,
      token: token ?? this.token,
    );
  }
}