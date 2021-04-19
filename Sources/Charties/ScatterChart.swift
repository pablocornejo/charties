//
//  ScatterChart.swift
//  
//
//  Created by Pablo Cornejo on 4/16/21.
//

import SwiftUI

enum ScatterLineStyle {
    case straight, smooth, none
}

public struct ScatterChart<Marker: View>: View {
    let data: ScatterData
    let marker: Marker
    let markerSize: CGSize
    let lineStyle: ScatterLineStyle
    var xLabelTextProvider: (Int) -> String = { "\($0)" }
    
    public var body: some View {
        GeometryReader { reader in
            HStack {
                VStack {
                    HStack {
                        if let yTitle = data.yAxisTitle {
                            Text(yTitle)
                        }
                        ScatterYAxisLabels(data: data, xLabelTextProvider: xLabelTextProvider)
                            .frame(width: yAxisLabelsWidth)
                    }
                        
                    Spacer(minLength: yAxisElementsBottomSpace)
                }
                
                VStack(spacing: 0) {
                    ZStack {
                        ScatterYAxisGuidelines(data: data)
                        
                        switch lineStyle {
                        case .smooth:   SmoothScatterLine(data: data)
                        case .straight: StraightScatterLine(data: data)
                        case .none:     EmptyView()
                        }
                        
                        ScatterMarkers(data: data,
                                       marker: marker,
                                       markerSize: markerSize,
                                       appearAnimation: .fadeIn(1.5)) // TODO: Refactor out animation
                    }
                    .layoutPriority(1)
                    
                    ScatterXAxisLabels(data: data, xLabelTextProvider: xLabelTextProvider)
                        .frame(height: xAxisLabelsHeight)
                        .padding(.top, xAxisLabelsTopPadding)
                    
                    if let xTitle = data.xAxisTitle {
                        Text(xTitle)
                            .frame(height: xAxisTitleHeight)
                    }
                }
            }
        }
        .padding()
    }
    
    private let xAxisLabelsHeight: CGFloat = 24
    private let xAxisLabelsTopPadding: CGFloat = 8
    private let xAxisTitleHeight: CGFloat = 24
    
    private let yAxisLabelsWidth: CGFloat = 24
    private var yAxisElementsBottomSpace: CGFloat {
        xAxisLabelsHeight + xAxisLabelsTopPadding +
            (data.xAxisTitle.map { _ in xAxisTitleHeight } ?? 0)
    }
}

struct ScatterXAxisLabels: View {
    let data: ScatterData
    let xLabelTextProvider: (Int) -> String
    
    var body: some View {
        GeometryReader { reader in
            let xStep = reader.size.width / CGFloat(data.xAxisSpan)

            ForEach(0..<data.xAxisSpan + 1) { idx in
                let text = xLabelTextProvider(data.minX + idx)
                let width = text.size(withFont: .preferredFont(forTextStyle: .caption1)).width
                Text(text)
                    .font(.caption)
                    .offset(x: CGFloat(idx) * xStep - width / 2)
            }
        }
    }
}

struct ScatterYAxisLabels: View {
    let data: ScatterData
    let xLabelTextProvider: (Int) -> String
    
    var body: some View {
        GeometryReader { reader in
            if data.yAxisMarkSize > 0 {
                let steps = Int(data.yAxisSpan / data.yAxisMarkSize)
                let yStep = reader.size.height / CGFloat(steps)
                
                ForEach(0..<steps + 1) { idx in
                    let yValue = data.maxY - Double(idx) * data.yAxisMarkSize
                    let text = yValue == 0 ? "0" : String(format: "%.1f", yValue)
                    
                    let height = text.size(withFont: .preferredFont(forTextStyle: .caption1)).height
                    
                    Text(text)
                        .font(.caption)
                        .offset(y: CGFloat(idx) * yStep - height / 2)
                }
            }
        }
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

struct SmoothScatterLine: View {
    let data: ScatterData
    
    @State var didAppear = false
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let points = data.averagedSortedPoints(forSize: reader.size).map {
                CGPoint(x: $0.x, y: height - $0.y)
            }
            
            var currentPoint = points.first ?? .zero
            
            Path { path in
                path.move(to: currentPoint)
                
                var oldControlP: CGPoint?
                
                for (idx, nextPoint) in Array(points.enumerated())[1...] {
                    var p3: CGPoint?
                    if idx < points.count - 1 {
                        p3 = points[idx + 1]
                    }
                    
                    let newControlP = controlPointForPoints(p1: currentPoint, p2: nextPoint, next: p3)
                    
                    path.addCurve(to: nextPoint,
                                  control1: oldControlP ?? currentPoint,
                                  control2: newControlP ?? nextPoint)
                    
                    currentPoint = nextPoint
                    oldControlP = antipodalFor(point: newControlP, center: nextPoint)
                }
            }
            .trim(from: 0, to: didAppear ? 1 : 0)
            // TODO: Refactor out stroke content and animation
            .stroke(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .animation(Animation.easeOut(duration: 1.5).delay(0.2))
            .onAppear {
                didAppear = true
            }
        }
    }
    
    func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else { return nil }
        
        let leftMidPoint = CGPoint.midPoint(p1, p2)
        let rightMidPoint = CGPoint.midPoint(p2, p3)
        
        var controlPoint = CGPoint.midPoint(leftMidPoint, antipodalFor(point: rightMidPoint, center: p2)!)
        
        if p1.y.isBetween(p2.y, and: controlPoint.y) {
            controlPoint.y = p1.y
        } else if p2.y.isBetween(p1.y, and: controlPoint.y) {
            controlPoint.y = p2.y
        }
        
        
        let imaginContol = antipodalFor(point: controlPoint, center: p2)!
        
        if p2.y.isBetween(p3.y, and: imaginContol.y) {
            controlPoint.y = p2.y
        }
        
        if p3.y.isBetween(p2.y, and: imaginContol.y) {
            let diffY = abs(p2.y - p3.y)
            controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
        }
        
        controlPoint.x += (p2.x - p1.x) * 0.1 // makes line smoother
        
        return controlPoint
    }
    
    func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let point = point, let center = center else { return nil }
        
        let newX = center.x + (center.x - point.x)
        let newY = center.y + (center.y - point.y)
        
        return CGPoint(x: newX, y: newY)
    }
}

struct StraightScatterLine: View {
    let data: ScatterData
    
    @State var didAppear = false
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let points = data.averagedSortedPoints(forSize: reader.size).map {
                CGPoint(x: $0.x, y: height - $0.y)
            }
            
            Path { path in
                path.addLines(points)
            }
            .trim(from: 0, to: didAppear ? 1 : 0)
            // TODO: Refactor out stroke content and animation
            .stroke(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .animation(Animation.easeOut(duration: 1.5).delay(0.2))
            .onAppear {
                didAppear = true
            }
        }
    }
}

extension CGPoint {
    static func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2,
                y: (p1.y + p2.y) / 2)
    }
}

extension CGFloat {
    func isBetween(_ a: CGFloat, and b: CGFloat) -> Bool {
        self >= Swift.min(a, b) && self <= Swift.max(a, b)
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
    
    static var previews: some View {
        ScatterChart(data: data,
                     marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.orange),
                     markerSize: CGSize(width: 16, height: 16),
                     lineStyle: .smooth)
            .frame(height: 350)
    }
}
