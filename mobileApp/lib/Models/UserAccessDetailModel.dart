class UserAccessDetailModel {
  String? id;
  String? name;
  String? mobile;
  String? email;
  String? location;
  String? profilePic;
  String? role;
  String? status;
  String? createdAt;
  String? accessLevel;    // optional, if you still want it
  String? designation;    // optional, if you still want it

  UserAccessDetailModel({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.location,
    this.profilePic,
    this.role,
    this.status,
    this.createdAt,
    this.accessLevel,
    this.designation,
  });
}