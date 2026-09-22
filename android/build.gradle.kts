allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://devrepo.kakao.com/nexus/content/groups/public/") }
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
            credentials {
                username = "mapbox"
                password = "sk.eyJ1IjoiamhqYW5nMDcwMyIsImEiOiJjbXF6OGZrcnYwM243MnJzZWg4b2Zra2prIn0.AkadZrZgBN-fpUer2bifxQ"
            }
            authentication {
                create<BasicAuthentication>("basic")
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 36
            }
        }
    }
}

// mapbox_maps_flutter 3.x는 "AGP 9 이상이면 Kotlin 내장"이라고 가정해 kotlin-android를
// 적용하지 않는다. 하지만 다른 플러그인(flutter_tts, audio_session 등)이 kotlin-android를
// 직접 적용하기 때문에 이 프로젝트는 builtInKotlin=false를 유지해야 하므로, mapbox에만
// 플러그인을 대신 적용해준다.
subprojects {
    if (name == "mapbox_maps_flutter_mobile") {
        plugins.withId("com.android.library") {
            apply(plugin = "org.jetbrains.kotlin.android")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
