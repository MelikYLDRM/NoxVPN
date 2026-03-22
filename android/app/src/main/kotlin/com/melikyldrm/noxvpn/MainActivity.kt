package com.melikyldrm.noxvpn

import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.melikyldrm.noxvpn.vpn.MyVpnService
import com.melikyldrm.noxvpn.vpn.TunnelManager
import com.melikyldrm.noxvpn.vpn.TunnelStatus
import com.melikyldrm.noxvpn.vpn.WireGuardChannel

class MainActivity : FlutterActivity() {
    private lateinit var wireGuardChannel: WireGuardChannel
    private val appUpdateManager by lazy { AppUpdateManagerFactory.create(this) }
    private val updateRequestCode = 1001

    private val installStateUpdatedListener = InstallStateUpdatedListener { state ->
        if (state.installStatus() == InstallStatus.DOWNLOADED) {
            appUpdateManager.completeUpdate()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        wireGuardChannel = WireGuardChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkForUpdates()
    }

    private fun checkForUpdates() {
        appUpdateManager.registerListener(installStateUpdatedListener)

        appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                if (appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)) {
                    appUpdateManager.startUpdateFlowForResult(
                        appUpdateInfo,
                        this,
                        AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                        updateRequestCode
                    )
                } else if (appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)) {
                    appUpdateManager.startUpdateFlowForResult(
                        appUpdateInfo,
                        this,
                        AppUpdateOptions.newBuilder(AppUpdateType.FLEXIBLE).build(),
                        updateRequestCode
                    )
                }
            } else if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    this,
                    AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                    updateRequestCode
                )
            }
        }.addOnFailureListener { e ->
            Log.e("MainActivity", "Update check failed: ${e.message}")
        }
    }

    override fun onResume() {
        super.onResume()
        appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    this,
                    AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build(),
                    updateRequestCode
                )
            }
            if (appUpdateInfo.installStatus() == InstallStatus.DOWNLOADED) {
                appUpdateManager.completeUpdate()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        wireGuardChannel.handleActivityResult(requestCode, resultCode)
    }

    override fun onDestroy() {
        appUpdateManager.unregisterListener(installStateUpdatedListener)
        stopVpnService()
        super.onDestroy()
    }

    private fun stopVpnService() {
        if (TunnelManager.status == TunnelStatus.connected || TunnelManager.status == TunnelStatus.connecting) {
            val serviceIntent = Intent(this, MyVpnService::class.java)
            serviceIntent.action = MyVpnService.ACTION_DISCONNECT
            startService(serviceIntent)
        }
    }
}
