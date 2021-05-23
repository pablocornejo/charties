//
//  BarChart.swift
//  
//
//  Created by Pablo Cornejo on 5/22/21.
//

import SwiftUI

public struct BarChart: View {
    let data: BarChartData
    
    @State private var itemWidth: CGFloat = .zero
    @State private var barsWidth: CGFloat = .zero
    
    public var body: some View {
        VStack {
            if !data.title.isEmpty {
                Text(data.title)
                    .font(.headline)
            }
            
            HStack {
                YAxisLabels(max: data.max, min: data.min, steps: 5)
                
                ZStack {
                    YAxisGridlines(max: data.max, min: data.min, steps: 25)
                    
                    HStack(spacing: itemSpacing) {
                        ForEach(0..<data.valuesCount) { itemIdx in
                            HStack(spacing: itemWidth / 20) {
                                ForEach(data.series, id: \.name) { serie in
                                    BarChartCell(filledRange: filledRange(forBarAt: itemIdx, in: serie),
                                                 fill: serie.name == "Series A" ? Color.blue : Color.green)
                                }
                            }
                            .captureWidth(in: $itemWidth)
                        }
                    }
                    .captureWidth(in: $barsWidth)
                    .padding(.horizontal, 8)
                }
            }
            .padding(.vertical)
            
            Legend(labels: data.series.map { ($0.name, $0.name == "Series A" ? Color.blue : Color.green) })
        }
    }
    
    private var itemSpacing: CGFloat {
        barsWidth / CGFloat(data.valuesCount) / 5
    }
    
    private func filledFraction(forBarAt index: Int, in series: BarChartData.Series) -> Double {
        guard data.span > 0, index < series.values.count else { return 0 }
        
        return abs(series.values[index] / data.span)
    }
    
    private func lowerBoundFraction(forBarAt index: Int, in series: BarChartData.Series) -> Double {
        guard data.min < 0 else { return 0 }
        
        let value = series.values[index]
        let maxPaddingFraction = abs(data.min / data.span)
        
        return value < 0 ? maxPaddingFraction - abs(value / data.span) : maxPaddingFraction
    }
    
    private func filledRange(forBarAt index: Int, in series: BarChartData.Series) -> ClosedRange<Double> {
        let lowerBound = lowerBoundFraction(forBarAt: index, in: series)
        
        return lowerBound...lowerBound + filledFraction(forBarAt: index, in: series)
    }
}

struct BarChart_Previews: PreviewProvider {
    static let chartData: BarChartData = {
        let seriesAValues: [Double] = [
            -5,
            10,
            9,
            -3,
            16,
        ]
        
        let seriesBValues: [Double] = [
            7,
            8,
            15,
            12,
            20,
        ]
        
        let series: [BarChartData.Series] = [.init(name: "Series A", values: seriesAValues),
                                               .init(name: "Series B", values: seriesBValues)]
        let itemNames = [
            "January 2021",
            "February 2021",
            "March 2021",
            "April 2021",
            "May 2021",
            "June 2021",
            "July 2021"
        ]
        
        return BarChartData(title: "Chart Title", series: series, categoryNames: itemNames)
    }()
    
    static var previews: some View {
        BarChart(data: chartData)
            .frame(height: 350)
    }
}
