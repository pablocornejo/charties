//
//  SizeUpdater.swift
//  
//
//  Created by Pablo Cornejo on 5/8/21.
//

import SwiftUI

private struct SizeUpdater: View {
    struct SizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero

        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    
    @Binding var size: CGSize
    
    init(_ size: Binding<CGSize>) {
        self._size = size
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
        .onPreferenceChange(SizePreferenceKey.self) { value in
            size = value
        }
    }
}

internal extension View {
    func captureSize(in size: Binding<CGSize>) -> some View {
        background(SizeUpdater(size))
    }
}
