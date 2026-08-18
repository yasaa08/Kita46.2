plugins {
    id("com.android.application")
    id("kotlin-android")
    // TAMBAHKAN BARIS DI BAWAH INI (WAJIB)
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

// Signing configuration - menggunakan keystore yang sudah di-generate
val keystorePath = file("${rootProject.projectDir}/app/release.keystore")
val ksStorePassword = "kita462barokah"
val ksKeyPassword = "kita462barokah"
val ksKeyAlias = "kita462"

android {
    namespace = "com.example.kita_46_2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.kita462.quran"
        // UBAH minSdkVersion JADI 21 (WAJIB BUAT FIREBASE)
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = keystorePath
            storePassword = ksStorePassword
            keyPassword = ksKeyPassword
            keyAlias = ksKeyAlias
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
