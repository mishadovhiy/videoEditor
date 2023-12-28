//
//  TracksView.swift
//  VideoEditorUIkit
//
//  Created by Misha Dovhiy on 27.12.2023.
//

import SwiftUI

struct TrackListView: View {
    @ObservedObject var model: TrackAppearenceModel

    var body: some View {
        GeometryReader(content: { geometry in
            ScrollView(.horizontal) {
                VStack {
                    HStack {
                        ForEach(0..<$model.movieData.count, id: \.self) {
                            Text("d \(model.movieData[$0].title)")
                                .background(.yellow)
                                .frame(width: model.movieData[$0].width * 10)
                        }
                        
                    }
                    .background(.green)
                    HStack {
                        ForEach(0..<$model.movieData.count, id: \.self) {
                            Text("d \(model.movieData[$0].title)")
                                .background(.blue)
                                .frame(width: model.movieData[$0].width * 10)
                        }
                    }
                    .background(.red)
                }
                .frame(height: geometry.size.height)
                .background(.orange)
            }
            .background(.blue)
        })
        .onAppear {
            
        }
    }
    

}

#Preview {
    TrackListView(model: .init(count: []))
}
