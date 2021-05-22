//
//  SwiftUIView.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

struct PlotGridlines: View {
    let data: ChartData
    
    var body: some View {
        if data.yAxisGridlineStep > 0 {
            GeometryReader { reader in
                let steps = Int(data.yAxisSpan / data.yAxisGridlineStep)
                let yStep = reader.size.height / CGFloat(steps)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = data.maxY - Double(idx) * data.yAxisGridlineStep
                    
                    Rectangle()
                        .foregroundColor(yValue == 0 ? .primary : .secondary)
                        .frame(height: 1)
                        .offset(y: CGFloat(idx) * yStep)
                }
            }
        }
    }
}

struct PlotGridlines_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview.")
    }
}
