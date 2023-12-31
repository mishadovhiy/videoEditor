//
//  TracksView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import SwiftUI

struct TrackListView: View {
    @ObservedObject var model: TrackAppearenceModel
    var presenter:TrackListViewPresenter?
    
    @State var offset:CGPoint = .zero
    
    var body: some View {
        GeometryReader(content: { geometry in
            ScrollableView($offset) {
                ScrollObservingView(scrollChanged: scrollChanged(_:)) {
                    contentData(size: geometry.size)
                }
            }
        })
    }
    
    
    func contentData(size:CGSize) -> some View {
        VStack {
            HStack(spacing:0) {
                ForEach(0..<$model.movieData.count, id: \.self) {
                    Text("d \(model.movieData[$0].title)")
                        .background(.yellow)
                        .frame(width: model.movieData[$0].width * 50)
                }
                
            }
            .background(.green)
            HStack(spacing:0)  {
                ForEach(0..<$model.movieData.count, id: \.self) {
                    Text("d \(model.movieData[$0].title)")
                        .background(.blue)
                        .frame(width: model.movieData[$0].width * 50)
                }
            }
            .background(.red)
        }
        .frame(height: size.height)
        .background(.orange)
    }
    
    
    func performScroll(percent:CGFloat) {
        let width = model.movieData.reduce(0, { partialResult, data in
            return partialResult + (data.width * 10)
        })
        let new = width * percent
        print(new, " erfwdeewd")
        self.$offset.wrappedValue = .init(x: new, y: 0)
    }
    
    private func scrollChanged(_ newValue:CGPoint) {
        let width = model.movieData.reduce(0, { partialResult, data in
            return partialResult + (data.width * 35)
        })
        print(width, " erff")
        self.presenter?.scrollChanged(newValue.x / width)
    }
}

#Preview {
    TrackListView(model: .init(count: []), presenter: nil)
}


extension TrackListView {
    func addToParent(parent:UIViewController, toView:UIView? = nil) {
        let hostingController = UIHostingController(rootView: self)
        parent.addChild(child: hostingController,  toView: toView ?? parent.view, name: "addSwiftUIView")
    }
}
