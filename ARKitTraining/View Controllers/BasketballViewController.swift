//
//  BasketballViewController.swift
//  ARKitTraining
//
//  Created by Cem Sertkaya on 8.04.2021.
//

import UIKit
import ARKit
import Each

class BasketballViewController: UIViewController, ARSCNViewDelegate
{

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var basketAdded: Bool  = false
    var power: Float = 1.0
    var timer = Each(0.05).seconds
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal //We've done this for detecting horizontal planes.
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        // Do any additional setup after loading the view.
    }
     
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        guard anchor is ARPlaneAnchor else {return}
        //If it detects a plane, navigation bar title is going to be "Plane Detected" for 3 seconds.
        DispatchQueue.main.async {print("detected")}
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {print("detected finish")}
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        print("cem")
        let sceneView = sender.view as! ARSCNView // you can also do this with guard let structure.
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty{self.addBoard(hitTestResult: hitTestResult.first!)} //We are adding the board in this if clause.
    }
    
    func addBoard(hitTestResult: ARHitTestResult)
    {
        if basketAdded == false
        {
            let board = SCNScene(named: "Basketball.scnassets/Basketball.scn")
            let boardNode = board?.rootNode.childNode(withName: "Basket", recursively: false)
            let transform = hitTestResult.worldTransform
            let planeXposition = transform.columns.3.x
            let planeYposition = transform.columns.3.y
            let planeZposition = transform.columns.3.z
            boardNode?.position = SCNVector3(planeXposition,planeYposition,planeZposition)
            boardNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: boardNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
            self.sceneView.scene.rootNode.addChildNode(boardNode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.basketAdded = true
            }
        }
    }
    
    override func touchesBegan(_ touches : Set<UITouch>, with event: UIEvent?)
    {
        if self.basketAdded == true
        {
            timer.perform { () -> NextStep in
                self.power = self.power + 1
                return .continue
            }
            
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if self.basketAdded == true
        {
            self.timer.stop()
            self.shootBall()
            
        }
        self.power = 1
    }
    
    func shootBall()
    {
        guard let pointOfView = self.sceneView.pointOfView else {return}
        self.removeEveryOtherBall()
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let position = location + orientation
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "ball")
        ball.position = position
        ball.name = "Basketball"
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
        body.restitution = 0.2
        ball.physicsBody = body
        ball.physicsBody?.applyForce(SCNVector3(orientation.x * power, orientation.y * power, orientation.z * power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ball)
    }
    
    func removeEveryOtherBall()
    {
            self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if node.name == "Basketball"{node.removeFromParentNode()}
            }
    }
    
    deinit {
        self.timer.stop()
    }
    
}


func +(left: SCNVector3, right: SCNVector3) -> SCNVector3
{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
