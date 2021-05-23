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
                        ForEach(0..<data.categoryValuesSpan) { itemIdx in
                            HStack(spacing: itemWidth / 20) {
                                ForEach(data.categories, id: \.name) { serie in
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
        }
    }
    
    private var itemSpacing: CGFloat {
        barsWidth / CGFloat(data.categoryValuesSpan) / 5
    }
    
    private func filledFraction(forBarAt index: Int, in category: BarChartData.Category) -> Double {
        guard data.span > 0, index < category.values.count else { return 0 }
        
        return abs(category.values[index] / data.span)
    }
    
    private func lowerBoundFraction(forBarAt index: Int, in category: BarChartData.Category) -> Double {
        guard data.min < 0 else { return 0 }
        
        let value = category.values[index]
        let maxPaddingFraction = abs(data.min / data.span)
        
        return value < 0 ? maxPaddingFraction - abs(value / data.span) : maxPaddingFraction
    }
    
    private func filledRange(forBarAt index: Int, in category: BarChartData.Category) -> ClosedRange<Double> {
        let lowerBound = lowerBoundFraction(forBarAt: index, in: category)
        
        return lowerBound...lowerBound + filledFraction(forBarAt: index, in: category)
    }
}

struct BarChartCell<Fill: ShapeStyle>: View {
    var filledRange: ClosedRange<Double>
    var fill: Fill
    
    @State private var barWidth: CGFloat = .zero
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                RoundedRectangle(cornerRadius: barWidth / 4)
                    .fill(fill)
                    .frame(height: proxy.size.height * CGFloat(filledRange.upperBound - filledRange.lowerBound))
                    .captureWidth(in: $barWidth)
                
                Rectangle()
                    .frame(height: proxy.size.height * CGFloat(filledRange.lowerBound))
                    .foregroundColor(.clear)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
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
        
        let series: [BarChartData.Category] = [.init(name: "Series A", values: seriesAValues),
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
        
        return BarChartData(title: "Chart Title", categories: series, itemNames: itemNames)
    }()
    
    static var previews: some View {
        BarChart(data: chartData)
            .frame(height: 350)
    }
}


struct BarChartData {
    struct Category {
        let name: String
        let values: [Double]
    }
    
    let title: String
    let categories: [Category]
    let itemNames: [String]
    
    var categoryValuesSpan: Int {
        categories.map(\.values.count).max() ?? 0
    }
    
    var max: Double {
        categories.flatMap(\.values).max() ?? 0
    }
    
    var min: Double {
        let minValue = categories.flatMap(\.values).min() ?? 0
        return minValue > 0 ? 0 : minValue
    }
    
    var span: Double { max - min }
}
