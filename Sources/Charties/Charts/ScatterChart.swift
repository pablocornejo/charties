//
//  ScatterChart.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

public struct ScatterChart<Marker: View>: View {
    let data: ChartData
    let marker: Marker
    let markerSize: CGSize
    var xLabelConfigProvider: (Int) -> (text: String?, angle: Angle) = { ("\($0)", .zero) }
    
    @State private var plotSize: CGSize = .zero
    
    public var body: some View {
        CartesianChart(data: data, xLabelConfigProvider: xLabelConfigProvider) {
            ZStack {
                PlotGridlines(data: data)
                
                PlotMarkers(data: data,
                        marker: marker,
                        markerSize: markerSize,
                        appearAnimation: .fadeIn(1.5)) { data, size in // TODO: Refactor out animation
                    data.plotPoints(for: size)
                }
            }
        }
    }
}

struct ScatterChart_Previews: PreviewProvider {
    static var data: ChartData {
        var data = ChartData([(x: 1, y: -0.25),
                              (x: 1, y: 0.5),
                              (x: 2, y: 2),
                              (x: 3, y: 1),
                              (x: 4, y: 2.5),
                              (x: 5, y: 2),
                              (x: 5, y: 0),
                              (x: 6, y: 2.5),
                              (x: 7, y: 2),
                              (x: 9, y: 1),
                              (x: 10, y: 2.75)],
                             xAxisTitle: "Day",
                             yAxisTitle: "pH")
        data.yAxisMarkSize = 1
        data.alwaysShowZero = true
        return data
    }
    
    static var previews: some View {
        ScatterChart(data: data,
                     marker: Rectangle().strokeBorder(lineWidth: 2).foregroundColor(.blue),
                     markerSize: CGSize(width: 16, height: 16))
            .frame(height: 350)
    }
}

