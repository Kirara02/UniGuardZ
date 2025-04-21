package com.uniguard.ugz_app.api.data

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

data class BeaconData(
    @SerializedName("major_value")
    val majorValue: Int,

    @SerializedName("minor_value")
    val minorValue: Int,

    @SerializedName("battery_level")
    val batteryLevel: Int
) {
    companion object {
        fun create(major: Int, minor: Int, battery: Int): BeaconData {
            return BeaconData(
                majorValue = major,
                minorValue = minor,
                batteryLevel = battery
            )
        }
    }

    override fun toString(): String {
        return "BeaconData(majorValue=$majorValue, minorValue=$minorValue, batteryLevel=$batteryLevel)"
    }
}

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
    val beacon: BeaconData
) {
    companion object {
        fun create(
            type: String,
            latitude: Double,
            longitude: Double,
            timestamp: Long,
            beacon: BeaconData
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

    override fun toString(): String {
        return "BeaconRequest(type='$type', latitude=$latitude, longitude=$longitude, originalSubmittedTime='$originalSubmittedTime', beacon=$beacon)"
    }
}
