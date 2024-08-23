//
//  HelloARContainer.swift
//  HelloAR
//
//  Created by Pawandeep Singh Sekhon on 23/8/24.
//

import RealityKit
import ARKit
import SwiftUI


/// create cube model
func createCubeModel() -> ModelEntity {
    let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
    let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
    let model = ModelEntity(mesh: mesh, materials: [material])
    model.transform.translation.y = 0.05
    return model
}

func anchor(model: ModelEntity, at location:SIMD3<Float>) -> AnchorEntity {
    
    //Anchor
    let anchor = AnchorEntity(world: location)
    
    // Tie model to anchor
    anchor.children.append(model)
    return anchor
}


//MARK: AR Container
// bridge between the SwiftUI framework and the RealityKit framework
struct HelloWorldARViewContainer: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)

        // Create a cube model
        let model = createCubeModel()
       

        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)

        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        // Set the 'view' property of the coordinator to the 'uiView' passed as an argument.
        context.coordinator.ARview = uiView
        
        // create tap gesture recogniser
        let tapGestureRecogniser = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(recogniser:)))
        
        // add gesture to view for user interaction
        uiView.addGestureRecognizer(tapGestureRecogniser)
        
    }
    
    //manage the integration of UIKit components or functionality into a SwiftUI-based app
    class Coordinator: NSObject {
        
        var ARview: ARView?
        
        
        //Handle Tap
        @objc
        func handleTap(recogniser: UITapGestureRecognizer? = nil) {
            
            // Check if there is a view to work with
            guard let view = self.ARview else { return }
            
            //Tap Location
            let tapLocation = recogniser!.location(in: view)
            
            //Raycast; 2d->3d
            let results = view.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResults = results.first {
                //3d points (x,y,z)
                let worldPos = simd_make_float3(firstResults.worldTransform.columns.3)
                
                // create Cube
                let cube = createCubeModel()
                
                // anchor content
                let anchor = anchor(model: cube, at: worldPos)
                
                // add anchor to scene
                view.scene.addAnchor(anchor)
                
            }
            
        }
    }
    
}
