import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/profile/bloc/profile_bloc.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  appBarIconButton(Icon icon, int index) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () {},
          icon: icon,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: GestureDetector(
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
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 24),
              ),
              backgroundColor: Colors.black,
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  Dialogs.showProgressBar(context);
                  await APIs.updateActiveStatus(false);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {});
                    //pop dialogs
                    Navigator.pop(context);
                    //pop homescreen
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => SplashScreen()));
                  });
                },
                backgroundColor: Colors.red,
                icon: Icon(Icons.logout),
                label: Text('Đăng xuất'),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: mq.width * 0.06,
                        vertical: mq.height * 0.02),
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            SizedBox(
                              width: mq.width,
                              height: mq.height * 0.01,
                            ),
                            Stack(children: [
                              (BlocProvider.of<ProfileBloc>(context).state.image == null
                                  || BlocProvider.of<ProfileBloc>(context).state.image == "")
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * 0.1),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: mq.height * 0.2,
                                        height: mq.height * 0.2,
                                        imageUrl: widget.user.image.toString(),
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const CircleAvatar(
                                                child: Icon(
                                                    Icons.person_outlined)),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          mq.height * 0.1),
                                      child: Image.file(
                                        File(BlocProvider.of<ProfileBloc>(
                                                context)
                                            .state
                                            .image),
                                        fit: BoxFit.cover,
                                        width: mq.height * 0.2,
                                        height: mq.height * 0.2,
                                      ),
                                    ),
                              Positioned(
                                bottom: -5,
                                right: -25,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: MaterialButton(
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      showModalBottomSheet(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          context: context,
                                          builder: (_) {
                                            return Container(
                                              color: Colors.grey[850],
                                              height: mq.height * 0.3,
                                              child: ListView(
                                                padding: EdgeInsets.only(
                                                    top: mq.height * 0.02),
                                                children: [
                                                  Text(
                                                    'Chọn ảnh đại diện',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: mq.height * 0.03),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    shape:
                                                                        CircleBorder(),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black,
                                                                    fixedSize: Size(
                                                                        mq.width *
                                                                            0.3,
                                                                        mq.height *
                                                                            0.15)),
                                                                onPressed:
                                                                    () async {
                                                                  final ImagePicker
                                                                      picker =
                                                                      ImagePicker();
                                                                  final XFile?
                                                                      image =
                                                                      await picker.pickImage(
                                                                          source: ImageSource
                                                                              .gallery,
                                                                          imageQuality:
                                                                              80);
                                                                  if (image !=
                                                                      null) {
                                                                    BlocProvider.of<ProfileBloc>(
                                                                            context)
                                                                        .add(NewImageFromGallery(
                                                                            image.path));
                                                                    APIs.updateProfilePicture(
                                                                        File(image
                                                                            .path));
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                },
                                                                child:
                                                                    Image.asset(
                                                                  'images/add_image.png',
                                                                  color: Colors
                                                                      .white70,
                                                                )),
                                                            SizedBox(
                                                                height:
                                                                    mq.height *
                                                                        0.01),
                                                            Text(
                                                              'Thư viện',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 16),
                                                            )
                                                          ],
                                                        ),
                                                        //SizedBox(width: mq.width*0.1,),
                                                        Column(
                                                          children: [
                                                            ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    shape:
                                                                        CircleBorder(),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black,
                                                                    fixedSize: Size(
                                                                        mq.width *
                                                                            0.3,
                                                                        mq.height *
                                                                            0.15)),
                                                                onPressed:
                                                                    () async {
                                                                  final ImagePicker
                                                                      picker =
                                                                      ImagePicker();
                                                                  final XFile?
                                                                      image =
                                                                      await picker.pickImage(
                                                                          source:
                                                                              ImageSource.camera);
                                                                  if (image !=
                                                                      null) {
                                                                    log('Image Path : ${image.path} -- MimeType:${image.mimeType}');
                                                                    BlocProvider.of<ProfileBloc>(context).add(NewImageFromCamera(image.path));
                                                                    APIs.updateProfilePicture(
                                                                        File(image.path));
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                },
                                                                child:
                                                                    Image.asset(
                                                                  'images/camera.png',
                                                                  color: Colors
                                                                      .white70,
                                                                )),
                                                            SizedBox(
                                                                height:
                                                                    mq.height *
                                                                        0.01),
                                                            Text(
                                                              'Camera',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 16),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    color: Colors.grey[850],
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ]),
                            SizedBox(
                              width: mq.width,
                              height: mq.height * 0.015,
                            ),
                            Text(
                              widget.user.email.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              height: mq.height * 0.05,
                            ),
                            TextFormField(
                              onSaved: (val) => APIs.me.name = val,
                              validator: (val) => val != null && val.isNotEmpty
                                  ? null
                                  : 'Required Field',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                hintText: 'Tên',
                                hintStyle: TextStyle(color: Colors.white70),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 15,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.lightBlue),
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              initialValue: widget.user.name,
                            ),
                            SizedBox(
                              height: mq.height * 0.03,
                            ),
                            TextFormField(
                              onSaved: (val) => APIs.me.about = val,
                              validator: (val) => val != null && val.isNotEmpty
                                  ? null
                                  : 'Required Field',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[850],
                                hintText: 'Tên',
                                hintStyle: TextStyle(color: Colors.white70),
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12,
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.lightBlue),
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              initialValue: widget.user.about,
                            ),
                            SizedBox(
                              height: mq.height * 0.04,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  log('Thoa man');
                                  _formKey.currentState!.save();
                                  APIs.updateUserInfo();
                                  Dialogs.showSnackBar(
                                      context, 'Lưu thông tin thành công !');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  minimumSize:
                                      Size(mq.width * 0.5, mq.height * 0.07)),
                              icon: const Icon(
                                Icons.edit,
                                size: 28,
                              ),
                              label: const Text(
                                'Chỉnh sửa',
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
//void _showBottomSheet() {}
