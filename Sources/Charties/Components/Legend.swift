//
//  Legend.swift
//  
//
//  Created by Pablo Cornejo on 5/23/21.
//

import SwiftUI

struct Legend<Fill: ShapeStyle>: View {
    let labels: [(String, Fill)]
    
    @State private var gridWidth: CGFloat = .zero
    
    private let spacing: CGFloat = 16
    
    private var columns: [GridItem] { [GridItem(.adaptive(minimum: minimumItemWidth), spacing: spacing)] }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(labels, id: \.0) { label in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(label.1)
                        .frame(width: 16, height: 16)
                    
                    Text(label.0)
                        .font(.caption)
                }
            }
        }
        .captureWidth(in: $gridWidth)
    }
    
    private var minimumItemWidth: CGFloat {
        let availableWidth = gridWidth - (CGFloat(labels.count) - 1) * spacing
        let minItemWidth: CGFloat = 100
        
        return max(availableWidth / CGFloat(labels.count), minItemWidth)
    }
}

struct LegendView_Previews: PreviewProvider {
    static let labels = [
        ("Category A", Color.blue),
        ("Category B", Color.green),
        ("Category C", Color.yellow),
        ("Category D", Color.purple),
        ("Category E", Color.black),
        ("Category F", Color.brown),
        ("Category G", Color.cyan)
    ]
    
    static var previews: some View {
        Group {
            Legend(labels: labels)
            
            Legend(labels: labels)
                .previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
