//
//  ViewController.swift
//  ARKitTraining
//
//  Created by Cem Sertkaya on 31.03.2021.
//

import UIKit
import ARKit

class DistanceMeasurementController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    var startingPosition: SCNNode?
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.delegate = self
    }

    // When user press the scene view, we want to add a sphere to the exact location of view of camera.
    // I also added a plus sign for this location.
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let currentFrame = sceneView.session.currentFrame else {return}
        if self.startingPosition != nil
        {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        let transform = camera.transform // If we do not modify this transform, it shows the exact location of our phone.
        var translationMatrix = matrix_identity_float4x4 // We initialize 4x4 because camera.transform is a 4x4 matrix.
        translationMatrix.columns.3.z = -0.1 //0.1 meters away from my phone
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = modifiedMatrix
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
    }
    
    @IBAction func addButtonClicked(_ sender: Any)
    {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) { // Goal is to calculate the distance
        guard let startingPosition = self.startingPosition else {return}
        guard let pointOfView = self.sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        DispatchQueue.main.async {
            
            self.xLabel.text = String(format:"%.2f",xDistance) + "m"
            self.yLabel.text = String(format:"%.2f",yDistance) + "m"
            self.zLabel.text = String(format:"%.2f",zDistance) + "m"
            self.distance.text =  String(format: "%.2f", self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
        
        
    }
    
    func distanceTravelled(x:Float, y:Float, z:Float) -> Float
    {
        return (sqrt(x*x + y*y + z*z))
    }
}

