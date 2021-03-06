// The MIT License (MIT)
//
// Copyright (c) 2016 Nicolas Seriot
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

protocol GenericNumber {
  var cgFloat: CGFloat { get }
  var double: Double { get }
}

extension CGFloat: GenericNumber {
  var cgFloat: CGFloat { return self }
  var double: Double { return Double(self) }
}

extension Int: GenericNumber {
  var cgFloat: CGFloat { return CGFloat(self) }
  var double: Double { return Double(self) }
}

extension Double: GenericNumber {
  var cgFloat: CGFloat { return CGFloat(self) }
  var double: Double { return self }
}

extension Float: GenericNumber {
  var cgFloat: CGFloat { return CGFloat(self) }
  var double: Double { return Double(self) }
}

extension UInt32: GenericNumber {
  var cgFloat: CGFloat { return CGFloat(self) }
  var double: Double { return Double(self) }
}

func P<T: GenericNumber>(_ x:T, _ y:T) -> NSPoint {
  return NSMakePoint(x.cgFloat, y.cgFloat)
}

infix operator * : MultiplicationPrecedence

func *(left:GenericNumber, right:GenericNumber) -> Double
{ return left.double * right.double }

infix operator / : MultiplicationPrecedence

func /(left:GenericNumber, right:GenericNumber) -> Double
{ return left.double / right.double }

infix operator + : AdditionPrecedence

func +(left:GenericNumber, right:GenericNumber) -> Double
{ return left.double + right.double }

infix operator - : AdditionPrecedence

func -(left:GenericNumber, right:GenericNumber) -> Double
{ return left.double - right.double }

func RandomPoint(maxX:Int, maxY:Int) -> NSPoint {
  
  return P(arc4random_uniform(UInt32(maxX+1)), arc4random_uniform(UInt32(maxY+1)))
}

func R<T: GenericNumber>(_ x:T, _ y:T, _ w:T, _ h:T) -> NSRect {
  return NSMakeRect(x.cgFloat, y.cgFloat, w.cgFloat, h.cgFloat)
}

class BitmapCanvas {
  
  let bitmapImageRep : NSBitmapImageRep
  let context : NSGraphicsContext
  
  var cgContext : CGContext {
    return context.cgContext
  }
  
  var width : CGFloat {
    return bitmapImageRep.size.width
  }
  
  var height : CGFloat {
    return bitmapImageRep.size.height
  }
  
  func setAllowsAntialiasing(_ antialiasing : Bool) {
    cgContext.setAllowsAntialiasing(antialiasing)
  }
  
  init(_ width:Int, _ height:Int, _ background:ConvertibleToNSColor? = nil) {
    
    self.bitmapImageRep = NSBitmapImageRep(
      bitmapDataPlanes:nil,
      pixelsWide:width,
      pixelsHigh:height,
      bitsPerSample:8,
      samplesPerPixel:4,
      hasAlpha:true,
      isPlanar:false,
      colorSpaceName:NSColorSpaceName.deviceRGB,
      bytesPerRow:width*4,
      bitsPerPixel:32)!
    
    self.context = NSGraphicsContext(bitmapImageRep: bitmapImageRep)!
    
    NSGraphicsContext.current = context
    
    setAllowsAntialiasing(false)
    
    if let b = background {
      
      let rect = NSMakeRect(0, 0, CGFloat(width), CGFloat(height))
      
      context.saveGraphicsState()
      
      b.color.setFill()
      NSBezierPath.fill(rect)
      
      context.restoreGraphicsState()
    }
    
    // makes coordinates start upper left
    cgContext.translateBy(x: 0, y: CGFloat(height))
    cgContext.scaleBy(x: 1.0, y: -1.0)
  }
  
  fileprivate func _colorIsEqual(_ p:NSPoint, _ pixelBuffer:UnsafePointer<UInt8>, _ rgba:(UInt8,UInt8,UInt8,UInt8)) -> Bool {
    
    let offset = 4 * ((Int(self.width) * Int(p.y) + Int(p.x)))
    
    let r = pixelBuffer[offset]
    let g = pixelBuffer[offset+1]
    let b = pixelBuffer[offset+2]
    let a = pixelBuffer[offset+3]
    
    if r != rgba.0 { return false }
    if g != rgba.1 { return false }
    if b != rgba.2 { return false }
    if a != rgba.3 { return false }
    
    return true
  }
  
  fileprivate func _color(_ p:NSPoint, pixelBuffer:UnsafePointer<UInt8>) -> NSColor {
    
    let offset = 4 * ((Int(self.width) * Int(p.y) + Int(p.x)))
    
    let r = pixelBuffer[offset]
    let g = pixelBuffer[offset+1]
    let b = pixelBuffer[offset+2]
    let a = pixelBuffer[offset+3]
    
    return NSColor(
      calibratedRed: CGFloat(Double(r)/255.0),
      green: CGFloat(Double(g)/255.0),
      blue: CGFloat(Double(b)/255.0),
      alpha: CGFloat(Double(a)/255.0))
  }
  
  func color(_ p:NSPoint) -> NSColor {
    
    guard let data = cgContext.data else { assertionFailure(); return NSColor.clear }
    
    let pixelBuffer = data.assumingMemoryBound(to: UInt8.self)
    
    return _color(p, pixelBuffer:pixelBuffer)
  }
  
  fileprivate func _setColor(_ p:NSPoint, pixelBuffer:UnsafeMutablePointer<UInt8>, normalizedColor:NSColor) {
    let offset = 4 * ((Int(self.width) * Int(p.y) + Int(p.x)))
    
    pixelBuffer[offset] = UInt8(normalizedColor.redComponent * 255.0)
    pixelBuffer[offset+1] = UInt8(normalizedColor.greenComponent * 255.0)
    pixelBuffer[offset+2] = UInt8(normalizedColor.blueComponent * 255.0)
    pixelBuffer[offset+3] = UInt8(normalizedColor.alphaComponent * 255.0)
  }
  
  func setColor(_ p:NSPoint, color color_:ConvertibleToNSColor) {
    
    let color = color_.color
    
    guard p.x <= width, p.y <= height else {
      return
    }
    
    guard let normalizedColor = color.usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
      print("-- cannot normalize color \(color)")
      return
    }
    
    guard let data = cgContext.data else { assertionFailure(); return }
    
    let pixelBuffer = data.assumingMemoryBound(to: UInt8.self)
    
    _setColor(p, pixelBuffer:pixelBuffer, normalizedColor:normalizedColor)
  }
  
  subscript(x:Int, y:Int) -> ConvertibleToNSColor {
    
    get {
      let p = P(x, y)
      return color(p)
    }
    
    set {
      let p = P(x, y)
      setColor(p, color:newValue)
    }
  }
  
  func fill(_ p:NSPoint, color rawNewColor_:ConvertibleToNSColor) {
    // floodFillScanlineStack from http://lodev.org/cgtutor/floodfill.html
    
    let rawNewColor = rawNewColor_.color
    
    assert(p.x < width, "p.x \(p.x) out of range, must be < \(width)")
    assert(p.y < height, "p.y \(p.y) out of range, must be < \(height)")
    
    guard let data = cgContext.data else { assertionFailure(); return }
    
    let pixelBuffer = data.assumingMemoryBound(to: UInt8.self)
    
    guard let newColor = rawNewColor.usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
      print("-- cannot normalize color \(rawNewColor)")
      return
    }
    
    let oldColor = _color(p, pixelBuffer:pixelBuffer)
    
    if oldColor == newColor { return }
    
    // store rgba as [UInt8] to speed up comparisons
    var r : CGFloat = 0.0
    var g : CGFloat = 0.0
    var b : CGFloat = 0.0
    var a : CGFloat = 0.0
    
    oldColor.getRed(&r, green: &g, blue: &b, alpha: &a)
    
    let rgba = (UInt8(r*255),UInt8(g*255),UInt8(b*255),UInt8(a*255))
    
    var stack : [NSPoint] = [p]
    
    while let pp = stack.popLast() {
      
      var x1 = pp.x
      
      while(x1 >= 0 && _color(P(x1, pp.y), pixelBuffer:pixelBuffer) == oldColor) {
        x1 -= 1
      }
      
      x1 += 1
      
      var spanAbove = false
      var spanBelow = false
      
      while(x1 < width && _colorIsEqual(P(x1, pp.y), pixelBuffer, rgba )) {
        
        _setColor(P(x1, pp.y), pixelBuffer:pixelBuffer, normalizedColor:newColor)
        
        let north = P(x1, pp.y-1)
        let south = P(x1, pp.y+1)
        
        if spanAbove == false && pp.y > 0 && _colorIsEqual(north, pixelBuffer, rgba) {
          stack.append(north)
          spanAbove = true
        } else if spanAbove && pp.y > 0 && !_colorIsEqual(north, pixelBuffer, rgba) {
          spanAbove = false
        } else if spanBelow == false && pp.y < height - 1 && _colorIsEqual(south, pixelBuffer, rgba) {
          stack.append(south)
          spanBelow = true
        } else if spanBelow && pp.y < height - 1 && !_colorIsEqual(south, pixelBuffer, rgba) {
          spanBelow = false
        }
        
        x1 += 1
      }
    }
  }
  
  func line(_ p1: NSPoint, _ p2: NSPoint, _ color_: ConvertibleToNSColor? = NSColor.black) {
    
    let color = color_?.color
    
    context.saveGraphicsState()
    
    // align to the pixel grid
    cgContext.translateBy(x: 0.5, y: 0.5)
    
    if let existingColor = color {
      cgContext.setStrokeColor(existingColor.cgColor);
    }
    
    cgContext.setLineCap(.square)
    cgContext.move(to: CGPoint(x: p1.x, y: p1.y))
    cgContext.addLine(to: CGPoint(x: p2.x, y: p2.y))
    cgContext.strokePath()
    
    context.restoreGraphicsState()
  }
  
  func line(_ p1: NSPoint, length: GenericNumber = 1.0, degreesCW: GenericNumber = 0.0, _ color_: ConvertibleToNSColor? = NSColor.black) -> NSPoint {
    let color = color_?.color
    let radians = degreesToRadians(degreesCW.double)
    let p2 = P(p1.x + sin(radians) * length.cgFloat, p1.y
      - cos(radians) * length.cgFloat)
    self.line(p1, p2, color)
    return p2
  }
  
  func lineVertical(_ p1: NSPoint, height: Double, _ color_: ConvertibleToNSColor? = nil) {
    let color = color_?.color
    let p2 = P(p1.x, p1.y + CGFloat(height - 1))
    self.line(p1, p2, color)
  }
  
  func lineHorizontal(_ p1:NSPoint, width: Double, _ color_: ConvertibleToNSColor? = nil) {
    let color = color_?.color
    let p2 = P(p1.x + width - 1, p1.y.double)
    self.line(p1, p2, color)
  }
  
  func line(_ p1: NSPoint, deltaX: Double, deltaY: Double, _ color_: ConvertibleToNSColor? = nil) {
    let color = color_?.color
    let p2 = P(p1.x + deltaX, p1.y + deltaY)
    self.line(p1, p2, color)
  }
  
  func rectangle(_ rect:NSRect, stroke stroke_:ConvertibleToNSColor? = NSColor.black, fill fill_:ConvertibleToNSColor? = nil) {
    
    let stroke = stroke_?.color
    let fill = fill_?.color
    
    context.saveGraphicsState()
    
    // align to the pixel grid
    cgContext.translateBy(x: 0.5, y: 0.5)
    
    if let existingFillColor = fill {
      existingFillColor.setFill()
      NSBezierPath.fill(rect)
    }
    
    if let existingStrokeColor = stroke {
      existingStrokeColor.setStroke()
      NSBezierPath.stroke(rect)
    }
    
    context.restoreGraphicsState()
  }
  
  func polygon(_ points:[NSPoint], stroke stroke_:ConvertibleToNSColor? = NSColor.black, lineWidth:CGFloat=1.0, fill fill_:ConvertibleToNSColor? = nil) {
    
    guard points.count >= 3 else {
      assertionFailure("at least 3 points are needed")
      return
    }
    
    context.saveGraphicsState()
    
    let path = NSBezierPath()
    
    path.move(to: points[0])
    
    for i in 1...points.count-1 {
      path.line(to: points[i])
    }
    
    if let existingFillColor = fill_?.color {
      existingFillColor.setFill()
      path.fill()
    }
    
    path.close()
    
    if let existingStrokeColor = stroke_?.color {
      existingStrokeColor.setStroke()
      path.lineWidth = lineWidth
      path.stroke()
    }
    
    context.restoreGraphicsState()
  }
  
  func ellipse(_ rect:NSRect, stroke stroke_:ConvertibleToNSColor? = NSColor.black, fill fill_:ConvertibleToNSColor? = nil) {
    
    let strokeColor = stroke_?.color
    let fillColor = fill_?.color
    
    context.saveGraphicsState()
    
    // align to the pixel grid
    cgContext.translateBy(x: 0.5, y: 0.5)
    
    // fill
    if let existingFillColor = fillColor {
      existingFillColor.setFill()
      
      // reduce fillRect so that is doesn't cross the stoke
      let fillRect = R(rect.origin.x+1, rect.origin.y+1, rect.size.width-2, rect.size.height-2)
      cgContext.fillEllipse(in: fillRect)
    }
    
    // stroke
    if let existingStrokeColor = strokeColor { existingStrokeColor.setStroke() }
    cgContext.strokeEllipse(in: rect)
    
    context.restoreGraphicsState()
  }
  
  fileprivate func degreesToRadians(_ x:GenericNumber) -> Double {
    return (Double.pi * x / 180.0)
  }
  
  func rotate(center p: CGPoint, radians: GenericNumber, closure: () -> ()) {
    let c = self.cgContext
    c.saveGState()
    c.translateBy(x: p.x, y: p.y)
    c.rotate(by: radians.cgFloat)
    c.translateBy(x: p.x * -1.0, y: p.y * -1.0)
    closure()
    c.restoreGState()
  }
  
  func save(_ path:String, open:Bool=false) {
    guard let data = bitmapImageRep.representation(using: .png, properties: [:]) else {
      print("\(#file) \(#function) cannot get PNG data from bitmap")
      return
    }
    
    do {
      try data.write(to: URL(fileURLWithPath: path), options: [])
      if open {
        NSWorkspace.shared.openFile(path)
      }
    } catch let e {
      print(e)
    }
  }
  
  static func textWidth(_ text:NSString, font:NSFont) -> CGFloat {
    let maxSize : CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: font.pointSize)
    let textRect : CGRect = text.boundingRect(
      with: maxSize,
      options: NSString.DrawingOptions.usesLineFragmentOrigin,
      attributes: [.font: font],
      context: nil)
    return textRect.size.width
  }
  
  func image(fromPath path:String, _ p:NSPoint) {
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      print("\(#file) \(#function) cannot read data at \(path)");
      return
    }
    
    guard let imgRep = NSBitmapImageRep(data: data) else {
      print("\(#file) \(#function) cannot create bitmap image rep from data at \(path)");
      return
    }
    
    guard let cgImage = imgRep.cgImage else {
      print("\(#file) \(#function) cannot get cgImage out of imageRep from \(path)");
      return
    }
    
    context.saveGraphicsState()
    
    cgContext.scaleBy(x: 1.0, y: -1.0)
    cgContext.translateBy(x: 0.0, y: -2.0 * p.y - imgRep.pixelsHigh.cgFloat)
    
    let rect = NSMakeRect(p.x, p.y, imgRep.pixelsWide.cgFloat, imgRep.pixelsHigh.cgFloat)
    
    cgContext.draw(cgImage, in: rect)
    
    context.restoreGraphicsState()
  }
  
  func text(_ text: String, _ p: NSPoint, rotationRadians: GenericNumber?, font: NSFont = NSFont(name: "Monaco", size: 10)!, color color_ : ConvertibleToNSColor = NSColor.black) {
    
    let color = color_.color
    
    context.saveGraphicsState()
    
    if let radians = rotationRadians {
      cgContext.translateBy(x: p.x, y: p.y);
      cgContext.rotate(by: radians.cgFloat)
      cgContext.translateBy(x: -p.x, y: -p.y);
    }
    
    cgContext.scaleBy(x: 1.0, y: -1.0)
    cgContext.translateBy(x: 0.0, y: -2.0 * p.y - font.pointSize)
    
    text.draw(at: p, withAttributes: [.font: font, .foregroundColor: color])
    
    context.restoreGraphicsState()
  }
  
  func text(_ text: String, _ p: NSPoint, rotationDegrees degrees: GenericNumber = 0.0, font: NSFont = NSFont(name: "Monaco", size: 10)!, color: ConvertibleToNSColor = NSColor.black) {
    self.text(text, p, rotationRadians: degreesToRadians(degrees), font: font, color: color)
  }
}




import Cocoa

extension NSRegularExpression {
  class func findAll(string s: String, pattern: String) throws -> [String] {
    
    let regex = try NSRegularExpression(pattern: pattern, options: [])
    let matches = regex.matches(in: s, options: [], range: NSMakeRange(0, s.count))
    
    var results : [String] = []
    
    for m in matches {
      for i in 1..<m.numberOfRanges {
        let range = m.range(at: i)
        results.append((s as NSString).substring(with: range))
      }
    }
    
    return results
  }
}

protocol ConvertibleToNSColor {
  var color : NSColor { get }
}

extension ConvertibleToNSColor {
  var hexValue: String {
    guard let rgbColor = color.usingColorSpace(.deviceRGB) else {
      return "#FFFFFF"
    }
    let red = Int(round(rgbColor.redComponent * 0xFF))
    let green = Int(round(rgbColor.greenComponent * 0xFF))
    let blue = Int(round(rgbColor.blueComponent * 0xFF))
    let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
    return hexString as String
  }
}

extension NSColor : ConvertibleToNSColor {
  var color : NSColor {
    return self
  }
}

extension UInt32 : ConvertibleToNSColor {
  
  var color : NSColor {
    
    let r = Double((self >> 16) & 0xff) / 255.0
    let g = Double((self >> 08) & 0xff) / 255.0
    let b = Double((self >> 00) & 0xff) / 255.0
    
    return NSColor(calibratedRed:r.cgFloat, green:g.cgFloat, blue:b.cgFloat, alpha:1.0)
  }
}

extension String : ConvertibleToNSColor {
  
  var color : NSColor {
    
    let scanner = Scanner(string: self)
    
    if scanner.scanString("#", into: nil) {
      var result : UInt32 = 0
      if scanner.scanHexInt32(&result) {
        return result.color
      } else {
        assertionFailure("cannot convert \(self) to hex color)")
        return NSColor.clear
      }
    }
    
    if let c = X11Colors.sharedInstance.colorList.color(withKey: self.lowercased()) {
      return c
    }
    
    assertionFailure("cannot convert \(self) into color)")
    return NSColor.clear
  }
}

extension NSColor {
  
  convenience init(_ r:Int, _ g:Int, _ b:Int, _ a:Int = 255) {
    self.init(
      calibratedRed: CGFloat(r)/255.0,
      green: CGFloat(g)/255.0,
      blue: CGFloat(b)/255.0,
      alpha: CGFloat(a)/255.0)
  }
  
  class var randomColor : NSColor {
    return C(Int(arc4random_uniform(256)), Int(arc4random_uniform(256)), Int(arc4random_uniform(256)))
  }
  
  class func rainbowColor(offset: Double = 0.0, percent pct: Double = 0.0, alpha: Double = 1.0) -> NSColor {
    let red = sin(2 * Double.pi * (offset + pct) + 0) * 0.5 + 0.5
    let green = sin(2 * Double.pi * (offset + pct) + 2) * 0.5 + 0.5
    let blue = sin(2 * Double.pi * (offset + pct) + 4) * 0.5 + 0.5
    
    return NSColor(
      calibratedRed: red.cgFloat,
      green: green.cgFloat,
      blue: blue.cgFloat,
      alpha: alpha.cgFloat
    )
  }
}

func C(_ r:Int, _ g:Int, _ b:Int, _ a:Int = 255) -> NSColor {
  return NSColor(r,g,b,a)
}

func C(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat = 255.0) -> NSColor {
  return NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
}

class X11Colors {
  
  static let sharedInstance = X11Colors(namePrettifier: { $0.lowercased() })
  
  var colorList = NSColorList(name: "X11")
  
  init(path:String = "/opt/X11/share/X11/rgb.txt", namePrettifier:@escaping (_ original:String) -> (String)) {
    
    let contents = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
    
    contents.enumerateLines { (line, stop) in
      
      let pattern = "\\s?+(\\d+?)\\s+(\\d+?)\\s+(\\d+?)\\s+(\\w+)$"
      let matches = try! NSRegularExpression.findAll(string: line, pattern: pattern)
      if matches.count != 4 { return } // ignore names with white spaces, they also appear in camel case
      
      let r = CGFloat(Int(matches[0])!)
      let g = CGFloat(Int(matches[1])!)
      let b = CGFloat(Int(matches[2])!)
      
      let name = matches[3]
      
      let prettyName = namePrettifier(name)
      
      let color = NSColor(calibratedRed: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
      self.colorList.setColor(color, forKey: prettyName)
      
      //print("\(name) \t -> \t \(prettyName)")
    }
  }
  
  static func dump(_ inPath:String, outPath:String) -> Bool {
    
    let x11Colors = X11Colors(namePrettifier: {
      let name = ($0 as NSString)
      let firstCharacter = name.substring(to: 1)
      let restOfString = name.substring(with: NSMakeRange(1, name.lengthOfBytes(using: String.Encoding.utf8.rawValue)-1))
      return "\(firstCharacter.uppercased())\(restOfString)"
    })
    
    return x11Colors.colorList.write(toFile: outPath)
  }
}
