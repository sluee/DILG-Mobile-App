import 'issuances.dart';
class JointCircular {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  JointCircular({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory JointCircular.fromJson(Map<String, dynamic> json) {
    return JointCircular(
      id: json['id'],
      responsible_office: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}