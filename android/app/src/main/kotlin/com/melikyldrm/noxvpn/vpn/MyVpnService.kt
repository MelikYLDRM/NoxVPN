package com.melikyldrm.noxvpn.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.util.Log
import com.melikyldrm.noxvpn.MainActivity
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import java.util.Timer
import java.util.TimerTask
import kotlin.concurrent.thread

class MyVpnService : VpnService() {

    companion object {
        const val ACTION_CONNECT = "com.melikyldrm.noxvpn.CONNECT"
        const val ACTION_DISCONNECT = "com.melikyldrm.noxvpn.DISCONNECT"
        private const val NOTIFICATION_CHANNEL_ID = "noxvpn_vpn_channel"
        private const val NOTIFICATION_ID = 1
        private const val TAG = "MyVpnService"
    }

    private var backend: GoBackend? = null
    private var tunnel: MyTunnel? = null
    private var statsTimer: Timer? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        backend = GoBackend(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> connect()
            ACTION_DISCONNECT -> disconnect()
        }
        return START_STICKY
    }

    private fun connect() {
        val config = TunnelManager.config ?: run {
            Log.e(TAG, "No WireGuard config available")
            TunnelManager.status = TunnelStatus.error
            return
        }

        TunnelManager.status = TunnelStatus.connecting
        startForeground(NOTIFICATION_ID, createNotification("Connecting..."))

        thread {
            try {
                tunnel = MyTunnel("noxvpn")
                backend?.setState(tunnel!!, Tunnel.State.UP, config)

                TunnelManager.status = TunnelStatus.connected

                val notificationManager = getSystemService(NotificationManager::class.java)
                notificationManager.notify(NOTIFICATION_ID, createNotification("Connected"))

                startStatsPolling()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect: ${e.message}", e)
                TunnelManager.status = TunnelStatus.error
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
    }

    private fun disconnect() {
        try {
            TunnelManager.status = TunnelStatus.disconnecting
            stopStatsPolling()

            if (tunnel != null) {
                backend?.setState(tunnel!!, Tunnel.State.DOWN, TunnelManager.config)
            }

            TunnelManager.reset()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting: ${e.message}", e)
            TunnelManager.reset()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    private fun startStatsPolling() {
        statsTimer?.cancel()
        statsTimer = Timer()
        statsTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                try {
                    if (tunnel != null && backend != null) {
                        val stats = backend?.getStatistics(tunnel!!)
                        if (stats != null) {
                            TunnelManager.updateStats(stats.totalRx(), stats.totalTx())
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Stats polling error: ${e.message}")
                }
            }
        }, 1000, 1000)
    }

    private fun stopStatsPolling() {
        statsTimer?.cancel()
        statsTimer = null
    }

    override fun onRevoke() {
        disconnect()
        super.onRevoke()
    }

    override fun onDestroy() {
        disconnect()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "VPN Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Nox VPN connection status"
                setShowBadge(false)
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(status: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        return builder
            .setContentTitle("Nox VPN")
            .setContentText(status)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private class MyTunnel(private val tunnelName: String) : Tunnel {
        override fun getName(): String = tunnelName

        override fun onStateChange(newState: Tunnel.State) {
            Log.i("MyTunnel", "State changed to: $newState")
        }
    }
}
