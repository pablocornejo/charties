//
//  File.swift
//  
//
//  Created by Pablo Cornejo on 4/19/21.
//

import SwiftUI

struct Example<Marker: View>: View {
    let lineColors: [Color]
    let marker: Marker
    var markerSize: CGSize = .init(width: 16, height: 16)
    
    let data: ChartData = {
        var data = ChartData([(x: 1, y: -0.25),
                              (x: 2, y: 2),
                              (x: 3, y: 1),
                              (x: 4, y: 2.5),
                              (x: 5, y: 2),
                              (x: 6, y: 2.5),
                              (x: 7, y: 2),
                              (x: 9, y: 1),
                              (x: 10, y: 2.75)],
                             xAxisTitle: "X Axis",
                             yAxisTitle: "Y\nAxis")
        data.yAxisMarkSize = 1
        data.alwaysShowZero = true
        return data
    }()
    
    var stroke: some ShapeStyle {
        LinearGradient(gradient: Gradient(colors: lineColors),
                       startPoint: .leading,
                       endPoint: .trailing)
    }
    
    var body: some View {
        VStack {
            LineChart(data: data,
                      marker: marker,
                      markerSize: markerSize,
                      lineStyle: .smooth(stroke)) { day in
                let shouldShow = (day) % 2 == 0
                return (shouldShow ? "X-\(day)" : nil, .zero)
            }
            .frame(height: 350)
        }
        .navigationBarTitle("pH")
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Example(lineColors: [Color(.systemPurple), Color(.systemIndigo)],
                    marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.blue))
            
            Example(lineColors: [Color(.systemPink), Color(.systemPurple)],
                    marker: Text("❌"),
                    markerSize: .init(width: 24, height: 24))
            
            Example(lineColors: [Color(.systemGray3), Color(.systemGray)],
                    marker: Text("👽"),
                    markerSize: .init(width: 24, height: 24))
            
            Example(lineColors: [.clear],
                    marker: Text("🤖"),
                    markerSize: .init(width: 24, height: 24))
        }
    }
}
