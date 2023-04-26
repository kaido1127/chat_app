
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/comment.dart';
import 'package:flutter/material.dart';

import '../main.dart';

 class CommentCard extends StatefulWidget {
   final Comment comment;
   const CommentCard({Key? key,required this.comment}) : super(key: key);

   @override
   State<CommentCard> createState() => _CommentCardState();
 }

 class _CommentCardState extends State<CommentCard> {
   ChatUser? _user;
   @override
   void initState() {
     super.initState();
     _loadUser();
   }

   Future<void> _loadUser() async {
     final user = await APIs.getUserFromId(widget.comment.userId.toString());
     setState(() {
       _user = user;
     });
   }
   @override
   Widget build(BuildContext context) {
     return _user==null?Container():Card(
       color: Colors.black,
       child: Row(
         children: [
           Expanded(
             child: ListTile(
               leading: CircleAvatar(backgroundImage: NetworkImage(_user!.image.toString()),),
               title: Row(
                 children: [
                   Text(_user!.name.toString(),
                     style:TextStyle(
                       color: Colors.white,
                       fontSize: 14,
                       fontWeight: FontWeight.bold),),
                   SizedBox(width: mq.width*0.05,),
                   Text(MyDateUtil.getTime(context: context, ftime: widget.comment.timeComment.toString()),
                     style:TextStyle(
                         color: Colors.white54,
                         fontSize: 14),),
                 ],
               ),
               subtitle: Padding(
                 padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                 child: Text(widget.comment.text.toString(),
                   style:TextStyle(
                       color: Colors.white,
                       fontSize: 14,),),
               ),
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(right: 10),
             child: Container(
               width: mq.width*0.07,
               child: Column(
                 children: [
                   InkWell(
                     onTap:()async{
                       await APIs.likeComment(widget.comment);
                     },
                     child: Icon(
                       (widget.comment.likedUserIds!.contains(APIs.auth.currentUser!.uid))?Icons.favorite:Icons.favorite_border,
                       color: (widget.comment.likedUserIds!.contains(APIs.auth.currentUser!.uid))?Colors.redAccent:Colors.white,
                       size: 19,
                     ),
                   ),
                   Text(
                     widget.comment.likedUserIds!.length.toString(),
                     style: TextStyle(color: Colors.white70),
                   ),

                 ],
               ),
             ),
           ),
         ],
       ),
     );
   }
 }
