package com.example.tv_clock

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    private var timeTextView: TextView? = null
    private var dateTextView: TextView? = null
    private var clockContainer: LinearLayout? = null

    private var is24HourFormat = false
    private var showSeconds = true
    private var showDate = true
    private var theme = "white"
    private var clockSize = 48f
    private var clockOpacity = 0.9f
    private var position = "topRight"

    private val updateRunnable = object : Runnable {
        override fun run() {
            updateClock()
            handler.postDelayed(this, 1000)
        }
    }

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_ON -> startClock()
                Intent.ACTION_SCREEN_OFF -> stopClock()
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // Android 14+
            registerReceiver(screenReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(screenReceiver, filter)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val settings = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent?.getSerializableExtra("settings", HashMap::class.java) as? HashMap<String, *>
        } else {
            @Suppress("DEPRECATION")
            intent?.getSerializableExtra("settings") as? HashMap<String, *>
        }
        applySettings(settings)

        if (overlayView == null) {
            showOverlay()
        } else {
            applyTheme()
            applyPosition()
        }

        startForeground(1, buildNotification())
        startClock()

        return START_STICKY
    }

     private var customColor: String? = null

    private fun applySettings(settings: HashMap<String, *>?) {
        if (settings == null) return

        is24HourFormat = settings["is24HourFormat"] as? Boolean ?: false
        showSeconds = settings["showSeconds"] as? Boolean ?: true
        showDate = settings["showDate"] as? Boolean ?: true
        theme = settings["theme"] as? String ?: "white"

        clockSize = when (val v = settings["size"]) {
            is Number -> v.toFloat()
            else -> 48f
        }

        clockOpacity = when (val v = settings["opacity"]) {
            is Number -> v.toFloat()
            else -> 0.9f
        }

        position = settings["position"] as? String ?: "topRight"
        customColor = settings["color"] as? String
    }

    private fun showOverlay() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        setPosition(params)

        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_clock, null)
        timeTextView = overlayView?.findViewById(R.id.timeTextView)
        dateTextView = overlayView?.findViewById(R.id.dateTextView)
        clockContainer = overlayView?.findViewById(R.id.clockContainer)

        applyTheme()
        windowManager?.addView(overlayView, params)
    }

    private fun setPosition(params: WindowManager.LayoutParams) {
        when (position) {
            "topLeft" -> {
                params.gravity = Gravity.TOP or Gravity.START
                params.x = 24
                params.y = 24
            }
            "topRight" -> {
                params.gravity = Gravity.TOP or Gravity.END
                params.x = 24
                params.y = 24
            }
            "bottomLeft" -> {
                params.gravity = Gravity.BOTTOM or Gravity.START
                params.x = 24
                params.y = 24
            }
            "bottomRight" -> {
                params.gravity = Gravity.BOTTOM or Gravity.END
                params.x = 24
                params.y = 24
            }
            else -> {
                params.gravity = Gravity.TOP or Gravity.END
                params.x = 24
                params.y = 24
            }
        }
    }

    private fun applyPosition() {
        overlayView?.let { view ->
            val params = view.layoutParams as? WindowManager.LayoutParams
            params?.let {
                setPosition(it)
                windowManager?.updateViewLayout(view, it)
            }
        }
    }

    private fun applyTheme() {
        val textColor = if (!customColor.isNullOrEmpty() && customColor != "default") {
            android.graphics.Color.parseColor(customColor)
        } else {
            when (theme) {
                "black" -> android.graphics.Color.BLACK
                "minimal" -> android.graphics.Color.WHITE
                else -> android.graphics.Color.WHITE
            }
        }

        val backgroundColor = when (theme) {
            "black" -> android.graphics.Color.argb(
                (255 * clockOpacity).toInt(),
                255, 255, 255
            )
            "minimal" -> android.graphics.Color.TRANSPARENT
            else -> android.graphics.Color.argb(
                (255 * clockOpacity).toInt(),
                0, 0, 0
            )
        }

        val shadow = if (theme == "minimal") 10f else 0f

        timeTextView?.apply {
            setTextColor(textColor)
            textSize = clockSize
            alpha = clockOpacity
            setShadowLayer(shadow, 0f, 0f, android.graphics.Color.BLACK)
        }

        dateTextView?.apply {
            setTextColor(textColor)
            textSize = clockSize * 0.4f
            alpha = clockOpacity
            visibility = if (showDate) View.VISIBLE else View.GONE
            setShadowLayer(shadow, 0f, 0f, android.graphics.Color.BLACK)
        }

        clockContainer?.setBackgroundColor(backgroundColor)
    }

    private fun startClock() {
        handler.post(updateRunnable)
    }

    private fun stopClock() {
        handler.removeCallbacks(updateRunnable)
    }

    private fun updateClock() {
        val now = Calendar.getInstance().time

        val timePattern = when {
            is24HourFormat && showSeconds -> "HH:mm:ss"
            is24HourFormat && !showSeconds -> "HH:mm"
            !is24HourFormat && showSeconds -> "hh:mm:ss a"
            else -> "hh:mm a"
        }

        val timeFormatter = SimpleDateFormat(timePattern, Locale.getDefault())
        timeTextView?.text = timeFormatter.format(now)

        if (showDate) {
            val dateFormatter = SimpleDateFormat("EEE, MMM d, yyyy", Locale.getDefault())
            dateTextView?.text = dateFormatter.format(now)
        }
    }

    private fun buildNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("TV Clock Overlay")
            .setContentText("Clock overlay is running")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "TV Clock Overlay Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        stopClock()
        unregisterReceiver(screenReceiver)
        overlayView?.let {
            windowManager?.removeView(it)
        }
        overlayView = null
    }

    companion object {
        private const val CHANNEL_ID = "tv_clock_overlay_channel"
    }
}