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
    func captureSize(in sizeBinding: Binding<CGSize>) -> some View {
        background(SizeUpdater(sizeBinding))
    }
    
    func captureWidth(in widthBinding: Binding<CGFloat>) -> some View {
        let sizeBinding = Binding<CGSize>(get: { .zero }, set: { size in
            widthBinding.wrappedValue = size.width
        })
        
        return captureSize(in: sizeBinding)
    }
    
    func captureHeight(in heightBinding: Binding<CGFloat>) -> some View {
        let sizeBinding = Binding<CGSize>(get: { .zero }, set: { size in
            heightBinding.wrappedValue = size.height
        })
        
        return captureSize(in: sizeBinding)
    }
}
