//
//  ParticleView.swift
//  Particles-IOS
//
//  Created by SEKNY YIM on 25/1/25.
//
import UIKit


class ParticleView: UIView {
    // Properties
    enum ECorner {
        case minX
        case minY
        case maxX
        case maxY
    }
    private let circleRadius: CGFloat = 2.0
    private var circleLayers: [CAShapeLayer] = []
    private var lineLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    private let nextValueKey = "nextPosition"
    private(set) var minX: CGFloat = .zero
    private(set) var maxX: CGFloat = .zero
    private(set) var minY: CGFloat = .zero
    private(set) var maxY: CGFloat = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        setup()
    }
    
    private func setup() {
        minX = bounds.minX - 10
        maxX = bounds.maxX + 10
        minY = bounds.minY - 10
        maxY = bounds.maxY + 10
        
        // Create circles
        for _ in 0..<100 {
            let circleLayer = createCircleLayer()
            layer.addSublayer(circleLayer)
            circleLayers.append(circleLayer)
            
            // Animate each circle
            animateCircle(circleLayer: circleLayer)
        }
        
        // Create a layer for lines
        lineLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        lineLayer.lineWidth = 1.0
        lineLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(lineLayer)
        
        // Start monitoring positions
        startMonitoringPositions()
    }
    
    
    // Create a single circle layer
    private func createCircleLayer() -> CAShapeLayer {
        let randomX = CGFloat.random(in: 50...bounds.width - 50)
        let randomY = CGFloat.random(in: 50...bounds.height - 50)
        let initialPosition = CGPoint(x: randomX, y: randomY)
        
        let circleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: .zero, radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.white.cgColor
        circleLayer.position = initialPosition // Set the position
        return circleLayer
    }
    
    
    // Animate a single circle
    private func animateCircle(circleLayer: CAShapeLayer) {
        // Step 3: Create a random animation
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = circleLayer.position
        
        // New random position
        let nextValue = circleLayer.value(forKey: nextValueKey) as? CGPoint
        let random: CGPoint = randomPosition(nextValue: nextValue)
        
        animation.toValue = random
        animation.duration = getDuration() // Double.random(in: 7.0...10.0) // Random duration
        //        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        // Save the destination as the new position
        circleLayer.setValue(NSValue(cgPoint: random), forKey: nextValueKey)
        
        // Add the animation
        circleLayer.add(animation, forKey: "positionAnimation")
    }
    
    private func randomPosition(nextValue: CGPoint?) -> CGPoint {
        var random = CGPoint.zero
        let multiple = 0.3
        // Width 10%
        let w10Percent = maxX * 0.1
        // Width 30%
        //        let w30Percent = maxX * multiple
        // Width 50%
        let w50Percent = maxX / 2
        // Width 70%
        //        let w70Percent = maxX - w30Percent
        // Width 90%
        let w90Percent = maxX - w10Percent
        // Height 10%
        let h10Percent = maxY * 0.1
        // Height 30%
        //        let h30Percent = maxY * multiple
        // Height 50%
        let h50Percent = maxY / 2
        // Height 70%
        //        let h70Percent = maxY - h30Percent
        // Height 90%
        let h90Percent = maxY - h10Percent
        
        // Next value nil => random next point to make a line
        if nextValue == nil {
            // Point must have one axis is max value that why we make it random
            let isMaxX = Bool.random()
            let randomValue = isMaxX ? CGFloat.random(in: minY...maxY) : CGFloat.random(in: minX...maxX)
            
            random.x = isMaxX ? maxX : randomValue
            random.y = isMaxX ? randomValue : maxY
        } else {
            let currentXValue = nextValue?.x ?? 0
            let currentYValue = nextValue?.y ?? 0
            var isCurrentUnderX: ECorner? = nil
            var isCurrentUnderY: ECorner? = nil
            
            if currentXValue <= minX {
                isCurrentUnderX = .minX
            } else if currentXValue >= maxX {
                isCurrentUnderX = .maxX
            }
            
            if currentYValue <= minY {
                isCurrentUnderY = .minY
            } else if currentYValue >= maxY {
                isCurrentUnderY = .maxY
            }
            
            // Point = top left
            // next point should be maxX or maxY
            if isCurrentUnderX == .minX && isCurrentUnderY == .minY {
                let nextMax = [ ECorner.maxX, ECorner.maxY].randomElement()
                
                if nextMax == .maxX {
                    random.x = maxX
                    random.y = CGFloat.random(in:h50Percent...maxY)
                } else {
                    random.y = maxY
                    random.x = CGFloat.random(in:w50Percent...maxX)
                }
            }
            // Point = top right
            // next point should be minX or maxY
            else if isCurrentUnderX == .maxX && isCurrentUnderY == .minY {
                let nextMax = [ECorner.minX, ECorner.maxY].randomElement()
                
                if nextMax == .minX {
                    random.x = minX
                    random.y = CGFloat.random(in:h50Percent...maxY)
                } else {
                    random.y = maxY
                    random.x = CGFloat.random(in:minX...w50Percent)
                }
            }
            // Point = bottom right
            // next point should be minX or minY
            else if isCurrentUnderX == .maxX && isCurrentUnderY == .maxY {
                let nextMax = [ECorner.minX, ECorner.minY].randomElement()
                
                if nextMax == .minX {
                    random.x = minX
                    random.y = CGFloat.random(in:minY...h50Percent)
                } else {
                    random.y = minY
                    random.x = CGFloat.random(in:minX...w50Percent)
                }
            }
            // Point = bottom left
            // next point should be maxX or maxY
            else if isCurrentUnderX == .minX && isCurrentUnderY == .maxY {
                let nextMax = [ECorner.maxX, ECorner.minY].randomElement()
                
                if nextMax == .maxX {
                    random.x = maxX
                    random.y = CGFloat.random(in:minY...h50Percent)
                } else {
                    random.y = minY
                    random.x = CGFloat.random(in: w50Percent...maxX)
                }
            }
            
            var nextMax: ECorner? = nil
            // Point around minX
            if isCurrentUnderX == .minX {
                nextMax = [ECorner.maxX, ECorner.maxY, ECorner.minY].randomElement()
            } else if isCurrentUnderX == .maxX {
                nextMax = [ECorner.minX, ECorner.minY, ECorner.maxY].randomElement()
            } else if isCurrentUnderY == .minY {
                nextMax = [ECorner.minX, ECorner.maxX, ECorner.maxY].randomElement()
            } else if isCurrentUnderY == .maxY {
                nextMax = [ECorner.minY, ECorner.minX, ECorner.maxX].randomElement()
            }
            
            switch nextMax {
            case .maxX:
                random.x = maxX
                random.y = CGFloat.random(in:h10Percent...h90Percent)
            case .maxY:
                random.y = maxY
                random.x = CGFloat.random(in: w10Percent...w90Percent)
            case .minY:
                random.y = minY
                random.x = CGFloat.random(in: w10Percent...w90Percent)
            case .minX:
                random.x = minX
                random.y = CGFloat.random(in: h10Percent...h90Percent)
            default:
                random.x = minX
                random.y = minY
                break
            }
        }
        
        return random
    }
    
    // Generate duration base by screen size
    private func getDuration() -> TimeInterval {
        let size = bounds.width > bounds.height ? bounds.width : bounds.height
        
        return Double.random(in: size / 130...size / 90)
    }
    
    // Start monitoring positions using CADisplayLink
    private func startMonitoringPositions() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateLines))
        displayLink?.preferredFrameRateRange = .init(minimum: 60, maximum: 120, __preferred: 120)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // Stop monitoring positions
    private func stopMonitoringPositions() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // Update lines based on distances
    @objc func updateLines() {
        let path = UIBezierPath()
        
        // Check distances between all pairs of circles
        for i in 0..<circleLayers.count {
            for j in (i + 1)..<circleLayers.count {
                let circle1 = circleLayers[i]
                let circle2 = circleLayers[j]
                
                // Get the current position from the presentation layer
                let position1 = circle1.presentation()?.position ?? circle1.position
                let position2 = circle2.presentation()?.position ?? circle2.position
                
                // Calculate the distance between circles
                let distance = hypot(position1.x - position2.x, position1.y - position2.y)
                
                if distance <= 100 {
                    // Add a line between the circles
                    path.move(to: position1)
                    path.addLine(to: position2)
                }
            }
        }
        
        // Update the line layer's path
        lineLayer.path = path.cgPath
    }
    
    // Stop CADisplayLink when no longer needed
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: Animate Delegate
extension ParticleView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return } // Ensure animation completed normally
        
        // Find the layer associated with this animation
        for circleLayer in circleLayers {
            if circleLayer.animation(forKey: "positionAnimation") === anim {
                // Update the circle's position to the animation's final value
                if let nextPosition = circleLayer.value(forKey: nextValueKey) as? CGPoint {
                    circleLayer.position = nextPosition
                }
                
                // Start a new animation
                animateCircle(circleLayer: circleLayer)
                break
            }
        }
    }
}
