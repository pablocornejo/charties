//
//  SwiftUIView.swift
//  
//
//  Created by Pablo Cornejo on 5/23/21.
//

import SwiftUI

struct BarChartCell<Fill: ShapeStyle>: View {
    var filledRange: ClosedRange<Double>
    var fill: Fill
    
    @State private var barWidth: CGFloat = .zero
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                RoundedRectangle(cornerRadius: barWidth / 4)
                    .fill(fill)
                    .frame(height: proxy.size.height * CGFloat(filledRange.upperBound - filledRange.lowerBound))
                    .captureWidth(in: $barWidth)
                
                Rectangle()
                    .frame(height: proxy.size.height * CGFloat(filledRange.lowerBound))
                    .foregroundColor(.clear)
            }
        }
    }
}

struct BarChartCell_Previews: PreviewProvider {
    static var previews: some View {
        Text("No Preview")
    }
}
