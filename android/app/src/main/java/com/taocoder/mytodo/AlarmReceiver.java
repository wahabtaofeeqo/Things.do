package com.taocoder.mytodo;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

public class AlarmReceiver extends BroadcastReceiver {

    public static String NOTIFICATION = "notification";
    public static String NOTIFICATION_ID = "notificationID";
    private static final String CHANNEL_NAME = "channel name";

    @Override
    public void onReceive(Context context, Intent intent) {
//        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
//        Notification notification = intent.getParcelableExtra(NOTIFICATION);
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            int important = NotificationManager.IMPORTANCE_HIGH;
//            NotificationChannel channel = new NotificationChannel(MainActivity.CHANNEL_ID, CHANNEL_NAME, important);
//            assert notificationManager != null;
//            notificationManager.createNotificationChannel(channel);
//        }
//
//        int id = intent.getIntExtra(NOTIFICATION_ID, 0);
//        assert notificationManager != null;
//
//        notificationManager.notify(id, notification);

        MainActivity.notifyFlutter();
    }
}