import XCTest
@testable import emu

class emuTests: XCTestCase {
  var mmu: MockMMU = MockMMU()
  var cpu: CPU = CPU(mmu: MockMMU())
  
  override func setUp() {
    super.setUp()
    
    mmu = MockMMU()
    cpu = CPU(mmu: mmu)
  }

  
  func testLD_R_NN() {
    ld_r_nn(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 1)
  }
  
  func testLD_NN_R() {
    mmu.read16 = 2
    
    cpu.registers.a = 255
    ld_nn_r(.a)(cpu)
    
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(mmu.writeAddress, 2)
  }
  
  func test8BitLoad() {
    cpu.registers.a = 255
    
    ld_r_r(.b, .a)(cpu)
    
    XCTAssertEqual(cpu.registers.b, cpu.registers.a)
  }
  
  func test8BitLoadFromAddress() {
    mmu.read8 = 32
    cpu.registers.hl = 0x0f
    
    ld_r_r(.b, .hl)(cpu)
    
    XCTAssertEqual(cpu.registers.b, 32)
    XCTAssertEqual(mmu.readAddress, 0x0f)
  }
  
  func test16BitLoad() {
    mmu.read8 = 32
    cpu.registers.bc = 0x02
    cpu.registers.hl = 0x0f
    
    ld_r_r(.bc, .hl)(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0x0f)
    XCTAssertEqual(mmu.writeAddress, 0x02)
    XCTAssertEqual(mmu.write8, 32)
  }
  
  func testLD_A_N() {
    cpu.registers.b = 255
    ld_a_n(.b)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 255)
  }
  
  func testLD_N_A() {
    cpu.registers.a = 255
    ld_n_a(.b)(cpu)
    
    XCTAssertEqual(cpu.registers.b, 255)
  }
  
  func testLD_A_C() {
    mmu.read8 = 48
    cpu.registers.c = 0xFF
    
    ld_a_c()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0xFFFF)
    XCTAssertEqual(cpu.registers.a, 48)
  }
  
  func testLD_C_A() {
    cpu.registers.a = 48
    cpu.registers.c = 0xFF
    
    ld_c_a()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 0xFFFF)
    XCTAssertEqual(mmu.write8, 48)
  }
  
  func testLD_A_HL_DEC() {
    mmu.read8 = 14
    cpu.registers.hl = 32
    
    ld_a_hl_dec()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 32)
    XCTAssertEqual(cpu.registers.a, 14)
    XCTAssertEqual(cpu.registers.hl, 31)
  }
  
  func testLD_A_HL_INC() {
    mmu.read8 = 14
    cpu.registers.hl = 32
    
    ld_a_hl_inc()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 32)
    XCTAssertEqual(cpu.registers.a, 14)
    XCTAssertEqual(cpu.registers.hl, 33)
  }
  
  func testLD_HL_A_DEC() {
    cpu.registers.a = 255
    cpu.registers.hl = 32
    
    ld_hl_a_dec()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 32)
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(cpu.registers.hl, 31)
  }
  
  func testLD_HL_A_INC() {
    cpu.registers.a = 255
    cpu.registers.hl = 32

    ld_hl_a_inc()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 32)
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(cpu.registers.hl, 33)
  }
  
  func testLDH_N_A() {
    cpu.registers.a = 255
    mmu.read8 = 0xFF
    
    ldh_n_a()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 0xFFFF)
    XCTAssertEqual(mmu.write8, 255)
  }
  
  func testLDH_A_N() {
    mmu.read8 = 0xFF
    
    ldh_a_n()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0xFFFF)
    XCTAssertEqual(cpu.registers.a, 0xFF)
  }
  
  
}

class MockMMU: MMU {
  var read16: UInt16 = 1
  var read8: UInt8 = 1
  
  var write8: UInt8? = nil
  var write16: UInt16? = nil
  
  var readAddress: UInt16? = nil
  var writeAddress: UInt16? = nil
  
  
  override func read(_ address: UInt16) -> UInt8 {
    readAddress = address
    return read8
  }
  
  override func read(_ address: UInt16) -> UInt16 {
    readAddress = address
    return read16
  }
  
  override func write(_ value: UInt8, at address: UInt16) {
    write8 = value
    writeAddress = address
  }
  
  override func write(_ value: UInt16, at address: UInt16) {
    write16 = value
    writeAddress = address
  }
}
