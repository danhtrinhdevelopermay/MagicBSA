# Build Compatibility Matrix

## Current Working Configuration (July 29, 2025)

| Component | Version | Reason |
|-----------|---------|---------|
| **Gradle** | 7.6.3 | Stable with AGP 7.4.2, avoids Kotlin DSL issues |
| **Android Gradle Plugin** | 7.4.2 | Compatible with Gradle 7.6.3, stable release |
| **Kotlin** | 1.8.22 | Updated to available version, compatible with Flutter 3.22.0 and AGP 7.4.2 |
| **Java** | 17 | Required for AGP 7.4.2 + SDK 33, current LTS |
| **Compile SDK** | 33 | Stable API level, good compatibility |
| **Target SDK** | 33 | Matches compile SDK for consistency |

## Previous Failed Configurations

### Configuration 1 (Failed)
- Gradle 8.0 + AGP 8.1.4 + Kotlin 1.9.10 + Java 17
- **Issues**: Maven resource missing, compile avoidance warnings

### Configuration 2 (Failed)  
- Gradle 8.0 + AGP 8.1.0 + Kotlin 1.8.22 + Java 17
- **Issues**: Plugin compatibility, network timeout errors

## Build Performance Settings

| Setting | Value | Reason |
|---------|-------|---------|
| `org.gradle.parallel` | false | Avoid race conditions in CI |
| `org.gradle.configureondemand` | false | More reliable builds |
| `org.gradle.caching` | false | Avoid cache corruption issues |
| `org.gradle.jvmargs` | -Xmx2G | Conservative memory allocation |

## Repository Order (Priority)

1. `google()` - Primary Android dependencies
2. `mavenCentral()` - Standard Java/Kotlin libraries  
3. `repo1.maven.org/maven2` - Backup for Central
4. `jcenter.bintray.com` - Legacy fallback
5. `maven.google.com` - Google backup

This configuration prioritizes **stability over performance** for CI builds.