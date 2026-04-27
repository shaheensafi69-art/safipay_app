import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.safipay.app"
    compileSdk = flutter.compileSdkVersion
    
    // استفاده از نسخه NDK مورد نیاز پلاگین‌های جدید
    ndkVersion = "28.2.13676358" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // روش جدید تعریف jvmTarget برای جلوگیری از خطای Deprecated
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.safipay.app"
        minSdk = 21 // تغییر به 21 برای پشتیبانی بهتر از کتابخانه‌های جدید
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            // غیرفعال کردن برای حل مشکل کرش (Force Close) بعد از نصب
            isMinifyEnabled = false 
            isShrinkResources = false
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}