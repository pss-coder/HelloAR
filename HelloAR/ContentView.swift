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
        ZStack(alignment: .bottom) {
            MeasureARViewContainer().edgesIgnoringSafeArea(.all)
                .border(.black)
//            VStack(alignment: .center, content: {
//                Text("Hello")
//                    .background(.white)
//            })
        }
    }
}



#Preview {
    ContentView()
}
