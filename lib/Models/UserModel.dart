import 'dart:convert';

UserModel userFromJson(String str) => UserModel.fromJson(json.decode(str));

String userToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  int userId;
  int empresaId;
  String token;
  String user;
  String password;

  UserModel({
    required this.userId,
    required this.empresaId,
    required this.token,
    required this.user,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["user_id"],
        empresaId: json["empresa_id"],
        token: json["token"],
        user: json["user"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "empresa_id": empresaId,
        "token": token,
        "user": user,
        "password": password,
      };
}
