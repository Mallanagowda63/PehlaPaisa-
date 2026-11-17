# Google Mobile Ads uses WorkManager, which opens its Room database through
# a generated class found by reflection (WorkDatabase_Impl). Without these
# rules R8 strips it and the release app crashes on start.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**
