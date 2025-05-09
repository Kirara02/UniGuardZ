package com.uniguard.ugz_app.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.uniguard.ugz_app.MainActivity
import com.uniguard.ugz_app.R
import com.uniguard.ugz_app.api.data.BeaconData
import com.uniguard.ugz_app.api.RetrofitClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import org.altbeacon.beacon.*
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import java.util.Timer
import java.util.TimerTask
import kotlinx.coroutines.SupervisorJob
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationToken
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.android.gms.tasks.OnTokenCanceledListener
import com.uniguard.ugz_app.utils.BeaconBatteryReader
import com.uniguard.ugz_app.BuildConfig
import com.uniguard.ugz_app.api.data.BeaconRequest
import com.uniguard.ugz_app.utils.BeaconScanData
import org.altbeacon.beacon.service.RunningAverageRssiFilter
import com.uniguard.ugz_app.utils.ServiceChecker

class BeaconService : Service(), RangeNotifier, MonitorNotifier {
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isScanning = false
    private var beaconManager: BeaconManager? = null
    private var beaconBuffer = mutableMapOf<String, BeaconScanData>()
    private var uploadTimer: Timer? = null
    private val UPLOAD_INTERVAL = 60000L // 1 minute in milliseconds
    private val SCAN_INTERVAL = 1100L // 1.1 seconds in milliseconds
    private lateinit var batteryReader: BeaconBatteryReader
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var isServiceRunning = false
    private lateinit var serviceChecker: ServiceChecker
    private var allowedBeacons = mutableListOf<Map<String, Any>>()

    companion object {
        private const val CHANNEL_ID = "BeaconServiceChannel"
        private const val NOTIFICATION_ID = 1
        private const val TAG = "BeaconService"
        
        private fun logDebug(message: String) {
            if (BuildConfig.DEBUG) {
                Log.d(TAG, message)
            }
        }
        
        private fun logError(message: String, e: Exception? = null) {
            if (BuildConfig.DEBUG) {
                if (e != null) {
                    Log.e(TAG, message, e)
                } else {
                    Log.e(TAG, message)
                }
            }
        }

        fun isRunning(): Boolean {
            return instance?.isServiceRunning ?: false
        }


        private var instance: BeaconService? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        try {
            createNotificationChannel()
            serviceChecker = ServiceChecker(applicationContext)
            
            if (!serviceChecker.canStartBeaconService()) {
                logError("Cannot start beacon service - Missing permissions or services disabled")
                stopSelf()
                return
            }
        
            fusedLocationClient = LocationServices.getFusedLocationProviderClient(applicationContext)
            batteryReader = BeaconBatteryReader(applicationContext)
            beaconManager = BeaconManager.getInstanceForApplication(applicationContext)
            
            val settings = Settings(
                scanStrategy = Settings.ForegroundServiceScanStrategy(
                    createNotification(), NOTIFICATION_ID
                ),
                scanPeriods = Settings.ScanPeriods(SCAN_INTERVAL, 0, SCAN_INTERVAL, 0),
                longScanForcingEnabled = true,
                rssiFilterClass = RunningAverageRssiFilter::class.java
            )
            
            beaconManager?.replaceSettings(settings)
            beaconManager?.beaconParsers?.clear()
            beaconManager?.beaconParsers?.add(BeaconParser().setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24"))
            beaconManager?.beaconParsers?.add(BeaconParser().setBeaconLayout("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25"))
        
            beaconManager?.removeRangeNotifier(this)
            beaconManager?.removeMonitorNotifier(this)
            beaconManager?.addRangeNotifier(this)
            beaconManager?.addMonitorNotifier(this)

            startBeaconService()
        } catch (e: Exception) {
            logError("Error in onCreate", e)
            stopSelf()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Beacon Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification() = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("Beacon Service")
        .setContentText("Scanning for beacons")
        .setSmallIcon(R.drawable.uniguard_logo)
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .setContentIntent(
            PendingIntent.getActivity(
                this,
                0,
                Intent(this, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        .build()


    private fun stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

    private fun startBeaconService() {
        if (!isScanning) {
            isScanning = true
            isServiceRunning = true
            
            try {
                startForeground(NOTIFICATION_ID, createNotification())
                val region = Region("all-beacons-region", null, null, null)
                beaconManager?.stopRangingBeacons(region)
                beaconManager?.startRangingBeacons(region)
                startUploadTimer()
                
                // Schedule a check to verify scanning is working
                Timer().schedule(object : TimerTask() {
                    override fun run() {
                        val isScanningActive = beaconManager?.rangedRegions?.isNotEmpty() ?: false
                        if (!isScanningActive) {
                            logError("Beacon scanning is not active, attempting to restart...")
                            stopBeaconService()
                            startBeaconService()
                        }
                    }
                }, 30000)
                
            } catch (e: Exception) {
                logError("Error starting beacon service: ${e.message}", e)
                isScanning = false
                isServiceRunning = false
                stopForegroundCompat()
                stopSelf()
            }
        }
    }

    private fun stopBeaconService() {
        if (isScanning) {
            isScanning = false
            try {
                beaconManager?.let {
                    it.stopRangingBeacons(Region("all-beacons-region", null, null, null))
                    it.removeRangeNotifier(this)
                    it.removeMonitorNotifier(this)
                }
                stopUploadTimer()
                beaconBuffer.clear()
                stopForegroundCompat()
            } catch (e: Exception) {
                logError("Error stopping beacon service", e)
            }
        }
    }

    private fun startUploadTimer() {
        uploadTimer = Timer()
        scheduleNextUpload()
    }

    private fun scheduleNextUpload() {
        uploadTimer?.schedule(object : TimerTask() {
            override fun run() {
                // Only upload if there are beacons in the buffer
                if (beaconBuffer.isNotEmpty()) {
                    logDebug("{\"status\": \"upload_scheduled\", \"beacon_count\": \"${beaconBuffer.size}\"}")
                    uploadBufferedBeacons()
                } else {
                    logDebug("{\"status\": \"upload_skipped\", \"reason\": \"no_beacons_in_buffer\"}")
                }
                scheduleNextUpload()
            }
        }, UPLOAD_INTERVAL)
    }

    private fun stopUploadTimer() {
        uploadTimer?.cancel()
        uploadTimer = null
    }

    private fun isBeaconAllowed(major: Int, minor: Int): Boolean {
        if (allowedBeacons.isEmpty()) {
            logDebug("{\"status\": \"no_restrictions\", \"message\": \"No beacon restrictions set, allowing all beacons\"}")
            return false // Change to false to prevent any beacon processing if no restrictions set
        }
        
        logDebug("{\"status\": \"checking_allowed_beacons\", \"allowed_beacons\": ${allowedBeacons.toList()}}")
        
        val isAllowed = allowedBeacons.any { beacon ->
            val beaconMajor = (beacon["major"] as? Number)?.toInt() ?: return@any false
            val beaconMinor = (beacon["minor"] as? Number)?.toInt() ?: return@any false
            beaconMajor == major && beaconMinor == minor
        }
        
        logDebug("{\"status\": \"beacon_check_result\", \"major\": $major, \"minor\": $minor, \"is_allowed\": $isAllowed}")
        return isAllowed
    }

    // RangeNotifier implementation
    override fun didRangeBeaconsInRegion(beacons: Collection<Beacon>, region: Region) {
        if (!isScanning) return

        if (beacons.isNotEmpty()) {
            beacons.forEach { beacon ->
                try {
                    val major = beacon.id2?.toInt() ?: 0
                    val minor = beacon.id3?.toInt() ?: 0
                    
                    // Check if beacon is allowed before processing
                    if (!isBeaconAllowed(major, minor)) {
                        logDebug("{\"status\": \"beacon_skipped\", \"reason\": \"not_in_allowed_list\", \"major\": $major, \"minor\": $minor}")
                        return@forEach
                    }

                val beaconJson = "{\n" +
                    "  \"name\": \"${beacon.bluetoothName ?: "Unknown"}\",\n" +
                    "  \"uuid\": \"${beacon.id1}\",\n" +
                    "  \"macAddress\": \"${beacon.bluetoothAddress ?: "Unknown"}\",\n" +
                    "  \"major\": \"$major\",\n" +
                    "  \"minor\": \"$minor\",\n" +
                    "  \"distance\": \"${beacon.distance}\",\n" +
                    "  \"proximity\": \"${BeaconScanData.getProximityOfBeacon(beacon).value}\",\n" +
                    "  \"scanTime\": \"${System.currentTimeMillis()}\",\n" +
                    "  \"rssi\": \"${beacon.rssi}\",\n" +
                    "  \"txPower\": \"${beacon.txPower}\"\n" +
                    "}"
                
                    logDebug("Processing allowed Beacon: $beaconJson")
                
                // Update beacon buffer with latest data
                val beaconKey = "${beacon.id1}-${beacon.id2}-${beacon.id3}"
                    val beaconData = BeaconScanData(
                    uuid = beacon.id1.toString(),
                    name = beacon.bluetoothName ?: "Unknown",
                    macAddress = beacon.bluetoothAddress ?: "Unknown",
                        major = major,
                        minor = minor,
                    distance = beacon.distance,
                    txPower = beacon.txPower,
                    proximity = BeaconScanData.getProximityOfBeacon(beacon).value,
                    rssi = beacon.rssi,
                    timestamp = System.currentTimeMillis(),
                    latitude = null,
                    longitude = null
                )
                    
                    beaconBuffer[beaconKey] = beaconData
                    logDebug("Added beacon to buffer - Key: $beaconKey, Buffer size: ${beaconBuffer.size}")
                } catch (e: Exception) {
                    logError("Error processing beacon data", e)
                }
            }
            logDebug("Beacon processing complete - Buffer size: ${beaconBuffer.size}")
        } else {
            logDebug("No beacons detected in range")
        }
    }

    private fun uploadBufferedBeacons() {
        if (beaconBuffer.isEmpty()) {
            return
        }

        coroutineScope.launch {
            try {
                // Get current location
                val location = getCurrentLocation()
                if (location == null) {
                    logError("{\"status\": \"location_error\", \"error\": \"Failed to get current location\"}")
                    return@launch
                }

                // Upload all beacons in the buffer
                beaconBuffer.values.forEach { beaconData ->
                    val beaconInfo = "{\"uuid\": \"${beaconData.uuid}\", \"major\": \"${beaconData.major}\", \"minor\": \"${beaconData.minor}\"}"
                    
                    logDebug("Processing allowed Beacon: $beaconInfo")
                    
                    // Get the actual beacon object from the buffer
                    val beacon = beaconBuffer.entries.find { 
                        it.value.uuid == beaconData.uuid && 
                        it.value.major == beaconData.major && 
                        it.value.minor == beaconData.minor 
                    }?.value?.let { 
                        org.altbeacon.beacon.Beacon.Builder()
                            .setId1(it.uuid)
                            .setId2(it.major.toString())
                            .setId3(it.minor.toString())
                            .setBluetoothAddress(it.macAddress)
                            .build()
                    }

                    // Get battery level if beacon is available and we have permission
                    val batteryLevel = if (ContextCompat.checkSelfPermission(
                            this@BeaconService,
                            Manifest.permission.BLUETOOTH_CONNECT
                        ) == PackageManager.PERMISSION_GRANTED) {
                        beacon?.let { batteryReader.readBatteryLevel(it) } ?: 0
                    } else {
                        logError("{\"status\": \"permission_error\", \"error\": \"BLUETOOTH_CONNECT permission not granted\"}")
                        0
                    }
                    
                    val request = BeaconRequest.create(
                        type = "beacon",
                        latitude = location.latitude,
                        longitude = location.longitude,
                        timestamp = System.currentTimeMillis(),
                        beacon = BeaconData(
                            majorValue = beaconData.major,
                            minorValue = beaconData.minor,
                            batteryLevel = batteryLevel
                        )
                    )

                    try {
                        val response = RetrofitClient.apiService.submitBeacon(request)
                        if (response.success) {
                            logDebug("{\"status\": \"upload_success\", \"beacon\": $beaconInfo, \"battery_level\": $batteryLevel}")
                        } else {
                            logError("{\"status\": \"upload_failed\", \"beacon\": $beaconInfo, \"battery_level\": $batteryLevel, \"error\": \"${response.message}\"}")
                        }
                    } catch (e: Exception) {
                        logError("{\"status\": \"upload_exception\", \"beacon\": $beaconInfo, \"battery_level\": $batteryLevel, \"error\": \"${e.message}\"}")
                    }
                }

                // Clear the buffer after successful upload
                beaconBuffer.clear()
                logDebug("{\"status\": \"upload_complete\", \"buffer_cleared\": \"true\"}")
            } catch (e: Exception) {
                logError("{\"status\": \"upload_process_error\", \"error\": \"${e.message}\"}")
            }
        }
    }

    private suspend fun getCurrentLocation(): android.location.Location? {
        return try {
            // Check if we have location permissions
            if (ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                logError("Location permissions not granted")
                return null
            }

            // Get current location with high accuracy
            val location = fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                object : CancellationToken() {
                    override fun onCanceledRequested(listener: OnTokenCanceledListener) = CancellationTokenSource().token
                    override fun isCancellationRequested() = false
                }
            ).await()

            location
        } catch (e: Exception) {
            logError("Error getting location", e)
            null
        }
    }

//    private fun sendNotification(message: String) {
//        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
//            .setContentTitle("Upload Beacon")
//            .setContentText(message)
//            .setSmallIcon(R.drawable.uniguard_logo)
//            .setPriority(NotificationCompat.PRIORITY_HIGH)
//            .setAutoCancel(true)
//            .setContentIntent(
//                PendingIntent.getActivity(
//                    this,
//                    0,
//                    Intent(this, MainActivity::class.java),
//                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//                )
//            )
//            .build()
//
//        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
//        manager.notify((System.currentTimeMillis() % 10000).toInt(), notification)
//    }

    // MonitorNotifier implementation
    override fun didEnterRegion(region: Region) {
        logDebug("Entered beacon region")
    }

    override fun didExitRegion(region: Region) {
        logDebug("Exited beacon region")
    }

    override fun didDetermineStateForRegion(state: Int, region: Region) {
        logDebug("Region state changed: $state")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!serviceChecker.canStartBeaconService()) {
            logError("Cannot start beacon service - Missing permissions or services disabled")
            stopSelf()
            return START_NOT_STICKY
        }
        
        try {
            // Get allowed beacons from intent
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent?.getSerializableExtra("allowedBeacons", ArrayList::class.java)?.let { beacons ->
                    allowedBeacons.clear()
                    allowedBeacons.addAll(beacons.filterIsInstance<Map<String, Any>>())
                    logDebug("{\"status\": \"beacons_updated\", \"count\": ${allowedBeacons.size}, \"beacons\": ${allowedBeacons.toList()}}")
                }
            } else {
                @Suppress("DEPRECATION")
                intent?.getSerializableExtra("allowedBeacons")?.let { beacons ->
                    if (beacons is ArrayList<*>) {
                        allowedBeacons.clear()
                        allowedBeacons.addAll(beacons.filterIsInstance<Map<String, Any>>())
                        logDebug("{\"status\": \"beacons_updated\", \"count\": ${allowedBeacons.size}, \"beacons\": ${allowedBeacons.toList()}}")
                    }
                }
            }
            
            startBeaconService()
            return START_STICKY
        } catch (e: Exception) {
            logError("Error in onStartCommand: ${e.message}", e)
            stopSelf()
            return START_NOT_STICKY
        }
    }

    override fun onDestroy() {
        isServiceRunning = false
        instance = null
        stopBeaconService()
        super.onDestroy()
    }
} 
