import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/chat_home/bloc/chat_home_bloc.dart';
import 'package:chat_app/screens/profile/profile_screen.dart';

import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';

class ChatHomeScreen extends StatefulWidget {
  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  List<ChatUser> _list = [];
  @override
  void initState() {
    super.initState();
  }
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => ChatHomeBloc(),
  child: GestureDetector(
      onTap:()=>FocusScope.of(context).unfocus(),
      child: BlocBuilder<ChatHomeBloc, ChatHomeState>(
  builder: (context, state) {
    return WillPopScope(
        onWillPop: (){
          if(BlocProvider.of<ChatHomeBloc>(context).state.isSearching){
            BlocProvider.of<ChatHomeBloc>(context).add(NotIsSearching());
            return Future.value(false);
          }else{return Future.value(true);}

        },
        child: Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: IconButton(onPressed: (){Navigator.pop(context);},icon: Icon(Icons.arrow_back),),
              ),
              title: BlocProvider.of<ChatHomeBloc>(context).state.isSearching?Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TextField(
                  onChanged: (val) {
                    //search logic
                    BlocProvider.of<ChatHomeBloc>(context).add(ClearSearchList());
                    if(_list!=null&&_list.isNotEmpty){
                      for (var i in _list) {
                        if (i.name != null && i.email != null &&
                            (i.name!.toLowerCase().contains(val.toLowerCase()) ||
                                i.email!.toLowerCase().contains(val.toLowerCase()))) {
                          BlocProvider.of<ChatHomeBloc>(context).add(AddSearchList(user: i));
                        }
                        else{
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
              ):const Text('Chats',style: TextStyle(fontSize: 24),),
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
                        BlocProvider.of<ChatHomeBloc>(context).add(NotIsSearching());
                        BlocProvider.of<ChatHomeBloc>(context).add(ClearSearchList());
                      },
                      icon: Icon(BlocProvider.of<ChatHomeBloc>(context).state.isSearching?Icons.clear:Icons.search),
                    )),
                SizedBox(
                  width: 15,
                ),
                Container(
                  //width: 40,
                  //height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me)));
                      },
                      icon: Icon(Icons.more_vert,)),),
                SizedBox(
                  width: 15,
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  onPressed: () async {
                    await APIs.auth.signOut();
                    await GoogleSignIn().signOut();
                  },
                  backgroundColor: Colors.grey[850],
                  child: Icon(Icons.add_comment_rounded)),
            ),
            body: Container(
              color: Colors.black,
              padding: EdgeInsets.fromLTRB(0, mq.height * 0.02, 0, 0),
              child: StreamBuilder(
                  stream: APIs.firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        {
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];
                          if(APIs.auth.currentUser != null) {
                            _list.removeWhere((user) => user.id == APIs.auth.currentUser?.uid);
                          }else{
                            Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        }
                        if(BlocProvider.of<ChatHomeBloc>(context).state.isSearching)
                        {
                          if (List.of(BlocProvider.of<ChatHomeBloc>(context).state.searchList).isNotEmpty) {
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: List.of(BlocProvider.of<ChatHomeBloc>(context).state.searchList).length,
                                itemBuilder: (context, index) {
                                  return List.of(BlocProvider.of<ChatHomeBloc>(context).state.searchList).length==0?Center(
                                    child: CircularProgressIndicator(),
                                  ):ChatUserCard(user: List.of(BlocProvider.of<ChatHomeBloc>(context).state.searchList)[index]);
                                });
                          } else {
                            return const Center(
                              child: Text(
                                '',
                                style: TextStyle(color: Colors.white70,fontSize: 19),
                              ),
                            );
                          }
                        }else{
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  return ChatUserCard(user: _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text(
                                'Hiện không có cuộc trò chuyện nào',
                                style: TextStyle(color: Colors.white70,fontSize: 19),
                              ),
                            );
                          }
                        }

                    }
                  }),
            )
        ),
      );
  },
),
    ),
);
  }
}
