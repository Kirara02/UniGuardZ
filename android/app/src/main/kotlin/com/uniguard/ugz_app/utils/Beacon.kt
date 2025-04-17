package com.uniguard.ugz_app.utils

import com.google.gson.annotations.SerializedName
import com.uniguard.ugz_app.utils.Proximity

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