import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/screens/chat/chat_screen.dart';
import 'package:chat_app/screens/profile/profile_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:chat_app/widgets/post_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';

class FriendProfileScreen extends StatefulWidget {
  final ChatUser user;

  const FriendProfileScreen({super.key, required this.user});

  @override
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool _showEmoji=false;
  final _textController=TextEditingController();
  List<Post> _listPost = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(CupertinoIcons.arrow_left)),
            ),
            centerTitle: true,
            title: Text(
              widget.user.name.toString(),
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              if(widget.user.id==APIs.auth.currentUser?.uid) Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me)));
                }, icon: Icon(Icons.settings,color: Colors.white,)),
              ),
              if(widget.user.id!=APIs.auth.currentUser?.uid) Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user)));
                }, icon: Icon(Icons.message,color: Colors.white,)),
              ),
            ],
            backgroundColor: Colors.black,
          ),
          body: Container(
            color: Colors.black,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(mq.height * 0.1),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width: mq.height * 0.1,
                                  height: mq.height * 0.1,
                                  imageUrl: widget.user.image.toString(),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(Icons.person_outlined)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: mq.width,
                                height: mq.height * 0.015,
                              ),
                              Text(
                                "Email: "+widget.user.email.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: mq.height * 0.01,
                              ),
                              Text(
                                'Giới thiệu : ' + widget.user.about.toString(),
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              SizedBox(
                                height: mq.height * 0.01,
                              ),
                              Text(
                                MyDateUtil.getCreatedTime(
                                    context: context,
                                    created: widget.user.createdAt.toString()),
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: mq.height*0.02,),
                  Divider(height: 1,color: Colors.white38,),
                  SizedBox(height: mq.height*0.02,),
                  if(widget.user.id==APIs.auth.currentUser?.uid) Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(mq.height * 0.06),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: mq.height * 0.06,
                            height: mq.height * 0.06,
                            imageUrl: widget.user.image.toString(),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(Icons.person_outlined)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: TextField(
                              onTap: () {
                                setState(() {
                                  if (_showEmoji) _showEmoji = !_showEmoji;
                                });
                              },
                              controller: _textController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    color: Colors.white60, fontSize: 15),
                                hintText: 'Bạn đang nghĩ gì ?',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                  BorderSide(color: Colors.white70),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                  BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide:
                                  BorderSide(color: Colors.white70),
                                ),
                                filled: true,
                                //fillColor: Colors.grey[800],
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showEmoji = !_showEmoji;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.emoji_emotions,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: mq.width * 0.15,
                          child: MaterialButton(
                            onPressed: () async {
                              if (_textController.text.isNotEmpty) {
                                setState(() {if (_showEmoji) _showEmoji = !_showEmoji;});
                                APIs.upPost(_textController.text,'');
                                Dialogs.showSnackBar(
                                    context, "Đăng bài thành công !");
                                _textController.text = '';
                              }
                            },
                            //minWidth: 0,
                            padding:
                            const EdgeInsets.fromLTRB(10, 15, 5, 15),
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Text(
                              'Đăng',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: mq.height*0.02,),
                  Divider(height: 1,color: Colors.white38,),
                  SizedBox(height: mq.height*0.02,),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: StreamBuilder(
                          //stream: APIs.firestore.collection('posts').where('userId', isEqualTo: widget.user.id).orderBy('id',descending: true).snapshots(),
                          stream: APIs.firestore.collection('posts').where('userId', isEqualTo: widget.user.id).snapshots(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              case ConnectionState.none:
                                return const CircularProgressIndicator();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _listPost = data
                                    ?.map((e) => Post.fromJson(e.data()))
                                    .toList() ??
                                    [];
                                if (_listPost.isNotEmpty) {
                                  log('${_listPost.length}');
                                  return ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      reverse: false,
                                      itemCount: _listPost.length,
                                      itemBuilder: (context, index) {
                                        return PostCard(
                                          post: _listPost[_listPost.length-index-1],
                                        );
                                      });
                                } else {
                                  //log('${_list.length}');
                                  return const Center(
                                    child: Text(
                                  'Chưa có bài viết nào',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 19),
                                    ),
                                  );
                                }
                            }
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ));

  }
}
