import Cocoa

class ViewController: NSViewController {
  var queue: DispatchQueue = DispatchQueue(label: "Render")
  
  @IBOutlet weak var screenImage: NSImageView!

  override func viewDidDisappear() {
    super.viewDidDisappear()
    
    let device = (NSApplication.shared.delegate as! AppDelegate).device
    device?.screen = nil
  }
}

extension ViewController : Screen {
  func display(_ bitmap: PPU.BitMap) {
    queue.async {
      guard let cgImage = bitmap.makeImage() else {
        return
      }
      
      let image = NSImage(cgImage: cgImage, size: NSMakeSize(160, 144))
      
      DispatchQueue.main.async {
        self.screenImage.image = image
      }
    }
  }
}
