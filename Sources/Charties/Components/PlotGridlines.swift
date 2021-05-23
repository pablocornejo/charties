//
//  PlotGridlines.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

struct PlotGridlines: View {
    let data: ChartData
    
    var body: some View {
        YAxisGridlines(max: data.maxY,
                       min: data.minY,
                       steps: Int(data.yAxisSpan / data.yAxisGridlineStep))
    }
}

struct PlotGridlines_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview.")
    }
}
