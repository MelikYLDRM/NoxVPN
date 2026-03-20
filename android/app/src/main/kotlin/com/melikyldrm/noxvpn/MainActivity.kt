package com.melikyldrm.noxvpn

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.melikyldrm.noxvpn.vpn.WireGuardChannel

class MainActivity : FlutterActivity() {
    private lateinit var wireGuardChannel: WireGuardChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        wireGuardChannel = WireGuardChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        wireGuardChannel.handleActivityResult(requestCode, resultCode)
    }
}
