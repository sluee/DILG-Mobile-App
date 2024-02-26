import 'issuances.dart';
class PresidentialDirective {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  PresidentialDirective({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory PresidentialDirective.fromJson(Map<String, dynamic> json) {
    return PresidentialDirective(
      id: json['id'],
      responsible_office: json['responsible_office'] ?? 'N/A',
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}