package com.uniguard.ugz_app.service

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.android.gms.tasks.CancellationToken
import com.google.android.gms.tasks.CancellationTokenSource
import com.google.android.gms.tasks.OnTokenCanceledListener
import com.uniguard.ugz_app.BuildConfig
import com.uniguard.ugz_app.MainActivity
import com.uniguard.ugz_app.R
import com.uniguard.ugz_app.api.RetrofitClient
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import java.util.Timer
import java.util.TimerTask
import com.uniguard.ugz_app.utils.ServiceChecker

class LocationUploadService : Service() {
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var uploadTimer: Timer? = null
    private var uploadInterval: Long = 60000 // Default 1 minute
    private var isServiceRunning = false
    private lateinit var serviceChecker: ServiceChecker

    companion object {
        private const val CHANNEL_ID = "LocationUploadServiceChannel"
        private const val NOTIFICATION_ID = 2
        private const val TAG = "LocationUploadService"
        const val EXTRA_INTERVAL = "upload_interval"

        fun isRunning(): Boolean {
            return instance?.isServiceRunning ?: false
        }

        private var instance: LocationUploadService? = null
    }

    private fun logDebug(message: String) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, message)
        }
    }

    private fun logError(message: String, e: Exception? = null) {
        Log.e(TAG, message, e)
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        
        try {
            createNotificationChannel()
            serviceChecker = ServiceChecker(applicationContext)
            
            if (!serviceChecker.canStartLocationService()) {
                logError("Cannot start location service - Missing permissions or location disabled")
                stopSelf()
                return
            }

            fusedLocationClient = LocationServices.getFusedLocationProviderClient(applicationContext)
        } catch (e: Exception) {
            logError("Error in onCreate: ${e.message}", e)
            stopSelf()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Location Upload Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification() = NotificationCompat.Builder(this, CHANNEL_ID)
        .setContentTitle("Location Upload Service")
        .setContentText("Uploading location data")
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

    private fun startLocationUpload() {
        isServiceRunning = true
        
        try {
            startForeground(NOTIFICATION_ID, createNotification())
            uploadTimer = Timer()
            scheduleNextUpload()
            
            // Schedule a check to verify service is working
            Timer().schedule(object : TimerTask() {
                override fun run() {
                    if (!isServiceRunning) {
                        logError("Service is not running, attempting to restart...")
                        stopLocationUpload()
                        startLocationUpload()
                    }
                }
            }, 30000)
            
        } catch (e: Exception) {
            logError("Error starting location upload: ${e.message}", e)
            isServiceRunning = false
            stopForegroundCompat()
            stopSelf()
        }
    }

    private fun scheduleNextUpload() {
        uploadTimer?.schedule(object : TimerTask() {
            override fun run() {
                logDebug("Upload timer triggered")
                uploadLocation()
                scheduleNextUpload()
            }
        }, uploadInterval)
    }

    private fun uploadLocation() {
        coroutineScope.launch {
            try {
                val location = getCurrentLocation()
                if (location != null) {
                    
                    val request = com.uniguard.ugz_app.api.data.LocationRequest.create(
                        latitude = location.latitude,
                        longitude = location.longitude,
                        timestamp = System.currentTimeMillis()
                    )

//                    sendNotifikasi("Lokasi: ${location.latitude}, ${location.longitude}")

                    val response = RetrofitClient.apiService.submitLocation(request)
                    if (response.success) {
                        logDebug("Location uploaded successfully")
                    } else {
                        logDebug("Failed to upload location: ${response.message}")
                    }
                }
            } catch (e: Exception) {
                logDebug("Error uploading location: ${e.message}")
            }
        }
    }

    private suspend fun getCurrentLocation(): android.location.Location? {
        return try {
            if (!serviceChecker.canStartLocationService()) {
                logError("Location service not available")
                stopSelf()
                return null
            }

            val client = fusedLocationClient ?: run {
                logError("Location client not initialized")
                return null
            }

            val location = client.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                object : CancellationToken() {
                    override fun onCanceledRequested(listener: OnTokenCanceledListener) = CancellationTokenSource().token
                    override fun isCancellationRequested() = false
                }
            ).await()

            if (location == null) {
                logError("Location is null")
            }
            
            location
        } catch (e: SecurityException) {
            logError("SecurityException while getting location: ${e.message}", e)
            null
        } catch (e: Exception) {
            logError("Error getting location: ${e.message}", e)
            null
        }
    }

    private fun stopLocationUpload() {
        isServiceRunning = false
        uploadTimer?.cancel()
        uploadTimer = null
        stopForegroundCompat()
    }

    private fun stopForegroundCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
    }

//    private fun sendNotification(message: String) {
//        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
//            .setContentTitle("Upload Location")
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


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (!serviceChecker.canStartLocationService()) {
            logError("Cannot start location service - Missing permissions or location disabled")
            stopSelf()
            return START_NOT_STICKY
        }

        intent?.let {
            uploadInterval = it.getLongExtra(EXTRA_INTERVAL, 60000)
        }
        
        try {
            startLocationUpload()
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
        stopLocationUpload()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
} 