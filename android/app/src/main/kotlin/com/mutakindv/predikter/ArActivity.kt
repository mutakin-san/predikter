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



        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.RED))
            .thenAccept { material ->
                redSphereRenderable = ShapeFactory.makeSphere(0.05f, Vector3.zero(), material)
                redSphereRenderable!!.isShadowCaster = false
                redSphereRenderable!!.isShadowReceiver = false
            }

        MaterialFactory.makeOpaqueWithColor(this, Color(android.graphics.Color.BLUE))
            .thenAccept { material ->
                blueSphereRenderable = ShapeFactory.makeSphere(0.05f, Vector3.zero(), material)
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

    companion object {
        val TAG = ArActivity::class.simpleName
    }

}



