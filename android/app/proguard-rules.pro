# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# WireGuard tunnel library
-keep class com.wireguard.** { *; }
-keep class com.wireguard.android.backend.** { *; }
-keep class com.wireguard.config.** { *; }
-keep class com.wireguard.crypto.** { *; }

# Keep our VPN service and channel
-keep class com.melikyldrm.noxvpn.vpn.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Google Play Core (referenced by Flutter deferred components)
-dontwarn com.google.android.play.core.**

# javax.annotation (referenced by WireGuard NonNullForAll)
-dontwarn javax.annotation.**
-dontwarn javax.annotation.meta.**

# Google Fonts / HTTP
-dontwarn okhttp3.**
-dontwarn okio.**
