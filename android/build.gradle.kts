plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val rootBuild = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(rootBuild)

subprojects {
    layout.buildDirectory.set(rootBuild.dir(name))
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}