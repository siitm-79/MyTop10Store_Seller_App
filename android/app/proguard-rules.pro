## Keep Firebase messaging service classes if any are referenced indirectly
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

## Flutter and plugin reflective access safety
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.** { *; }

## Keep generated registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }