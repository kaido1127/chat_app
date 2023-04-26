class Message {
  String? msg;
  String? read;
  String? toId;
  Type? type;
  String? sent;
  String? fromId;

  Message({this.msg, this.read, this.toId, this.type, this.sent, this.fromId});

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    read = json['read'];
    toId = json['told'];
    type = json['type'].toString() == Type.image.name
        ? Type.image
        : json['type'].toString() == Type.voice.name
            ? Type.voice
            : Type.text;

    sent = json['sent'];
    fromId = json['fromId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = this.msg;
    data['read'] = this.read;
    data['told'] = this.toId;
    data['type'] = this.type?.name;
    data['sent'] = this.sent;
    data['fromId'] = this.fromId;
    return data;
  }
}

enum Type { text, image, voice }
