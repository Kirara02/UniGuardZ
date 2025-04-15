package com.uniguard.ugz_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import com.uniguard.ugz_app.api.BeaconData
import com.uniguard.ugz_app.api.BeaconScanData
import com.uniguard.ugz_app.api.LocationRequest
import com.uniguard.ugz_app.api.RetrofitClient
import com.uniguard.ugz_app.BuildConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.altbeacon.beacon.Beacon
import org.altbeacon.beacon.BeaconManager
import org.altbeacon.beacon.BeaconParser
import org.altbeacon.beacon.MonitorNotifier
import org.altbeacon.beacon.RangeNotifier
import org.altbeacon.beacon.Region
import java.util.concurrent.atomic.AtomicInteger
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import org.altbeacon.beacon.service.RunningAverageRssiFilter
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.ConcurrentHashMap
import com.uniguard.ugz_app.BeaconBatteryReader
import kotlinx.coroutines.SupervisorJob

class BeaconService : Service(), RangeNotifier, MonitorNotifier {
    private lateinit var channel: MethodChannel
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isScanning = false
    private val notificationId = AtomicInteger(0)
    private lateinit var beaconManager: BeaconManager
    private var validBeaconIds: List<String> = emptyList()
    private var authToken: String = ""
    private var headers: Map<String, String> = emptyMap()
    private val scannedBeacons = mutableMapOf<String, BeaconScanData>()
    private var beaconBuffer = mutableMapOf<String, BeaconScanData>()
    private var uploadTimer: Timer? = null
    private val UPLOAD_INTERVAL = 60000L // 1 minute in milliseconds
    private val SCAN_INTERVAL = 1000L // 1 second in milliseconds
    private val batteryReader = BeaconBatteryReader(this)

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
    }

    override fun onCreate() {
        super.onCreate()
        logDebug("BeaconService onCreate called")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        
        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.uniguard.ugz_app/beacon_service")
        setupMethodChannel()
        
        // Initialize BeaconManager with multiple beacon layouts
        BeaconManager.setRssiFilterImplClass(RunningAverageRssiFilter::class.java)
        beaconManager = BeaconManager.getInstanceForApplication(this)
        logDebug("BeaconManager initialized")
        
        // Add support for iBeacon
        beaconManager.beaconParsers.add(BeaconParser().setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24"))
        logDebug("Added iBeacon parser")
        
        // Add support for AltBeacon
        beaconManager.beaconParsers.add(BeaconParser().setBeaconLayout("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25"))
        logDebug("Added AltBeacon parser")
        
        beaconManager.addRangeNotifier(this)
        beaconManager.addMonitorNotifier(this)
        
        // Set scan interval to 1 second
        beaconManager.foregroundScanPeriod = SCAN_INTERVAL
        beaconManager.foregroundBetweenScanPeriod = 0
        beaconManager.backgroundScanPeriod = SCAN_INTERVAL
        beaconManager.backgroundBetweenScanPeriod = 0

        logDebug("Scan intervals set - ForegroundScanPeriod: $SCAN_INTERVAL, BetweenScanPeriod: 0")
        
        // Start scanning immediately
        startBeaconService()
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
        .setContentText("Scanning for beacons...")
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .build()

    private fun setupMethodChannel() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val token = call.argument<String>("token") ?: ""
                    val beaconIds = call.argument<List<String>>("beaconIds") ?: emptyList()
                    val headersMap = call.argument<Map<String, String>>("headers") ?: emptyMap()
                    initialize(token, beaconIds, headersMap)
                    result.success(null)
                }
                "startBeaconService" -> {
                    startBeaconService()
                    result.success(null)
                }
                "stopBeaconService" -> {
                    stopBeaconService()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initialize(token: String, beaconIds: List<String>, headers: Map<String, String>) {
        this.authToken = token
        this.headers = headers
        
        // Update Retrofit client with new headers
        RetrofitClient.updateHeaders(headers + mapOf("Authorization" to "Bearer $token"))
        
        logDebug("BeaconService initialized with token and headers")
    }

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
            logDebug("Attempting to start beacon service...")
            isScanning = true
            try {
                // Ensure we're running in foreground
                startForeground(NOTIFICATION_ID, createNotification())
                
                val region = Region("all-beacons-region", null, null, null)
                logDebug("Starting ranging beacons in region: $region")
                beaconManager.startRangingBeacons(region)
                startUploadTimer()
                logDebug("Beacon service started successfully in foreground mode")
                logDebug("Scan interval set to: $SCAN_INTERVAL ms")
                logDebug("Upload interval set to: $UPLOAD_INTERVAL ms")
                
                // Add debug log to verify scanning is active
                logDebug("Beacon scanning is now active and running in foreground mode")
            } catch (e: Exception) {
                logError("Error starting beacon service", e)
                isScanning = false
                stopForegroundCompat()
            }
        } else {
            logDebug("Beacon service is already running")
        }
    }

    private fun stopBeaconService() {
        if (isScanning) {
            logDebug("Attempting to stop beacon service...")
            isScanning = false
            try {
                beaconManager.stopRangingBeacons(Region("all-beacons-region", null, null, null))
                stopUploadTimer()
                beaconBuffer.clear()
                stopForegroundCompat()
                logDebug("Beacon service stopped successfully")
            } catch (e: Exception) {
                logError("Error stopping beacon service", e)
            }
        } else {
            logDebug("Beacon service is already stopped")
        }
    }

    private fun startUploadTimer() {
        logDebug("Starting upload timer with interval: $UPLOAD_INTERVAL ms")
        uploadTimer = Timer()
        scheduleNextUpload()
    }

    private fun scheduleNextUpload() {
        uploadTimer?.schedule(object : TimerTask() {
            override fun run() {
                logDebug("Upload timer triggered at ${System.currentTimeMillis()}")
                uploadBufferedBeacons()
                scheduleNextUpload()
            }
        }, UPLOAD_INTERVAL)
    }

    private fun stopUploadTimer() {
        uploadTimer?.cancel()
        uploadTimer = null
    }

    // RangeNotifier implementation
    override fun didRangeBeaconsInRegion(beacons: Collection<Beacon>, region: Region) {
        logDebug("didRangeBeaconsInRegion called - isScanning: $isScanning")
        if (!isScanning) {
            logDebug("Not scanning, returning")
            return
        }

        // Process all detected beacons without UUID validation
        if (beacons.isNotEmpty()) {
            beacons.forEach { beacon ->
                val beaconJson = "{\n" +
                    "  \"name\": \"${beacon.bluetoothName ?: "Unknown"}\",\n" +
                    "  \"uuid\": \"${beacon.id1}\",\n" +
                    "  \"macAddress\": \"${beacon.bluetoothAddress ?: "Unknown"}\",\n" +
                    "  \"major\": \"${beacon.id2?.toInt() ?: 0}\",\n" +
                    "  \"minor\": \"${beacon.id3?.toInt() ?: 0}\",\n" +
                    "  \"distance\": \"${beacon.distance}\",\n" +
                    "  \"proximity\": \"${BeaconScanData.getProximityOfBeacon(beacon).value}\",\n" +
                    "  \"scanTime\": \"${System.currentTimeMillis()}\",\n" +
                    "  \"rssi\": \"${beacon.rssi}\",\n" +
                    "  \"txPower\": \"${beacon.txPower}\"\n" +
                    "}"
                
                logDebug("Beacon Data: $beaconJson")
                
                // Update beacon buffer with latest data
                val beaconKey = "${beacon.id1}-${beacon.id2}-${beacon.id3}"
                beaconBuffer[beaconKey] = BeaconScanData(
                    uuid = beacon.id1.toString(),
                    name = beacon.bluetoothName ?: "Unknown",
                    macAddress = beacon.bluetoothAddress ?: "Unknown",
                    major = beacon.id2?.toInt() ?: 0,
                    minor = beacon.id3?.toInt() ?: 0,
                    distance = beacon.distance,
                    txPower = beacon.txPower,
                    proximity = BeaconScanData.getProximityOfBeacon(beacon).value,
                    rssi = beacon.rssi,
                    timestamp = System.currentTimeMillis(),
                    latitude = null,
                    longitude = null
                )
            }
            logDebug("{\"buffer_size\": \"${beaconBuffer.size}\"}")
        } else {
            logDebug("{\"status\": \"no_beacons_detected\", \"timestamp\": \"${System.currentTimeMillis()}\"}")
        }
    }

    private fun uploadBufferedBeacons() {
        if (beaconBuffer.isEmpty()) {
            logDebug("{\"status\": \"no_beacons_to_upload\", \"buffer_empty\": \"true\"}")
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

                logDebug("{\"status\": \"starting_upload\", \"beacon_count\": \"${beaconBuffer.size}\", \"location\": {\"latitude\": \"${location.latitude}\", \"longitude\": \"${location.longitude}\"}}")

                // Upload all beacons in the buffer
                beaconBuffer.values.forEach { beaconData ->
                    val beaconInfo = "{\"uuid\": \"${beaconData.uuid}\", \"major\": \"${beaconData.major}\", \"minor\": \"${beaconData.minor}\"}"
                    logDebug("Uploading Beacon: $beaconInfo")
                    
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

                    // Get battery level if beacon is available
                    val batteryLevel = beacon?.let { batteryReader.readBatteryLevel(it) } ?: 0
                    
                    val request = LocationRequest.create(
                        type = "beacon",
                        latitude = location.latitude,
                        longitude = location.longitude,
                        timestamp = System.currentTimeMillis(),
                        beacon = BeaconData(
                            major_value = beaconData.major,
                            minor_value = beaconData.minor,
                            battery_level = batteryLevel
                        )
                    )

                    try {
                        val response = RetrofitClient.beaconApi.submitLocation(request)
                        if (response.isSuccessful) {
                            logDebug("{\"status\": \"upload_success\", \"beacon\": $beaconInfo, \"battery_level\": $batteryLevel}")
                        } else {
                            logError("{\"status\": \"upload_failed\", \"beacon\": $beaconInfo, \"battery_level\": $batteryLevel, \"http_code\": \"${response.code()}\", \"error\": \"${response.errorBody()?.string()}\"}")
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
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            
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

            // Try to get last known location from GPS provider
            var location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            
            // If GPS location is not available, try network provider
            if (location == null) {
                location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
            }
            
            location
        } catch (e: Exception) {
            logError("Error getting location", e)
            null
        }
    }

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
        // Handle initialization parameters if they exist
        intent?.let {
            if (it.hasExtra("token") && it.hasExtra("beaconIds") && it.hasExtra("headers")) {
                val token = it.getStringExtra("token") ?: ""
                val beaconIds = it.getStringArrayExtra("beaconIds")?.toList() ?: emptyList()
                val headers = it.getSerializableExtra("headers") as? HashMap<String, String> ?: emptyMap()
                
                initialize(token, beaconIds, headers)
            }
        }
        
        return START_STICKY
    }

    override fun onDestroy() {
        logDebug("Service is being destroyed")
        stopBeaconService()
        beaconManager.removeRangeNotifier(this)
        beaconManager.removeMonitorNotifier(this)
        super.onDestroy()
    }
} 
