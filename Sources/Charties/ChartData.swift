//
//  ScatterData.swift
//  
//
//  Created by Pablo Cornejo on 4/18/21.
//

import Foundation
import CoreGraphics

public struct ChartData {
    let data: [(x: Double, y: Double)]
    let xAxisTitle: String?
    let yAxisTitle: String?
    var yAxisMarkSize: Double
    var alwaysShowZero: Bool
    
    var minX: Int { Int(floor(data.map(\.x).min() ?? 0)) }
    var maxX: Int { Int(ceil(data.map(\.x).max() ?? 0)) }
    
    var minY: Double {
        let minValue = data.map(\.y).min() ?? 0
        
        guard yAxisMarkSize > 0 else { return minValue }
        
        if minValue >= 0 && alwaysShowZero {
            return 0
        }
        
        let stepRemainder = minValue.truncatingRemainder(dividingBy: yAxisMarkSize)
        
        if stepRemainder == 0 {
            return minValue
        } else {
            var minY = minValue - stepRemainder
            if minValue < 0 {
                minY -= yAxisMarkSize
            }
            return minY
        }
    }
    
    var maxY: Double {
        let maxValue = data.map(\.y).max() ?? 0
        
        guard yAxisMarkSize > 0 else { return maxValue }
        
        if maxValue <= 0 && alwaysShowZero {
            return 0
        }
        
        let stepRemainder = maxValue.truncatingRemainder(dividingBy: yAxisMarkSize)
        
        if stepRemainder == 0 {
            return maxValue
        } else {
            var maxY = maxValue - stepRemainder
            if maxValue > 0 {
                maxY += yAxisMarkSize
            }
            return maxY
        }
    }
    
    var xAxisSpan: Int { maxX - minX }
    var yAxisSpan: Double { maxY - minY }
    
    init(_ data: [(x: Double, y: Double)],
         xAxisTitle: String? = nil,
         yAxisTitle: String? = nil,
         yAxisMarkSize: Double = 0,
         alwaysShowZero: Bool = true) {
        self.data = data
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self.yAxisMarkSize = yAxisMarkSize
        self.alwaysShowZero = alwaysShowZero
    }
    
    func plotAveragedSortedPoints(for size: CGSize) -> [CGPoint] {
        averagedSortedData(from: data)
            .map { plotPoint(from: $0, for: size) }
    }
    
    func plotPoints(for size: CGSize) -> [CGPoint] {
        data
            .map { plotPoint(from: $0, for: size) }
    }
}

// MARK: - Private

private extension ChartData {
    func averagedSortedData(from data: [(x: Double, y: Double)]) -> [(x: Double, y: Double)] {
        var result: [(x: Double, y: Double)] = []
        for value in data {
            if let existingIdx = result.firstIndex(where: { $0.x == value.x }) {
                let existing = result[existingIdx]
                let averageY = (existing.y + value.y) / 2
                result[existingIdx] = (x: value.x, y: averageY)
            } else {
                result.append(value)
            }
        }
        return result.sorted { $0.x < $1.x }
    }
    
    func xOffset(forValue x: Double, totalWidth: CGFloat) -> CGFloat {
        let span = CGFloat(xAxisSpan)
        let offsetFromMin = CGFloat(x - Double(minX))
        return offsetFromMin / span * totalWidth
    }
    
    func yOffset(forValue y: Double, totalHeight: CGFloat) -> CGFloat {
        let offsetFromMin = y - minY
        return CGFloat(offsetFromMin / yAxisSpan) * totalHeight
    }
    
    func plotPoint(from dataPoint: (x: Double, y: Double), for size: CGSize) -> CGPoint {
        let x = xOffset(forValue: dataPoint.x, totalWidth: size.width)
        let y = yOffset(forValue: dataPoint.y, totalHeight: size.height)
        
        return CGPoint(x: x,
                       y: size.height - y)
    }
}
