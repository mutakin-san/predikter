package com.mutakindv.predikter

import android.content.Context
import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContract
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private var methodChannel: MethodChannel? = null
    private lateinit var mResult: MethodChannel.Result
    private val arLauncher = (this as ComponentActivity).registerForActivityResult(
        MyActivityForResultContract()
    ) { result ->
        mResult.success(result)
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel =  MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel?.setMethodCallHandler {
                call, result ->
            if (call.method == "moveToArPage") {
                arLauncher.launch(call.arguments as Int)
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



class MyActivityForResultContract : ActivityResultContract<Int, Map<String,Double?>>() {
    override fun createIntent(context: Context, input: Int): Intent {
        return Intent(context, ArActivity::class.java).apply {
            putExtra("pricePerKg", input)
        }
    }

    override fun parseResult(resultCode: Int, intent: Intent?): Map<String, Double?> {
        return if (resultCode == FlutterFragmentActivity.RESULT_OK) {
            mapOf(
                "bodyLength" to intent?.getDoubleExtra("bodyLength", 0.0),
                "chestSize" to intent?.getDoubleExtra("chestSize", 0.0),
                "bodyWeight" to intent?.getDoubleExtra("bodyWeight", 0.0),
                "priceEstimation" to intent?.getDoubleExtra("priceEstimation", 0.0),
            )
        } else {
            emptyMap()
        }
    }

}