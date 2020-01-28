package com.example.pothole;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
//import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
import io.flutter.plugins.MyPluginRegistrant;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.os.Bundle;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

public class Application extends FlutterActivity{

  /* @Override
  public void onCreate(Bundle savedInstances){
    super.onCreate(savedInstances);
    FlutterFirebaseMessagingService.setPluginRegistrant(this);
  }

  @Override
  public void registerWith(PluginRegistry registry) {
    MyPluginRegistrant.registerWith(registry);
  } */

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    FlutterFirebaseMessagingService.setPluginRegistrant(new PluginRegistrantCallback() {
      @Override
      public void registerWith(PluginRegistry registry) {
        final String key = FirebaseMessagingPlugin.class.getCanonicalName();
        if(!registry.hasPlugin(key))
          FirebaseMessagingPlugin.registerWith(registry.registrarFor(key));
      }
    });
  }
}