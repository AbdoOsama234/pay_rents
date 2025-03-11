buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0") // تأكد من تحديث نسخة Gradle
        classpath("com.google.gms:google-services:4.4.2") // هذه المكتبة لخدمات جوجل
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ضبط مسار `build` ليكون خارج `android`
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    project.evaluationDependsOn(":app") // هذا السطر يمكن إبقاؤه هنا
}

// تعريف مهمة `clean` لحذف الملفات المؤقتة
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
