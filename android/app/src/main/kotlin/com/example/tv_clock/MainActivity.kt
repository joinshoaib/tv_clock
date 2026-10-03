package com.example.tv_clock

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.tv_clock/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    result.success(canDrawOverlays())
                }
                "requestPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "startOverlay" -> {
                    @Suppress("UNCHECKED_CAST")
                    val settings = call.arguments as? Map<String, Any>
                    saveSettingsAndStart(settings)
                    result.success(true)
                }
                "stopOverlay" -> {
                    clearOverlayEnabled()
                    stopOverlayService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun saveSettingsAndStart(settings: Map<String, Any>?) {
        val prefs = getSharedPreferences("tv_clock_overlay", Context.MODE_PRIVATE)
        prefs.edit().apply {
            putBoolean("overlay_enabled", true)
            if (settings != null) {
                putBoolean("is24HourFormat", settings["is24HourFormat"] as? Boolean ?: false)
                putBoolean("showSeconds", settings["showSeconds"] as? Boolean ?: true)
                putBoolean("showDate", settings["showDate"] as? Boolean ?: true)
                putString("theme", settings["theme"] as? String ?: "white")
                putFloat("size", ((settings["size"] as? Double)?.toFloat() ?: 48f))
                putFloat("opacity", ((settings["opacity"] as? Double)?.toFloat() ?: 0.9f))
                putString("position", settings["position"] as? String ?: "topRight")
                putString("color", settings["color"] as? String ?: "default")
            }
            apply()
        }

        val intent = Intent(this, OverlayService::class.java).apply {
            putExtra("settings", HashMap(settings ?: emptyMap()))
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun clearOverlayEnabled() {
        val prefs = getSharedPreferences("tv_clock_overlay", Context.MODE_PRIVATE)
        prefs.edit().putBoolean("overlay_enabled", false).apply()
    }

    private fun stopOverlayService() {
        val intent = Intent(this, OverlayService::class.java)
        stopService(intent)
    }
}