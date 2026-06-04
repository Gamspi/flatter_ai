class UserModel {
  final int id;
  final String name;
  final String lastName;
  final String secondName;
  final String phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.secondName,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      secondName: json['second_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  String get displayName => '$name $lastName';
}
