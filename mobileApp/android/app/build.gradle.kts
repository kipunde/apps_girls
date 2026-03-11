plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.esrs_eqa_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.esrs_eqa_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            // debug signing for now; replace with your release keystore
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Rename release APK in Kotlin DSL
    applicationVariants.all {
        if (buildType.name == "release") {
            outputs.all {
                val newName = "EQA-App-v${versionName}.apk"
                (this as com.android.build.gradle.internal.api.BaseVariantOutputImpl).outputFileName = newName
            }
        }
    }
}

flutter {
    source = "../.."
}
