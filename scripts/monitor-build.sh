#!/bin/bash
# Build Monitoring Script for Continuum Android Project
# Actively monitors the compilation process and reports progress in real-time

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build metrics
START_TIME=$(date +%s)
BUILD_LOG_FILE="build-monitor-$(date +%Y%m%d-%H%M%S).log"

# Function to log with timestamp
log_event() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${BUILD_LOG_FILE}"
}

# Function to display colored status
show_status() {
    local status=$1
    local message=$2
    case $status in
        "INFO")
            echo -e "${BLUE}ℹ${NC} ${message}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✓${NC} ${message}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠${NC} ${message}"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} ${message}"
            ;;
        "PROGRESS")
            echo -e "${BLUE}▶${NC} ${message}"
            ;;
    esac
}

# Function to check prerequisites
check_prerequisites() {
    log_event "INFO" "Checking build prerequisites..."
    show_status "PROGRESS" "Checking build prerequisites..."

    # Check Java version
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        log_event "INFO" "Java version detected: ${JAVA_VERSION}"
        show_status "INFO" "Java version: ${JAVA_VERSION}"

        if [[ $JAVA_VERSION == 21.* ]]; then
            show_status "SUCCESS" "Java 21 detected (required)"
        else
            show_status "WARNING" "Java 21 recommended, found: ${JAVA_VERSION}"
        fi
    else
        log_event "ERROR" "Java not found"
        show_status "ERROR" "Java not found in PATH"
        exit 1
    fi

    # Check Gradle wrapper
    if [[ -f "./gradlew" ]]; then
        show_status "SUCCESS" "Gradle wrapper found"
        log_event "INFO" "Gradle wrapper exists"
    else
        log_event "ERROR" "Gradle wrapper not found"
        show_status "ERROR" "gradlew not found"
        exit 1
    fi

    # Check for build.gradle
    if [[ -f "./build.gradle" ]] || [[ -f "./build.gradle.kts" ]]; then
        show_status "SUCCESS" "Build configuration found"
        log_event "INFO" "Build configuration exists"
    else
        log_event "ERROR" "build.gradle not found"
        show_status "ERROR" "build.gradle not found"
        exit 1
    fi
}

# Function to monitor Gradle build progress
monitor_gradle_build() {
    local build_task=$1
    log_event "INFO" "Starting monitored build: ${build_task}"
    show_status "PROGRESS" "Starting build task: ${build_task}"

    # Create temporary file for Gradle output
    local gradle_output=$(mktemp)

    # Run Gradle with progress tracking
    if ./gradlew ${build_task} --console=plain 2>&1 | tee "${gradle_output}" | while IFS= read -r line; do
        # Monitor specific build phases
        if [[ $line == *"BUILD SUCCESSFUL"* ]]; then
            show_status "SUCCESS" "Build completed successfully"
            log_event "SUCCESS" "Build successful"
        elif [[ $line == *"BUILD FAILED"* ]]; then
            show_status "ERROR" "Build failed"
            log_event "ERROR" "Build failed"
        elif [[ $line == *"Executing task"* ]] || [[ $line == *"> Task"* ]]; then
            show_status "PROGRESS" "${line}"
            log_event "PROGRESS" "${line}"
        elif [[ $line == *"Downloading"* ]]; then
            show_status "INFO" "${line}"
            log_event "INFO" "${line}"
        elif [[ $line == *"Compiling"* ]] || [[ $line == *"compileDebug"* ]] || [[ $line == *"compileRelease"* ]]; then
            show_status "PROGRESS" "${line}"
            log_event "PROGRESS" "${line}"
        elif [[ $line == *"error:"* ]] || [[ $line == *"Error:"* ]] || [[ $line == *"FAILURE:"* ]]; then
            show_status "ERROR" "${line}"
            log_event "ERROR" "${line}"
        elif [[ $line == *"warning:"* ]] || [[ $line == *"Warning:"* ]]; then
            show_status "WARNING" "${line}"
            log_event "WARNING" "${line}"
        fi
    done; then
        rm -f "${gradle_output}"
        return 0
    else
        local exit_code=$?
        rm -f "${gradle_output}"
        return $exit_code
    fi
}

# Function to display build summary
show_build_summary() {
    local exit_code=$1
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  BUILD MONITORING SUMMARY"
    echo "═══════════════════════════════════════════════════════"

    if [[ $exit_code -eq 0 ]]; then
        show_status "SUCCESS" "Build completed successfully"
        log_event "SUCCESS" "Build completed in ${minutes}m ${seconds}s"
    else
        show_status "ERROR" "Build failed with exit code: ${exit_code}"
        log_event "ERROR" "Build failed after ${minutes}m ${seconds}s with exit code: ${exit_code}"
    fi

    echo "Duration: ${minutes}m ${seconds}s"
    echo "Log file: ${BUILD_LOG_FILE}"
    echo "═══════════════════════════════════════════════════════"
    echo ""
}

# Main execution
main() {
    local build_task="${1:-assembleDebug}"

    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  CONTINUUM BUILD MONITOR"
    echo "═══════════════════════════════════════════════════════"
    echo "  Task: ${build_task}"
    echo "  Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "═══════════════════════════════════════════════════════"
    echo ""

    log_event "INFO" "Build monitoring started for task: ${build_task}"

    # Check prerequisites
    check_prerequisites

    echo ""
    show_status "PROGRESS" "Initiating monitored build..."
    echo ""

    # Monitor the build
    if monitor_gradle_build "${build_task}"; then
        show_build_summary 0
        exit 0
    else
        local exit_code=$?
        show_build_summary $exit_code
        exit $exit_code
    fi
}

# Run main function with all arguments
main "$@"
