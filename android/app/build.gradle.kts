plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.lisa.assistant"

    // compileSdk কে flutter এর default (এখন 36) এ ফিরিয়ে রাখা হয়েছে।
    // কারণ androidx.core এর নতুন version (flutter_local_notifications,
    // permission_handler এর মাধ্যমে আসছে) compileSdk 36+ দাবি করে —
    // compileSdk 34 এ আটকে রাখলে build error হয়।
    //
    // compileSdk শুধু build-time এ কোন API ব্যবহার করা যাবে তা নির্ধারণ
    // করে, এটা runtime behavior পরিবর্তন করে না — তাই এটা বাড়ালে
    // crash এর ঝুঁকি নেই।
    //
    // targetSdk আলাদাভাবে 34 এ পিন করা আছে (নিচে defaultConfig এ),
    // কারণ targetSdk বাড়ালে Android নতুন runtime behavior enforce
    // করে (permission, background restriction ইত্যাদি), যা পুরনো
    // ফোন ও plugin গুলোর সাথে compatibility সমস্যা করতে পারত।
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
        applicationId = "com.lisa.assistant"

        minSdk = flutter.minSdkVersion

        // targetSdk স্থিরভাবে 34 (Android 14) রাখা হয়েছে — এটাই
        // সবচেয়ে stable ও widely-compatible target বর্তমানে।
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
