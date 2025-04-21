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

class LocationUploadService : Service() {
    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var uploadTimer: Timer? = null
    private var uploadInterval: Long = 60000 // Default 1 minute
    private var isServiceRunning = false

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

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(applicationContext)
        
        // Check permissions on service start
        val hasFineLocation = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val hasCoarseLocation = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasFineLocation && !hasCoarseLocation) {
            logDebug("Location permissions not granted, stopping service")
            stopSelf()
            return
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
        // Start foreground service
        startForeground(NOTIFICATION_ID, createNotification())
        
        // Start upload timer
        uploadTimer = Timer()
        scheduleNextUpload()
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
            // Check location permissions
            val hasFineLocation = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED

            val hasCoarseLocation = ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED

            if (!hasFineLocation && !hasCoarseLocation) {
                logDebug("Location permissions not granted")
                return null
            }

            val location = fusedLocationClient.getCurrentLocation(
                Priority.PRIORITY_HIGH_ACCURACY,
                object : CancellationToken() {
                    override fun onCanceledRequested(listener: OnTokenCanceledListener) = CancellationTokenSource().token
                    override fun isCancellationRequested() = false
                }
            ).await()

            location
        } catch (e: SecurityException) {
            logDebug("SecurityException while getting location: ${e.message}")
            null
        } catch (e: Exception) {
            logDebug("Error getting location: ${e.message}")
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
        
        intent?.let {
            // Get upload interval from intent
            uploadInterval = it.getLongExtra(EXTRA_INTERVAL, 60000)
        }
        
        startLocationUpload()
        return START_STICKY
    }

    override fun onDestroy() {
        isServiceRunning = false
        instance = null
        logDebug("Service is being destroyed")
        stopLocationUpload()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
} 