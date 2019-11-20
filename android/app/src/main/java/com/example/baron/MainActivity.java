package com.saverl.baron;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import android.view.WindowManager;
import android.widget.Toast;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), "com.saverl.baron/awake").setMethodCallHandler(new MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("keepScreenAwake")) {
          keepScreenAwake();
          result.success("Done");
        } else if (call.method.equals("keepScreenNormal")) {
          keepScreenNormal();
          result.success("Done");
        } else if (call.method.equals("showToast")) {
          Toast.makeText(getApplicationContext() ,call.argument("text") ,Toast.LENGTH_SHORT).show();
          result.success("Done");
        } else {
          result.error("UNAVAILABLE", "Could not set It", null);
        }
      }
    });
  }

  private void keepScreenAwake() {
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
  }

  private void keepScreenNormal() {
    getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
  }
}
