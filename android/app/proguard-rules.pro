# Keep AltBeacon classes
-keep class org.altbeacon.beacon.** { *; }
-keep class org.altbeacon.bluetooth.** { *; }
-keep class org.altbeacon.background.** { *; }

# Keep your service classes
-keep class com.uniguard.ugz_app.service.BeaconService { *; }
-keep class com.uniguard.ugz_app.service.LocationUploadService { *; }

# Keep BeaconManager and its methods
-keep class org.altbeacon.beacon.BeaconManager { *; }
-keepclassmembers class org.altbeacon.beacon.BeaconManager {
    public <init>();
    public void startRangingBeacons(org.altbeacon.beacon.Region);
    public void stopRangingBeacons(org.altbeacon.beacon.Region);
    public void addRangeNotifier(org.altbeacon.beacon.RangeNotifier);
    public void removeRangeNotifier(org.altbeacon.beacon.RangeNotifier);
    public void addMonitorNotifier(org.altbeacon.beacon.MonitorNotifier);
    public void removeMonitorNotifier(org.altbeacon.beacon.MonitorNotifier);
}

# Keep BeaconParser
-keep class org.altbeacon.beacon.BeaconParser { *; }
-keepclassmembers class org.altbeacon.beacon.BeaconParser {
    public <init>();
    public void setBeaconLayout(java.lang.String);
}

# Keep Region
-keep class org.altbeacon.beacon.Region { *; }
-keepclassmembers class org.altbeacon.beacon.Region {
    public <init>(java.lang.String, org.altbeacon.beacon.Identifier, org.altbeacon.beacon.Identifier, org.altbeacon.beacon.Identifier);
}

# Keep RangeNotifier and MonitorNotifier
-keep interface org.altbeacon.beacon.RangeNotifier { *; }
-keep interface org.altbeacon.beacon.MonitorNotifier { *; }

# Keep AltBeacon JobService and related classes
-keep class org.altbeacon.beacon.service.ScanJob { *; }
-keep class org.altbeacon.beacon.service.ScanJobScheduler { *; }
-keep class org.altbeacon.beacon.service.ScanJobScheduler$ScanJobSchedulerImpl { *; }

# Keep Android JobService implementation
-keep class * extends android.app.job.JobService {
    public <init>();
    public void onCreate();
    public boolean onStartJob(android.app.job.JobParameters);
    public boolean onStopJob(android.app.job.JobParameters);
}

# Keep Android JobScheduler related classes
-keep class android.app.job.JobInfo { *; }
-keep class android.app.job.JobParameters { *; }
-keep class android.app.job.JobScheduler { *; }

# Keep Android JobService related methods
-keepclassmembers class * extends android.app.job.JobService {
    public <init>();
    public void onCreate();
    public boolean onStartJob(android.app.job.JobParameters);
    public boolean onStopJob(android.app.job.JobParameters);
}

# === Retrofit & OkHttp ===

-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

##---------------Begin: proguard configuration for Gson  ----------
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Application classes that will be serialized/deserialized over Gson
-keep class com.google.gson.examples.android.model.** { <fields>; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}


-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type


# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

##---------------End: proguard configuration for Gson  ----------

# === Gson ===
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }


# === Coroutines support ===
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# === Location Services ===
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# === Keep all API related classes ===
-keep class com.uniguard.ugz_app.api.** { *; }
-keep class com.uniguard.ugz_app.service.** { *; }
-keep class com.uniguard.ugz_app.utils.** { *; }

# === Keep all model classes with SerializedName ===
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# === Keep all methods in service classes ===
-keepclassmembers class com.uniguard.ugz_app.service.BeaconService {
    public <init>();
    public void onCreate();
    public int onStartCommand(android.content.Intent, int, int);
    public void onDestroy();
    public void didRangeBeaconsInRegion(java.util.Collection, org.altbeacon.beacon.Region);
    public void didEnterRegion(org.altbeacon.beacon.Region);
    public void didExitRegion(org.altbeacon.beacon.Region);
    public void didDetermineStateForRegion(int, org.altbeacon.beacon.Region);
}

-keepclassmembers class com.uniguard.ugz_app.service.LocationUploadService {
    public <init>();
    public void onCreate();
    public int onStartCommand(android.content.Intent, int, int);
    public void onDestroy();
}

# === Keep all methods in API classes ===
-keepclassmembers class com.uniguard.ugz_app.api.RetrofitClient {
    public static <methods>;
}

# === Keep all methods in request/response models ===
-keepclassmembers class com.uniguard.ugz_app.api.BeaconRequest { *; }
-keepclassmembers class com.uniguard.ugz_app.api.LocationRequest { *; }
-keepclassmembers class com.uniguard.ugz_app.api.BeaconData { *; }

# === Keep all utility classes ===
-keep class com.uniguard.ugz_app.utils.BeaconBatteryReader { *; }
-keep class com.uniguard.ugz_app.utils.BeaconScanData { *; }

# === Keep generic type information ===
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# === Keep all model classes and their fields ===
-keep class com.uniguard.ugz_app.api.** {
    *;
}
-keepclassmembers class com.uniguard.ugz_app.api.** {
    *;
}

# === Keep all response classes ===
-keep class retrofit2.Response { *; }
-keep class retrofit2.Call { *; }
-keep class retrofit2.Callback { *; }

-if interface * { @retrofit2.http.* public *** *(...); }
-keep,allowoptimization,allowshrinking,allowobfuscation class <3>


-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# === Keep all generic type information for API models ===
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# === Keep specific API models and their type information ===
-keep class com.uniguard.ugz_app.api.BeaconData { *; }
-keep class com.uniguard.ugz_app.api.BeaconRequest { *; }
-keep class com.uniguard.ugz_app.api.LocationRequest { *; }

# === Keep all methods in API models ===
-keepclassmembers class com.uniguard.ugz_app.api.BeaconData {
    public <init>(...);
    public *;
}
-keepclassmembers class com.uniguard.ugz_app.api.BeaconRequest {
    public <init>(...);
    public *;
}
-keepclassmembers class com.uniguard.ugz_app.api.LocationRequest {
    public <init>(...);
    public *;
}
