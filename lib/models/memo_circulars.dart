import 'issuances.dart';
class MemoCircular {
  final int id;
  final String responsible_office;
  final Issuance issuance;

  MemoCircular({
    required this.id,
    required this.responsible_office,
    required this.issuance,
  });

  factory MemoCircular.fromJson(Map<String, dynamic> json) {
    return MemoCircular(
      id: json['id'],
      responsible_office: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}