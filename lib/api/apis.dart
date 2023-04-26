import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/comment.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {
  //authentication-dang nhap
  static FirebaseAuth auth = FirebaseAuth.instance;

  //accessing cloud firebase database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //cloud
  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static get user => auth.currentUser!;

  //checking if users exit or not?
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> getMyInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        updateActiveStatus(true);
      } else {
        await createUser().then((value) {
          getMyInfo();
        });
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName,
      image: user.photoURL,
      email: user.email.toString(),
      about: 'Hello World!!!',
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: "",
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.${ext}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('UpdateProfile');
    });
    me.image = await ref.getDownloadURL();
    log('${me.image}');
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  static String getConversationID(String id) {
    return user.uid.hashCode <= id.hashCode
        ? '${user.uid}_$id'
        : '${id}_${user.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id.toString())}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore.collection(
        'chats/${getConversationID(chatUser.id.toString())}/messages/');
    await ref
        .doc(time)
        .set(message.toJson())
        .then((value) => sendPushNotification(
            chatUser,
            type == Type.text
                ? msg
                : (type == Type.voice)
                    ? 'Chat thoại'
                    : 'Hình ảnh'));
  }

  static Future<void> upPost(String textPost, String imageUrl) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Post myPost = Post(
      id: int.tryParse(time),
      userId: auth.currentUser?.uid,
      timePost: time,
      text: textPost,
      imageUrl: imageUrl,
      likedUserIds: [],
      //comments: [],
    );
    final ref = firestore.collection('posts/');
    await ref.doc(time).set(myPost.toJson());
    log('MyPost : $myPost');
  }

  static Future<void> upComment(String textComment, String postID) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Comment myComment = Comment(
      timeComment: time,
      userId: auth.currentUser?.uid,
      text: textComment,
      likedUserIds: [],
      postId: postID,
    );
    final ref = firestore
        .collection('posts')
        .doc(postID)
        .collection('comments')
        .doc(time);
    await ref.set(myComment.toJson());
    log('MyPost : $myComment');
  }

  static Future<void> likePost(Post post) async {
    final currentUserUid = APIs.auth.currentUser!.uid;
    final updatedLikedUserIds = List<String>.from(post.likedUserIds ?? []);

    if (updatedLikedUserIds.contains(currentUserUid)) {
      updatedLikedUserIds.remove(currentUserUid);
    } else {
      updatedLikedUserIds.add(currentUserUid);
    }

    await firestore
        .collection('posts')
        .doc(post.timePost)
        .update({'likedUserIds': updatedLikedUserIds});
  }

  static Future<void> likeComment(Comment comment) async {
    final currentUserUid = APIs.auth.currentUser!.uid;
    final updateLikeUserIds = List<String>.from(comment.likedUserIds ?? []);
    if (updateLikeUserIds.contains(currentUserUid)) {
      updateLikeUserIds.remove(currentUserUid);
    } else {
      updateLikeUserIds.add(currentUserUid);
    }
    await firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.timeComment)
        .update({'likedUserIds': updateLikeUserIds});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    return firestore
        .collectionGroup('post')
        .orderBy('timePost', descending: true)
        .snapshots();
  }

  static Future<void> upDateReadStatus(Message message) async {
    firestore
        .collection(
            'chats/${getConversationID(message.fromId.toString())}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id.toString())}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.${ext}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred : ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    log('${imageUrl}');
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> sendChatVoice(ChatUser chatUser, File file) async {
    try {
      final ext = file.path.split('.').last;
      final ref = storage.ref().child(
          'voices/${getConversationID(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext');
      final task =
          await ref.putFile(file, SettableMetadata(contentType: 'audio/$ext'));
      log('Data Transferred: ${task.bytesTransferred / 1000} kb');
      final voicePath = await ref.getDownloadURL();
      log('Voice URL: $voicePath');
      await APIs.sendMessage(chatUser, voicePath, Type.voice);
    } catch (e) {
      log('Error sending voice message: $e');
    }
  }

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('PushToken: $t');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    //var url = Uri.https('https://fcm.googleapis.com/fcm/send', 'whatsit/create');
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {"title": chatUser.name, "body": msg}
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAfUDX4ck:APA91bFnaXpUrTSkEUiqLNcYvfW7_QeAE7f_aXww7tPWe1HysG9WJ2WcEyOyzpvwer8SdKWHDVpq83jmGqtzyJnVsFvKUp995O_jwITAKCpJGRLUMMqfhuxps9Sg80yjoaIfG93gvGDH',
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nPushNotificationE : $e');
    }
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection(
            'chats/${getConversationID(message.toId.toString())}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image)
      await storage.refFromURL(message.msg.toString()).delete();
  }

  static Future<void> editMessage(Message message, String newMsg) async {
    await firestore
        .collection(
            'chats/${getConversationID(message.toId.toString())}/messages/')
        .doc(message.sent)
        .update({'msg': newMsg});
  }

  static Future<ChatUser> getUserFromId(String id) async {
    final snapshot =
        await firestore.collection('users').where('id', isEqualTo: id).get();
    final data = snapshot.docs.first.data();
    return ChatUser.fromJson(data);
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getListUnSeen() {
    return firestore
        .collection('chats/${getConversationID(user.id.toString())}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
