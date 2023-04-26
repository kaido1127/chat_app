import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat/chat_screen.dart';
import 'package:chat_app/screens/friend_profile_screen.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  _ChatUserCardState createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: mq.width * 0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.grey[900],
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }
              return ListTile(
                  leading: Stack(children: [
                    InkWell(
                      onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>FriendProfileScreen(user: widget.user,))),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.03),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: mq.height * 0.055,
                          height: mq.height * 0.055,
                          imageUrl: widget.user.image.toString(),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                          const CircleAvatar(
                              child: Icon(Icons.person_outlined)),
                        ),
                      ),
                    ),
                   /* const Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 15,
                      ),
                    ),*/
                  ]),
                  title: Text(
                    widget.user.name.toString(),
                    style: _message?.read?.isEmpty == true &&
                            _message!.fromId != APIs.user.uid
                        ? TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17)
                        : TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    _message == null
                        ? widget.user.about.toString()
                        : (_message!.fromId == APIs.user.uid
                            ? 'Bạn : ${(_message?.type == Type.text) ? _message!.msg : (_message?.type == Type.voice)?'Audio':'Hình ảnh'}'
                            : '${widget.user.name!.split(' ').first} : ${(_message?.type == Type.text) ? _message!.msg : (_message?.type == Type.voice)?'Audio':'Hình ảnh'}'),
                    style: _message?.read?.isEmpty == true &&
                            _message!.fromId != APIs.user.uid
                        ? TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )
                        : TextStyle(
                            color: Colors.white,
                          ),
                  ),
                  trailing: _message == null
                      ? null
                      : (_message!.read!.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 15,
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context,
                                  time: _message!.sent.toString()),
                              style: TextStyle(color: Colors.white38),
                            )));
            },
          )),
    );
  }
}
