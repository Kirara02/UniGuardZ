package com.uniguard.ugz_app.api

import com.uniguard.ugz_app.api.data.BeaconResponse
import com.uniguard.ugz_app.api.data.LocationResponse
import retrofit2.http.Body
import retrofit2.http.POST

interface ApiService {
    @POST("/mobile-api/admin/checkpoint/log")
    suspend fun submitBeacon(@Body request: BeaconRequest): BeaconResponse

    @POST("/mobile-api/admin/geolocation/log/interval")
    suspend fun submitLocation(@Body request: LocationRequest): LocationResponse
}