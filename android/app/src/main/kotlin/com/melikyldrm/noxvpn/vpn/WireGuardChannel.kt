package com.melikyldrm.noxvpn.vpn

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.VpnService
import android.os.Build
import android.util.Log
import com.wireguard.config.Config
import com.wireguard.config.InetNetwork
import com.wireguard.config.Interface
import com.wireguard.config.Peer
import com.wireguard.crypto.KeyPair
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WireGuardChannel(
    private val activity: Activity,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.melikyldrm.noxvpn/vpn"
        private const val EVENT_CHANNEL_NAME = "com.melikyldrm.noxvpn/vpn_status"
        private const val VPN_REQUEST_CODE = 24601
    }

    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
    private var pendingResult: MethodChannel.Result? = null
    private var eventSink: EventChannel.EventSink? = null

    init {
        channel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                TunnelManager.statusListener = { status ->
                    activity.runOnUiThread {
                        eventSink?.success(status.name)
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                TunnelManager.statusListener = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "prepareVpn" -> prepareVpn(result)
            "connect" -> connect(call, result)
            "disconnect" -> disconnect(result)
            "getStatus" -> getStatus(result)
            "getStatistics" -> getStatistics(result)
            "generateKeyPair" -> generateKeyPair(result)
            "getInstalledApps" -> getInstalledApps(result)
            else -> result.notImplemented()
        }
    }

    private fun prepareVpn(result: MethodChannel.Result) {
        val intent = VpnService.prepare(activity)
        if (intent != null) {
            pendingResult = result
            activity.startActivityForResult(intent, VPN_REQUEST_CODE)
        } else {
            result.success(true)
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == VPN_REQUEST_CODE) {
            pendingResult?.success(resultCode == Activity.RESULT_OK)
            pendingResult = null
        }
    }

    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        try {
            val privateKey = call.argument<String>("privateKey") ?: throw IllegalArgumentException("Missing privateKey")
            val address = call.argument<String>("address") ?: throw IllegalArgumentException("Missing address")
            val dns = call.argument<String>("dns") ?: "1.1.1.1"
            val mtu = call.argument<Int>("mtu") ?: 1420
            val publicKey = call.argument<String>("publicKey") ?: throw IllegalArgumentException("Missing publicKey")
            val endpoint = call.argument<String>("endpoint") ?: throw IllegalArgumentException("Missing endpoint")
            val allowedIPs = call.argument<String>("allowedIPs") ?: "0.0.0.0/0"
            val presharedKey = call.argument<String>("presharedKey")
            val persistentKeepalive = call.argument<Int>("persistentKeepalive") ?: 15
            val killSwitch = call.argument<Boolean>("killSwitch") ?: false
            val excludedApps = call.argument<List<String>>("excludedApps") ?: emptyList()

            // Build WireGuard Config
            val interfaceBuilder = Interface.Builder()
            interfaceBuilder.parsePrivateKey(privateKey)
            address.split(",").forEach { addr ->
                interfaceBuilder.addAddress(InetNetwork.parse(addr.trim()))
            }
            dns.split(",").forEach { d ->
                interfaceBuilder.parseDnsServers(d.trim())
            }
            interfaceBuilder.parseMtu(mtu.toString())

            // Apply split tunneling — exclude specified apps from VPN
            if (excludedApps.isNotEmpty()) {
                for (app in excludedApps) {
                    try {
                        interfaceBuilder.excludeApplication(app)
                    } catch (e: Exception) {
                        Log.w("WireGuardChannel", "Could not exclude app: $app")
                    }
                }
            }

            val peerBuilder = Peer.Builder()
            peerBuilder.parsePublicKey(publicKey)
            peerBuilder.parseEndpoint(endpoint)
            allowedIPs.split(",").forEach { ip ->
                peerBuilder.addAllowedIp(InetNetwork.parse(ip.trim()))
            }
            if (!presharedKey.isNullOrEmpty() && presharedKey != "") {
                peerBuilder.parsePreSharedKey(presharedKey)
            }
            peerBuilder.parsePersistentKeepalive(persistentKeepalive.toString())

            val config = Config.Builder()
                .setInterface(interfaceBuilder.build())
                .addPeer(peerBuilder.build())
                .build()

            // Store config in TunnelManager and start service
            TunnelManager.config = config
            TunnelManager.killSwitchEnabled = killSwitch
            TunnelManager.excludedApps = excludedApps

            val serviceIntent = Intent(activity, MyVpnService::class.java)
            serviceIntent.action = MyVpnService.ACTION_CONNECT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.startForegroundService(serviceIntent)
            } else {
                activity.startService(serviceIntent)
            }

            result.success(true)
        } catch (e: Exception) {
            Log.e("WireGuardChannel", "Connect error: ${e.message}", e)
            result.error("CONNECT_ERROR", e.message, null)
        }
    }

    private fun disconnect(result: MethodChannel.Result) {
        try {
            val serviceIntent = Intent(activity, MyVpnService::class.java)
            serviceIntent.action = MyVpnService.ACTION_DISCONNECT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                activity.startForegroundService(serviceIntent)
            } else {
                activity.startService(serviceIntent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }

    private fun getStatus(result: MethodChannel.Result) {
        result.success(TunnelManager.status.name)
    }

    private fun getStatistics(result: MethodChannel.Result) {
        val stats = TunnelManager.getStatistics()
        if (stats != null) {
            result.success(stats)
        } else {
            result.success(null)
        }
    }

    private fun generateKeyPair(result: MethodChannel.Result) {
        try {
            val keyPair = KeyPair()
            result.success(
                mapOf(
                    "privateKey" to keyPair.privateKey.toBase64(),
                    "publicKey" to keyPair.publicKey.toBase64()
                )
            )
        } catch (e: Exception) {
            result.error("KEY_GEN_ERROR", e.message, null)
        }
    }

    private fun getInstalledApps(result: MethodChannel.Result) {
        try {
            val pm = activity.packageManager
            val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            val apps = mutableListOf<Map<String, String>>()
            for (appInfo in packages) {
                if (pm.getLaunchIntentForPackage(appInfo.packageName) == null) continue
                if (appInfo.packageName == activity.packageName) continue
                apps.add(mapOf(
                    "packageName" to appInfo.packageName,
                    "appName" to pm.getApplicationLabel(appInfo).toString()
                ))
            }
            apps.sortBy { (it["appName"] ?: "").lowercase() }
            result.success(apps)
        } catch (e: Exception) {
            result.error("APPS_ERROR", e.message, null)
        }
    }
}
