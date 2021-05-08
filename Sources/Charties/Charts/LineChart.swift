//
//  LineChart.swift
//  
//
//  Created by Pablo Cornejo on 4/16/21.
//

import SwiftUI

private extension VerticalAlignment {
    private enum BottomYLabelsAndPlot: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.bottom]
        }
    }
    
    static let bottomYLabelsAndPlot = VerticalAlignment(BottomYLabelsAndPlot.self)
}

public struct LineChart<Marker: View, Stroke: ShapeStyle>: View {
    let data: ScatterData
    let marker: Marker
    let markerSize: CGSize
    let lineStyle: PlotLineStyle<Stroke>
    var xLabelConfigProvider: (Int) -> (text: String?, angle: Angle) = { ("\($0)", .zero) }
    
    @State private var plotSize: CGSize = .zero
    
    public var body: some View {
        HStack(alignment: .bottomYLabelsAndPlot) {
            HStack {
                if let yTitle = data.yAxisTitle {
                    Text(yTitle)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                YAxisLabels(data: data)
                    .alignmentGuide(.bottomYLabelsAndPlot) { $0[.bottom] }
            }
            .frame(height: plotSize.height)
            
            VStack {
                ZStack {
                    PlotGridlines(data: data)
                    
                    PlotLine(data: data, style: lineStyle)
                    
                    ScatterMarkers(data: data,
                                   marker: marker,
                                   markerSize: markerSize,
                                   appearAnimation: .fadeIn(1.5)) // TODO: Refactor out animation
                }
                .padding(.leading, plotLeadingPadding)
                .padding(.trailing, plotTrailingPadding)
                .alignmentGuide(.bottomYLabelsAndPlot) { $0[.bottom] }
                .captureSize(in: $plotSize)
                
                XAxisLabels(data: data, xLabelConfigProvider: xLabelConfigProvider)
                
                if let xTitle = data.xAxisTitle {
                    Text(xTitle)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    private let xAxisLabelsHeight: CGFloat = 24
    private let xAxisLabelsTopPadding: CGFloat = 8
    private let xAxisTitleHeight: CGFloat = 24
    
    private let yAxisLabelsWidth: CGFloat = 24
    private var yAxisElementsBottomSpace: CGFloat {
        xAxisLabelsHeight + xAxisLabelsTopPadding +
            (data.xAxisTitle.map { _ in xAxisTitleHeight } ?? 0)
    }
    
    private let axisLabelsFont: UIFont = .preferredFont(forTextStyle: .caption1)
    
    private var plotLeadingPadding: CGFloat {
        xLabelConfigProvider(data.minX)
            .text
            .map {
                $0.size(withFont: axisLabelsFont).width / 2
            } ?? 0
    }
    
    private var plotTrailingPadding: CGFloat {
        xLabelConfigProvider(data.maxX)
            .text
            .map {
                $0.size(withFont: axisLabelsFont).width / 2
            } ?? 0
    }
}

struct ScatterChart_Previews: PreviewProvider {
    static var data: ScatterData {
        var data = ScatterData([(x: 1, y: -0.25),
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
