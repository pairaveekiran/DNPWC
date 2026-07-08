# ─────────────────────────────────────────────────────────────
# ProGuard / R8 keep rules for mobile_scanner (CameraX + ML Kit)
#
# REQUIRED: Without these rules, R8 strips/obfuscates classes
# that mobile_scanner's CameraX and ML Kit layers access via
# reflection, causing a native null-reference crash on first
# camera use in release builds ("Attempt to invoke virtual
# method '...' on a null object reference").
#
# If this file is ever deleted or disconnected in
# build.gradle.kts, the release-only crash WILL return.
# ─────────────────────────────────────────────────────────────

# Google ML Kit — barcode scanning, object detection, etc.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-dontwarn com.google.mlkit.**

# AndroidX Camera — CameraX internals accessed via reflection
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# mobile_scanner plugin internals (dev.steenbakker)
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**
