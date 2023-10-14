//
//  LoadingView.swift
//  it
//
//  Created by hashimo ryoya on 2023/10/12.
//

import SwiftUI

struct ActivityIndicator: View {

    @State var currentDegrees = 0.0

    let colorGradient = LinearGradient(gradient: Gradient(colors: [
        Color("loading"),
        Color("loading").opacity(0.75),
        Color("loading").opacity(0.5),
        Color("loading").opacity(0.2),
        .clear]),
        startPoint: .leading, endPoint: .trailing)

    var body: some View {
        VStack{
            Circle()
                .trim(from: 0.0, to: 0.85)
                .stroke(colorGradient, style: StrokeStyle(lineWidth: 5))
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: currentDegrees))
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                        withAnimation {
                            self.currentDegrees += 10
                        }
                    }
                }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .background(Color("Color2"))
    }
}

struct LoadingView: View {
    
    @State var isLoading : Bool = false
    var body: some View {
        VStack{
            Button {
                Task{
                        isLoading = true
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        isLoading = false
                }
            } label: {
                Group{
                    if isLoading {
                        ActivityIndicator()
                    } else {
                        Text("Click")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .frame(width: 240, height: 80, alignment: .center)
            }
            .background(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white, lineWidth: 2.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicator()
    }
}
