import 'package:chat_app/models/comment.dart';

class Post {
  int? id;
  String? timePost;
  String? userId;
  String? text;
  String? imageUrl;
  List<String>? likedUserIds;
  //List<Comment>? comments;

  Post(
      {this.timePost,
      this.userId,
      this.text,
      this.imageUrl,
      this.likedUserIds,
      this.id,});

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    timePost = json['timePost'];
    userId = json['userId'];
    text = json['text'];
    imageUrl = json['imageUrl'];
    likedUserIds = json['likedUserIds'] != null ? List<String>.from(json['likedUserIds']) : null;
    //comments = json['comments'] != null ? List<Comment>.from(json['comments'].map((comment) => Comment.fromJson(comment))) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timePost'] = this.timePost;
    data['userId'] = this.userId;
    data['text'] = this.text;
    data['imageUrl'] = this.imageUrl;
    data['likedUserIds'] = this.likedUserIds;
    data['id'] = this.id;
    //data['comments'] = this.comments != null ? this.comments!.map((comment) => comment.toJson()).toList() : null;
    return data;
  }
}
