//
//  SwiftUIView.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

struct YAxisLabels: View {
    let data: ChartData
    
    var body: some View {
        if data.yAxisGridlineStep > 0 {
            VStack(alignment: .trailing) {
                let steps = Int(data.yAxisSpan / data.yAxisGridlineStep)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = data.maxY - Double(idx) * data.yAxisGridlineStep
                    
                    Text(text(forYValue: yValue))
                        .font(.caption)
                    
                    if idx < steps {
                        Spacer()
                    }
                }
            }
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
        } else {
            EmptyView()
        }
    }
    
    private let font: UIFont = .preferredFont(forTextStyle: .caption1)
    
    private var topPadding: CGFloat {
        -text(forYValue: data.maxY)
            .size(withFont: font)
            .height / 2
    }
    
    private var bottomPadding: CGFloat {
        -text(forYValue: data.minY)
            .size(withFont: font)
            .height / 2
    }
    
    private func text(forYValue yValue: Double) -> String {
        yValue == 0 ? "0" : String(format: "%.1f", yValue)
    }
}

struct YAxisLabels_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview.")
    }
}
