import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/chat/bloc/chat_bloc.dart';
import 'package:chat_app/screens/friend_profile_screen.dart';
import 'package:chat_app/widgets/messeage_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../api/apis.dart';
import '../../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);


  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
  List<Message> _list = [];
  final _textController = TextEditingController();
  Record? record;
  //File? file;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return WillPopScope(
              onWillPop: () {
                if (BlocProvider.of<ChatBloc>(context).state.showEmoji) {
                  BlocProvider.of<ChatBloc>(context).add(NotShowEmoji());
                  return Future.value(false);
                } else
                  return Future.value(true);
              },
              child: Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  title: StreamBuilder(
                      stream: APIs.getUserInfo(widget.user),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.docs;
                        final list = data
                                ?.map((e) => ChatUser.fromJson(e.data()))
                                .toList() ??
                            [];
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.03),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: mq.height * 0.045,
                                height: mq.height * 0.045,
                                imageUrl: list.isNotEmpty
                                    ? list[0].image.toString()
                                    : widget.user.image.toString(),
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                        child: Icon(Icons.person_outlined)),
                              ),
                            ),
                            SizedBox(
                              width: mq.width * 0.04,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (list.isNotEmpty
                                          ? list[0].name.toString()
                                          : widget.user.name.toString())
                                      .split(' ')
                                      .last,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: mq.height * 0.002),
                                Text(
                                  list.isNotEmpty
                                      ? list.first.isOnline == true
                                          ? 'Đang hoạt động'
                                          : MyDateUtil.getLastActiveTime(
                                              context: context,
                                              lastActive: list![0]
                                                  .lastActive
                                                  .toString())
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive: widget.user.lastActive
                                              .toString()),
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                  actions: [
                    IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FriendProfileScreen(user: widget.user))),
                        icon: Icon(
                          Icons.info,
                          size: 28,
                        )),
                    SizedBox(
                      width: mq.width * 0.03,
                    )
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: APIs.getAllMessages(widget.user),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const SizedBox();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                _list = data
                                        ?.map((e) => Message.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                if (_list.isNotEmpty) {
                                  return ListView.builder(
                                      reverse: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: _list.length,
                                      itemBuilder: (context, index) {
                                        return MessageCard(
                                          message: _list[index],
                                        );
                                      });
                                } else {
                                  //log('${_list.length}');
                                  return const Center(
                                    child: Text(
                                      'Hãy bắt đầu trò chuyện với nhau nào 👋',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 19),
                                    ),
                                  );
                                }
                            }
                          }),
                    ),
                    if (BlocProvider.of<ChatBloc>(context).state.isUploadImage)
                      const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 20, 5),
                            child: CircularProgressIndicator(),
                          )),
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
                                    if (BlocProvider.of<ChatBloc>(context)
                                            .state
                                            .isTyping ==
                                        false)
                                      IconButton(
                                          onPressed: () async {
                                            final ImagePicker picker = ImagePicker();
                                            final XFile? image = await picker.pickImage(source: ImageSource.camera);
                                            if (image != null) {
                                              log('Image Path : ${image.path} -- MimeType:${image.mimeType}');
                                              await APIs.sendChatImage(widget.user, File(image.path));
                                            }
                                          },
                                          iconSize: 25,
                                          icon: const Icon(
                                            Icons.camera_alt,
                                          )),
                                    if (BlocProvider.of<ChatBloc>(context).state.isTyping ==false)
                                      IconButton(
                                          onPressed: () async {
                                            final ImagePicker picker = ImagePicker();
                                            final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                                            if (images.isNotEmpty) {
                                              for (var image in images) {BlocProvider.of<ChatBloc>(context).add(NotUploadImage());
                                                log('Image Path : ${image.path} -- MimeType:${image.mimeType}');
                                                await APIs.sendChatImage(
                                                    widget.user,
                                                    File(image.path));
                                                BlocProvider.of<ChatBloc>(
                                                        context)
                                                    .add(NotUploadImage());
                                              }
                                            }
                                          },
                                          iconSize: 25,
                                          icon: const Icon(
                                            Icons.image,
                                          )),
                                    if (BlocProvider.of<ChatBloc>(context).state.isTyping ==false)
                                      GestureDetector(
                                          onLongPress: () async {
                                            Directory? appDir = await getExternalStorageDirectory();
                                            String dirPath = '${appDir!.path}/NTVChat/recordings';
                                            log('MyDirpath: $dirPath');
                                            String time=DateTime.now().millisecondsSinceEpoch.toString();
                                            await Directory(dirPath).create(recursive: true);
                                            String filePath = '$dirPath/$time.wav';
                                            record = Record();
                                            if (await record!.hasPermission()) {
                                              // Start recording
                                              await record!.start(
                                                path: filePath,
                                                encoder: AudioEncoder.wav, // by default
                                                bitRate: 128000, // by default
                                                samplingRate: 44100, // by default
                                              );
                                            }
                                          },
                                          onLongPressEnd: (details) async {
                                            String? path = await record!.stop();
                                            if (path != null) {
                                              log('My Voice Path : $path' );
                                              await APIs.sendChatVoice(widget.user, File(path));
                                            } else {
                                              log('Recording failed');
                                            }
                                          },
                                          child: const Icon(
                                            Icons.mic,
                                            size: 25,
                                          )),
                                    if (BlocProvider.of<ChatBloc>(context).state.isTyping ==true)
                                      IconButton(
                                          onPressed: () {
                                            BlocProvider.of<ChatBloc>(context)
                                                .add(NotIsTyping());
                                          },
                                          iconSize: 25,
                                          icon: const Icon(
                                            Icons.arrow_back_ios,
                                          )),
                                    Container(
                                      width: BlocProvider.of<ChatBloc>(context)
                                                  .state
                                                  .isTyping ==
                                              false
                                          ? mq.width * 0.43
                                          : mq.width * 0.615,
                                      //height: mq.height*0.05,
                                      //color: Colors.grey,
                                      child: TextField(
                                        onTap: () {
                                          if (BlocProvider.of<ChatBloc>(context).state.isTyping==false)
                                          BlocProvider.of<ChatBloc>(context).add(IsTyping());
                                          else BlocProvider.of<ChatBloc>(context).add(NotIsTyping());
                                          if (BlocProvider.of<ChatBloc>(context).state.showEmoji)
                                            BlocProvider.of<ChatBloc>(context).add(NotShowEmoji());
                                        },
                                        controller: _textController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintStyle: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 18),
                                          hintText: 'Tin nhắn',
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
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              BlocProvider.of<ChatBloc>(context)
                                                  .add(NotShowEmoji());
                                              //log('${BlocProvider.of<ChatBloc>(context).state.showEmoji}');
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              //BlocProvider.of<ChatBloc>(context).add(NotIsTyping());
                              if (_textController.text.isNotEmpty) {
                                if (BlocProvider.of<ChatBloc>(context)
                                    .state
                                    .showEmoji)
                                  BlocProvider.of<ChatBloc>(context)
                                      .add(NotShowEmoji());
                                if (_list.isEmpty) {
                                  APIs.sendMessage(widget.user,
                                      _textController.text, Type.text);
                                } else {
                                  APIs.sendMessage(widget.user,
                                      _textController.text, Type.text);
                                }
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
                    if (BlocProvider.of<ChatBloc>(context).state.showEmoji)
                      SizedBox(
                        height: mq.height * 0.3,
                        child: EmojiPicker(
                          textEditingController: _textController,
                          // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                          config: Config(
                            bgColor: Colors.black,
                            columns: 8,
                            emojiSizeMax: 32 *
                                (Platform.isIOS
                                    ? 1.30
                                    : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



