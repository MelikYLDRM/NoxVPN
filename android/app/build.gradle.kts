import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Imzalama anahtarı yükleme:
// 1) Önce ortam değişkenlerinden (CI/CD) okumayı dener.
// 2) Bulamazsa android/key.properties dosyasına düşer (yerel geliştirme).
// 3) Hiçbiri yoksa release debug imzayla derlenir (CI dostu).
// ---------------------------------------------------------------------------
fun loadSigning(): Properties? {
    val envStore = System.getenv("NOXVPN_KEYSTORE_PATH")
    val envStorePass = System.getenv("NOXVPN_KEYSTORE_PASSWORD")
    val envKeyAlias = System.getenv("NOXVPN_KEY_ALIAS")
    val envKeyPass = System.getenv("NOXVPN_KEY_PASSWORD")

    if (!envStore.isNullOrBlank() && !envStorePass.isNullOrBlank()
        && !envKeyAlias.isNullOrBlank() && !envKeyPass.isNullOrBlank()) {
        return Properties().apply {
            setProperty("storeFile", envStore)
            setProperty("storePassword", envStorePass)
            setProperty("keyAlias", envKeyAlias)
            setProperty("keyPassword", envKeyPass)
        }
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        return Properties().apply { load(keystorePropertiesFile.inputStream()) }
    }
    return null
}

val keystoreProperties: Properties? = loadSigning()

android {
    namespace = "com.melikyldrm.noxvpn"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.melikyldrm.noxvpn"
        minSdk = 24
        // Google Play (Aug 2025+): yeni uygulamalar için targetSdk 35 zorunlu.
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Yalnızca güncel mimariler için native lib paketle (boyut + 16 KB page).
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    signingConfigs {
        create("release") {
            keystoreProperties?.let { props ->
                keyAlias = props["keyAlias"] as String?
                keyPassword = props["keyPassword"] as String?
                storeFile = (props["storeFile"] as String?)?.let { file(it) }
                storePassword = props["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties != null)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            // Native debug semboller — Play Console crash analizinde kullanılır.
            ndk {
                debugSymbolLevel = "FULL"
            }
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
        }
    }

    // 16 KB page size uyumluluğu (Android 15+ Play Store gereksinimi)
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }

    bundle {
        language { enableSplit = true }
        density  { enableSplit = true }
        abi      { enableSplit = true }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // WireGuard Android tunnel — 16 KB page size uyumlu sürüm (Android 15+ Play Store gereksinimi).
    implementation("com.wireguard.android:tunnel:1.0.20260102")
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:app-update-ktx:2.1.0")
}
