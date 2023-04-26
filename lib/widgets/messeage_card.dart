import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showModalBottomSheet(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            context: context,
            builder: (_) {
              return Container(
                padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                color: Colors.grey[850],
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: mq.height * 0.02),
                  children: [
                    /*Container(
                  height: 0,
                  margin: EdgeInsets.symmetric(vertical: mq.height*0.015,horizontal: mq.width*0.4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),*/
                    //Divider(height: 1,color: Colors.white70,),
                    widget.message.type == Type.text
                        ? _OptionItem(
                            icon: Icon(
                              Icons.copy,
                              color: Colors.blue,
                            ),
                            name: 'Sao chép',
                            onTap: () async {
                              await Clipboard.setData(
                                      ClipboardData(text: widget.message.msg))
                                  .then((value) {
                                Navigator.pop(context);
                                Dialogs.showSnackBar(
                                    context, 'Copy: "${widget.message.msg}"');
                              });
                            })
                        : _OptionItem(
                            icon: Icon(
                              Icons.download,
                              color: Colors.blue,
                            ),
                            name: 'Tải xuống',
                            onTap: () {}),
                    Divider(
                      height: 1,
                      color: Colors.white70,
                    ),
                    if (isMe)
                      _OptionItem(
                          icon: Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          name: 'Xóa bỏ',
                          onTap: () async {
                            await APIs.deleteMessage(widget.message)
                                .then((value) {
                              Navigator.pop(context);
                              Dialogs.showSnackBar(context, 'Đã xóa !');
                            });
                          }),
                    if (isMe)
                      Divider(
                        height: 1,
                        color: Colors.white70,
                      ),
                    _OptionItem(
                        icon: Icon(Icons.send, color: Colors.blue),
                        name:
                            'Gửi lúc : ${MyDateUtil.getTime(context: context, ftime: widget.message.sent.toString())}',
                        onTap: () {}),
                    _OptionItem(
                        icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                        name: widget.message.read!.isNotEmpty
                            ? 'Xem lúc : ${MyDateUtil.getTime(context: context, ftime: widget.message.read.toString())}'
                            : 'Chưa xem',
                        onTap: () {}),
                  ],
                ),
              );
            });
      },
      child: (isMe&&widget.message.type!=Type.voice) ? _greyMessage() : (isMe&&widget.message.type==Type.voice)?GreyVoiceMessage(message: widget.message):(!isMe&&widget.message.type==Type.voice)?BlackVoiceMessage(message: widget.message):_blackMessage(),
    );
  }
  Widget _blackMessage() {
    if (widget.message.read!.isEmpty) {
      APIs.upDateReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white),
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child: (widget.message.type == Type.image)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      //width: mq.height * 0.2,
                      //height: mq.height * 0.2,
                      imageUrl: widget.message.msg.toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: 70,
                      )),
                    ),
                  )
                : ((widget.message.type == Type.text)
                    ? Text(
                        widget.message.msg.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : BlocProvider(
                        create: (context) => ChatBloc(),
                        child: BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            return Container(
                              height: mq.height*0.05,
                              width: mq.width*0.3,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final player = AudioPlayer();
                                      try {
                                        // Thiết lập nguồn phát
                                        await player
                                            .setUrl(widget.message.msg.toString());
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(IsPlayRecord());
                                        // Bắt đầu phát
                                        await player.play();
                                        await player.stop();
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(NotIsPlayRecord());
                                      } catch (e) {
                                        // Xử lý lỗi
                                        print("Error: $e");
                                      }
                                    },
                                    icon: Icon((BlocProvider.of<ChatBloc>(context).state.isPlayRecord) ? Icons.pause : Icons.play_arrow),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent.toString()),
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        )
      ],
    );
  }

  Widget _greyMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: mq.width * 0.04),
          child: Row(
            children: [
              if (widget.message.read!.isNotEmpty)
                const Icon(
                  Icons.done_all,
                  size: 20,
                ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent.toString()),
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              //border: Border.all(color: Colors.white),
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child: (widget.message.type == Type.image)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      //width: mq.height * 0.2,
                      //height: mq.height * 0.2,
                      imageUrl: widget.message.msg.toString(),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                        Icons.image,
                        size: 70,
                      )),
                    ),
                  )
                : Text(widget.message.msg.toString(), style: TextStyle(color: Colors.white, fontSize: 16),)
          ),
        ),
      ],
    );
  }
  }

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ))
          ],
        ),
      ),
    );
  }
}
class GreyVoiceMessage extends StatefulWidget {
  final Message message;

  const GreyVoiceMessage({Key? key, required this.message}) : super(key: key);

  @override
  _GreyVoiceMessageState createState() => _GreyVoiceMessageState();
}

class _GreyVoiceMessageState extends State<GreyVoiceMessage> {
  late final AudioPlayer _player;
   late Duration _duration;
   bool isLoading=true;
   String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    initAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> initAudio() async {
    try {
      await _player.setUrl(widget.message.msg.toString());
      setState(() {
        isLoading=false;
        _duration = _player.duration!;
        _currentUrl=widget.message.msg;
      });
    } catch (e) {
      //Dialogs.showSnackBar(context, 'Lỗi tải âm thanh');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: mq.width * 0.04),
          child: Row(
            children: [
              if (widget.message.read!.isNotEmpty)
                const Icon(
                  Icons.done_all,
                  size: 20,
                ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent.toString()),
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              //border: Border.all(color: Colors.white),
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child: BlocProvider(
              create: (context) => ChatBloc(),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
    if (_currentUrl != widget.message.msg.toString()) {
    _currentUrl = widget.message.msg.toString();
    initAudio();
    return CircularProgressIndicator();
    } else {
                  return (isLoading)?CircularProgressIndicator():Container(
                    height: mq.height* 0.05,
                    width: mq.width * 0.3,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (BlocProvider.of<ChatBloc>(context).state.isPlayRecord) {
                              BlocProvider.of<ChatBloc>(context).add(IsPlayRecord());
                            } else {
                              BlocProvider.of<ChatBloc>(context).add(IsPlayRecord());
                              await _player.play();
                              await _player.stop();
                              BlocProvider.of<ChatBloc>(context)
                                  .add(NotIsPlayRecord());
                            }
                          },
                          icon: Icon((BlocProvider.of<ChatBloc>(context).state.isPlayRecord) ? Icons.pause : Icons.play_arrow),
                        ),
                        Text(
                          '${_duration.inMinutes.remainder(60)}:${_duration.inSeconds.remainder(60)}',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }}
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class BlackVoiceMessage extends StatefulWidget {
  final Message message;

  const BlackVoiceMessage({Key? key, required this.message}) : super(key: key);

  @override
  _BlackVoiceMessageState createState() => _BlackVoiceMessageState();
}

class _BlackVoiceMessageState extends State<BlackVoiceMessage> {
  late final AudioPlayer _player;
  late Duration _duration;
  bool isLoading = true;
  String? _currentUrl;

  @override
  void initState() {
    if (widget.message.read!.isEmpty) {
      APIs.upDateReadStatus(widget.message);}
    super.initState();
    _player = AudioPlayer();
    initAudio();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> initAudio() async {
    try {
      await _player.setUrl(widget.message.msg.toString());
      setState(() {
        isLoading = false;
        _duration = _player.duration!;
        _currentUrl=widget.message.msg;
      });
    } catch (e) {
      //Dialogs.showSnackBar(context, 'Lỗi tải âm thanh');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white),
            ),
            padding: EdgeInsets.all(mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            child: BlocProvider(
              create: (context) => ChatBloc(),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
    if (_currentUrl != widget.message.msg.toString()) {
    _currentUrl = widget.message.msg.toString();
    initAudio();
    return CircularProgressIndicator();
    } else {
                  return (isLoading) ? CircularProgressIndicator() : Container(
                    height: mq.height * 0.05,
                    width: mq.width * 0.3,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            if (BlocProvider
                                .of<ChatBloc>(context)
                                .state
                                .isPlayRecord) {
                              BlocProvider.of<ChatBloc>(context).add(
                                  IsPlayRecord());
                            } else {
                              BlocProvider.of<ChatBloc>(context).add(
                                  IsPlayRecord());
                              await _player.play();
                              await _player.stop();
                              BlocProvider.of<ChatBloc>(context)
                                  .add(NotIsPlayRecord());
                            }
                          },
                          icon: Icon((BlocProvider
                              .of<ChatBloc>(context)
                              .state
                              .isPlayRecord)
                              ? Icons.pause
                              : Icons.play_arrow),
                        ),
                        Text(
                          '${_duration.inMinutes.remainder(
                              60)}:${_duration.inSeconds.remainder(60)}',
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }}
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Row(
            children: [
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent.toString()),
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

