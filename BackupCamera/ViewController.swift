//
//  ViewController.swift
//  BackupCamera
//
//  Created by Mohamed Alturfi on 2/16/25.
//

import UIKit
import AVFoundation
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceBar: UIProgressView!
    
    private let arSession = ARSession()
    private let beepSoundID: SystemSoundID = 1052
    private let minDistanceThreshold: Float = 1.0
    private var lastUpdateTime: TimeInterval = 0
    private var lidarUpdateInterval: Double = 0.2

    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(distanceLabel)
        setupCamera()
        setupLiDAR()
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        let arView = ARSCNView(frame: cameraView.bounds)
        arView.session = arSession
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.automaticallyUpdatesLighting = true
        arView.scene = SCNScene()
        cameraView.addSubview(arView)
    }

    // MARK: - LiDAR & ARKit Setup
    private func setupLiDAR() {
        guard ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) else {
            print("LiDAR not supported on this device.")
            return
        }

        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .meshWithClassification
        config.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .sceneDepth
            print("Scene Depth Enabled")
        }

        config.planeDetection = []  // Reduce load
        config.isAutoFocusEnabled = false

        arSession.delegate = self
        arSession.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - ARSession Delegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentTime = frame.timestamp
        if currentTime - lastUpdateTime < lidarUpdateInterval { return }  // Limit updates to every second
        lastUpdateTime = currentTime

        guard let depthMap = frame.sceneDepth?.depthMap else {
            print("No Depth Map Available")
            return
        }

        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        let centerPoint = CGPoint(x: CGFloat(width) / 2, y: CGFloat(height) / 2)

        DispatchQueue.global(qos: .userInitiated).async {
            let distance = self.getDepthValue(from: depthMap, at: centerPoint)

            DispatchQueue.main.async {
                self.updateDistanceLabel(distance)
            }
        }
    }

    // MARK: - Distance Processing
    private func getDepthValue(from depthMap: CVPixelBuffer, at point: CGPoint) -> Float {
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)

        guard let baseAddress = CVPixelBufferGetBaseAddress(depthMap)?.assumingMemoryBound(to: Float32.self) else {
            print("Failed to get depth map base address")
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            return -1
        }

        let width = CVPixelBufferGetWidth(depthMap)
        let height = CVPixelBufferGetHeight(depthMap)
        let rowBytes = CVPixelBufferGetBytesPerRow(depthMap)

        let x = max(0, min(Int(point.x), width - 1))
        let y = max(0, min(Int(point.y), height - 1))
        let index = y * (rowBytes / MemoryLayout<Float32>.stride) + x

        let depth = baseAddress[index]
        CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)

        return depth.isNaN ? -1 : depth
    }

    // MARK: - UI Updates
    private func updateDistanceLabel(_ distance: Float) {
        print("Distance to Object: \(distance) meters")
        
        // Update the label
        distanceLabel.text = String(format: "Distance: %.2f m", distance)
        distanceLabel.textColor = (distance < minDistanceThreshold) ? .red : .white
        
        // Update the progress bar (distanceBar)
        let normalizedDistance = max(0, min(distance, 1.0)) // Normalize distance between 0 and 1
        distanceBar.progress = normalizedDistance // Set progress bar

        if distance < minDistanceThreshold {
            triggerBeep(distance)
        } else {
            stopBeeping()
        }
    }

    // MARK: - Sound & Alerts
    var beepTimer: Timer?
    var lastBeepThreshold: TimeInterval? // Stores the last threshold to avoid unnecessary resets

    func triggerBeep(_ distance: Float) {
        let newBeepInterval: TimeInterval

        switch distance {
        case 0..<0.2:
            newBeepInterval = 0.1 // Fastest beeps
        case 0.2..<0.5:
            newBeepInterval = 0.3
        case 0.5..<0.7:
            newBeepInterval = 0.5 // Medium-speed beeps
        case 0.7..<1.0:
            newBeepInterval = 1.0 // Slowest beeps
        default:
            print("Stopping beeps (Distance: \(distance)m)")
            stopBeeping()
            lastBeepThreshold = nil
            return
        }

        // Prevent unnecessary restarts: Only update if threshold has changed
        if lastBeepThreshold == newBeepInterval {
            return
        }

        lastBeepThreshold = newBeepInterval // Store the current threshold

        print("Beeping every \(newBeepInterval) seconds for distance: \(distance)m")

        // Stop any existing timer before starting a new one
        stopBeeping()

        beepTimer = Timer.scheduledTimer(withTimeInterval: newBeepInterval, repeats: true) { _ in
            AudioServicesPlaySystemSound(1052) // Beep sound
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // Vibrate
        }
    }

    // MARK: - Stop Beeping
    func stopBeeping() {
        beepTimer?.invalidate()
        beepTimer = nil
        print("Beeping stopped")
    }


}
