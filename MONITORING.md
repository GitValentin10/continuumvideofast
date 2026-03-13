# Build Monitoring Documentation

## Overview

The Continuum project now includes active build monitoring capabilities to track compilation progress in real-time, detect issues early, and provide detailed build metrics.

## Features

### 1. Real-Time Build Progress Tracking

The monitoring system actively tracks:
- Build phase progression (task execution)
- Compilation steps
- Dependency downloads
- Test execution
- APK generation

### 2. Structured Logging

All build events are logged with:
- Timestamps
- Event levels (INFO, SUCCESS, WARNING, ERROR, PROGRESS)
- Detailed messages
- Build metrics

Log files are automatically generated with format: `build-monitor-YYYYMMDD-HHMMSS.log`

### 3. Build Status Visualization

Color-coded output for different event types:
- 🔵 INFO (Blue) - Informational messages
- ✓ SUCCESS (Green) - Successful operations
- ⚠ WARNING (Yellow) - Non-critical issues
- ✗ ERROR (Red) - Build failures
- ▶ PROGRESS (Blue) - Active build steps

### 4. Environment Verification

The monitoring system checks:
- Java version (requires Java 21)
- Gradle wrapper availability
- Build configuration files
- System resources (memory, disk space)

### 5. Build Metrics

Automatically tracked metrics:
- Build duration (minutes and seconds)
- Build exit codes
- APK size and location
- Environment information

## Usage

### Local Development

Run the monitoring script directly:

```bash
# Monitor debug build
./scripts/monitor-build.sh assembleDebug

# Monitor release build
./scripts/monitor-build.sh assembleRelease

# Monitor tests
./scripts/monitor-build.sh testDebugUnitTest
```

### GitHub Actions

The build monitoring is automatically integrated into the GitHub Actions workflow. When you push to `master` or manually trigger the workflow, the monitoring will:

1. Verify the build environment
2. Display Java and Gradle versions
3. Show system resources
4. Monitor the build progress in real-time
5. Verify the generated APK
6. Upload build logs as artifacts

### Viewing Build Logs

#### GitHub Actions
Build logs are automatically uploaded as artifacts after each workflow run. To access them:

1. Go to the Actions tab in GitHub
2. Select the workflow run
3. Download the "build-logs" artifact
4. Extract and view `build-monitor-*.log`

#### Local Development
Log files are saved in the repository root with the naming pattern:
```
build-monitor-YYYYMMDD-HHMMSS.log
```

**Note**: Log files are ignored by `.gitignore` to avoid cluttering the repository.

## Build Monitoring Output Example

```
═══════════════════════════════════════════════════════
  CONTINUUM BUILD MONITOR
═══════════════════════════════════════════════════════
  Task: assembleDebug
  Started: 2026-03-13 11:30:00
═══════════════════════════════════════════════════════

ℹ Checking build prerequisites...
ℹ Java version: 21.0.1
✓ Java 21 detected (required)
✓ Gradle wrapper found
✓ Build configuration found

▶ Starting build task: assembleDebug

▶ > Task :app:preBuild
▶ > Task :app:compileDebugKotlin
▶ > Task :app:compileDebugJavaWithJavac
▶ > Task :app:mergeDebugResources
▶ > Task :app:processDebugManifest
▶ > Task :app:packageDebug

✓ Build completed successfully

═══════════════════════════════════════════════════════
  BUILD MONITORING SUMMARY
═══════════════════════════════════════════════════════
✓ Build completed successfully
Duration: 2m 34s
Log file: build-monitor-20260313-113000.log
═══════════════════════════════════════════════════════
```

## Integration with Existing Tools

### Gradle
The monitoring script wraps Gradle execution and parses its output for real-time feedback. It uses `--console=plain` mode to ensure consistent output parsing.

### GitHub Actions
The workflow uses GitHub Actions annotations for enhanced visibility:
- `::group::` - Collapsible output sections
- `::error::` - Build failure notifications
- `::notice::` - Build success notifications
- `::warning::` - Non-critical issue alerts

## Troubleshooting

### Java Version Mismatch
If you see a warning about Java version:
```
⚠ Java 21 recommended, found: 17.0.x
```

**Solution**: Install Java 21 or update your `JAVA_HOME` environment variable.

### Build Script Not Executable
If you encounter "Permission denied" errors:
```bash
chmod +x scripts/monitor-build.sh
```

### Log Files Not Created
Ensure you have write permissions in the repository directory. Log files are created in the current working directory.

## Advanced Configuration

### Custom Build Tasks
Monitor any Gradle task by passing it as an argument:

```bash
# Monitor custom task
./scripts/monitor-build.sh customTask

# Monitor multiple tasks
./scripts/monitor-build.sh clean assembleDebug
```

### Environment Variables
The monitoring script respects standard Gradle environment variables:
- `GRADLE_OPTS` - JVM options for Gradle
- `JAVA_HOME` - Java installation directory
- `ANDROID_HOME` - Android SDK location

## Monitoring in CI/CD

The monitoring system is designed for continuous integration environments:

1. **Build Status Tracking**: Real-time feedback on build progress
2. **Early Failure Detection**: Immediate notification of build errors
3. **Resource Monitoring**: Track memory and disk usage
4. **Artifact Verification**: Ensure APK is generated correctly
5. **Log Preservation**: Automatic upload of detailed build logs

## Best Practices

1. **Review Build Logs**: After each build, review the logs for warnings or potential issues
2. **Monitor Build Times**: Track build duration to identify performance degradation
3. **Check Environment**: Verify Java and Gradle versions match project requirements
4. **Preserve Logs**: Archive build logs for troubleshooting and historical analysis
5. **Use Monitoring Locally**: Test builds with monitoring before pushing to CI/CD

## Future Enhancements

Potential improvements for the monitoring system:
- Build performance metrics tracking
- Memory usage profiling
- Dependency conflict detection
- Build cache statistics
- Notification integrations (Slack, email)
- Historical build trend analysis

## Support

For issues or questions about build monitoring:
1. Check the build logs for detailed error messages
2. Review the `BUILD_APK_INSTRUCTIONS.md` for build requirements
3. Create an issue in the GitHub repository with:
   - Build log file
   - Environment information
   - Steps to reproduce the issue
