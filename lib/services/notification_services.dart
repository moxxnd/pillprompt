import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> postRequest(String title, String content) async {
  final token = await FirebaseMessaging.instance.getToken();
  var url = Uri.parse("http://3.37.208.162:8080/notification");

  debugPrint("토큰 $token");

  if (token == null) {
    debugPrint("토큰을 가져오지 못했습니다.");
    return;
  }

  var body = json.encode({
    'token': token,
    'title': title,
    'body': content,
  });

  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    debugPrint("POST 요청 완료: ${response.body}");
  } else {
    debugPrint("POST 요청 오류: ${response.statusCode}");
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_notification_channel_id', // 채널 ID
    'your_app_name', // 채널 이름
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> showNotification(int id, String title, String body) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          'pillprompt_notification_channel', 'pillprompt',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const Color.fromARGB(255, 255, 0, 0);

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
      id, title, body, notificationDetails);
}

Future<void> onMessageHandler(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    String title = notification.title ?? '제목 없음';
    String body = notification.body ?? '내용 없음';
    await showNotification(0, title, body);
  }
}
