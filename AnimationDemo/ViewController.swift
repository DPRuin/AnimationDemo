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

struct CycleArray<T> {
    private var array: [T]
    private var cycleIndex: Int
    
    var currentElement: T? {
        get { return array.count > 0 ? array[cycleIndex] : nil }
    }
    
    init(_ array: [T]) {
        self.array = array
        self.cycleIndex = 0
    }
    
    mutating func cycle() -> T?  {
        cycleIndex = cycleIndex + 1 == array.count ? 0 : cycleIndex + 1
        return currentElement
    }
}

let Animations: [(name: String, file: String)] = [
    ("Idle",  "idle.dae"),
    ("Dancing",  "dancing.dae"),
    ("Jumping", "jumping.dae")]

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var heroNode = SCNNode()
    var animationPlayer: SCNAnimationPlayer!
    var animationLength: TimeInterval!
    var animationFrame: Float!
    var isZero:Bool = false
    
    var heroAnimations = CycleArray(Animations)
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var placeButton: UIButton!
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
        // Create a new scene
        scene = SCNScene(named: "art.scnassets/hero.scn")!
        // loadModel()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        heroNode = scene.rootNode.childNode(withName: "hero", recursively: true)!
        
        for animation in Animations {
            let animationPlayer = SCNAnimationPlayer.loadAnimation(fromSceneNamed: "art.scnassets/animations/\(animation.file)")
            
            // Adjust animation blend duration for smooth transitions.
            animationPlayer.animation.blendInDuration = 0.25
            animationPlayer.animation.blendOutDuration  = 0.5
            animationPlayer.stop()
            
            heroNode.addAnimationPlayer(animationPlayer, forKey: animation.name)
        }
        
        heroNode.animationPlayer(forKey: heroAnimations.currentElement!.name)!.play()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDidClick(_:)))
        sceneView.addGestureRecognizer(tap)
        
        slider.isHidden = true
        // heroNode.isHidden = true
        
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // heroNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

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
    

    @objc func tapDidClick(_ gesture: UITapGestureRecognizer) {
        let currAnimation = heroAnimations.currentElement
        let nextAnimation = heroAnimations.cycle()
        
        // Stop current animation.
        heroNode.animationPlayer(forKey: currAnimation!.name)!.stop(withBlendOutDuration: 1.0)
        
        // Play next animation.
        heroNode.animationPlayer(forKey: nextAnimation!.name)!.play()
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let animation = self.animationPlayer?.animation
        animation?.isCumulative = true
        animation?.timeOffset = Double(sender.value) * animationLength
        animationPlayer?.speed = 0
    }
    
    @IBAction func placeButtonDidClick(_ sender: UIButton) {
//        guard let transform = sceneView.session.currentFrame?.camera.transform  else {
//            return
//        }
//        // heroNode.simdPosition = transform.translation
//        heroNode.position = SCNVector3Make(transform.translation.x, transform.translation.y, -2)
//        // heroNode.eulerAngles = SCNVector3Make(0, 0, Float(Double.pi / 2))
//        // heroNode.position = SCNVector3Make(0, 0, -3)
        
        
        guard let centerPoint = sceneView.pointOfView else{return}
        
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x:cameraTransform.m41, y: cameraTransform.m42, z:cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y , cameraLocation.z + cameraOrientation.z)
        heroNode.position = cameraPosition
        
        print("-transform-\(cameraPosition)")
        heroNode.isHidden = false
    }
    
}

extension SCNAnimationPlayer {
    class func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene( named: sceneName )!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer! = nil
        scene.rootNode.enumerateChildNodes { (child, stop) in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }
}


extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // 已经显示后不再更新位置
        if !heroNode.isHidden {return}
//        guard let transform = sceneView.session.currentFrame?.camera.transform  else {
//            return
//        }
//        // heroNode.simdTransform = transform
//        heroNode.position = SCNVector3Make(transform.translation.x, transform.translation.y, -2)
//        // heroNode.position = SCNVector3Make(0, 0, -3)
//        heroNode.isHidden = false
        
        guard let centerPoint = sceneView.pointOfView else{return}
        
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x:cameraTransform.m41, y: cameraTransform.m42, z:cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y , cameraLocation.z + cameraOrientation.z)
        heroNode.position = cameraPosition
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else { return }
        
        let placedObjectIsInView = sceneView.isNode(heroNode, insideFrustumOf: pointOfView)
        
        if placedObjectIsInView { // 隐藏按钮
            DispatchQueue.main.async {
                self.placeButton.isHidden = true
            }
        } else { // 显示按钮
            DispatchQueue.main.async {
                self.placeButton.isHidden = false
            }
        }
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}


