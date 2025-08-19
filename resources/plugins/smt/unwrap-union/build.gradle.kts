plugins {
    kotlin("jvm") version "2.1.20"
    id("com.github.johnrengelman.shadow") version "8.1.1"
}

group = "io.factorhouse"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
    maven("https://packages.confluent.io/maven/")
}

dependencies {
    implementation("org.apache.kafka:connect-api:3.9.0")
    implementation("io.confluent:kafka-connect-avro-converter:7.9.0")
    implementation("io.github.microutils:kotlin-logging-jvm:3.0.5")
    implementation("ch.qos.logback:logback-classic:1.5.13")
    testImplementation(kotlin("test"))
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
}

kotlin {
    jvmToolchain(17)
}

tasks.shadowJar {
    archiveClassifier.set("")
    archiveVersion.set("1.0")
    mergeServiceFiles()
    minimize()
    from("src/main/resources") {
        include("META-INF/**")
    }
}

tasks.test {
    useJUnitPlatform()
}
