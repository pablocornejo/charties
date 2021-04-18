//
//  ScatterMarks.swift
//  
//
//  Created by Pablo Cornejo on 4/18/21.
//

import SwiftUI

enum AppearAnimation {
    case none
    case fadeIn(_ duration: Double)
}

struct ScatterMarkers<Marker: View>: View {
    let data: ScatterData
    let marker: Marker
    let markerSize: CGSize
    let appearAnimation: AppearAnimation

    @State private var didAppear = false
    
    private var appearAnimDuration: Double {
        switch appearAnimation {
        case .none:
            return 0
        case .fadeIn(let duration):
            return duration
        }
    }
    
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            let points = data.averagedSortedPoints(forSize: reader.size).map {
                CGPoint(x: $0.x, y: height - $0.y)
            }
            
            ZStack {
                ForEach(0..<points.count) { idx in
                    let point = points[idx]
                    marker
                        .frame(width: markerSize.width, height: markerSize.height)
                        .offset(x: point.x - markerSize.width / 2,
                                y: point.y - markerSize.height / 2)
                        .opacity(didAppear ? 1 : 0)
                        .animation(getAppearAnimation(forMarkAt: idx))
                }
            }
            .onAppear {
                didAppear = true
            }
        }
    }
    
    private func getAppearAnimation(forMarkAt index: Int) -> Animation? {
        switch appearAnimation {
        case .none:
            return nil
        case .fadeIn(let duration):
            return Animation
                .easeIn(duration: 0.2)
                .delay(Double(index) * duration/Double(data.xAxisSpan))
        }
    }
}

struct ScatterMarkers_Previews: PreviewProvider {
    static var data: ScatterData {
        var data = ScatterData([(x: 1, y: -0.25),
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
        ScatterMarkers(data: data,
                       marker: Circle().strokeBorder(lineWidth: 2).foregroundColor(.blue),
                       markerSize: CGSize(width: 16, height: 16),
                       appearAnimation: .fadeIn(1.5))
            .padding()
            .frame(height: 350)
    }
}
