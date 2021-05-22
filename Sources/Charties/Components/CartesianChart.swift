//
//  CartesianChart.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
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

struct CartesianChart<PlotContent: View>: View {
    let data: ChartData
    var xLabelConfigProvider: (Int) -> (text: String?, angle: Angle) = { ("\($0)", .zero) }
    @ViewBuilder let plotContent: PlotContent
    
    @State private var plotSize: CGSize = .zero
    
    var body: some View {
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
                plotContent
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

struct CartesianChart_Previews: PreviewProvider {
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
                             xAxisTitle: "X",
                             yAxisTitle: "Y")
        data.yAxisGridlineStep = 1
        data.alwaysShowZero = true
        return data
    }
    
    static var previews: some View {
        CartesianChart(data: data) {
            ZStack {
                Color.blue
                Text("Plot content goes here")
                    .foregroundColor(.white)
            }
        }
        .frame(height: 350)
    }
}
