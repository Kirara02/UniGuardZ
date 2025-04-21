package com.uniguard.ugz_app

import android.content.Intent
import android.os.Build
import android.util.Log
import com.uniguard.ugz_app.api.RetrofitClient
import com.uniguard.ugz_app.service.BeaconService
import com.uniguard.ugz_app.service.LocationUploadService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.uniguard.ugz_app/uniguard_service"
    private val TAG = "MainActivity"

    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        return when (serviceClass) {
            LocationUploadService::class.java -> LocationUploadService.isRunning()
            BeaconService::class.java -> BeaconService.isRunning()
            else -> false
        }
    }

    private fun startLocationUploadService(interval: Long) {
        if (isServiceRunning(LocationUploadService::class.java)) {
            return
        }

        if (interval <= 0) {
            return
        }

        val intent = Intent(this, LocationUploadService::class.java).apply {
            putExtra(LocationUploadService.EXTRA_INTERVAL, interval)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }

    }

    private fun stopLocationUploadService() {
        if (!isServiceRunning(LocationUploadService::class.java)) {
            return
        }

        val intent = Intent(this, LocationUploadService::class.java)
        stopService(intent)
    }

    private fun initializeService(headers: Map<String, String>) {
        try {
            Log.i(TAG, "Initializing service with headers")
            
            // Update Retrofit client with headers
            RetrofitClient.updateHeaders(headers)
            
            // Add Bearer prefix to Authorization header if it exists
            val updatedHeaders = headers.toMutableMap()
            headers["Authorization"]?.let { authHeader ->
                if (!authHeader.startsWith("Bearer ")) {
                    updatedHeaders["Authorization"] = "Bearer $authHeader"
                }
            }
            
            // Update Retrofit client with updated headers
            RetrofitClient.updateHeaders(updatedHeaders)
            
            Log.i(TAG, "Service initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing service: ${e.message}", e)
            throw e
        }
    }

    private fun startBeaconService() {
        if (isServiceRunning(BeaconService::class.java)) {
            return
        }

        val intent = Intent(this, BeaconService::class.java)
        startService(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "initializeService" -> {
                        val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
                        initializeService(headers)
                        result.success(null)
                    }
                    "startBeaconService" -> {
                        startBeaconService()
                        result.success(null)
                    }
                    "stopBeaconService" -> {
                        if (!isServiceRunning(BeaconService::class.java)) {
                            result.success(null)
                            return@setMethodCallHandler
                        }

                        val intent = Intent(this, BeaconService::class.java)
                        stopService(intent)
                        result.success(null)
                    }
                    "isBeaconServiceRunning" -> {
                        val isRunning = isServiceRunning(BeaconService::class.java)
                        result.success(isRunning)
                    }
                    "startLocationUploadService" -> {
                        val interval = (call.argument<Number>("interval") ?: 0).toLong()
                        
                        if (interval <= 0) {
                            result.error("INVALID_INTERVAL", "Interval must be greater than 0", null)
                            return@setMethodCallHandler
                        }
                        
                        startLocationUploadService(interval)
                        result.success(null)
                    }
                    "stopLocationUploadService" -> {
                        stopLocationUploadService()
                        result.success(null)
                    }
                    "isLocationUploadServiceRunning" -> {
                        val isRunning = isServiceRunning(LocationUploadService::class.java)
                        result.success(isRunning)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling method call ${call.method}: ${e.message}", e)
                result.error("SERVICE_ERROR", "Failed to handle ${call.method}", e.message)
            }
        }
    }
}

