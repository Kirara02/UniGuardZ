package com.uniguard.ugz_app.api

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST

interface ApiService {
    @POST("/mobile-api/admin/checkpoint/log")
    suspend fun submitBeacon(@Body request: BeaconRequest): Response<Unit>

    @POST("/mobile-api/admin/geolocation/log/interval")
    suspend fun submitLocation(@Body request: LocationRequest): Response<Unit>
}