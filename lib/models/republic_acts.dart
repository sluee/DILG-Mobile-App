import 'issuances.dart';

class RepublicAct {
  final int id;
  final String responsibleOffice;
  final Issuance issuance;

  RepublicAct({
    required this.id,
    required this.responsibleOffice,
    required this.issuance,
  });

  factory RepublicAct.fromJson(Map<String, dynamic> json) {
    return RepublicAct(
      id: json['id'],
      responsibleOffice: json['responsible_office'],
      issuance: Issuance.fromJson(json['issuance']),
    );
  }
}
