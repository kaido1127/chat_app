

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/screens/chat/chat_screen.dart';
import 'package:chat_app/screens/friend_profile_screen.dart';
import 'package:chat_app/screens/post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ChatUser? _user;
  QuerySnapshot? _comment;
  late ChatUser _thisUser;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await APIs.getUserFromId(widget.post.userId.toString());
    final postRef = APIs.firestore.collection('posts').doc(widget.post.timePost);
    final QuerySnapshot commentsQuerySnapshot = await postRef.collection('comments').get();
    setState(() {
      _user = _thisUser = user;
      _comment = commentsQuerySnapshot; // docs trả về danh sách các DocumentSnapshot trong collection
    });
  }

  Widget build(BuildContext context) {
    return _user == null
        ? Container()
        : Card(
            color: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FriendProfileScreen(user: _thisUser)));
                    },
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(_user!.image.toString())),
                  ),
                  title: InkWell(
                    onTap: () {
                      if (_user?.id == APIs.me.id) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FriendProfileScreen(user: _thisUser)));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FriendProfileScreen(user: _thisUser)));
                      }
                    },
                    child: Text(
                      _user!.name.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Text(
                    MyDateUtil.getTime(
                        context: context,
                        ftime: widget.post.timePost.toString()),
                    style: TextStyle(color: Colors.white38),
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.close,
                      color: Colors.white38,
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                    child: Text(
                      widget.post.text.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
                if (widget.post.imageUrl.toString().isNotEmpty)
                  Image.network(widget.post.userId.toString()),

                (widget.post.likedUserIds!.isEmpty)
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                      child: Text(
                          'Hãy là người đầu tiên yêu thích bài viết này nàoo',
                          style: TextStyle(color: Colors.white70),
                        ),
                    )
                    : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 17,
                              ),
                              Text(
                                widget.post.likedUserIds!.length.toString(),
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Text(
                            "${_comment!.docs.length} Bình luận",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    ),
                SizedBox(height: mq.height*0.01),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        APIs.likePost(widget.post);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                              color: (widget.post.likedUserIds!.contains(APIs.me.id))?Colors.redAccent:Colors.grey
                          ),
                          SizedBox(
                            width: mq.width * 0.02,
                          ),
                          Text(
                            'Yêu thích',
                            style: TextStyle(color: (widget.post.likedUserIds!.contains(APIs.me.id)?Colors.redAccent:Colors.grey),
                          ))
                        ],
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>PostScreen(post: widget.post)));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.comment_bank,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: mq.width * 0.02,
                          ),
                          Text(
                            'Bình luận',
                            style: TextStyle(color: Colors.white60),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }
}
