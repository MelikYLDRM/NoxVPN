# =====================================================================
# Nox VPN - ProGuard / R8 kuralları
# =====================================================================

# --- Flutter framework ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- WireGuard tunnel kütüphanesi ---
-keep class com.wireguard.** { *; }
-keep class com.wireguard.android.backend.** { *; }
-keep class com.wireguard.config.** { *; }
-keep class com.wireguard.crypto.** { *; }

# --- Bizim VPN servisi ve native köprü ---
-keep class com.melikyldrm.noxvpn.vpn.** { *; }

# Native metodlar
-keepclasseswithmembernames class * {
    native <methods>;
}

# Google Play Core (in-app updates)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# javax.annotation (WireGuard NonNullForAll referansı)
-dontwarn javax.annotation.**
-dontwarn javax.annotation.meta.**

# Ağ kütüphaneleri (uyarı bastırma)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**

# =====================================================================
# GÜVENLİK SERTLEŞTİRMESİ
# =====================================================================

# Release build'de TÜM Log.* çağrılarını kaldır — hassas veri sızıntısını
# (anahtar, endpoint, kullanıcı IP) önler.
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** wtf(...);
    public static *** println(...);
}

# Stacktrace'leri okunabilir tut (Crashlytics / Play Console için)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Anotasyonlar
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
