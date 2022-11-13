//
//  MathsModel.swift
//  WindTurbines
//
//  Created by Yicheng Xia on 12/11/2022.
//

import CoreGraphics

struct Vector {
    static var zero = Vector(x: 0.0, y: 0.0)
    
    var x: CGFloat
    var y: CGFloat
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    func add(v: Vector) -> Vector {
        return Vector(x: x + v.x, y: y + v.y)
    }
}

struct Matrix {
    var m11: CGFloat
    var m12: CGFloat
    var m21: CGFloat
    var m22: CGFloat
    
    init(rotationWithAngle ang: CGFloat) {
        self.m11 = cos(ang)
        self.m12 = -sin(ang)
        self.m21 = sin(ang)
        self.m22 = cos(ang)
    }
    
    func multiply(vector v: Vector) -> Vector {
        return Vector(x: m11 * v.x + m12 * v.y, y: m21 * v.x + m22 * v.y)
    }
}

struct Rectangle {
    var width: CGFloat
    var height: CGFloat
    
    var maxX: CGFloat { return width / 2}
    var minX: CGFloat { return width / -2}
    var maxY: CGFloat { return height / 2}
    var minY: CGFloat { return height / -2}
    
    init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}

class TurbineModel {
    
    let n: Int
    let radius: CGFloat
    let k: CGFloat
    var positions: [Vector]
    let boundary: Rectangle
    
    var currPower: CGFloat = 0.0
    
    let angles: Int = 20
    var rotationMatrices: [Matrix] = []
    
    var delta: CGFloat = 3
    var descendSpeed: CGFloat = 5
    
    
    init(n: Int, radius: CGFloat, k: CGFloat, boundary: Rectangle) {
        self.n = n
        self.radius = radius
        self.k = k
        self.boundary = boundary
        
        positions = [Vector].init(repeating: Vector.zero, count: n)
        
        for i in 0..<20 {
            rotationMatrices.append(Matrix(rotationWithAngle: CGFloat(i) / 20 * 2 * CGFloat.pi))
        }
        
    }
    
    func power(positions: [Vector], angN: Int) -> CGFloat {
        let M = rotationMatrices[angN]
        let newPositions = positions.map({M.multiply(vector: $0)})
        
        // (lower, upper, count)
        var endpoints: [CGFloat] = []
        
        for p in newPositions {
            endpoints.append(p.x - radius)
            endpoints.append(p.x + radius)
        }
        endpoints.sort()
        
        var turbineCount: [Int] = [Int].init(repeating: 0, count: endpoints.count - 1)
        
        for i in 0..<endpoints.count - 1 {
            let midpt = (endpoints[i] + endpoints[i+1]) / 2
            for p in newPositions {
                if abs(midpt - p.x) < radius {
                    turbineCount[i] += 1
                }
            }
        }

        // Calculate power
        var power: CGFloat = 0
        for i in 0..<endpoints.count - 1 {
            let width = endpoints[i + 1] - endpoints[i]
            let n = turbineCount[i]
            let factor: CGFloat = 1 - pow((1 - k), CGFloat(n))
            power += width * factor
        }
        
        return power
    }
    
    func meanPower(positions: [Vector]) -> CGFloat {
        var sum: CGFloat = 0.0
        for i in 0..<20 {
            sum += power(positions: positions, angN: i)
        }
        return sum / 20
    }
    
    func randomise() {
        for i in 0..<positions.count {
            positions[i] = Vector(x: CGFloat.random(in: boundary.minX...boundary.maxX),
                                  y: CGFloat.random(in: boundary.minY...boundary.maxY))
        }
    }
    
    func getGradient(at poses: [Vector], n: Int, varyX: Bool, delta: CGFloat, f1: CGFloat) -> CGFloat {
        var poses2 = poses
        if varyX {
            poses2[n].x += delta
        } else {
            poses2[n].y += delta
        }
        
        
        let f2 = meanPower(positions: poses2)
        return (f2 - f1) / delta
        
    }
    
    func gradientDescent() {
        
        let f1 = meanPower(positions: positions)
        
        currPower = f1
        
        var gradVector: [Vector] = []
        
        for i in 0..<positions.count {
            let a = getGradient(at: positions, n: i, varyX: true, delta: self.delta, f1: f1)
            let b = getGradient(at: positions, n: i, varyX: false, delta: self.delta, f1: f1)
            gradVector.append(Vector(x: a * self.descendSpeed, y: b * self.descendSpeed))
        }
        
        for i in 0..<positions.count {
            var newPosition = positions[i].add(v: gradVector[i])
            
            // boundary condition check
            if newPosition.x > boundary.maxX {
                newPosition.x = boundary.maxX
            } else if newPosition.x < boundary.minX {
                newPosition.x = boundary.minX
            }
            if newPosition.y > boundary.maxY {
                newPosition.y = boundary.maxY
            } else if newPosition.y < boundary.minY {
                newPosition.y = boundary.minY
            }
            
            positions[i] = newPosition
        }
        
    }
    
}

func inverseNormalCDF(x: CGFloat) -> CGFloat {
    if x < 0.5 {
        let y = sqrt(-2 * log(x))
        return -y + ((0.01 * y + 0.8) * y + 2.5) / (0.2 * y + 1)
        
    } else {
        let y = sqrt(-2 * log(1-x))
        return y - ((0.01 * y + 0.8) * y + 2.5) / (0.2 * y + 1)
    }
}
