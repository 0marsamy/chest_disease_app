class LoginResponseModel {
  String? token;
  User? user;

  LoginResponseModel({this.token, this.user});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    // ✅ إضافة التوكن لليوزر لو موجود في الريسبونس
    if (user != null && token != null) {
      user!.token = token;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? profilePicture;
  String? fullName;
  String? userName;
  String? email;
  String? phone;
  String? dateOfBirth;
  String? role;
  String? gender;
  String? token; // ✅ تم إضافة التوكن هنا
  double? latitude;
  double? longitude;
  int? age;

  User({
    this.id,
    this.profilePicture,
    this.fullName,
    this.userName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.role,
    this.gender,
    this.token, // ✅
    this.latitude,
    this.longitude,
    this.age,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    profilePicture = json['profilePicture'];
    fullName = json['fullName'];
    role = json['role'];
    userName = json['userName'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    token = json['token']; // ✅
    latitude = json['latitude'];
    longitude = json['longitude'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['profilePicture'] = profilePicture;
    data['fullName'] = fullName;
    data['userName'] = userName;
    data['email'] = email;
    data['phone'] = phone;
    data['dateOfBirth'] = dateOfBirth;
    data['gender'] = gender;
    data['token'] = token; // ✅
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['age'] = age;
    data['role'] = role;
    return data;
  }

  User copyWith({
    String? id,
    String? profilePicture,
    String? fullName,
    String? userName,
    String? email,
    String? phone,
    String? dateOfBirth,
    String? role,
    String? gender,
    String? token, // ✅
    double? latitude,
    double? longitude,
    int? age,
  }) {
    return User(
      id: id ?? this.id,
      profilePicture: profilePicture ?? this.profilePicture,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      token: token ?? this.token, // ✅
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      age: age ?? this.age,
    );
  }
}

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}