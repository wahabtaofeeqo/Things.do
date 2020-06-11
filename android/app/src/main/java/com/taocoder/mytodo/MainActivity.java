package com.taocoder.mytodo;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.SystemClock;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.taocoder.todo/alarm";
  public static final String CHANNEL_ID = "10001";
  private static FlutterEngine engine;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);

    engine = flutterEngine;
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
    .setMethodCallHandler((call, result) -> {
      if (call.method.equals("getBatteryLevel")) {

        int batteryLevel = getBatteryLevel();
        if (batteryLevel != -1) {
          result.success(batteryLevel);
        }
        else {
          result.error("UNAVAILABLE", "Battery Level not available", null);
        }
      }
      else if(call.method.equals("createAlarm")) {

        // Get parameter
        String params = (String) call.arguments;
        String[] arr = params.split(" ");

        // Date
        int year = Integer.parseInt(arr[0]);
        int month = Integer.parseInt(arr[1]);
        int day = Integer.parseInt(arr[2]);

        // Time
        int hour = Integer.parseInt(arr[3]);
        int minute = Integer.parseInt(arr[4]);

        Calendar calendar = Calendar.getInstance();
        calendar.set(year, month - 1, day, hour - 1, minute);

        //setReminderDate(calendar.getTimeInMillis());


        scheduleNotification(getNotification(), calendar.getTimeInMillis());
        result.success(true);
      }
      else {
        result.notImplemented();
      }
    });
  }

  private void setReminderDate(long delay) {
    AlarmManager alarmManager = (AlarmManager) getSystemService(ALARM_SERVICE);
    if (alarmManager != null) {

      Intent intent = new Intent(this, AlarmReceiver.class);

    }
  }


  private int getBatteryLevel() {
    int batterLevel = -1;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
      batterLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
    }
    else {
      Intent intent = new ContextWrapper(getApplicationContext()).registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
      batterLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
              intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);

    }
    return  batterLevel;
  }

  private void scheduleNotification(Notification notification, long delay) {
    Intent intent = new Intent(this, AlarmReceiver.class);
    intent.putExtra(AlarmReceiver.NOTIFICATION, notification);
    intent.putExtra(AlarmReceiver.NOTIFICATION_ID, 1);

    PendingIntent pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    AlarmManager alarmManager = (AlarmManager) getSystemService(ALARM_SERVICE);
    assert  alarmManager != null;
    alarmManager.set(AlarmManager.RTC_WAKEUP, delay, pendingIntent);
  }

  private Notification getNotification() {
    NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "default");
    builder.setContentTitle("Alarm");
    builder.setContentText("Hello World!");
    builder.setSmallIcon(R.drawable.ic_announcement);
    builder.setAutoCancel(true);
    builder.setChannelId(CHANNEL_ID);
    return  builder.build();
  }

  public static void notifyFlutter() {
    MethodChannel channel = new MethodChannel(engine.getDartExecutor(), CHANNEL);
    channel.invokeMethod("taskToday", "Task");
  }
}