//
//  MeasureARViewContainer.swift
//  HelloAR
//
//  Created by Pawandeep Singh Sekhon on 23/8/24.
//

import RealityKit
import ARKit
import SwiftUI

//MARK: AR Container
// bridge between the SwiftUI framework and the RealityKit framework
struct MeasureARViewContainer: UIViewRepresentable {
    
    func makeCoordinator() -> MeasureCoordinator  {
        return MeasureCoordinator()
    }
    
    
    func makeUIView(context: Context) -> some UIView {
        
        //create AR view
        let arView = ARView(frame: .zero)
        
        // set up configurations - horizontal
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // Link view to coordinator view and setup UI
        context.coordinator.view = arView
        context.coordinator.makeUI()
        
        // add tap gesture
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:))))
        
        // add coaching overlay for instructions
        arView.addCoachingOverlay()
        
        
        
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        return
    }
    
    
}

class MeasureCoordinator: NSObject {
    var view: ARView?
    
    var startAnchor: AnchorEntity?
    var endAnchor: AnchorEntity?
    
    //MARK:  set display buttons
    lazy var measurementButton: UIButton = {
        
        let btn = UIButton(configuration: .filled())
        btn.setTitle("0.00", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isUserInteractionEnabled = false

        return btn
    }()
    
    lazy var resetButton: UIButton = {
        let btn = UIButton(configuration: .gray(), primaryAction: UIAction(handler: { [weak self] action in
            guard let arView = self?.view else { return }
            
            // reset anchors
            self?.startAnchor = nil
            self?.endAnchor = nil
            
            // remove anchors
            arView.scene.anchors.removeAll()
            self?.measurementButton.setTitle("0.00", for: .normal)
        }))
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Reset Measurement", for: .normal)
        
        return btn
    }()
    
    
    //MARK: UI Setup
    func makeUI() {
        guard let arView = view else {return}
        
        // using stack
        let stackView = UIStackView(arrangedSubviews: [measurementButton, resetButton])
        
        // add stack to ar view
        arView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // position stackview to bottom
        stackView.centerXAnchor.constraint(equalTo: arView.centerXAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: arView.bottomAnchor, constant: -60).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 44).isActive = true

    }
    
    
    @objc
    func handleTap(_ recogniser: UITapGestureRecognizer) {
        
        // Check if there is a view to work with
        guard let view = self.view else { return }
        
        //Tap Location
        let tapLocation = recogniser.location(in: view)
        
        //Raycast; 2d->3d
        let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            
            //start with first pointer
            if startAnchor == nil {
                
                //initialise startAnchor with pointer to view
                startAnchor = anchor(model: createPoint(), at: firstResult)
                
                guard let startAnchor = startAnchor else {return}
                
                // add anchor to view
                view.scene.addAnchor(startAnchor)
                
                
            } else if endAnchor == nil {
                //second pointer
                endAnchor = anchor(model: createPoint(), at: firstResult)
                
                guard let endAnchor = endAnchor,
                        let startAnchor = startAnchor else {return}
                
                // add anchor to view
                view.scene.addAnchor(endAnchor)
                
                //get distance between 2 points
                let distance = calculateDistanceBetween(start: startAnchor, end: endAnchor)
                
                
                // draw line between the 2 points
                
                let rectangle = ModelEntity(mesh: .generateBox(width: 0.003, height: 0.003, depth: distance), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
                
                // Middle point of the two points
                // get point distance
                let startPoint = startAnchor.position(relativeTo: nil)
                let endPoint = endAnchor.position(relativeTo: nil)
                
                let middlePoint : simd_float3 = simd_float3((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y)/2, (startPoint.z + endPoint.z)/2)
                        
                let lineAnchor = AnchorEntity()
                lineAnchor.position = middlePoint
                lineAnchor.look(at: startPoint, from: middlePoint, relativeTo: nil)
                lineAnchor.addChild(rectangle)
                view.scene.addAnchor(lineAnchor)

                
                
               
                
                // Update UI
                measurementButton.setTitle(String(format: "%.2f m", distance), for: .normal)
                
                
            }
        }
    }
    
    func calculateDistanceBetween(start: AnchorEntity, end: AnchorEntity) -> Float {
        
        // get point distance
        let startPoint = startAnchor!.position(relativeTo: nil)
        let endPoint = endAnchor!.position(relativeTo: nil)
        
        // get distance between the two points
        let distance = simd_distance(startPoint, endPoint)
        return distance
    }
    
    func createPoint() -> ModelEntity {
        let ball = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [SimpleMaterial(color: .black,isMetallic: false)])
        
        return ball
    }
    
    func anchor(model: ModelEntity, at location:ARRaycastResult) -> AnchorEntity {
        
        //Anchor
        let anchor = AnchorEntity(raycastResult: location)
        
        // Tie model to anchor
        anchor.addChild(model)
        return anchor
    }
}

//MARK: Extension for ARView
extension ARView {
    func addCoachingOverlay() {
        let coachingView = ARCoachingOverlayView()
        
        // ask user to place horizontally
        coachingView.goal = .horizontalPlane
        
        coachingView.session = self.session
        coachingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Add coaching view
        self.addSubview(coachingView)
    }
}
