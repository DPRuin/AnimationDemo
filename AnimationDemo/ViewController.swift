//
//  ViewController.swift
//  AnimationDemo
//
//  Created by mac126 on 2018/5/23.
//  Copyright © 2018年 mac126. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var heroNode = SCNNode()
    var animationLength: Float!
    var animationFrame: Float!
    
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/dahuangfeng.DAE")!
        // loadModel()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        heroNode = scene.rootNode.childNode(withName: "Group001", recursively: true)!
        
        let animationPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: "art.scnassets/dahuangfeng.DAE")
        
        // Adjust animation blend duration for smooth transitions.
        animationPlayer.animation.blendInDuration = 0.25
        animationPlayer.animation.blendOutDuration  = 0.5
        animationPlayer.stop()
        
        heroNode.addAnimationPlayer(animationPlayer, forKey: "dahuangfeng")
        animationPlayer.play()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    private func loadModel() {
        scene = SCNScene()
        
        let myscene = SCNScene(named: "Dahuangfeng", inDirectory: "art.scnassets")!
        let wrapperNode = SCNNode()
        for child in myscene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        heroNode.addChildNode(wrapperNode)
        heroNode.position = SCNVector3Make(0, 0, 0)
        heroNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
        scene.rootNode.addChildNode(heroNode)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let animationPlayer = heroNode.animationPlayer(forKey: "dahuangfeng")
        let animation = animationPlayer?.animation
        animationLength = Float((animation?.duration)!)
        animation?.timeOffset = TimeInterval(sender.value * animationLength)
        
        animationPlayer?.speed = 0
    }
    
    
}

// For loading animations with in collada model.
extension SCNAnimationPlayer {
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
//        let dhfnode = scene.rootNode.childNode(withName: "dahuangfeng", recursively: true)!
//        dhfnode.enumerateChildNodes { (child, stop) in
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                print("--\(child.name)--\(child.animationKeys)")
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}
