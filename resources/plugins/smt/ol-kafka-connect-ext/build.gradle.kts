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
    implementation("io.openlineage:openlineage-java:1.37.0")

    compileOnly("org.apache.kafka:connect-api:3.6.1")
    compileOnly("org.apache.kafka:connect-runtime:3.6.1")
    compileOnly("org.slf4j:slf4j-api:2.0.13")
    compileOnly("io.confluent:kafka-avro-serializer:7.6.1")

    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(17)
}

tasks.shadowJar {
    archiveBaseName.set("openlineage-kafka-connect-smt")
    archiveClassifier.set("")
    archiveVersion.set("1.0")
    from(sourceSets.main.get().resources)
}

tasks.jar {
    enabled = false
}

tasks.test {
    useJUnitPlatform()
}
