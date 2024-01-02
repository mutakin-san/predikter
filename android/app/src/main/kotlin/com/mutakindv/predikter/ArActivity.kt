package com.mutakindv.predikter

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.Session
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.FrameTime
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.Scene
import com.google.ar.sceneform.math.Quaternion
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.rendering.Color
import com.google.ar.sceneform.rendering.Material
import com.google.ar.sceneform.rendering.MaterialFactory
import com.google.ar.sceneform.rendering.ModelRenderable
import com.google.ar.sceneform.rendering.PlaneRenderer
import com.google.ar.sceneform.rendering.ShapeFactory
import com.google.ar.sceneform.rendering.Texture
import com.google.ar.sceneform.ux.ArFragment
import com.google.ar.sceneform.ux.TransformableNode
import java.util.Objects
import java.util.concurrent.CompletableFuture
import kotlin.math.PI
import kotlin.math.pow
import kotlin.math.sqrt


class ArActivity : AppCompatActivity(), Scene.OnUpdateListener {


    private var lineRenderable: ModelRenderable? = null
    private var arFragment: ArFragment? = null
    private lateinit var tvChestSize: TextView
    private lateinit var tvBodyLength: TextView
    private lateinit var tvWeight: TextView
    private lateinit var btnSave: FloatingActionButton


    private var bodyLength: Double? = null
    private var chestSize: Double? = null
    private var bodyWeight: Double? = null


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

        if (!checkIsSupportedDeviceOrFinish(this)) {
            Toast.makeText(applicationContext, "Device not supported", Toast.LENGTH_LONG).show()
        }

        setContentView(R.layout.activity_ar)

        arFragment = supportFragmentManager.findFragmentById(R.id.ux_fragment) as ArFragment?
        tvChestSize = findViewById(R.id.tvChestSize)
        tvBodyLength = findViewById(R.id.tvBodyLength)
        tvWeight = findViewById(R.id.tvWeight)
        btnSave = findViewById(R.id.btnSave)


        btnSave.setOnClickListener {
            val data = Intent()
            data.putExtra("bodyWeight" , bodyWeight)
            data.putExtra("bodyLength" , bodyLength)
            data.putExtra("chestSize" , chestSize)
            if(bodyLength != null && chestSize != null && bodyWeight != null) {
                setResult(Activity.RESULT_OK, data)
                finish()
            } else {
                Toast.makeText(this, "Body Measurement is not finished yet", Toast.LENGTH_SHORT)
                    .show()
            }
        }
        mSession = Session(this)

        val config = Config(mSession)
        config.planeFindingMode = Config.PlaneFindingMode.VERTICAL
        config.lightEstimationMode = Config.LightEstimationMode.DISABLED
        config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
        mSession?.configure(config)
        arFragment?.arSceneView?.setupSession(mSession)
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
        mSession?.pause();
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


    private fun checkIsSupportedDeviceOrFinish(activity: Activity): Boolean {

        val openGlVersionString =
            (Objects.requireNonNull(activity.getSystemService(Context.ACTIVITY_SERVICE)) as ActivityManager)
                .deviceConfigurationInfo
                .glEsVersion
        if (java.lang.Double.parseDouble(openGlVersionString) < MIN_OPENGL_VERSION) {
            Toast.makeText(activity, "Sceneform requires OpenGL ES 3.0 or later", Toast.LENGTH_LONG)
                .show()
            activity.finish()
            return false
        }
        return true
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
        if (nodeA != null && nodeB != null && nodeC != null && nodeD != null) {

            val positionA = nodeA!!.worldPosition
            val positionB = nodeB!!.worldPosition

            val positionC = nodeC!!.worldPosition
            val positionD = nodeD!!.worldPosition

            val dx = positionA.x - positionB.x
            val dy = positionA.y - positionB.y
            val dz = positionA.z - positionB.z

            val dx2 = positionC.x - positionD.x
            val dy2 = positionC.y - positionD.y
            val dz2 = positionC.z - positionD.z

            //Computing a straight-line distance.
            val distanceMeters = sqrt((dx * dx + dy * dy + dz * dz).toDouble())
            val distance2Meters =
                sqrt((dx2 * dx2 + dy2 * dy2 + dz2 * dz2).toDouble())


            chestSize = (PI * (distanceMeters * 100))
            bodyLength = distance2Meters * 100

            val distanceFormatted = String.format("%.2f", chestSize)
            val distance2Formatted = String.format("%.2f", bodyLength)

            tvChestSize.text =
                getString(R.string.lingkar_dada_cm, distanceFormatted)
             tvBodyLength.text =
                 getString(R.string.panjang_badan_cm, distance2Formatted)


            if (chestSize != null && bodyLength != null) {
                bodyWeight = ((chestSize!!.pow(2.0) * bodyLength!!) / 10840)
                val weightFormatted = String.format("%.2f", bodyWeight)
                tvWeight.text = getString(R.string.prediksi_bobot_kg, weightFormatted)

            }
        }
    }

    fun lineBetweenPoints(point1: Vector3?, point2: Vector3?, anchorNode: AnchorNode) {
        val lineNode = Node()

        /* First, find the vector extending between the two points and define a look rotation in terms of this
        Vector. */
        val difference = Vector3.subtract(point1, point2)
        val directionFromTopToBottom = difference.normalized()
        val rotationFromAToB = Quaternion.lookRotation(directionFromTopToBottom, Vector3.up())

        /* Then, create a rectangular prism, using ShapeFactory.makeCube() and use the difference vector
         to extend to the necessary length.  */

        MaterialFactory.makeOpaqueWithColor(
            this,
            Color(android.graphics.Color.WHITE)
        )
            .thenAccept { material: Material? ->
                lineRenderable = ShapeFactory.makeCube(
                    Vector3(.01f, .01f, difference.length()),
                    Vector3.zero(), material
                )
            }

        /* Last, set the local rotation of the node to the rotation calculated earlier and set the local position to
          the midpoint between the given points . */
        lineNode.setParent(anchorNode)
        lineNode.renderable = lineRenderable
        lineNode.localPosition = Vector3.add(point1, point2).scaled(.5f)
        lineNode.localRotation = rotationFromAToB
    }
    companion object {
        private const val MIN_OPENGL_VERSION = 3.0
    }
}



