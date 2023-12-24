package com.mutakindv.predikter

import android.content.Intent
import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private var methodChannel: MethodChannel? = null
    private lateinit var mResult: MethodChannel.Result
    private val arLauncher = (this as ComponentActivity).registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result: ActivityResult ->
        if (result.resultCode == RESULT_OK) {
            val data = result.data

            mResult.success(mapOf(
                "bodyLength" to data?.getDoubleExtra("bodyLength", 0.0),
                "chestSize" to data?.getDoubleExtra("chestSize", 0.0),
                "bodyWeight" to data?.getDoubleExtra("bodyWeight", 0.0),
            ))


//            methodChannel?.invokeMethod("sendData", )


        }

    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel =  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler {
                call, result ->
            if (call.method == "moveToArPage") {
                arLauncher.launch(Intent(this, ArActivity::class.java))
//                val intent = Intent(this, ArActivity::class.java)
//                startActivity(intent)
//                result.success(true)
                mResult = result
            } else {
                result.notImplemented()
            }
        }

    }

    companion object {
        const val CHANNEL = "com.mutakindv.predikter"
    }
}
