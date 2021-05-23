//
//  YAxisGridlines.swift
//  
//
//  Created by Pablo Cornejo on 5/23/21.
//

import SwiftUI

struct YAxisGridlines: View {
    let max: Double
    let min: Double
    let steps: Int
    
    var body: some View {
        if steps > 0 && span > 0 {
            GeometryReader { reader in
                let stepSize = reader.size.height / CGFloat(steps)
                let stepValue = span / Double(steps)

                ForEach(0..<steps + 1) { idx in
                    let yValue = max - Double(idx) * stepValue
                    
                    Rectangle()
                        .foregroundColor(yValue == 0 ? .primary : .secondary)
                        .frame(height: 1)
                        .offset(y: CGFloat(idx) * stepSize)
                }
            }
        }
    }
    
    private var span: Double { max - min }
}

struct YAxisGridlines_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview.")
    }
}
