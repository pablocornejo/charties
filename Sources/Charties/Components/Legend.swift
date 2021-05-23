//
//  Legend.swift
//  
//
//  Created by Pablo Cornejo on 5/23/21.
//

import SwiftUI

struct Legend<Fill: ShapeStyle>: View {
    let labels: [(String, Fill)]
    
    @State private var textHeight: CGFloat = .zero
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), spacing: 24, alignment: .trailing),
        GridItem(.adaptive(minimum: 150), alignment: .leading)
    ]
    
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
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
        Legend(labels: [("Category A", Color.blue), ("Category B", Color.green), ("Category C", Color.yellow)])
    }
}
