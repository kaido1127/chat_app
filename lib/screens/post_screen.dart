import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/comment.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/widgets/comment_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  final Post post;
  const PostScreen({Key? key,required this.post}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Comment> _listComments=[];
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back,color: Colors.white,),
        ),
        title: Text('Bình luận',style: TextStyle(color: Colors.white,fontSize: 22),),
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, mq.height * 0.02, 0, 0),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    //stream: APIs.firestore.collection('posts/${widget.post.timePost}/comments').orderBy('timeComment',descending: true).snapshots(),
                    stream: APIs.firestore.collection('posts/${widget.post.timePost}/comments').snapshots(),
                    //stream: APIs.firestore.collectionGroup('post').snapshots(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _listComments = data?.map((e) => Comment.fromJson(e.data())).toList() ?? [];
                          if (_listComments.isNotEmpty) {
                            log(_listComments.length.toString());
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _listComments.length,
                                itemBuilder: (context, index) {
                                  return CommentCard(
                                    comment: _listComments[index],
                                  );
                                });
                          } else {
                            log('không có comment nào');
                            return const Center(
                              child: Text(
                                'Hãy là người đầu tiên bình luận bài viết này nào',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15),
                              ),
                            );
                          }
                      }
                    }),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: mq.height * 0.01),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.white, width: 1),
                        ),
                        color: Colors.black,
                        //height: mq.height*0.05,
                        //padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            children: [
                              Container(
                                width: mq.width * 0.74,
                                //height: mq.height*0.05,
                                //color: Colors.grey,
                                child: TextField(
                                  onTap: () {},
                                  controller: _textController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintStyle: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 18),
                                    hintText: 'Bình luận của bạn',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      //borderSide: BorderSide(color: Colors.white70),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      //borderSide: BorderSide(color: Colors.white70),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0),
                                      //borderSide: BorderSide(color: Colors.white70),
                                    ),
                                    filled: true,
                                    //fillColor: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        if (_textController.text.isNotEmpty) {
                          APIs.upComment(_textController.text,widget.post.id.toString());
                          Dialogs.showSnackBar(
                              context, "Bình luận thành công !");
                          _textController.text = '';
                        }
                      },
                      //minWidth: 0,
                      padding: const EdgeInsets.fromLTRB(10, 15, 5, 15),
                      color: Colors.blue,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
        ]
          ),
        ),
      ),
    );
  }
}



