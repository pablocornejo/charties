//
//  File.swift
//  
//
//  Created by Pablo Cornejo on 5/1/21.
//

import SwiftUI

enum PlotLineStyle<Stroke: ShapeStyle> {
    case straight(Stroke)
    case smooth(Stroke)
    case none
}

struct PlotLine<Stroke: ShapeStyle>: View {
    let data: ChartData
    let style: PlotLineStyle<Stroke>
    
    @State private var didAppear = false
    
    var body: some View {
        GeometryReader { reader in
            switch style {
            case .smooth(let stroke), .straight(let stroke):
                path(forSize: reader.size)
                    .trim(from: 0, to: didAppear ? 1 : 0)
                    // TODO: Refactor out stroke style and animation
                    .stroke(stroke, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .animation(Animation.easeOut(duration: 1.5).delay(0.2))
                    .onAppear {
                        didAppear = true
                    }
            case .none:
                EmptyView()
            }
        }
    }
    
    private func path(forSize size: CGSize) -> some Shape {
        let points = data.plotAveragedSortedPoints(for: size)
        
        switch style {
        case .smooth:
            var currentPoint = points.first ?? .zero
            
            return Path { path in
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
        case .straight:
            return Path { path in
                path.addLines(points)
            }
        case .none:
            return Path()
        }
    }
    
    private func controlPointForPoints(p1: CGPoint, p2: CGPoint, next p3: CGPoint?) -> CGPoint? {
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
    
    private func antipodalFor(point: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let point = point, let center = center else { return nil }
        
        let newX = center.x + (center.x - point.x)
        let newY = center.y + (center.y - point.y)
        
        return CGPoint(x: newX, y: newY)
    }
}

private extension CGPoint {
    static func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        CGPoint(x: (p1.x + p2.x) / 2,
                y: (p1.y + p2.y) / 2)
    }
}

private extension CGFloat {
    func isBetween(_ a: CGFloat, and b: CGFloat) -> Bool {
        self >= Swift.min(a, b) && self <= Swift.max(a, b)
    }
}
