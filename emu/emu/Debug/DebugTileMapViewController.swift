import Cocoa

class DebugTileMapViewController: NSViewController {
  var queue: DispatchQueue = DispatchQueue(label: "Render")

  var image: NSImage? {
    set {
      self.view.layer = CALayer()
      self.view.layer?.allowsEdgeAntialiasing = false
      self.view.layer?.contentsGravity = .resizeAspect
      self.view.layer?.contents = newValue
      self.view.wantsLayer = true

    }
    get {
      return nil
    }
  }
}

extension DebugTileMapViewController {
  func display(_ canvas: BitmapCanvas) {
    queue.async {
      let bitmap = canvas.bitmapImageRep
      let image = NSImage(cgImage: bitmap.cgImage!, size: bitmap.size)

      DispatchQueue.main.async {
        self.image = image
      }
    }
  }
}
