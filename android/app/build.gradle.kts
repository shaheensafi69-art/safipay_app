import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// خواندن اطلاعات شناسنامه رسمی SafiPay
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // شناسه رسمی برند شما
    namespace = "com.safipay.app"
    compileSdk = flutter.compileSdkVersion
    
    // اصلاح شده: استفاده از بالاترین نسخه مورد نیاز پلاگین‌ها برای جلوگیری از کرش
    ndkVersion = "28.2.13676358" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.safipay.app"
        minSdk = flutter.minSdkVersion // حداقل نسخه برای پشتیبانی بهتر از پلاگین‌ها
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // اضافه کردن برای پایداری در رندرینگ
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
        release {
            // فعال کردن امضای رسمی SafiPay
            signingConfig = signingConfigs.getByName("release")
            
            // بهینه‌سازی کد (اگر اپلیکیشن کرش کرد، این دو را false کن)
            isMinifyEnabled = false 
            isShrinkResources = false
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
