import Cocoa

class DebugMemoryViewController: NSViewController {
  struct MemoryEntry {
    var address: String
    var row: Int
    var value: UInt8
    
    init(_ row: Int, _ value: UInt8) {
      self.row = row
      self.address = UInt16(clamping: row).toHex
      self.value = value
    }
  }
  
  @IBInspectable var isCartDump: Bool = false
  
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var field: NSSearchField!
  private var memoryCopy: [UInt8] = [] {
    didSet {
      refilter()
      tableView?.reloadData()
    }
  }
  
  private var filteredMemoryCopy: [MemoryEntry] = [] {
    didSet {
      tableView?.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    
    if isCartDump {
      DebugService.shared.cartMap = self
    } else {
      DebugService.shared.memoryMap = self
    }
  }
  
  func setMemory(memory: [UInt8]) {
    memoryCopy = memory
  }
}

extension DebugMemoryViewController: NSSearchFieldDelegate {
  func controlTextDidChange(_ obj: Notification) {
    refilter()
  }
  
  func refilter() {
    let formatedString = field.stringValue.replacingOccurrences(of: "0x", with: "")
    
    let lowerRange = formatedString.padding(toLength: 4, withPad: "0", startingAt: 0)
    let upperRange = formatedString.padding(toLength: 4, withPad: "F", startingAt: 0)
    
    let lowerInt =  Int(lowerRange, radix: 16) ?? 0
    var upperInt =  Int(upperRange, radix: 16) ?? (lowerInt + 1)
    upperInt = min(upperInt, memoryCopy.count-1)
    
    let range = lowerInt...upperInt
    
    filteredMemoryCopy = Array(memoryCopy.enumerated())[range].map { (index, value) in return MemoryEntry(index, value) }
  }
}

extension DebugMemoryViewController : NSTableViewDelegate, NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return filteredMemoryCopy.count
  }
  
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let identifer: NSUserInterfaceItemIdentifier
    let value: String
    
    switch tableColumn {
    case tableView.tableColumns[0]:
      identifer = NSUserInterfaceItemIdentifier(rawValue: "AddressID")
      value = filteredMemoryCopy[row].address
      
    case tableView.tableColumns[1]:
      identifer = NSUserInterfaceItemIdentifier(rawValue: "ValueID")
      value = filteredMemoryCopy[row].value.toHex
      
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
