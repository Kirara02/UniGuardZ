# Keep AltBeacon classes
-keep class org.altbeacon.beacon.** { *; }
-keep class org.altbeacon.bluetooth.** { *; }
-keep class org.altbeacon.background.** { *; }

# Keep your service class
-keep class com.uniguard.ugz_app.service.BeaconService { *; }

# Keep BeaconManager
-keep class org.altbeacon.beacon.BeaconManager { *; }

# Keep BeaconParser
-keep class org.altbeacon.beacon.BeaconParser { *; }

# Keep Region
-keep class org.altbeacon.beacon.Region { *; }

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