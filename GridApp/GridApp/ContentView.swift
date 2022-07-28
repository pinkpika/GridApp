//
//  ContentView.swift
//  GridApp
//
//  Created by cm0620 on 2022/7/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    var symbols: [String] = [
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣",
        "😀","😃","😄","😁","😆","😅","😂","🤣"
    ]
    var rowCount = 8
    var totalWidth: CGFloat = 300.0
    var totalHeight: CGFloat = 300.0
    @State var focalPoint: CGPoint? = nil
    var body: some View {
        ZStack{
            GeometryReader{ proxy in
                let points = getPoints()
                ForEach(Array(symbols.enumerated()), id: \.0){
                    index, symbol in
                    let point = points[index]
                    //let (sRect, scale, _) = rect.zoomTransform(around: focalPoint, radius: 80, zoom: 1.5)
                    Text(symbol)
                        .font(.system(size: 20))
                        //.scaleEffect(x: scale, y: scale, anchor: .bottom)
                        .position(point)
                        //.animation(.spring(), value: focalPoint)
                }
            }
        }
        .frame(width: totalWidth, height: totalHeight)
        .animation(.spring(), value: focalPoint)
        .ignoresSafeArea()
    }
    
    func getPoints() -> [CGPoint]{
        let width = totalWidth / CGFloat(rowCount-1)
        let height = totalHeight / CGFloat(rowCount-1)
        return symbols.enumerated().map{
            (index, element) in
            let x: CGFloat = CGFloat( index % rowCount ) * width
            let y: CGFloat = CGFloat( index / rowCount ) * height
            return CGPoint(x: x, y: y)
        }
    }
    
    struct XYZPoint{
        let x: CGFloat
        let y: CGFloat
        let z: CGFloat
    }
    
    func getXYZPoints() -> [XYZPoint]{
        var output: [XYZPoint] = []
        for indexX in 0...rowCount{
            let lat: CGFloat = CGFloat(indexX) * CGFloat.pi / CGFloat(rowCount)
            for indexY in 0...rowCount{
                let lon: CGFloat  = CGFloat(indexY * 2) * CGFloat.pi / CGFloat(rowCount)
                let x = sin(lat) * cos(lon)
                let y = sin(lat) * sin(lon)
                let z = cos(lat)
                output.append(XYZPoint(x: y, y: z, z: x))
            }
        }
        return output
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
