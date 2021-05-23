//
//  YAxisLabels.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

struct YAxisLabels: View {
    let max: Double
    let min: Double
    let steps: Int
    
    var body: some View {
        if steps > 0 && span > 0 {
            VStack(alignment: .trailing) {
                let stepValue = span / Double(steps)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = max - Double(idx) * stepValue
                    
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
    
    private var span: Double { max - min }
    
    private let font: UIFont = .preferredFont(forTextStyle: .caption1)
    
    private var topPadding: CGFloat {
        -text(forYValue: max)
            .size(withFont: font)
            .height / 2
    }
    
    private var bottomPadding: CGFloat {
        -text(forYValue: min)
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
