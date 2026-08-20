#!/bin/bash
# Builds Daybook.app and packages it as a .dmg.
#
#   ./scripts/build-app.sh              # ad-hoc signed, runs locally
#   DEVELOPMENT_TEAM=XXXXXXXXXX \
#   CODE_SIGN_IDENTITY="Developer ID Application" \
#     ./scripts/build-app.sh            # distributable, notarize separately
#
# Signing identity and team are read from the environment so no certificate,
# Apple ID, or team ID is ever committed to the repo.

set -euo pipefail

cd "$(dirname "$0")/.."
PROJECT_DIR="$PWD"
BUILD_DIR="${BUILD_DIR:-$PROJECT_DIR/build}"
DIST_DIR="${DIST_DIR:-$PROJECT_DIR/dist}"
VERSION="${VERSION:-1.0}"
APP_NAME="Daybook"

# xcodebuild refuses to sign a bundle carrying a com.apple.FinderInfo xattr,
# which iCloud/Finder add to directories under ~/Desktop and ~/Documents.
# Building into a scratch dir outside those trees avoids it entirely.
if [[ "$BUILD_DIR" == "$HOME/Desktop"* || "$BUILD_DIR" == "$HOME/Documents"* ]]; then
    BUILD_DIR="$(mktemp -d)/build"
    echo "==> Building in $BUILD_DIR (source tree is in a synced folder)"
fi

SIGN_ARGS=()
if [[ -n "${CODE_SIGN_IDENTITY:-}" ]]; then
    SIGN_ARGS+=("CODE_SIGN_IDENTITY=$CODE_SIGN_IDENTITY" "CODE_SIGN_STYLE=Manual")
fi
if [[ -n "${DEVELOPMENT_TEAM:-}" ]]; then
    SIGN_ARGS+=("DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM")
fi

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building $APP_NAME (Release, universal)"
rm -rf "$BUILD_DIR"
xcodebuild \
    -project PersonalSecretary.xcodeproj \
    -scheme PersonalSecretary \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    ${SIGN_ARGS[@]+"${SIGN_ARGS[@]}"} \
    clean build

APP="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
test -d "$APP" || { echo "error: $APP was not produced"; exit 1; }

echo "==> Verifying bundle"
EXPECTED="$(plutil -extract CFBundleExecutable raw "$APP/Contents/Info.plist")"
test -x "$APP/Contents/MacOS/$EXPECTED" \
    || { echo "error: CFBundleExecutable '$EXPECTED' is missing or not executable"; exit 1; }
plutil -lint "$APP/Contents/Info.plist"
file "$APP/Contents/MacOS/$EXPECTED"
codesign --verify --deep --strict --verbose=2 "$APP"

echo "==> Packaging $APP_NAME-$VERSION.dmg"
mkdir -p "$DIST_DIR"
STAGING="$(mktemp -d)"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
DMG="$DIST_DIR/$APP_NAME-$VERSION.dmg"
rm -f "$DMG"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGING"

echo
echo "App: $APP"
echo "DMG: $DMG"
codesign -dv "$APP" 2>&1 | grep -E "Identifier|Signature|TeamIdentifier"
