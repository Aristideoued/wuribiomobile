package com.example.wuriproject

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.FingerpintHelper

class MainActivity : FlutterActivity() {
    private val REQUEST_FINGERPRINT = 1001
    private lateinit var resultCallback: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sf370/sdk").setMethodCallHandler { call, result ->
            if (call.method == "captureFingerprint") {
                resultCallback = result
                val intent = Intent(this, FingerpintHelper::class.java)
                startActivityForResult(intent, REQUEST_FINGERPRINT)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_FINGERPRINT && resultCode == Activity.RESULT_OK && data != null) {
            val base64 = data.getStringExtra("fingerprint_base64")
            resultCallback.success(base64)
        }
    }
}


/*import android.graphics.Bitmap
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import android.widget.ImageView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.Capture
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity(){
    private val CHANNEL = "sf370/sdk"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "captureFingerprint") {
                val imageView = ImageView(this)
                val helper = Capture(this, imageView) { bitmap ->
                    val base64 = bitmapToBase64(bitmap)
                    result.success(base64)
                }
                helper.startCapture()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        val byteArray = stream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }
}*/

/*package com.example.wuriproject

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Base64
import com.suprema.BioMiniFactory;
import com.suprema.CaptureResponder;
import com.suprema.IBioMiniDevice;
import com.suprema.IUsbEventHandler;


class MainActivity : FlutterActivity() {
    private val CHANNEL = "sf370/fingerprint"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "captureFingerprint") {
                try {
                    val fingerprintData = captureFingerprintFromBioMini()
                    result.success(fingerprintData)
                } catch (e: Exception) {
                    result.error("CAPTURE_ERROR", "Erreur SDK: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun captureFingerprintFromBioMini(): String {
        // Exemple fictif — remplacer par le vrai appel du SDK BioMini
        // Exemple typique (à adapter) :
        //
        // val device = BioMiniFactory.getDevice()
        // val fp = device.capture()
        // return fp?.getTemplateBase64() ?: ""

        return "empreinte_dummy_base64" // Remplacer par vrai template
    }

     private fun captureFingerprintFromSdk(resultCallback: MethodChannel.Result) {
    val bioMiniFactory = BioMiniFactory.getInstance()
    val device = bioMiniFactory.getDevice()

    val captureOption = IBioMiniDevice.CaptureOption()
    // Configure les options ici si besoin

    val captureResponder = object : CaptureResponder {
        override fun onCaptureEx(
            context: Any?,
            capturedImage: Bitmap?,
            capturedTemplate: IBioMiniDevice.TemplateData?,
            fingerState: IBioMiniDevice.FingerState?
        ): Boolean {
            runOnUiThread {
                if (capturedTemplate != null) {
                    val templateData = capturedTemplate.data
                    val base64Template = Base64.encodeToString(templateData, Base64.NO_WRAP)

                    resultCallback.success(base64Template)
                } else {
                    resultCallback.error("NO_TEMPLATE", "Template vide", null)
                }
            }
            return true
        }

        override fun onCaptureError(context: Any?, errorCode: Int, error: String?) {
            runOnUiThread {
                resultCallback.error("CAPTURE_ERROR", "Erreur SDK: $error", null)
            }
        }
    }

    // Lancer la capture
    device.captureSingle(captureResponder, captureOption)
}

}
*/
