package com.uniguard.ugz_app.utils

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import com.uniguard.ugz_app.BuildConfig

class ServiceChecker(private val context: Context) {
    companion object {
        private const val TAG = "ServiceChecker"
    }
    
    private fun logDebug(message: String) {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, message)
        }
    }
    
    fun checkNotificationPermission(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val result = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            logDebug("Notification permission (Android 13+): $result")
            result
        } else {
            logDebug("Notification permission not required (Android 12 and below)")
            true
        }
        return hasPermission
    }
    
    private fun checkBluetoothPermissions(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12 and above
            val scanPermission = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_SCAN
            ) == PackageManager.PERMISSION_GRANTED
            val connectPermission = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
            
            logDebug("Bluetooth permissions (Android 12+):")
            logDebug("- BLUETOOTH_SCAN: $scanPermission")
            logDebug("- BLUETOOTH_CONNECT: $connectPermission")
            
            if (!scanPermission) {
                logDebug("Missing BLUETOOTH_SCAN permission")
            }
            if (!connectPermission) {
                logDebug("Missing BLUETOOTH_CONNECT permission")
            }
            
            scanPermission && connectPermission
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 and 11
            val fineLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            val backgroundLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            
            logDebug("Bluetooth permissions (Android 10-11):")
            logDebug("- ACCESS_FINE_LOCATION: $fineLocation")
            logDebug("- ACCESS_BACKGROUND_LOCATION: $backgroundLocation")
            
            if (!fineLocation) {
                logDebug("Missing ACCESS_FINE_LOCATION permission")
            }
            if (!backgroundLocation) {
                logDebug("Missing ACCESS_BACKGROUND_LOCATION permission")
            }
            
            fineLocation && backgroundLocation
        } else {
            // Android 9 and below
            val fineLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            
            logDebug("Bluetooth permissions (Android 9 and below):")
            logDebug("- ACCESS_FINE_LOCATION: $fineLocation")
            
            if (!fineLocation) {
                logDebug("Missing ACCESS_FINE_LOCATION permission")
            }
            
            fineLocation
        }
        return hasPermission
    }

    private fun checkLocationPermissions(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 and above
            val fineLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            val backgroundLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            
            logDebug("Location permissions (Android 10+):")
            logDebug("- ACCESS_FINE_LOCATION: $fineLocation")
            logDebug("- ACCESS_BACKGROUND_LOCATION: $backgroundLocation")
            
            fineLocation && backgroundLocation
        } else {
            // Android 9 and below
            val fineLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            val coarseLocation = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            
            logDebug("Location permissions (Android 9 and below):")
            logDebug("- ACCESS_FINE_LOCATION: $fineLocation")
            logDebug("- ACCESS_COARSE_LOCATION: $coarseLocation")
            
            fineLocation || coarseLocation
        }
        return hasPermission
    }

    private fun checkForegroundServicePermissions(): Boolean {
        val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 and above
            var foregroundService = true
            var foregroundServiceLocation = true

            foregroundService = ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.FOREGROUND_SERVICE
            ) == PackageManager.PERMISSION_GRANTED

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                foregroundServiceLocation = ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.FOREGROUND_SERVICE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
            }
            
            logDebug("Foreground service permissions (Android 10+):")
            logDebug("- FOREGROUND_SERVICE: $foregroundService")
            logDebug("- FOREGROUND_SERVICE_LOCATION: $foregroundServiceLocation")
            
            foregroundService && foregroundServiceLocation
        } else {
            // Android 9 and below - no foreground service permission required
            logDebug("Foreground service permissions (Android 9 and below):")
            logDebug("- No foreground service permission required")
            true
        }
        return hasPermission
    }

    fun isBluetoothEnabled(): Boolean {
        val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        val isEnabled = bluetoothAdapter?.isEnabled == true
        logDebug("Bluetooth enabled: $isEnabled")
        return isEnabled
    }

    fun isLocationEnabled(): Boolean {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val networkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        
        logDebug("Location services status:")
        logDebug("- GPS enabled: $gpsEnabled")
        logDebug("- Network enabled: $networkEnabled")
        
        return gpsEnabled || networkEnabled
    }

    fun canStartBeaconService(): Boolean {
        val notificationPermission = checkNotificationPermission()
        val bluetoothPermissions = checkBluetoothPermissions()
        val locationPermissions = checkLocationPermissions()
        val bluetoothEnabled = isBluetoothEnabled()
        val locationEnabled = isLocationEnabled()
        
        logDebug("Beacon service requirements:")
        logDebug("- Notification permission: $notificationPermission")
        logDebug("- Bluetooth permissions: $bluetoothPermissions")
        logDebug("- Location permissions: $locationPermissions")
        logDebug("- Bluetooth enabled: $bluetoothEnabled")
        logDebug("- Location enabled: $locationEnabled")
        
        return notificationPermission && 
               bluetoothPermissions && 
               locationPermissions && 
               bluetoothEnabled && 
               locationEnabled
    }

    fun canStartLocationService(): Boolean {
        val notificationPermission = checkNotificationPermission()
        val locationPermissions = checkLocationPermissions()
        val foregroundServicePermissions = checkForegroundServicePermissions()
        val locationEnabled = isLocationEnabled()
        
        logDebug("Location service requirements:")
        logDebug("- Notification permission: $notificationPermission")
        logDebug("- Location permissions: $locationPermissions")
        logDebug("- Foreground service permissions: $foregroundServicePermissions")
        logDebug("- Location enabled: $locationEnabled")
        
        return notificationPermission && 
               locationPermissions && 
               foregroundServicePermissions &&
               locationEnabled
    }

    fun getRequiredPermissions(): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13 and above
            val permissions = mutableListOf(
                Manifest.permission.POST_NOTIFICATIONS,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                Manifest.permission.FOREGROUND_SERVICE
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                permissions.add(Manifest.permission.FOREGROUND_SERVICE_LOCATION)
            }

            permissions.toTypedArray()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12
            val permissions = mutableListOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            )

            permissions.toTypedArray()
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10 and 11
            val permissions = mutableListOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_BACKGROUND_LOCATION
            )

            permissions.toTypedArray()
        } else {
            // Android 9 and below
            arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }
    }
} 