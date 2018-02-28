//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: CALayer {
  weak var rangeSlider: RangeSlider?

  override func draw(in ctx: CGContext) {
    guard let slider = rangeSlider else {
      return
    }

    // Clip
    let cornerRadius = bounds.height * slider.curvaceousness / 2.0
    let path = UIBezierPath(roundedRect: CGRect(x: bounds.origin.x, y: bounds.origin.y , width: bounds.width, height: slider.heightLine), cornerRadius: cornerRadius)
    ctx.addPath(path.cgPath)

    // Fill the track
    ctx.setFillColor(slider.trackTintColor.cgColor)
    ctx.addPath(path.cgPath)
    ctx.fillPath()

    // Fill the highlighted range
    ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
    let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
    let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
    let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: slider.heightLine)
    ctx.fill(rect)

    // Fill until less value
    ctx.setFillColor(slider.trackLessTintColor.cgColor)
    let rectLess = CGRect(x: 0.0, y: 0.0, width: lowerValuePosition, height: slider.heightLine)
    ctx.fill(rectLess)
  }
}

class RangeSliderThumbLayer: CALayer {

  var highlighted: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }

  var id: Int = 0

  weak var rangeSlider: RangeSlider?

  var strokeColor: UIColor = UIColor.gray {
    didSet {
      setNeedsDisplay()
    }
  }
  var lineWidth: CGFloat = 0.5 {
    didSet {
      setNeedsDisplay()
    }
  }

  override func draw(in ctx: CGContext) {
    guard let slider = rangeSlider else {
      return
    }

    let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
    let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
    let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)

    // Fill
    if id == 0{
      ctx.setFillColor(slider.thumbLowerTintColor.cgColor)
    } else {
      ctx.setFillColor(slider.thumbUpperTintColor.cgColor)
    }
    ctx.addPath(thumbPath.cgPath)
    ctx.fillPath()

    // Outline
    ctx.setStrokeColor(strokeColor.cgColor)
    ctx.setLineWidth(lineWidth)
    ctx.addPath(thumbPath.cgPath)
    ctx.strokePath()

    if highlighted {
      ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
      ctx.addPath(thumbPath.cgPath)
      ctx.fillPath()
    }
  }
}

@IBDesignable
public class RangeSlider: UIControl {
  @IBInspectable public var minimumValue: Double = 0.0 {
    willSet(newValue) {
      assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
    }
    didSet {
      updateLayerFrames()
    }
  }

  @IBInspectable public var maximumValue: Double = 1.0 {
    willSet(newValue) {
      assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
    }
    didSet {
      updateLayerFrames()
    }
  }

  @IBInspectable public var lowerValue: Double = 0.2 {
    didSet {
      if lowerValue < minimumValue {
        lowerValue = minimumValue
      }
      updateLayerFrames()
    }
  }

  @IBInspectable public var upperValue: Double = 0.8 {
    didSet {
      if upperValue > maximumValue {
        upperValue = maximumValue
      }
      updateLayerFrames()
    }
  }
  @IBInspectable public var heightLine: CGFloat = 2 {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  var gapBetweenThumbs: Double {
    return 0.5 * Double(thumbWidth) * (maximumValue - minimumValue) / Double(bounds.width)
  }

  @IBInspectable public var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  @IBInspectable public var trackLessTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  @IBInspectable public var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
    didSet {
      trackLayer.setNeedsDisplay()
    }
  }

  @IBInspectable public var thumbUpperTintColor: UIColor = UIColor.white {
    didSet {
      upperThumbLayer.setNeedsDisplay()
    }
  }

  @IBInspectable public var thumbLowerTintColor: UIColor = UIColor.white {
    didSet {
      lowerThumbLayer.setNeedsDisplay()
    }
  }

  @IBInspectable public var thumbBorderColor: UIColor = UIColor.gray {
    didSet {
      lowerThumbLayer.strokeColor = thumbBorderColor
      upperThumbLayer.strokeColor = thumbBorderColor
    }
  }

  @IBInspectable public var thumbBorderWidth: CGFloat = 0.5 {
    didSet {
      lowerThumbLayer.lineWidth = thumbBorderWidth
      upperThumbLayer.lineWidth = thumbBorderWidth
    }
  }
  @IBInspectable public var thumbLowerWidth: CGFloat = 10
  @IBInspectable public var thumbUpperWidth: CGFloat = 18

  @IBInspectable public var moveLowerThumb: Bool = false

  @IBInspectable public var moveLessThenLower: Bool = false


  @IBInspectable public var curvaceousness: CGFloat = 1.0 {
    didSet {
      if curvaceousness < 0.0 {
        curvaceousness = 0.0
      }

      if curvaceousness > 1.0 {
        curvaceousness = 1.0
      }

      trackLayer.setNeedsDisplay()
      lowerThumbLayer.setNeedsDisplay()
      upperThumbLayer.setNeedsDisplay()
    }
  }

  fileprivate var previouslocation = CGPoint()

  fileprivate let trackLayer = RangeSliderTrackLayer()
  fileprivate let lowerThumbLayer = RangeSliderThumbLayer()
  fileprivate let upperThumbLayer = RangeSliderThumbLayer()

  fileprivate var thumbWidth: CGFloat {
    return thumbUpperWidth//CGFloat(bounds.height)
  }

  override public var frame: CGRect {
    didSet {
      updateLayerFrames()
    }
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    initializeLayers()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
    initializeLayers()
  }

  override public func layoutSublayers(of: CALayer) {
    super.layoutSublayers(of:layer)
    updateLayerFrames()
  }

  fileprivate func initializeLayers() {
    layer.backgroundColor = UIColor.clear.cgColor

    trackLayer.rangeSlider = self
    trackLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(trackLayer)

    lowerThumbLayer.rangeSlider = self
    lowerThumbLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(lowerThumbLayer)

    upperThumbLayer.rangeSlider = self
    upperThumbLayer.id = 1
    upperThumbLayer.contentsScale = UIScreen.main.scale
    layer.addSublayer(upperThumbLayer)
  }

  func updateLayerFrames() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height/3)
    trackLayer.setNeedsDisplay()

    let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
    lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbLowerWidth/2.0, y: (thumbUpperWidth/2 - 3), width: thumbLowerWidth, height: thumbLowerWidth)
    lowerThumbLayer.setNeedsDisplay()

    let upperThumbCenter = CGFloat(positionForValue(upperValue))
    upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbUpperWidth/2.0, y:
      heightLine/2, width: thumbUpperWidth, height: thumbUpperWidth)
    upperThumbLayer.setNeedsDisplay()

    CATransaction.commit()
  }

  func positionForValue(_ value: Double) -> Double {
    return Double(bounds.width - thumbWidth) * (value - minimumValue) /
      (maximumValue - minimumValue) + Double(thumbWidth/2.0)
  }

  func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
    return min(max(value, lowerValue), upperValue)
  }


  // MARK: - Touches

  override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    previouslocation = touch.location(in: self)

    // Hit test the thumb layers
    if moveLowerThumb && lowerThumbLayer.frame.contains(previouslocation) {
      lowerThumbLayer.highlighted = true
    } else if upperThumbLayer.frame.contains(previouslocation) {
      upperThumbLayer.highlighted = true
    }

    return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
  }

  override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let location = touch.location(in: self)

    // Determine by how much the user has dragged
    let deltaLocation = Double(location.x - previouslocation.x)
    let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)

    previouslocation = location

    // Update the values
    if lowerThumbLayer.highlighted {
      lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
    } else if upperThumbLayer.highlighted {
      if moveLessThenLower {
        upperValue = boundValue(upperValue + deltaValue, toLowerValue: minimumValue - 1, upperValue: maximumValue)
      } else {
        upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
      }
    }

    sendActions(for: .valueChanged)

    return true
  }

  override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    lowerThumbLayer.highlighted = false
    upperThumbLayer.highlighted = false
  }
}

