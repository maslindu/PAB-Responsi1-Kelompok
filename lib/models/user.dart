import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 2) // Ensure this typeId is unique
class User extends HiveObject {
  @HiveField(0)
  String fullName;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String phoneNumber;

  @HiveField(4)
  String profilePicturePath; // Path to the local image file

  User({
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.profilePicturePath = 'assets/images/default_profile.png',
  });
}
