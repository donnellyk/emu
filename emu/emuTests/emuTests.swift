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
  
  func testLDD_R_NN() {
    mmu.read16 = 0xFF00
    ldd_r_nn(.bc)(cpu)
    
    XCTAssertEqual(cpu.registers.bc, 0xFF00)
  }
  
  func testLDD_SP_HL() {
    cpu.registers.hl = 0xFF00
    ldd_sp_hl()(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 0xFF00)
  }
  
  func testLDD_SP_HL_N() {
    mmu.read8 = 1
    cpu.registers.sp = 1
    
    ldd_hl_sp_n()(cpu)
    
    XCTAssertEqual(cpu.registers.hl, 2)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0x0)
    
    mmu.read8 = 0xFF
    cpu.registers.sp = 0x00FF

    ldd_hl_sp_n()(cpu)
    XCTAssertEqual(cpu.registers.hl, 510)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b100000)
    
    mmu.read8 = 0xFF
    cpu.registers.sp = 0xFFFF
    
    ldd_hl_sp_n()(cpu)
    XCTAssertEqual(cpu.registers.hl, 254)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b110000)
  }
  
  func testLDD_NN_SP() {
    mmu.read16 = 753
    
    ldd_nn_sp()(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 753)
  }
  
  func testPush() {
    cpu.registers.hl = 0xFF
    cpu.registers.sp = 100
    
    push(.hl)(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 98)
    XCTAssertEqual(mmu.writeAddress, 98)
    XCTAssertEqual(mmu.write16, 0xFF)
  }
  
  func testPop() {
    mmu.read16 = 0xFF
    cpu.registers.sp = 100
    
    pop(.hl)(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 102)
    XCTAssertEqual(mmu.readAddress, 100)
    XCTAssertEqual(cpu.registers.hl, 0xFF)
  }
  
  func testAdd() {
    addValue(in: .a, a: 1, b: 1)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 2)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    addValue(in: .a, a: 0, b: 0)(cpu)
    XCTAssertEqual(cpu.registers.a, 0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
    
    addValue(in: .a, a: 62, b: 34)(cpu)
    XCTAssertEqual(cpu.registers.a, 96)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00100000)
    
    addValue(in: .a, a: 0xF0, b: 0xF0)(cpu)
    XCTAssertEqual(cpu.registers.a, 224)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00010000)
    
    addValue(in: .a, a: 0xFF, b: 0xFF)(cpu)
    XCTAssertEqual(cpu.registers.a, 254)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00110000)
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
