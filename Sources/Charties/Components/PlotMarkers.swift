//
//  PlotMarkers.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

enum AppearAnimation {
    case none
    case fadeIn(_ duration: Double)
}

struct PlotMarkers<Marker: View>: View {
    let data: ChartData
    let marker: Marker
    let markerSize: CGSize
    let appearAnimation: AppearAnimation
    let pointsProvider: (ChartData, CGSize) -> [CGPoint]
    
    @State private var didAppear = false
    
    var body: some View {
        GeometryReader { reader in
            let points = pointsProvider(data, reader.size)
            
            ZStack {
                ForEach(0..<points.count) { idx in
                    let point = points[idx]
                    marker
                        .frame(width: markerSize.width, height: markerSize.height)
                        .offset(x: point.x - markerSize.width / 2,
                                y: point.y - markerSize.height / 2)
                        .opacity(didAppear ? 1 : 0)
                        .animation(appearAnimation(forMarkAt: idx, totalCount: points.count))
                }
            }
            .onAppear {
                didAppear = true
            }
        }
    }
    
    private func appearAnimation(forMarkAt index: Int, totalCount: Int) -> Animation? {
        switch appearAnimation {
        case .none:
            return nil
        case .fadeIn(let duration):
            return Animation
                .easeIn(duration: 0.2)
                .delay(Double(index) / Double(totalCount) * duration)
        }
    }
}

struct Markers_Previews: PreviewProvider {
    static var data: ChartData {
        var data = ChartData([(x: 1, y: -0.25),
                              (x: 2, y: 2),
                              (x: 3, y: 1),
                              (x: 4, y: 2.5),
                              (x: 5, y: 2),
                              (x: 6, y: 2.5),
                              (x: 7, y: 2),
                              (x: 9, y: 1),
                              (x: 10, y: 2.75)])
        data.yAxisMarkSize = 1
        data.alwaysShowZero = true
        return data
    }
    
    static var previews: some View {
        PlotMarkers(data: data,
                marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.blue),
                markerSize: CGSize(width: 16, height: 16),
                appearAnimation: .fadeIn(1.5)) { data, size in
            data.plotPoints(for: size)
        }
        .padding()
        .frame(height: 350)
    }
}
