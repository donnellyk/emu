import Cocoa

class DebugTileMapViewController: ImageViewController {
  var queue: DispatchQueue = DispatchQueue(label: "Render")
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
