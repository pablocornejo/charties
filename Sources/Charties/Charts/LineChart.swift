//
//  LineChart.swift
//  
//
//  Created by Pablo Cornejo on 4/16/21.
//

import SwiftUI

public struct LineChart<Marker: View, Stroke: ShapeStyle>: View {
    let data: ChartData
    let marker: Marker
    let markerSize: CGSize
    let lineStyle: PlotLineStyle<Stroke>
    var xLabelConfigProvider: (Int) -> (text: String?, angle: Angle) = { ("\($0)", .zero) }
    
    public var body: some View {
        CartesianChart(data: data, xLabelConfigProvider: xLabelConfigProvider) {
            ZStack {
                PlotGridlines(data: data)
                
                PlotLine(data: data, style: lineStyle)
                
                PlotMarkers(data: data,
                        marker: marker,
                        markerSize: markerSize,
                        appearAnimation: .fadeIn(1.5)) { data, size in // TODO: Refactor out animation
                    data.plotAveragedSortedPoints(for: size)
                }
            }
        }
    }
}

struct LineChart_Previews: PreviewProvider {
    static var data: ChartData {
        var data = ChartData([(x: 1, y: -0.25),
                              (x: 2, y: 2),
                              (x: 3, y: 1),
                              (x: 4, y: 2.5),
                              (x: 5, y: 2),
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
    
    static var stroke: some ShapeStyle {
        LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing)
    }
    
    static var previews: some View {
        LineChart(data: data,
                  marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.orange),
                  markerSize: CGSize(width: 16, height: 16),
                  lineStyle: .smooth(stroke))
            .frame(height: 350)
    }
}
