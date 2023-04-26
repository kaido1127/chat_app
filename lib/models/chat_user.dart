class ChatUser {
  String? about;
  String? createdAt;
  String? email;
  String? id;
  String? image;
  bool? isOnline;
  String? lastActive;
  String? name;
  String? pushToken;

  ChatUser({this.about,
    this.createdAt,
    this.email,
    this.id,
    this.image,
    this.isOnline,
    this.lastActive,
    this.name,
    this.pushToken});

  ChatUser.fromJson(Map<String, dynamic> json) {
    about = json['about']??'';
    createdAt = json['created_at']??'';
    email = json['email']??'';
    id = json['id']??'';
    image = json['image']??'';
    isOnline = json['is_online']??false;
    lastActive = json['last_active']??'';
    name = json['name']??'';
    pushToken = json['push_token']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['about'] = this.about;
    data['created_at'] = this.createdAt;
    data['email'] = this.email;
    data['id'] = this.id;
    data['image'] = this.image;
    data['is_online'] = this.isOnline;
    data['last_active'] = this.lastActive;
    data['name'] = this.name;
    data['push_token'] = this.pushToken;
    return data;
  }
}
