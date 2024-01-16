package com.mutakindv.predikter

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.HandlerThread
import android.provider.MediaStore
import android.util.Log
import android.view.PixelCopy
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.RecordingConfig
import com.google.ar.core.RecordingStatus
import com.google.ar.core.Session
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.RecordingFailedException
import com.google.ar.core.exceptions.UnavailableApkTooOldException
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import com.google.ar.core.exceptions.UnavailableSdkTooOldException
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.FrameTime
import com.google.ar.sceneform.Scene
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.rendering.Color
import com.google.ar.sceneform.rendering.Material
import com.google.ar.sceneform.rendering.MaterialFactory
import com.google.ar.sceneform.rendering.ModelRenderable
import com.google.ar.sceneform.rendering.PlaneRenderer
import com.google.ar.sceneform.rendering.ShapeFactory
import com.google.ar.sceneform.ux.ArFragment
import com.google.ar.sceneform.ux.TransformableNode
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.sqrt


enum class AppState {
    Idle,
    Recording,
    Playingback
}


// Tracks app's specific state changes.
private var appState = AppState.Idle

class ArActivity : AppCompatActivity(), Scene.OnUpdateListener {


    private var imagesDirectory: File? = null
    private var imagePath: String? = null
    private var arFragment: ArFragment? = null
    private lateinit var tvChestSize: TextView
    private lateinit var tvBodyLength: TextView
    private lateinit var tvWeight: TextView
    private lateinit var tvPrice: TextView
    private lateinit var btnSave: FloatingActionButton
    private lateinit var loadingIndicator: ProgressBar

    private var bodyLength: Double? = null
    private var chestSize: Double? = null
    private var bodyWeight: Double? = null
    private var priceEstimation: Double? = null


    private var redSphereRenderable: ModelRenderable? = null
    private var blueSphereRenderable: ModelRenderable? = null
    private var mSession: Session? = null

    private var nodeA: TransformableNode? = null
    private var nodeB: TransformableNode? = null

    private var nodeC: TransformableNode? = null
    private var nodeD: TransformableNode? = null


    private var anchorA: Anchor? = null
    private var anchorB: Anchor? = null

    private var anchorC: Anchor? = null
    private var anchorD: Anchor? = null


    private var greenMaterial: Material? = null
    private var blueMaterial: Material? = null
    private var originalMaterial: Material? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ar)

        arFragment = supportFragmentManager.findFragmentById(R.id.ux_fragment) as ArFragment?
        tvChestSize = findViewById(R.id.tvChestSize)
        tvBodyLength = findViewById(R.id.tvBodyLength)
        tvWeight = findViewById(R.id.tvWeight)
        tvPrice = findViewById(R.id.tvPrice)
        btnSave = findViewById(R.id.btnSave)
        loadingIndicator = findViewById(R.id.loadingIndicator)


        btnSave.setOnClickListener {
            takePhotoAndSetData()
        }

        try {
            mSession = Session(this)
        } catch (e: UnavailableArcoreNotInstalledException) {
            Log.e(
                TAG,
                "Error in return to Idle state. Cannot create new ARCore session",
                e
            )
        } catch (e: UnavailableApkTooOldException) {
            Log.e(
                TAG,
                "Error in return to Idle state. Cannot create new ARCore session",
                e
            )
        } catch (e: UnavailableSdkTooOldException) {
            Log.e(
                TAG,
                "Error in return to Idle state. Cannot create new ARCore session",
                e
            )
        } catch (e: UnavailableDeviceNotCompatibleException) {
            Log.e(
                TAG,
                "Error in return to Idle state. Cannot create new ARCore session",
                e
            )
        }
        configureSession()
        arFragment!!.arSceneView.scene.addOnUpdateListener(this)

        initModel()

        arFragment!!.setOnTapArPlaneListener { hitResult, _, _ ->


            if (redSphereRenderable != null && blueSphereRenderable != null) {

                val anchor = hitResult.createAnchor()
                val anchorNode = AnchorNode(anchor)
                anchorNode.setParent(arFragment!!.arSceneView.scene)

                if (nodeA != null && nodeB != null && nodeC != null && nodeD != null) {
                    clearAnchors()
                }

                val node = TransformableNode(arFragment!!.transformationSystem)
                node.renderable = if(nodeB != null) redSphereRenderable else blueSphereRenderable
                node.setParent(anchorNode)

                arFragment!!.arSceneView.scene.addChild(anchorNode)
                node.select()

                if (nodeA == null) {
                    nodeA = node
                    anchorA = anchor
                } else if (nodeB == null) {
                    nodeB = node
                    anchorB = anchor

                } else if (nodeC == null) {
                    nodeC = node
                    anchorC = anchor

                } else if (nodeD == null) {
                    nodeD = node
                    anchorD = anchor
                }
            }
        }
    }


    override fun onPause() {
        super.onPause()
        mSession?.pause()
    }

    override fun onDestroy() {
        super.onDestroy()
        mSession?.close()
        mSession = null
    }


    override fun onResume() {
        super.onResume()
        mSession?.resume()
    }

    private fun initModel() {

        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.GREEN))
            .thenAccept { material ->
                greenMaterial = material
            }
        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.BLUE))
            .thenAccept { material ->
                blueMaterial = material
            }

        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.RED))
            .thenAccept { material ->
                redSphereRenderable = ShapeFactory.makeSphere(0.05f, Vector3.zero(), material)
                originalMaterial = material
                redSphereRenderable!!.isShadowCaster = false
                redSphereRenderable!!.isShadowReceiver = false
            }

        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.BLUE))
            .thenAccept { material ->
                blueSphereRenderable = ShapeFactory.makeSphere(0.05f, Vector3.zero(), material)
                blueMaterial = material
                blueSphereRenderable!!.isShadowCaster = false
                blueSphereRenderable!!.isShadowReceiver = false
            }
    }


    private fun configureSession() {

        val config = Config(mSession)
        config.planeFindingMode = Config.PlaneFindingMode.VERTICAL
        config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        config.focusMode = Config.FocusMode.AUTO
        mSession?.configure(config)
        arFragment?.arSceneView?.setupSession(mSession)
    }


    private fun clearAnchors() {

        arFragment!!.arSceneView.scene.removeChild(nodeA!!.parent!!)
        arFragment!!.arSceneView.scene.removeChild(nodeB!!.parent!!)
        arFragment!!.arSceneView.scene.removeChild(nodeC!!.parent!!)
        arFragment!!.arSceneView.scene.removeChild(nodeD!!.parent!!)

        nodeA = null
        nodeB = null
        nodeC = null
        nodeD = null
    }

    override fun onUpdate(frameTime: FrameTime) {

        // Set plane texture
        arFragment?.arSceneView
            ?.planeRenderer
            ?.material
            ?.thenAccept { material ->
                material.setFloat(PlaneRenderer.MATERIAL_SPOTLIGHT_RADIUS, 1000f)
                // material.setFloat2(PlaneRenderer.MATERIAL_UV_SCALE, 50f, 50f);
            }

        if (nodeA != null && nodeB != null) {

            val positionA = nodeA!!.worldPosition
            val positionB = nodeB!!.worldPosition

            val dx = positionA.x - positionB.x
            val dy = positionA.y - positionB.y
            val dz = positionA.z - positionB.z

            val chestGirth = sqrt((dx * dx + dy * dy + dz * dz).toDouble())
            chestSize = (PI * (chestGirth * 100))
            val distanceFormatted = String.format("%.2f", chestSize)
            tvChestSize.text =
                getString(R.string.lingkar_dada_cm, distanceFormatted)

        }

        if(nodeC != null && nodeD != null) {

            val positionC = nodeC!!.worldPosition
            val positionD = nodeD!!.worldPosition

            val dx2 = positionC.x - positionD.x
            val dy2 = positionC.y - positionD.y
            val dz2 = positionC.z - positionD.z
            val bdLength =
                sqrt((dx2 * dx2 + dy2 * dy2 + dz2 * dz2).toDouble())
            bodyLength = bdLength * 100
            val distance2Formatted = String.format("%.2f", bodyLength)
            tvBodyLength.text =
                getString(R.string.panjang_badan_cm, distance2Formatted)
        }

        if (chestSize != null && bodyLength != null) {
            // Rumus penghitung bobot badan sapi menggunakan Winter Indonesia
            bodyWeight = ((chestSize!!.pow(2.0) * bodyLength!!) / 10815.15)
            val pricePerKg = intent.getIntExtra("pricePerKg", 0)
            priceEstimation = (bodyWeight ?: 0.0) * pricePerKg
            val weightFormatted = String.format("%.2f", bodyWeight)
            val numFormatter = NumberFormat.getNumberInstance()
            tvWeight.text = getString(R.string.prediksi_bobot_kg, weightFormatted)
            tvPrice.text =
                getString(R.string.prediksi_harga_jual, numFormatter.format(priceEstimation))
        }
    }


    private fun setResultDataAndFinish() {

        val data = Intent()
        data.putExtra("imagePath", imagePath)
        data.putExtra("bodyWeight", bodyWeight)
        data.putExtra("bodyLength", bodyLength)
        data.putExtra("chestSize", chestSize)
        data.putExtra("priceEstimation", priceEstimation)
        if (bodyLength != null && chestSize != null && bodyWeight != null) {
            setResult(Activity.RESULT_OK, data)
            finish()
        } else {
            Toast.makeText(
                this,
                "Pengukuran belum selesai, silahkan tentukan ukuran lingkar dada dan panjang badan sapi dengan benar",
                Toast.LENGTH_SHORT
            )
                .show()
        }

    }


    private fun takePhotoAndSetData() {
        btnSave.isEnabled = false
        loadingIndicator.visibility = View.VISIBLE
        val view = arFragment!!.arSceneView

        // Create a bitmap the size of the scene view.
        val bitmap = Bitmap.createBitmap(
            view.width, view.height,
            Bitmap.Config.ARGB_8888
        )

        // Create a handler thread to offload the processing of the image.
        val handlerThread = HandlerThread("PixelCopier")
        handlerThread.start()
        // Make the request to copy.
        PixelCopy.request(view, bitmap, { copyResult ->
            if (copyResult == PixelCopy.SUCCESS) {
                try {
                    saveBitmapToDisk(bitmap)
                } catch (e: IOException) {
                    val toast = Toast.makeText(
                        this@ArActivity, e.toString(),
                        Toast.LENGTH_LONG
                    )
                    toast.show()
                    return@request
                }
            } else {
                Snackbar.make(view, "Failed to take screenshot", Snackbar.LENGTH_LONG).show()
            }
            handlerThread.quitSafely()
        }, Handler(handlerThread.looper))

    }


    @Throws(IOException::class)
    fun saveBitmapToDisk(bitmap: Bitmap) {

        //  String path = Environment.getExternalStorageDirectory().toString() +  "/Pictures/Screenshots/";
        if (imagesDirectory == null) {
            val folder = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                    .toString() + "/Predikter"
            )

            imagesDirectory = if (folder.exists()) {
                folder
            } else {
                if (folder.mkdir()) {
                    folder
                } else {
                    return
                }
            }
        }
        val c: Calendar = Calendar.getInstance()
        val df = SimpleDateFormat("yyyy-MM-dd HH.mm.ss", Locale.getDefault())
        val formattedDate: String = df.format(c.time)
        val mediaFile = File(
            imagesDirectory,
            "Pengukuran$formattedDate.jpeg"
        )
        imagePath = mediaFile.path
        Log.d("Screenshot", "ImagePath: $imagePath")


        val fileOutputStream = FileOutputStream(mediaFile)
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, fileOutputStream)
        fileOutputStream.flush()
        fileOutputStream.close()
        runOnUiThread {

            loadingIndicator.visibility = View.GONE
            btnSave.isEnabled = true
            setResultDataAndFinish()

        }
    }

    // Update the "Record" button based on app's internal state.
    private fun updateRecordButton() {
        val buttonView = findViewById<View>(R.id.record_button)
        val button = buttonView as Button

        when (appState) {
            AppState.Idle -> {
                button.text = "Record"
                button.visibility = View.VISIBLE
            }

            AppState.Recording -> {
                button.text = "Stop"
                button.visibility = View.VISIBLE
            }

            AppState.Playingback -> button.visibility = View.INVISIBLE
        }
    }


    // Handle the "Record" button click event.
    fun onClickRecord(view: View?) {
        Log.d(TAG, "onClickRecord")
        when (appState) {
            AppState.Idle -> {
                val hasStarted: Boolean = startRecording()
                Log.d(
                    TAG,
                    String.format("onClickRecord start: hasStarted %b", hasStarted)
                )
                if (hasStarted) appState = AppState.Recording
            }

            AppState.Recording -> {
                val hasStopped: Boolean = stopRecording()
                Log.d(
                    TAG,
                    String.format("onClickRecord stop: hasStopped %b", hasStopped)
                )
                if (hasStopped) appState = AppState.Idle
            }


            else -> {}
        }
        updateRecordButton()
    }


    private val REQUEST_WRITE_EXTERNAL_STORAGE = 1
    private fun checkAndRequestStoragePermission(): Boolean {
        if (ContextCompat.checkSelfPermission(
                this,
                android.Manifest.permission.WRITE_EXTERNAL_STORAGE
            )
            != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this, arrayOf(android.Manifest.permission.WRITE_EXTERNAL_STORAGE),
                REQUEST_WRITE_EXTERNAL_STORAGE
            )
            return false
        }
        return true
    }


    private val MP4_VIDEO_MIME_TYPE = "video/mp4"

    private fun createMp4File(): Uri? {
        // Since we use legacy external storage for Android 10,
        // we still need to request for storage permission on Android 10.
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.Q) {
            if (!checkAndRequestStoragePermission()) {
                Log.i(
                    TAG, String.format(
                        "Didn't createMp4File. No storage permission, API Level = %d",
                        Build.VERSION.SDK_INT
                    )
                )
                return null
            }
        }

        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
        val mp4FileName = "arcore-" + dateFormat.format(Date()) + ".mp4"
        val resolver = this.contentResolver
        val videoCollection: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Video.Media.getContentUri(
                MediaStore.VOLUME_EXTERNAL_PRIMARY
            )
        } else {
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }

        // Create a new Media file record.
        val newMp4FileDetails = ContentValues()
        newMp4FileDetails.put(MediaStore.Video.Media.DISPLAY_NAME, mp4FileName)
        newMp4FileDetails.put(MediaStore.Video.Media.MIME_TYPE, MP4_VIDEO_MIME_TYPE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // The Relative_Path column is only available since API Level 29.
            newMp4FileDetails.put(
                MediaStore.Video.Media.RELATIVE_PATH,
                Environment.DIRECTORY_MOVIES
            )
        } else {
            // Use the Data column to set path for API Level <= 28.
            val mp4FileDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            val absoluteMp4FilePath = File(mp4FileDir, mp4FileName).absolutePath
            newMp4FileDetails.put(MediaStore.Video.Media.DATA, absoluteMp4FilePath)
        }
        val newMp4FileUri = resolver.insert(videoCollection, newMp4FileDetails)

        // Ensure that this file exists and can be written.
        if (newMp4FileUri == null) {
            Log.e(
                TAG,
                String.format(
                    "Failed to insert Video entity in MediaStore. API Level = %d",
                    Build.VERSION.SDK_INT
                )
            )
            return null
        }

        // This call ensures the file exist before we pass it to the ARCore API.
        if (!testFileWriteAccess(newMp4FileUri)) {
            return null
        }
        Log.d(
            TAG,
            String.format(
                "createMp4File = %s, API Level = %d",
                newMp4FileUri,
                Build.VERSION.SDK_INT
            )
        )
        return newMp4FileUri
    }

    // Test if the file represented by the content Uri can be open with write access.
    private fun testFileWriteAccess(contentUri: Uri): Boolean {
        try {
            this.contentResolver.openOutputStream(contentUri).use { mp4File ->
                Log.d(
                    TAG,
                    String.format("Success in testFileWriteAccess %s", contentUri.toString())
                )
                return true
            }
        } catch (e: FileNotFoundException) {
            Log.e(
                TAG,
                String.format(
                    "FileNotFoundException in testFileWriteAccess %s",
                    contentUri.toString()
                ),
                e
            )
        } catch (e: IOException) {
            Log.e(
                TAG,
                String.format("IOException in testFileWriteAccess %s", contentUri.toString()),
                e
            )
        }
        return false
    }

    private fun startRecording(): Boolean {
        val mp4FileUri: Uri = createMp4File() ?: return false
        Log.d(TAG, "startRecording at: $mp4FileUri")
        pauseARCoreSession()

        // Configure the ARCore session to start recording.
        val recordingConfig: RecordingConfig = RecordingConfig(mSession)
            .setRecordingRotation(90)
            .setMp4DatasetUri(mp4FileUri)
            .setAutoStopOnPause(true)
        try {
            // Prepare the session for recording, but do not start recording yet.
            mSession?.startRecording(recordingConfig)
        } catch (e: RecordingFailedException) {
            Log.e(TAG, "startRecording - Failed to prepare to start recording", e)
            return false
        }
        val canResume: Boolean = resumeARCoreSession()
        if (!canResume) return false

        // Correctness checking: check the ARCore session's RecordingState.
        val recordingStatus: RecordingStatus? = mSession?.recordingStatus
        Log.d(
            TAG,
            java.lang.String.format("startRecording - recordingStatus %s", recordingStatus)
        )
        return recordingStatus === RecordingStatus.OK
    }


    private fun pauseARCoreSession() {
        // Pause the GLSurfaceView so that it doesn't update the ARCore mSession?.
        // Pause the ARCore session so that we can update its configuration.
        // If the GLSurfaceView is not paused,
        //   onDrawFrame() will try to update the ARCore session
        //   while it's paused, resulting in a crash.
        arFragment!!.arSceneView.pause()
        mSession?.pause()
    }

    private fun resumeARCoreSession(): Boolean {
        // We must resume the ARCore session before the GLSurfaceView.
        // Otherwise, the GLSurfaceView will try to update the ARCore mSession?.
        try {
            mSession?.resume()
        } catch (e: CameraNotAvailableException) {
            Log.e(TAG, "CameraNotAvailableException in resumeARCoreSession", e)
            return false
        }
        arFragment!!.arSceneView.resume()
        return true
    }

    private fun stopRecording(): Boolean {
        try {
            mSession?.stopRecording()
        } catch (e: RecordingFailedException) {
            Log.e(TAG, "stopRecording - Failed to stop recording", e)
            return false
        }

        // Correctness checking: check if the session stopped recording.
        return mSession?.recordingStatus === RecordingStatus.NONE
    }

    companion object {
        val TAG = ArActivity::class.simpleName
    }

}



