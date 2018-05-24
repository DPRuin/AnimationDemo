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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var heroNode = SCNNode()
    var animationPlayer: SCNAnimationPlayer!
    var animationLength: TimeInterval!
    var animationFrame: Float!
    var isZero:Bool = false
    
    var heroAnimations = CycleArray(Animations)
    
    @IBOutlet weak var slider: UISlider!
    
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

