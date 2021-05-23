//
//  BarChartData.swift
//  
//
//  Created by Pablo Cornejo on 5/23/21.
//

import Foundation

struct BarChartData {
    struct Series {
        let name: String
        let values: [Double]
    }
    
    let title: String
    let series: [Series]
    let categoryNames: [String]
    
    var valuesCount: Int {
        series.map(\.values.count).max() ?? 0
    }
    
    var max: Double {
        series.flatMap(\.values).max() ?? 0
    }
    
    var min: Double {
        let minValue = series.flatMap(\.values).min() ?? 0
        return minValue > 0 ? 0 : minValue
    }
    
    var span: Double { max - min }
}
