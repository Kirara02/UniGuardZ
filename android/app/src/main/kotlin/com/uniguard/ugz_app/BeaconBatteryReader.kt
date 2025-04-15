package com.uniguard.ugz_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.util.Log
import androidx.annotation.RequiresPermission
import org.altbeacon.beacon.Beacon
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class BeaconBatteryReader(private val context: Context) {
    private var gatt: BluetoothGatt? = null
    private var batteryLevel: Int = 0 // Default value
    private var isReading = false
    private var connectionLatch: CountDownLatch? = null
    private val bluetoothManager: BluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter = bluetoothManager.adapter

    companion object {
        private const val TAG = "BeaconBatteryReader"
        private val BATTERY_SERVICE_UUID = UUID.fromString("0000180f-0000-1000-8000-00805f9b34fb")
        private val BATTERY_LEVEL_CHARACTERISTIC_UUID = UUID.fromString("00002a19-0000-1000-8000-00805f9b34fb")
        private const val CONNECTION_TIMEOUT_MS = 5000L
    }

    private val gattCallback = object : BluetoothGattCallback() {
        @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "Connected to GATT server")
                }
                gatt.discoverServices()
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "Disconnected from GATT server")
                }
                this@BeaconBatteryReader.gatt = null
                isReading = false
                connectionLatch?.countDown()
            }
        }

        @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "Services discovered")
                }
                val batteryService = gatt.getService(BATTERY_SERVICE_UUID)
                if (batteryService != null) {
                    val batteryLevelChar = batteryService.getCharacteristic(BATTERY_LEVEL_CHARACTERISTIC_UUID)
                    if (batteryLevelChar != null) {
                        if (BuildConfig.DEBUG) {
                            Log.d(TAG, "Reading battery level characteristic")
                        }
                        gatt.readCharacteristic(batteryLevelChar)
                    } else {
                        if (BuildConfig.DEBUG) {
                            Log.d(TAG, "Battery level characteristic not found")
                        }
                        disconnect()
                    }
                } else {
                    if (BuildConfig.DEBUG) {
                        Log.d(TAG, "Battery service not found")
                    }
                    disconnect()
                }
            } else {
                if (BuildConfig.DEBUG) {
                    Log.e(TAG, "Service discovery failed with status: $status")
                }
                disconnect()
            }
        }

        @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray,
            status: Int
        ) {
            if (status == BluetoothGatt.GATT_SUCCESS && characteristic.uuid == BATTERY_LEVEL_CHARACTERISTIC_UUID) {
                batteryLevel = value[0].toInt() and 0xFF
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "Battery level: $batteryLevel%")
                }
            } else {
                if (BuildConfig.DEBUG) {
                    Log.e(TAG, "Failed to read battery level, status: $status")
                }
            }
            disconnect()
        }
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    fun readBatteryLevel(beacon: Beacon): Int {
        if (isReading) {
            return batteryLevel
        }

        isReading = true
        batteryLevel = 0 // Reset to default
        connectionLatch = CountDownLatch(1)

        try {
            val macAddress = beacon.bluetoothAddress
            if (macAddress != null) {
                val bluetoothDevice = bluetoothAdapter.getRemoteDevice(macAddress)
                if (bluetoothDevice != null) {
                    if (BuildConfig.DEBUG) {
                        Log.d(TAG, "Connecting to device: $macAddress")
                    }
                    gatt = bluetoothDevice.connectGatt(context, false, gattCallback)
                    
                    // Wait for connection to complete or timeout
                    if (!connectionLatch?.await(CONNECTION_TIMEOUT_MS, TimeUnit.MILLISECONDS)!!) {
                        if (BuildConfig.DEBUG) {
                            Log.e(TAG, "Connection timeout")
                        }
                        disconnect()
                    }
                }
            }
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Error reading battery level", e)
            }
            isReading = false
        }

        return batteryLevel
    }

    @RequiresPermission(Manifest.permission.BLUETOOTH_CONNECT)
    private fun disconnect() {
        try {
            gatt?.disconnect()
            gatt?.close()
            gatt = null
            isReading = false
            connectionLatch?.countDown()
            connectionLatch = null
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Error during disconnect", e)
            }
        }
    }
} 