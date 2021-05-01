//
//  ScatterChart.swift
//  
//
//  Created by Pablo Cornejo on 4/16/21.
//

import SwiftUI

enum ChartLineStyle<Stroke: ShapeStyle> {
    case straight(Stroke)
    case smooth(Stroke)
    case none
}

private extension VerticalAlignment {
    private enum BottomYLabelsAndPlot: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.bottom]
        }
    }
    
    static let bottomYLabelsAndPlot = VerticalAlignment(BottomYLabelsAndPlot.self)
}

struct SizeUpdater: View {
    private struct SizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero

        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    @Binding var size: CGSize
    
    init(_ size: Binding<CGSize>) {
        self._size = size
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
        .onPreferenceChange(SizePreferenceKey.self) { value in
            size = value
        }
    }
}

extension View {
    func captureSize(in size: Binding<CGSize>) -> some View {
        background(SizeUpdater(size))
    }
}

public struct ScatterChart<Marker: View, Stroke: ShapeStyle>: View {
    let data: ScatterData
    let marker: Marker
    let markerSize: CGSize
    let lineStyle: ChartLineStyle<Stroke>
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
                ScatterYAxisLabels(data: data)
                    .alignmentGuide(.bottomYLabelsAndPlot) { $0[.bottom] }
            }
            .frame(height: plotSize.height)
            
            VStack {
                ZStack {
                    ScatterYAxisGuidelines(data: data)
                    
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
                
                ScatterXAxisLabels(data: data, xLabelConfigProvider: xLabelConfigProvider)
                
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

struct ScatterXAxisLabels: View {
    let data: ScatterData
    let xLabelConfigProvider: (Int) -> (text: String?, angle: Angle)
    
    var body: some View {
        HStack {
            ForEach(data.minX..<data.maxX + 1) { x in
                let config = xLabelConfigProvider(x)
                Text(config.text ?? "")
                    .font(.caption)
                    .rotationEffect(config.angle)
                
                if x < data.maxX {
                    Spacer()
                }
            }
        }
    }
}

struct ScatterYAxisLabels: View {
    let data: ScatterData
    
    var body: some View {
        if data.yAxisMarkSize > 0 {
            VStack(alignment: .trailing) {
                let steps = Int(data.yAxisSpan / data.yAxisMarkSize)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = data.maxY - Double(idx) * data.yAxisMarkSize
                    
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
    
    private let font: UIFont = .preferredFont(forTextStyle: .caption1)
    
    private var topPadding: CGFloat {
        -text(forYValue: data.maxY)
            .size(withFont: font)
            .height / 2
    }
    
    private var bottomPadding: CGFloat {
        -text(forYValue: data.minY)
            .size(withFont: font)
            .height / 2
    }
    
    private func text(forYValue yValue: Double) -> String {
        yValue == 0 ? "0" : String(format: "%.1f", yValue)
    }
}

struct ScatterYAxisGuidelines: View {
    let data: ScatterData
    
    var body: some View {
        if data.yAxisMarkSize > 0 {
            GeometryReader { reader in
                let steps = Int(data.yAxisSpan / data.yAxisMarkSize)
                let yStep = reader.size.height / CGFloat(steps)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = data.maxY - Double(idx) * data.yAxisMarkSize
                    
                    Rectangle()
                        .foregroundColor(yValue == 0 ? .primary : .secondary)
                        .frame(height: 1)
                        .offset(y: CGFloat(idx) * yStep)
                }
            }
        }
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
        ScatterChart(data: data,
                     marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.orange),
                     markerSize: CGSize(width: 16, height: 16),
                     lineStyle: .smooth(stroke))
            .frame(height: 350)
    }
}
