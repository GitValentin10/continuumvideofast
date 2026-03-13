# APK Build Instructions

## Compilation Issue Investigation Summary

### Root Cause
The project was configured to use Java 21 (`sourceCompatibility` and `targetCompatibility` set to `JavaVersion.VERSION_21` in `app/build.gradle`), but the GitHub Actions workflow was using Java 17, causing compilation failures with the error:
```
error: invalid source release: 21
```

### Resolution
PR #7 updated `.github/workflows/build-apk.yml` to use Java 21 (Temurin distribution), which resolved the compilation issues. Subsequent workflow runs (#4 and #5) successfully built the APK.

## Building the APK Locally

### Prerequisites
- Java 21 (Temurin or equivalent)
- Android SDK
- Gradle (or use the included Gradle wrapper)

### Build Commands

#### Debug APK
```bash
./gradlew assembleDebug
```

The generated APK will be located at:
```
app/build/outputs/apk/debug/continuum-debug-<abi>-<version>.apk
```

#### Release APK
```bash
./gradlew assembleRelease
```

The generated APK will be located at:
```
app/build/outputs/apk/release/continuum-<abi>-<version>.apk
```

### ABI Variants
The project is configured to generate separate APKs for different ABIs:
- `armeabi-v7a` (32-bit ARM)
- `arm64-v8a` (64-bit ARM)

## APK Storage in Repository

The `.gitignore` file has been updated to allow APK files to be committed to the repository:
- Line 8 changed from `*.apk` to `# *.apk - Commented out to allow APK files to be committed`

## Sandbox Build Limitation

**Note**: Building the APK in the GitHub Actions sandbox environment failed due to network restrictions preventing access to required build dependencies from:
- `dl.google.com` (Android build tools)
- `jitpack.io` (JitPack Maven repository)

To add a built APK to the repository:
1. Build the APK locally using the instructions above
2. Copy the generated APK file to a desired location in the repository (e.g., `apk/` directory)
3. Commit and push the APK file

## GitHub Actions Workflow

The build workflow (`.github/workflows/build-apk.yml`) is configured to:
- Trigger on pushes to the `master` branch or manual workflow dispatch
- Use Java 21 (Temurin)
- Build the debug APK
- Upload the APK as a workflow artifact (named `app-debug`)

Workflow artifacts are typically retained for 90 days after the workflow run completes.
