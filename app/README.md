# Iridium (Ir) App

A modern multiplatform ebook reader based on the Flutter framework.

## Purpose

This project is designed as a tutorial about developing ebook reading apps in Flutter.

## Iteration 1: Skeleton

We want to make this project will be multiplatform from scratch. So, before creating if with `flutter create`, we must
enable macos-desktop, windows-desktop, linux-desktop and web support:

```
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
flutter config --enable-web
```

### Creating the skeleton

Then we can create the flutter app, thanks to the Android Studio menu or `flutter create iridium` command.

### Running it

On macOS, you may encounter the following
error: `xcrun: error: unable to find utility "xcodebuild", not a developer tool or in PATH`. You can fix it with the
following command:

```
 sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
 ```

Or, on a M1 mac:

```
 sudo /usr/bin/arch -arm64e xcode-select -s /Applications/Xcode.app/Contents/Developer
 ```

## Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
