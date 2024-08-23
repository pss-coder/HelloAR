//
//  ContentView.swift
//  HelloAR
//
//  Created by Pawandeep Singh Sekhon on 23/8/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        VStack(content: {
            Text("Hello AR")
            MeasureARViewContainer().edgesIgnoringSafeArea(.all)
                .border(.black)
                .padding()
        })
        
    }
}

#Preview {
    ContentView()
}
