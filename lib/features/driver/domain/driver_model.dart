class DriverModel {
  final String id;
  final String name;
  final int permanentNumber;
  final String teamName;
  final int points;
  final String teammateId;
  final String imageUrl;

  const DriverModel({
    required this.id,
    required this.name,
    required this.permanentNumber,
    required this.teamName,
    required this.points,
    required this.teammateId,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'permanentNumber': permanentNumber,
        'teamName': teamName,
        'points': points,
        'teammateId': teammateId,
        'imageUrl': imageUrl,
      };

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        permanentNumber: json['permanentNumber'] as int? ?? 0,
        teamName: json['teamName'] as String? ?? '',
        points: json['points'] as int? ?? 0,
        teammateId: json['teammateId'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
      );
}