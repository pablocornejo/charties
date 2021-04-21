//
//  File.swift
//  
//
//  Created by Pablo Cornejo on 4/19/21.
//

import SwiftUI

struct Example: View {
    
    let data: ScatterData = {
        var data = ScatterData([(x: 0, y: -0.25),
                                (x: 1, y: -0.25),
                                (x: 2, y: 2),
                                (x: 3, y: 1),
                                (x: 4, y: 2.5),
                                (x: 5, y: 2),
                                (x: 6, y: 2.5),
                                (x: 7, y: 2),
                                (x: 9, y: 1),
                                (x: 10, y: 2.75)],
                               xAxisTitle: nil,
                               yAxisTitle: "pH")
        data.yAxisMarkSize = 1
        data.alwaysShowZero = true
        return data
    }()
    
    var body: some View {
//        NavigationView {
            VStack {
                ScatterChart(data: data,
                             marker: Circle(),
                             markerSize: .init(width: 12, height: 12),
                             lineStyle: .smooth) { day in
                    let shouldShow = (day) % 2 == 0
                    return (shouldShow ? "Day \(day)" : nil, .degrees(-45))
                }
                .frame(height: 350)
            }
            .navigationBarTitle("pH")
//        }
    }
}

struct Example_Previews: PreviewProvider {
    static var previews: some View {
        Example()
    }
}
