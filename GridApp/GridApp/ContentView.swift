//
//  ContentView.swift
//  GridApp
//
//  Created by cm0620 on 2022/7/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    var symbolRow: [String] {
        return ["🍏","🍎","🍐","🍋","🍌","🍉","🍇","🍓","🍈","🍒","🫐",""]
    }
    var symbols: [String] {
        var output: [String] = []
        for i in 0...rowCount-2{
            output.append(contentsOf: symbolRow.map{ "\(i)"+$0 })
        }
        output.append(contentsOf: Array(repeating: "", count: symbolRow.count))
        return output
    }
    var rowCount: Int {
        return symbolRow.count
    }
    var totalWidth: CGFloat = 300.0
    var totalHeight: CGFloat = 300.0
    @State var focalPoint: CGPoint? = nil
    
    var body: some View {
        VStack{
            
            ZStack{
                GeometryReader{ proxy in
                    let points = getPoints()
                    ForEach(Array(symbols.enumerated()), id: \.0){
                        index, symbol in
                        let point = points[index]
                        Text(symbol)
                            .font(.system(size: 20))
                            .position(CGPoint(x: point.x, y: point.y))
                    }
                }
            }
            .frame(width: totalWidth, height: totalHeight)
            .ignoresSafeArea()
            .border(Color.red)
            
            ZStack{
                GeometryReader{ proxy in
                    let apoints: [XYZPoint] = getPoints()
                    //let rotateValue = getRotateValue()
                    let bpoints: [XYZPoint] = getXYZPoints(origin: focalPoint ?? CGPoint(x: 0, y: 0))
                        //.getRotateXAxis(rotate: rotateValue.y)
                        //.getRotateYAxis(rotate: rotateValue.x)
                        .getMove(origin: focalPoint ?? CGPoint(x: 0, y: 0))
                    ForEach(Array(symbols.enumerated()), id: \.0){
                        index, symbol in
                        let point = focalPoint == nil ? apoints[index] : bpoints[index]
                        let scale = focalPoint == nil ? 1 : abs(point.z / 100.0 * 1.7)
                        Text(symbol)
                            .font(.system(size: 20))
                            .scaleEffect(x: scale, y: scale)
                            .position(CGPoint(x: point.x, y: point.y))
                            .zIndex(scale)
                            .opacity(point.z >= 0.0 ? 1.0 : 0.0)
                    }
                }
            }
            .frame(width: totalWidth, height: totalHeight)
            .animation(.spring(), value: focalPoint)
            .ignoresSafeArea()
            .gesture(
                DragGesture()
                .onChanged { val in
                    self.focalPoint = val.location
                }
                .onEnded { val in
                    self.focalPoint = nil
                }
            )
            .border(Color.red)
        }
    }
    
    func getPoints() -> [XYZPoint]{
        let width = totalWidth / CGFloat(rowCount-1)
        let height = totalHeight / CGFloat(rowCount-1)
        let output = symbols.enumerated().map{
            (index, element) -> XYZPoint in
            let x: CGFloat = CGFloat( index % rowCount ) * width
            let y: CGFloat = CGFloat( index / rowCount ) * height
            return XYZPoint(x: x, y: y, z: 0)
        }
        return output
    }
    
    func getXYZPoints(origin: CGPoint) -> [XYZPoint]{

        let r: CGFloat = 100.0
        var output: [XYZPoint] = []
        
        for indexY in 0...rowCount-1{
            
            var newOriginY = origin.y - 150
            if newOriginY <= 0 { newOriginY += 300 }
            var newY: CGFloat = CGFloat(indexY) - newOriginY / totalWidth * CGFloat(rowCount-1)
            if newY <= 0 { newY += CGFloat(rowCount-1) }
            let lat: CGFloat = CGFloat(newY) * CGFloat.pi / CGFloat(rowCount-1)
            
            for indexX in 0...rowCount-1{
                
                var newX: CGFloat = CGFloat(indexX) - origin.x / totalHeight * CGFloat(rowCount-1)
                if newX <= 0 { newX += CGFloat(rowCount-1) }
                let lon: CGFloat = CGFloat(newX * 2) * CGFloat.pi / CGFloat(rowCount-1)
                
                let x: CGFloat = sin(lat) * cos(lon) * r
                let y: CGFloat = sin(lat) * sin(lon) * r
                let z: CGFloat = cos(lat) * r
                let xyzPoint = XYZPoint(x: y , y: -z , z: x)
                output.append(xyzPoint)
            }
        }
        return output
    }
    
    func getRotateValue() -> (x: CGFloat, y: CGFloat){
        if let focalPoint = focalPoint {
            return (x: ( focalPoint.x / totalWidth ) * CGFloat.pi * -2.0,
                    y: ( focalPoint.y / totalHeight ) * CGFloat.pi * -2.0)
        } else {
            return (x: 0.0, y: 0.0)
        }
    }
}

struct XYZPoint{
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
}

extension Array where Element == XYZPoint {
    func getMove(origin: CGPoint) -> Self{
        return self.map{ one in
            XYZPoint(x: one.x + origin.x, y: one.y + origin.y, z: one.z)
        }
    }
    func getRotateXAxis(rotate: CGFloat) -> Self{
        return self.map{ one in
            return XYZPoint(x: one.x,
                            y: one.y * cos(rotate) + one.z * sin(rotate),
                            z: -1 * one.y * sin(rotate) + one.z * cos(rotate))
        }
    }
    func getRotateYAxis(rotate: CGFloat) -> Self{
        return self.map{ one in
            return XYZPoint(x: one.x * cos(rotate) + one.z * sin(rotate),
                            y: one.y,
                            z: -1 * one.x * sin(rotate) + one.z * cos(rotate))
        }
    }
    func getPerspective() -> Self{
        return self
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
