package com.uniguard.ugz_app.api

import com.google.gson.annotations.SerializedName
import com.uniguard.ugz_app.utils.Proximity
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST
import java.text.SimpleDateFormat
import java.util.*

// Model for scanning beacons
data class BeaconScanData(
    @SerializedName("uuid")
    val uuid: String? = "",
    
    @SerializedName("name")
    val name: String = "",
    
    @SerializedName("mac_address")
    val macAddress: String = "",
    
    @SerializedName("major")
    val major: Int,
    
    @SerializedName("minor")
    val minor: Int,
    
    @SerializedName("proximity")
    var proximity: String = "",
    
    @SerializedName("distance")
    val distance: Double,
    
    @SerializedName("tx_power")
    val txPower: Int,
    
    @SerializedName("rssi")
    val rssi: Int,
    
    @SerializedName("timestamp")
    val timestamp: Long,
    
    @SerializedName("latitude")
    val latitude: Double?,
    
    @SerializedName("longitude")
    val longitude: Double?
) {
    companion object {
        fun getProximityOfBeacon(beacon: org.altbeacon.beacon.Beacon): Proximity {
            return if (beacon.distance < 0.5) {
                Proximity.IMMEDIATE
            } else if (beacon.distance > 0.5 && beacon.distance < 3.0) {
                Proximity.NEAR
            } else if (beacon.distance > 3.0) {
                Proximity.FAR
            } else {
                Proximity.UNKNOWN
            }
        }
    }
}

// Model for uploading beacons
data class BeaconData(
    @SerializedName("major_value")
    val major_value: Int,
    
    @SerializedName("minor_value")
    val minor_value: Int,
    
    @SerializedName("battery_level")
    val battery_level: Int
)

data class LocationRequest(
    @SerializedName("type")
    val type: String,
    
    @SerializedName("latitude")
    val latitude: Double,
    
    @SerializedName("longitude")
    val longitude: Double,
    
    @SerializedName("original_submitted_time")
    val original_submitted_time: String,
    
    @SerializedName("beacon")
    val beacon: BeaconData?
) {
    companion object {
        fun create(
            type: String,
            latitude: Double,
            longitude: Double,
            timestamp: Long,
            beacon: BeaconData?
        ): LocationRequest {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
            val utcTime = dateFormat.format(Date(timestamp))
            
            return LocationRequest(
                type = type,
                latitude = latitude,
                longitude = longitude,
                original_submitted_time = utcTime,
                beacon = beacon
            )
        }
    }
}

interface BeaconApi {
    @POST("/mobile-api/admin/checkpoint/log")
    suspend fun submitLocation(@Body request: LocationRequest): Response<Unit>
} 