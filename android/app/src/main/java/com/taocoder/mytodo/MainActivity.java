package com.taocoder.mytodo;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Bundle;
import android.os.SystemClock;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {

  private static final String CHANNEL = "com.taocoder.todo/alarm";
  private static final String GREETCHANNEL = "com.taocoder.todo/greet";

  private static FlutterEngine engine;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), GREETCHANNEL).setMethodCallHandler(this);
    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(this);
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    engine = flutterEngine;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {

    switch (call.method) {
      case "greet":
        sayHi(result);
        break;

      case "setReminder":
        setReminder(call, result);
        break;

      default:
        result.notImplemented();
    }
  }

  public static void notifyFlutter() {
    MethodChannel channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
    channel.invokeMethod("taskToday", null);
  }

  private void sayHi(MethodChannel.Result result) {
    Map<String, String> map = new HashMap<>();
    map.put("greet", "This is still a beginning");
    result.success(map);
  }

  private void setReminder(MethodCall call, MethodChannel.Result result) {

    Object hashMap = (Object) call.arguments;
    HashMap map = (HashMap) hashMap;

    if (hashMap != null) {

      Calendar  calendar = Calendar.getInstance();
      String date = (String) map.get("date");
      String time = (String) map.get("time");

      String[] dArr = date.split("-");
      String[] tArr = time.split(":");

      int year = Integer.parseInt(dArr[0]);
      int month = Integer.parseInt(dArr[1]);
      int day = Integer.parseInt(dArr[2]);

      int hour = Integer.parseInt(tArr[0]);
      int minute = Integer.parseInt(tArr[1]);

      calendar.set(year, month - 1, day, hour, minute);
      createReminder(result, calendar.getTimeInMillis());
    }
    else {
      result.error("Error", "This need parameter is not found", null);
    }
  }

  private void createReminder(MethodChannel.Result result, long delay) {

      Intent intent = new Intent(this, AlarmReceiver.class);

      PendingIntent pendingIntent = PendingIntent.getBroadcast(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
      AlarmManager alarmManager = (AlarmManager) getSystemService(ALARM_SERVICE);

      if (alarmManager != null) {
          alarmManager.set(AlarmManager.RTC_WAKEUP, delay, pendingIntent);
          result.success("created");
      }
      else {
          result.success("error");
      }
  }
}