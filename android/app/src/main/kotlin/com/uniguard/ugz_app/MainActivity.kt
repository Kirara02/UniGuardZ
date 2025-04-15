package com.uniguard.ugz_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.uniguard.ugz_app/beacon_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val token = call.argument<String>("token") ?: ""
                    val beaconIds = call.argument<List<String>>("beaconIds") ?: emptyList()
                    val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
                    
                    // Start the service with initialization parameters
                    val intent = Intent(this, BeaconService::class.java).apply {
                        putExtra("token", token)
                        putExtra("beaconIds", beaconIds.toTypedArray())
                        putExtra("headers", headers as HashMap<String, String>)
                    }
                    startService(intent)
                    result.success(null)
                }
                "startBeaconService" -> {
                    startService(Intent(this, BeaconService::class.java))
                    result.success(null)
                }
                "stopBeaconService" -> {
                    stopService(Intent(this, BeaconService::class.java))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}

