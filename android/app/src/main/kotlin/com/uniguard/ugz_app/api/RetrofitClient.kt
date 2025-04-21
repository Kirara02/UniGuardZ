package com.uniguard.ugz_app.api

import android.util.Log
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.uniguard.ugz_app.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object RetrofitClient {
    private const val TAG = "RetrofitClient"
    private const val BASE_URL = "https://ugz-api-668795567730.asia-southeast1.run.app"
    private var currentHeaders: Map<String, String> = emptyMap()

    private val gson: Gson = GsonBuilder()
        .setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        .create()

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor { chain ->
            val original = chain.request()
            val builder = original.newBuilder()
            
            // Add all headers
            currentHeaders.forEach { (key, value) ->
                builder.header(key, value)
            }
            
            val request = builder.build()
            
            // Log request details only in debug mode
            if (BuildConfig.DEBUG) {
                Log.d(TAG, "Request URL: ${request.url}")
                Log.d(TAG, "Request Headers: ${request.headers}")
            }
            
            chain.proceed(request)
        }
        .addInterceptor(HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        })
        .addInterceptor { chain ->
            try {
                val response = chain.proceed(chain.request())
                if (BuildConfig.DEBUG) {
                    Log.d(TAG, "Response Code: ${response.code}")
                    Log.d(TAG, "Response Headers: ${response.headers}")
                }
                response
            } catch (e: Exception) {
                if (BuildConfig.DEBUG) {
                    Log.e(TAG, "Network error: ${e.message}", e)
                }
                throw e
            }
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create(gson))
        .build()

    val apiService: ApiService = retrofit.create(ApiService::class.java)

    fun updateHeaders(headers: Map<String, String>) {
        currentHeaders = headers
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "Headers updated: ${headers.keys}")
        }
    }
} 