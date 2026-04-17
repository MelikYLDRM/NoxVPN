package com.melikyldrm.noxvpn.vpn

import com.wireguard.config.Config

enum class TunnelStatus {
    disconnected,
    connecting,
    connected,
    disconnecting,
    error
}

object TunnelManager {
    var config: Config? = null
    var killSwitchEnabled: Boolean = false
    var excludedApps: List<String> = emptyList()
    var statusListener: ((TunnelStatus) -> Unit)? = null

    var status: TunnelStatus = TunnelStatus.disconnected
        set(value) {
            field = value
            statusListener?.invoke(value)
        }

    private var lastDownloadBytes: Long = 0
    private var lastUploadBytes: Long = 0
    private var prevDownloadBytes: Long = 0
    private var prevUploadBytes: Long = 0
    private var lastStatsTime: Long = System.currentTimeMillis()
    private var prevStatsTime: Long = System.currentTimeMillis()

    fun updateStats(downloadBytes: Long, uploadBytes: Long) {
        val now = System.currentTimeMillis()

        prevDownloadBytes = lastDownloadBytes
        prevUploadBytes = lastUploadBytes
        prevStatsTime = lastStatsTime

        lastDownloadBytes = downloadBytes
        lastUploadBytes = uploadBytes
        lastStatsTime = now
    }

    fun getStatistics(): Map<String, Any>? {
        if (status != TunnelStatus.connected) return null

        val elapsedMs = (lastStatsTime - prevStatsTime).coerceAtLeast(1)
        val elapsedSec = elapsedMs.toDouble() / 1000.0

        val dlDiff = (lastDownloadBytes - prevDownloadBytes).coerceAtLeast(0)
        val ulDiff = (lastUploadBytes - prevUploadBytes).coerceAtLeast(0)

        val dlSpeed = if (elapsedSec > 0) (dlDiff / elapsedSec) else 0.0
        val ulSpeed = if (elapsedSec > 0) (ulDiff / elapsedSec) else 0.0

        return mapOf(
            "downloadBytes" to lastDownloadBytes,
            "uploadBytes" to lastUploadBytes,
            "downloadSpeedBps" to dlSpeed,
            "uploadSpeedBps" to ulSpeed
        )
    }

    fun reset() {
        status = TunnelStatus.disconnected
        lastDownloadBytes = 0
        lastUploadBytes = 0
        prevDownloadBytes = 0
        prevUploadBytes = 0
        lastStatsTime = System.currentTimeMillis()
        prevStatsTime = System.currentTimeMillis()
        excludedApps = emptyList()
    }
}
