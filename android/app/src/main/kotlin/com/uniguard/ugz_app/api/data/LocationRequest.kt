package com.uniguard.ugz_app.api.data

import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

data class LocationRequest(
    @SerializedName("latitude")
    val latitude: Double,

    @SerializedName("longitude")
    val longitude: Double,

    @SerializedName("original_submitted_time")
    val originalSubmittedTime: String
) {
    companion object {
        fun create(
            latitude: Double,
            longitude: Double,
            timestamp: Long
        ): LocationRequest {
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

    override fun toString(): String {
        return "LocationRequest(latitude=$latitude, longitude=$longitude, originalSubmittedTime='$originalSubmittedTime')"
    }
}