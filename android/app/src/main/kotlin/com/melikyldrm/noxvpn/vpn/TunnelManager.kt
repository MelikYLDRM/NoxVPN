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
    var status: TunnelStatus = TunnelStatus.disconnected
    var killSwitchEnabled: Boolean = false

    private var lastDownloadBytes: Long = 0
    private var lastUploadBytes: Long = 0
    private var prevDownloadBytes: Long = 0
    private var prevUploadBytes: Long = 0
    private var lastStatsTime: Long = System.currentTimeMillis()

    fun updateStats(downloadBytes: Long, uploadBytes: Long) {
        val now = System.currentTimeMillis()
        val elapsed = (now - lastStatsTime).coerceAtLeast(1)

        prevDownloadBytes = lastDownloadBytes
        prevUploadBytes = lastUploadBytes
        lastDownloadBytes = downloadBytes
        lastUploadBytes = uploadBytes
        lastStatsTime = now
    }

    fun getStatistics(): Map<String, Any>? {
        if (status != TunnelStatus.connected) return null

        val elapsed = (System.currentTimeMillis() - lastStatsTime).coerceAtLeast(1).toDouble() / 1000.0
        val dlSpeed = if (elapsed > 0) ((lastDownloadBytes - prevDownloadBytes) / elapsed) else 0.0
        val ulSpeed = if (elapsed > 0) ((lastUploadBytes - prevUploadBytes) / elapsed) else 0.0

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
    }
}
