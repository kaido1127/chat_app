class Comment {
  String? timeComment;
  String? userId;
  String? postId;
  String? text;
  List<String>? likedUserIds;

  Comment({this.timeComment, this.userId, this.text, this.likedUserIds,this.postId});

  Comment.fromJson(Map<String, dynamic> json) {
    timeComment = json['timePost'];
    userId = json['userId'];
    text = json['text'];
    postId=json['postId'];
    likedUserIds = json['likedUserIds'] != null ? List<String>.from(json['likedUserIds']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timePost'] = this.timeComment;
    data['userId'] = this.userId;
    data['text'] = this.text;
    data['postId']=this.postId;
    data['likedUserIds'] = this.likedUserIds;
    return data;
  }
}
