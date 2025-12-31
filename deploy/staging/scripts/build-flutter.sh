#!/bin/bash

# CarSiGo Flutter Build Script for Staging
# Usage: ./build-flutter.sh [platform]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PLATFORM=${1:-all}
FLUTTER_DIR="../carsigo_flutter"
BUILD_DIR="./builds"
APK_OUTPUT_DIR="$BUILD_DIR/android"
IPA_OUTPUT_DIR="$BUILD_DIR/ios"
WEB_OUTPUT_DIR="$BUILD_DIR/web"
LOG_FILE="/var/log/carsigo-staging-flutter-build.log"

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}" | tee -a "$LOG_FILE"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    log "Flutter version: $FLUTTER_VERSION"
}

# Check Flutter directory
check_flutter_dir() {
    if [ ! -d "$FLUTTER_DIR" ]; then
        error "Flutter directory not found: $FLUTTER_DIR"
        exit 1
    fi
    
    cd "$FLUTTER_DIR"
    log "Working directory: $(pwd)"
}

# Create build directories
create_build_dirs() {
    mkdir -p "$APK_OUTPUT_DIR"
    mkdir -p "$IPA_OUTPUT_DIR"
    mkdir -p "$WEB_OUTPUT_DIR"
    log "Build directories created"
}

# Update Flutter dependencies
update_dependencies() {
    log "Updating Flutter dependencies..."
    flutter clean
    flutter pub get
    
    if [ -f "pubspec.yaml" ] && grep -q "flutter_gen" "pubspec.yaml"; then
        log "Running code generation..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
}

# Update API configuration for staging
update_api_config() {
    log "Updating API configuration for staging..."
    
    # Update app config
    if [ -f "lib/core/config/app_config.dart" ]; then
        sed -i.bak "s|http://localhost:8000/api|https://staging.carsigo.com/api|g" lib/core/config/app_config.dart
        log "Updated API URL in app config"
    fi
    
    # Update environment configuration
    if [ -f "assets/config/staging.json" ]; then
        cp assets/config/staging.json assets/config/app.json
        log "Updated environment configuration"
    fi
}

# Build for Android
build_android() {
    log "Building for Android..."
    
    # Check Android SDK
    flutter doctor --android-licenses
    
    # Build APK
    flutter build apk --release --target-platform android-arm64
    
    # Build App Bundle
    flutter build appbundle --release --target-platform android-arm64
    
    # Copy builds
    cp build/app/outputs/flutter-apk/app-release.apk "$APK_OUTPUT_DIR/carsigo-staging.apk"
    cp build/app/outputs/bundle/release/app-release.aab "$APK_OUTPUT_DIR/carsigo-staging.aab"
    
    log "✅ Android build completed"
    info "APK: $APK_OUTPUT_DIR/carsigo-staging.apk"
    info "AAB: $APK_OUTPUT_DIR/carsigo-staging.aab"
}

# Build for iOS
build_ios() {
    log "Building for iOS..."
    
    # Check iOS setup
    if ! command -v xcodebuild &> /dev/null; then
        warning "Xcode not found, skipping iOS build"
        return
    fi
    
    # Build iOS
    flutter build ios --release --no-codesign
    
    # Create IPA directory structure
    mkdir -p "$IPA_OUTPUT_DIR/Payload"
    
    # Copy app bundle
    cp -r build/ios/Release-iphoneos/Runner.app "$IPA_OUTPUT_DIR/Payload/"
    
    # Create IPA
    cd "$IPA_OUTPUT_DIR"
    zip -r carsigo-staging.ipa Payload/
    cd - > /dev/null
    
    log "✅ iOS build completed"
    info "IPA: $IPA_OUTPUT_DIR/carsigo-staging.ipa"
}

# Build for Web
build_web() {
    log "Building for Web..."
    
    # Build web
    flutter build web --release --web-renderer canvaskit
    
    # Copy build
    cp -r build/web/* "$WEB_OUTPUT_DIR/"
    
    # Create web configuration
    cat > "$WEB_OUTPUT_DIR/.htaccess" << 'EOF'
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.+)$ /index.html [QSA,L]
</IfModule>

# Cache static files
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 year"
    ExpiresByType application/javascript "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
</IfModule>
EOF
    
    log "✅ Web build completed"
    info "Web: $WEB_OUTPUT_DIR/"
}

# Generate build information
generate_build_info() {
    log "Generating build information..."
    
    BUILD_INFO="$BUILD_DIR/build-info.json"
    cat > "$BUILD_INFO" << EOF
{
    "build_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "flutter_version": "$(flutter --version | head -n 1)",
    "platform": "$PLATFORM",
    "environment": "staging",
    "api_url": "https://staging.carsigo.com/api",
    "builds": {
        "android": {
            "apk": "$(ls -la $APK_OUTPUT_DIR/*.apk 2>/dev/null | awk '{print $9}' | head -n 1 || echo 'N/A')",
            "aab": "$(ls -la $APK_OUTPUT_DIR/*.aab 2>/dev/null | awk '{print $9}' | head -n 1 || echo 'N/A')"
        },
        "ios": {
            "ipa": "$(ls -la $IPA_OUTPUT_DIR/*.ipa 2>/dev/null | awk '{print $9}' | head -n 1 || echo 'N/A')"
        },
        "web": {
            "path": "$WEB_OUTPUT_DIR"
        }
    }
}
EOF
    
    log "Build information saved to: $BUILD_INFO"
}

# Create deployment package
create_deployment_package() {
    log "Creating deployment package..."
    
    PACKAGE_NAME="carsigo-staging-$(date +%Y%m%d-%H%M%S).tar.gz"
    PACKAGE_PATH="$BUILD_DIR/$PACKAGE_NAME"
    
    # Create package
    tar -czf "$PACKAGE_PATH" -C "$BUILD_DIR" \
        android/carsigo-staging.apk \
        android/carsigo-staging.aab \
        ios/carsigo-staging.ipa \
        web/ \
        build-info.json
    
    log "✅ Deployment package created: $PACKAGE_PATH"
    info "Package size: $(du -h "$PACKAGE_PATH" | cut -f1)"
}

# Upload to staging server (optional)
upload_to_staging() {
    if [ -n "$STAGING_SERVER" ] && [ -n "$STAGING_USER" ]; then
        log "Uploading builds to staging server..."
        
        # Upload web files
        if [ -d "$WEB_OUTPUT_DIR" ]; then
            rsync -avz "$WEB_OUTPUT_DIR/" "$STAGING_USER@$STAGING_SERVER:/var/www/carsigo-staging-web/"
        fi
        
        # Upload mobile builds
        if [ -f "$APK_OUTPUT_DIR/carsigo-staging.apk" ]; then
            scp "$APK_OUTPUT_DIR/carsigo-staging.apk" "$STAGING_USER@$STAGING_SERVER:/var/www/carsigo-staging-downloads/"
        fi
        
        if [ -f "$IPA_OUTPUT_DIR/carsigo-staging.ipa" ]; then
            scp "$IPA_OUTPUT_DIR/carsigo-staging.ipa" "$STAGING_USER@$STAGING_SERVER:/var/www/carsigo-staging-downloads/"
        fi
        
        log "✅ Files uploaded to staging server"
    fi
}

# Main execution
main() {
    log "Starting CarSiGo Flutter Build for Staging"
    log "Platform: $PLATFORM"
    
    # Check prerequisites
    check_flutter
    check_flutter_dir
    create_build_dirs
    
    # Update dependencies
    update_dependencies
    
    # Update configuration
    update_api_config
    
    # Build based on platform
    case "$PLATFORM" in
        "android")
            build_android
            ;;
        "ios")
            build_ios
            ;;
        "web")
            build_web
            ;;
        "all")
            build_android
            build_ios
            build_web
            ;;
        *)
            error "Invalid platform: $PLATFORM"
            error "Valid options: android, ios, web, all"
            exit 1
            ;;
    esac
    
    # Generate build information
    generate_build_info
    
    # Create deployment package
    create_deployment_package
    
    # Upload to staging (if configured)
    upload_to_staging
    
    log "🎉 Flutter build completed successfully!"
    echo ""
    echo "=== Build Summary ==="
    echo "Platform: $PLATFORM"
    echo "Environment: staging"
    echo "Build Directory: $BUILD_DIR"
    echo "Web URL: https://staging.carsigo.com"
    echo "===================="
    
    # Display file sizes
    echo ""
    echo "Build Files:"
    find "$BUILD_DIR" -name "*.apk" -o -name "*.aab" -o -name "*.ipa" | while read file; do
        echo "$(basename "$file"): $(du -h "$file" | cut -f1)"
    done
}

# Run main function
main "$@"
