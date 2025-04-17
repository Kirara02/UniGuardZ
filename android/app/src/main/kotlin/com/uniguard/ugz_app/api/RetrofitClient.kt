package com.uniguard.ugz_app.api

import com.uniguard.ugz_app.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object RetrofitClient {
    private const val BASE_URL = "https://ugz-api-668795567730.asia-southeast1.run.app" // Ganti dengan base URL API Anda
    private var currentHeaders: Map<String, String> = emptyMap()

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor { chain ->
            val original = chain.request()
            val builder = original.newBuilder()
            
            // Add all headers
            currentHeaders.forEach { (key, value) ->
                builder.header(key, value)
            }
            
            chain.proceed(builder.build())
        }
        .addInterceptor(HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        })
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create(GsonConfig.gson))
        .build()

    val apiService: ApiService = retrofit.create(ApiService::class.java)

    fun updateHeaders(headers: Map<String, String>) {
        currentHeaders = headers
    }
} 