plugins {
    id("com.android.application")
    id("kotlin-android")
    // TAMBAHKAN BARIS DI BAWAH INI (WAJIB)
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

// Reading signing properties from key.properties
val keyPropertiesFile = rootProject.file("key.properties")
var ksStorePassword: String? = null
var ksKeyPassword: String? = null
var ksKeyAlias: String? = null
var ksStoreFilePath: String? = null

if (keyPropertiesFile.exists()) {
    val lines = keyPropertiesFile.readLines()
    for (line in lines) {
        val trimmed = line.trim()
        if (trimmed.isEmpty() || trimmed.startsWith("#")) continue
        val parts = trimmed.split("=", limit = 2)
        if (parts.size == 2) {
            when (parts[0].trim()) {
                "storePassword" -> ksStorePassword = parts[1].trim()
                "keyPassword" -> ksKeyPassword = parts[1].trim()
                "keyAlias" -> ksKeyAlias = parts[1].trim()
                "storeFile" -> ksStoreFilePath = parts[1].trim()
            }
        }
    }
}

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
            if (ksStoreFilePath != null) {
                val resolvedPath: String = if (ksStoreFilePath!!.startsWith("/")) {
                    ksStoreFilePath!!
                } else {
                    rootProject.file(ksStoreFilePath!!).absolutePath
                }
                storeFile = file(resolvedPath)
            }
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
