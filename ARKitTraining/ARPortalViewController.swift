//
//  ARPortalViewController.swift
//  ARKitTraining
//
//  Created by Cem Sertkaya on 6.04.2021.
//

import UIKit
import ARKit
class ARPortalViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var barText: UIBarButtonItem!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal //We've done this for detecting horizontal planes...
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
       
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        print("cem")
        let sceneView = sender.view as! ARSCNView
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty
        {
            self.addPortal(hitTestResult: hitTestResult.first!)
        }
        else
        {
            
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        guard anchor is ARPlaneAnchor else {return}
        //If it detects a plane, navigation bar title is going to be "Plane Detected" for 3 seconds.
        DispatchQueue.main.async {
            self.barText.title = "Plane Detected"
            print("detected")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.barText.title = ""
            print("detected finish")
        }
        
    }
    
    func addPortal(hitTestResult: ARHitTestResult)
    {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false)
        let transform = hitTestResult.worldTransform
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        portalNode?.position = SCNVector3(planeXposition,planeYposition,planeZposition)
        self.sceneView.scene.rootNode.addChildNode(portalNode!)
        self.addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode!, imageName: "bottom")
        self.addWalls(nodeName: "backWall", portalNode: portalNode!, imageName: "back")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode!, imageName: "sideA")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode!, imageName: "sideB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode!, imageName: "sideDoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode!, imageName: "sideDoorB")
        
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
    }

    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
    }

}
