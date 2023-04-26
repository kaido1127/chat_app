import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/screens/chat_home/chat_home_screen.dart';
import 'package:chat_app/screens/friend_profile_screen.dart';
import 'package:chat_app/screens/home/bloc/home_bloc.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:chat_app/widgets/post_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';

class HomeScreen extends StatefulWidget {
  final ChatUser user;

  const HomeScreen({super.key, required this.user});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _listPost = [];
  List<ChatUser> _list = [];
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //APIs.getMyInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('message : $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('inactive'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('paused'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => HomeBloc(),
  child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocBuilder<HomeBloc, HomeState>(
  builder: (context, state) {
    return WillPopScope(
        onWillPop: () {
          if (BlocProvider.of<HomeBloc>(context).state.isSearching) {
           BlocProvider.of<HomeBloc>(context).add(NotIsSearching());
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Icon(CupertinoIcons.home),
              ),
              title: BlocProvider.of<HomeBloc>(context).state.isSearching
                  ? Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          //search logic
                          BlocProvider.of<HomeBloc>(context).add(ClearSearchList());
                          if (_list != null && _list.isNotEmpty) {
                            for (var i in _list) {
                              if (i.name != null &&
                                  i.email != null &&
                                  (i.name!
                                          .toLowerCase()
                                          .contains(val.toLowerCase()) ||
                                      i.email!
                                          .toLowerCase()
                                          .contains(val.toLowerCase()))) {
                                BlocProvider.of<HomeBloc>(context).add(AddSearchList(user: i));
                              } else {
                                Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }
                          }
                        },
                        autofocus: true,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Tên hoặc email',
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  : const Text(
                      'NTV Chat',
                      style: TextStyle(fontSize: 24),
                    ),
              backgroundColor: Colors.black,
              actions: [
                Container(
                    //width: 40,
                    //height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        BlocProvider.of<HomeBloc>(context).add(NotIsSearching());
                        BlocProvider.of<HomeBloc>(context).add(ClearSearchList());
                      },
                      icon: Icon(BlocProvider.of<HomeBloc>(context).state.isSearching ? Icons.clear : Icons.search),
                    )),
                SizedBox(
                  width: 15,
                ),
                if (!BlocProvider.of<HomeBloc>(context).state.isSearching)
                  Container(
                    //width: 40,
                    //height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ChatHomeScreen()));
                        },
                        icon: Icon(
                          Icons.chat_bubble,
                        )),
                  ),
                if (!BlocProvider.of<HomeBloc>(context).state.isSearching)
                  SizedBox(
                    width: 15,
                  ),
                if (!BlocProvider.of<HomeBloc>(context).state.isSearching)
                  Container(
                    //width: 40,
                    //height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      FriendProfileScreen(user: APIs.me)));
                        },
                        icon: Icon(
                          Icons.person,
                        )),
                  ),
                if (!BlocProvider.of<HomeBloc>(context).state.isSearching)
                  SizedBox(
                    width: 15,
                  ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  onPressed: () async {},
                  backgroundColor: Colors.grey[850],
                  child: Icon(Icons.add_comment_rounded)),
            ),
            body: Container(
              color: Colors.black,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 2,
                    color: CupertinoColors.white,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Container(
                      color: Colors.black,
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FriendProfileScreen(user: APIs.me))),
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
                                    if (BlocProvider.of<HomeBloc>(context).state.showEmoji) BlocProvider.of<HomeBloc>(context).add(NotShowEmoji());
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
                                        BlocProvider.of<HomeBloc>(context).add(NotShowEmoji());
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
                                    if (BlocProvider.of<HomeBloc>(context).state.showEmoji) BlocProvider.of<HomeBloc>(context).add(NotShowEmoji());
                                    APIs.upPost(_textController.text,"");
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
                    ),
                  ),
                  Divider(
                    height: 2,
                    color: CupertinoColors.white,
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      padding: EdgeInsets.fromLTRB(0, mq.height * 0.02, 0, 0),
                      child: StreamBuilder(
                          stream: APIs.firestore.collection('posts').orderBy('id',descending: true).snapshots(),
                          //stream: APIs.firestore.collectionGroup('post').snapshots(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const SizedBox();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _listPost = data
                                    ?.map((e) => Post.fromJson(e.data()))
                                    .toList() ??
                                    [];
                                if (_listPost.isNotEmpty) {
                                  log('Không rỗng');
                                  return ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _listPost.length,
                                      itemBuilder: (context, index) {
                                        return PostCard(
                                          post: _listPost[index],
                                        );
                                      });
                                } else {
                                  log('rỗng');
                                  return const Center(
                                    child: Text(
                                      'Hãy tìm kiếm những người bạn nào',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 19),
                                    ),
                                  );
                                }
                            }
                          }),
                    ),
                  ),
                  if (BlocProvider.of<HomeBloc>(context).state.showEmoji)
                    Expanded(
                      child: SizedBox(
                        height: mq.height * 0.3,
                        child: EmojiPicker(
                          textEditingController:
                              _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                          config: Config(
                            bgColor: Colors.black,
                            columns: 8,
                            emojiSizeMax: 32 *
                                (Platform.isIOS
                                    ? 1.30
                                    : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )),
      );
  },
),
    ),
);
  }
}
