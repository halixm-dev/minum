plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    kotlin("android")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

}

android {
    namespace = "com.halixm.minum"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.halixm.minum"
        minSdk = 33
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        targetSdk = 35
        versionCode = 1 // CRUCIAL: Your application's version code
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    buildToolsVersion = "36.0.0"

    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}
