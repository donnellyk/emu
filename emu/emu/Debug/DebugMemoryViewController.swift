import Cocoa

class DebugMemoryViewController: NSViewController {
  @IBOutlet weak var tableView: NSTableView!
  private var memoryCopy: [UInt8] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    
    DebugService.shared.memoryMap = self
  }
  
  func setMemory(memory: [UInt8]) {
    memoryCopy = memory
    tableView.reloadData()
  }
}

extension DebugMemoryViewController : NSTableViewDelegate, NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return memoryCopy.count
  }
  
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let identifer: NSUserInterfaceItemIdentifier
    let value: String
    
    switch tableColumn {
    case tableView.tableColumns[0]:
      identifer = NSUserInterfaceItemIdentifier(rawValue: "AddressID")
      value = UInt16(clamping: row).toHex
      
    case tableView.tableColumns[1]:
      identifer = NSUserInterfaceItemIdentifier(rawValue: "ValueID")
      value = memoryCopy[row].toHex
      
    default:
      return nil
    }
    
    guard let cell = tableView.makeView(withIdentifier: identifer, owner: nil) as? NSTableCellView else {
      return nil
    }
    
    cell.textField?.stringValue = value
    
    return cell
  }
  
  //  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
  
  //  }
}
