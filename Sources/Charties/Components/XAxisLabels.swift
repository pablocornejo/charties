//
//  SwiftUIView.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

struct XAxisLabels: View {
    let data: ScatterData
    let xLabelConfigProvider: (Int) -> (text: String?, angle: Angle)
    
    var body: some View {
        HStack {
            ForEach(data.minX..<data.maxX + 1) { x in
                let config = xLabelConfigProvider(x)
                Text(config.text ?? "")
                    .font(.caption)
                    .rotationEffect(config.angle)
                
                if x < data.maxX {
                    Spacer()
                }
            }
        }
    }
}

struct XAxisLabels_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview.")
    }
}
