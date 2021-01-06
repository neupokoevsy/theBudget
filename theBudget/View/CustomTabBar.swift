//
//  CustomTabBar.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import UIKit

@IBDesignable

class CustomTabBar: UITabBar {

    private var shapeLayer: CALayer?
    
        private func addShape() {

            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = createPath()
            shapeLayer.strokeColor = UIColor.lightGray.cgColor
            shapeLayer.fillColor = #colorLiteral(red: 0.485127151, green: 0.494517386, blue: 0.500644803, alpha: 1)
            shapeLayer.lineWidth = 1.0


            if let oldShapeLayer = self.shapeLayer {
                self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
            } else {
                self.layer.insertSublayer(shapeLayer, at: 0)
            }

            self.shapeLayer = shapeLayer
        }


        override func draw(_ rect: CGRect) {
            self.addShape()
        }

        func createPath() -> CGPath {

            let height: CGFloat = 37.0
            let path = UIBezierPath()
            let centerWidth = self.frame.width / 2

            path.move(to: CGPoint(x: 0, y: 0)) // start top left
            path.addLine(to: CGPoint(x: (centerWidth - height * 2), y: 0)) // the beginning of the trough
            // first curve down
            path.addCurve(to: CGPoint(x: centerWidth, y: height),
                          controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height))
            // second curve up
            path.addCurve(to: CGPoint(x: (centerWidth + height * 2), y: 0),
                          controlPoint1: CGPoint(x: centerWidth + 35, y: height), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))

            // complete the rect
            path.addLine(to: CGPoint(x: self.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            path.addLine(to: CGPoint(x: 0, y: self.frame.height))
            path.close()

            return path.cgPath
        }

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let buttonRadius: CGFloat = 35
            return abs(self.center.x - point.x) > buttonRadius || abs(point.y) > buttonRadius
        }

        func createPathCircle() -> CGPath {

            let radius: CGFloat = 37.0
            let path = UIBezierPath()
            let centerWidth = self.frame.width / 2

            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: (centerWidth - radius * 2), y: 0))
            path.addArc(withCenter: CGPoint(x: centerWidth, y: 0), radius: radius, startAngle: CGFloat(180).degreesToRadians, endAngle: CGFloat(0).degreesToRadians, clockwise: false)
            path.addLine(to: CGPoint(x: self.frame.width, y: 0))
            path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
            path.addLine(to: CGPoint(x: 0, y: self.frame.height))
            path.close()
            return path.cgPath
        }
    }

    extension CGFloat {
        var degreesToRadians: CGFloat { return self * .pi / 180 }
        var radiansToDegrees: CGFloat { return self * 180 / .pi }
    }
