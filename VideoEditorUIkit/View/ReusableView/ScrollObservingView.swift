//
//  ScrollObservingView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 29.12.2023.
//

import SwiftUI

struct ScrollObservingView<Content: View>: View {
    var scrollChanged:((_ newValue:CGPoint)->())?
    @State private var offset = CGPoint.zero {
        didSet {
            scrollChanged?(offset)
        }
    }
    private let coordinateSpaceName = UUID()
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        PositionObservingView(
            coordinateSpace: .named(coordinateSpaceName),
            position: Binding(
                get: { offset },
                set: { newOffset in
                    offset = CGPoint(
                        x: -newOffset.x,
                        y: -newOffset.y
                    )
                }
            ),
            content: content
        )
    }
    
    
}


struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { position in
                self.position = position
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }
        
        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}


////
///


/*
struct OffsetScrollView<Content: View>: UIViewRepresentable {
    var content: () -> Content
    @Binding var offset: CGPoint

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        //scrollView.addSubview(context.coordinator.hostingController.view)
        scrollView.addSubview(context.coordinator.parent)

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content()
        
        if uiView.contentOffset != offset {
            uiView.contentOffset = offset
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: OffsetScrollView

        init(parent: OffsetScrollView) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.offset = scrollView.contentOffset
            }
        }
    }
}

extension View {
    func offsetScrollView<Content: View>(offset: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) -> some View {
        OffsetScrollView(content: content, offset: offset)
    }
}

*/
