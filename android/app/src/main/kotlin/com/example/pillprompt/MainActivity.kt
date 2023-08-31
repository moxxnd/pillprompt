package com.example.pillprompt
import android.os.Bundle
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // 알림 채널을 생성합니다.
            val channel = NotificationChannel(
                "pillprompt_notification_channel",
                "Pill Prompt Notification Channel",
                NotificationManager.IMPORTANCE_HIGH
            )
            channel.description = "Pill Prompt 알림 채널"
            
            // 시스템에 알림 채널을 등록합니다.
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
