package com.uniguard.ugz_app.api

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.*

// Model for uploading beacons
data class BeaconData(
    @SerializedName("major_value")
    val majorValue: Int,
    
    @SerializedName("minor_value")
    val minorValue: Int,
    
    @SerializedName("battery_level")
    val batteryLevel: Int
)

data class BeaconRequest(
    @SerializedName("type")
    val type: String,
    
    @SerializedName("latitude")
    val latitude: Double,
    
    @SerializedName("longitude")
    val longitude: Double,
    
    @SerializedName("original_submitted_time")
    val originalSubmittedTime: String,
    
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
        ): BeaconRequest {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
            val utcTime = dateFormat.format(Date(timestamp))
            
            return BeaconRequest(
                type = type,
                latitude = latitude,
                longitude = longitude,
                originalSubmittedTime = utcTime,
                beacon = beacon
            )
        }
    }
}

data class LocationRequest (
    @SerializedName("latitude")
    val latitude: Double,

    @SerializedName("longitude")
    val longitude: Double,

    @SerializedName("original_submitted_time")
    val originalSubmittedTime: String,
) {
    companion object {
        fun create(
            latitude: Double,
            longitude: Double,
            timestamp: Long,
        ) : LocationRequest {
            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
            val utcTime = dateFormat.format(Date(timestamp))

            return LocationRequest(
                latitude = latitude,
                longitude = longitude,
                originalSubmittedTime = utcTime
            )
        }
    }
}


