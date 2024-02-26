import 'issuances.dart';

class DraftIssuance {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  DraftIssuance({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory DraftIssuance.fromJson(Map<String, dynamic> json) {
    return DraftIssuance(
      id: json['id'],
      responsible_office: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}