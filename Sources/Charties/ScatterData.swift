//
//  ScatterData.swift
//  
//
//  Created by Pablo Cornejo on 4/18/21.
//

import Foundation
import CoreGraphics

public struct ScatterData {
    let data: [(x: Int, y: Double)]
    var yAxisMarkSize: Double
    var alwaysShowZero: Bool
    
    var minX: Int { data.map(\.x).min() ?? 0 }
    var maxX: Int { data.map(\.x).max() ?? 0 }
    
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
    
    init(_ data: [(x: Int, y: Double)], yAxisMarkSize: Double = 0, alwaysShowZero: Bool = true) {
        self.data = data
        self.yAxisMarkSize = yAxisMarkSize
        self.alwaysShowZero = alwaysShowZero
    }
    
    func averagedSortedPoints(forSize size: CGSize) -> [CGPoint] {
        averagedSortedData(from: data)
            .map { data in
                CGPoint(x: xOffset(forValue: data.x,
                                   totalWidth: size.width),
                        y: yOffset(forValue: data.y,
                                   totalHeight: size.height))
            }
    }
}

// MARK: - Private

private extension ScatterData {
    func averagedSortedData(from data: [(x: Int, y: Double)]) -> [(x: Int, y: Double)] {
        var result: [(x: Int, y: Double)] = []
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
    
    func xOffset(forValue x: Int, totalWidth: CGFloat) -> CGFloat {
        let span = CGFloat(xAxisSpan)
        let offsetFromMin = CGFloat(x - minX)
        return (CGFloat(offsetFromMin / span)) * totalWidth
    }
    
    func yOffset(forValue y: Double, totalHeight: CGFloat) -> CGFloat {
        let offsetFromMin = y - minY
        return CGFloat(offsetFromMin / yAxisSpan) * totalHeight
    }
}