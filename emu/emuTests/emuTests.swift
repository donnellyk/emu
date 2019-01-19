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
    I.ld_r_nn(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 1)
  }
  
  func testLD_NN_R() {
    mmu.read16 = 2
    
    cpu.registers.a = 255
    I.ld_nn_r(.a)(cpu)
    
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(mmu.writeAddress, 2)
  }
  
  func test8BitLoad() {
    cpu.registers.a = 255
    
    I.ld_r_r(.b, .a)(cpu)
    
    XCTAssertEqual(cpu.registers.b, cpu.registers.a)
  }
  
  func test8BitLoadFromAddress() {
    mmu.read8 = 32
    cpu.registers.hl = 0x0f
    
    I.ld_r_r(.b, .hl)(cpu)
    
    XCTAssertEqual(cpu.registers.b, 32)
    XCTAssertEqual(mmu.readAddress, 0x0f)
  }
  
  func test16BitLoad() {
    mmu.read8 = 32
    cpu.registers.bc = 0x02
    cpu.registers.hl = 0x0f
    
    I.ld_r_r(.bc, .hl)(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0x0f)
    XCTAssertEqual(mmu.writeAddress, 0x02)
    XCTAssertEqual(mmu.write8, 32)
  }
  
  func testLD_A_N() {
    cpu.registers.b = 255
    I.ld_a_n(.b)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 255)
  }
  
  func testLD_N_A() {
    cpu.registers.a = 255
    I.ld_n_a(.b)(cpu)
    
    XCTAssertEqual(cpu.registers.b, 255)
  }
  
  func testLD_A_C() {
    mmu.read8 = 48
    cpu.registers.c = 0xFF
    
    I.ld_a_c()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0xFFFF)
    XCTAssertEqual(cpu.registers.a, 48)
  }
  
  func testLD_C_A() {
    cpu.registers.a = 48
    cpu.registers.c = 0xFF
    
    I.ld_c_a()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 0xFFFF)
    XCTAssertEqual(mmu.write8, 48)
  }
  
  func testLD_A_HL_DEC() {
    mmu.read8 = 14
    cpu.registers.hl = 32
    
    I.ld_a_hl_dec()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 32)
    XCTAssertEqual(cpu.registers.a, 14)
    XCTAssertEqual(cpu.registers.hl, 31)
  }
  
  func testLD_A_HL_INC() {
    mmu.read8 = 14
    cpu.registers.hl = 32
    
    I.ld_a_hl_inc()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 32)
    XCTAssertEqual(cpu.registers.a, 14)
    XCTAssertEqual(cpu.registers.hl, 33)
  }
  
  func testLD_HL_A_DEC() {
    cpu.registers.a = 255
    cpu.registers.hl = 32
    
    I.ld_hl_a_dec()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 32)
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(cpu.registers.hl, 31)
  }
  
  func testLD_HL_A_INC() {
    cpu.registers.a = 255
    cpu.registers.hl = 32

    I.ld_hl_a_inc()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 32)
    XCTAssertEqual(mmu.write8, 255)
    XCTAssertEqual(cpu.registers.hl, 33)
  }
  
  func testLDH_N_A() {
    cpu.registers.a = 255
    mmu.read8 = 0xFF
    
    I.ldh_n_a()(cpu)
    
    XCTAssertEqual(mmu.writeAddress, 0xFFFF)
    XCTAssertEqual(mmu.write8, 255)
  }
  
  func testLDH_A_N() {
    mmu.read8 = 0xFF
    
    I.ldh_a_n()(cpu)
    
    XCTAssertEqual(mmu.readAddress, 0xFFFF)
    XCTAssertEqual(cpu.registers.a, 0xFF)
  }
  
  func testLDD_R_NN() {
    mmu.read16 = 0xFF00
    I.ldd_r_nn(.bc)(cpu)
    
    XCTAssertEqual(cpu.registers.bc, 0xFF00)
  }
  
  func testLDD_SP_HL() {
    cpu.registers.hl = 0xFF00
    I.ldd_sp_hl()(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 0xFF00)
  }
  
  func testLDD_SP_HL_N() {
    mmu.read8 = 1
    cpu.registers.sp = 1
    
    I.ldd_hl_sp_n()(cpu)
    
    XCTAssertEqual(cpu.registers.hl, 2)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0x0)
    
    mmu.read8 = 0xFF // Twos-Compliment -1
    cpu.registers.sp = 0x00FF

    I.ldd_hl_sp_n()(cpu)
    XCTAssertEqual(cpu.registers.hl, 254)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b110000)
    
    mmu.read8 = 0x0F
    cpu.registers.sp = 0xFFF0
    
    I.ldd_hl_sp_n()(cpu)
    XCTAssertEqual(cpu.registers.hl, 65535)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
  }
  
  func testLDD_NN_SP() {
    mmu.read16 = 753
    
    I.ldd_nn_sp()(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 753)
  }
  
  func testPush() {
    cpu.registers.hl = 0xFF
    cpu.registers.sp = 100
    
    I.push(.hl)(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 98)
    XCTAssertEqual(mmu.writeAddress, 98)
    XCTAssertEqual(mmu.write16, 0xFF)
  }
  
  func testPop() {
    mmu.read16 = 0xFF
    cpu.registers.sp = 100
    
    I.pop(.hl)(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 102)
    XCTAssertEqual(mmu.readAddress, 100)
    XCTAssertEqual(cpu.registers.hl, 0xFF)
  }
  
  func testAdd() {
    I.addValue(in: .a, a: 1, b: 1)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 2)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    I.addValue(in: .a, a: 0, b: 0)(cpu)
    XCTAssertEqual(cpu.registers.a, 0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
    
    I.addValue(in: .a, a: 62, b: 34)(cpu)
    XCTAssertEqual(cpu.registers.a, 96)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00100000)
    
    I.addValue(in: .a, a: 0xF0, b: 0xF0)(cpu)
    XCTAssertEqual(cpu.registers.a, 224)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00010000)
    
    I.addValue(in: .a, a: 0xFF, b: 0xFF)(cpu)
    XCTAssertEqual(cpu.registers.a, 254)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00110000)
  }
  
  func testSub() {
    I.subValue(in: .a, a: 5, b: 3)(cpu)
    XCTAssertEqual(cpu.registers.a, 2)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01000000)
    
    I.subValue(in: .a, a: 0b10000, b: 0b1111)(cpu)
    XCTAssertEqual(cpu.registers.a, 1)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01100000)
    
    I.subValue(in: .a, a: 1, b: 2)(cpu)
    XCTAssertEqual(cpu.registers.a, 255)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01110000)
  }
  
  func testSBC_A() {
    mmu.read8 = 3
    cpu.registers.a = 10
    cpu.registers.b = 5
    cpu.registers.flags.c = true
    
    
    I.sbc_a(.b)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 4)
    
    I.sbc_a()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 1)
  }
  
  func testAND_A() {
    cpu.registers.a = 0b1
    
    I.and_a(0b1)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    I.and_a(0b0)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
  }
  
  func testOR_A() {
    cpu.registers.a = 0b1
    
    I.or_a(0b1)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    I.or_a(0b0)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    cpu.registers.a = 0b0
    I.or_a(0b0)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
  }
  
  func testXOR_A() {
    cpu.registers.a = 0b1
    
    I.xor_a(0b1)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
    
    I.xor_a(0b0)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
    
    cpu.registers.a = 0b1
    I.xor_a(0b0)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
  }
  
  func testCompare_A() {
    cpu.registers.a = 10
    I.cp_a(10)(cpu)
    XCTAssertEqual(cpu.registers.a, 10)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b11000000)
    
    cpu.registers.a = 10
    I.cp_a(9)(cpu)
    XCTAssertEqual(cpu.registers.a, 10)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01000000)
    
    I.cp_a(11)(cpu)
    XCTAssertEqual(cpu.registers.a, 10)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01110000)
  }
  
  func testIncrement() {
    cpu.registers.a = 10
    I.inc(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 11)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    cpu.registers.a = 0b1111
    I.inc(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b10000)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00100000)
    
    cpu.registers.flags.c = true
    cpu.registers.a = 0b1111
    I.inc(.a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b10000)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b00110000)
    
    cpu.registers.a = 0xFF
    I.inc(.a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10110000)
  }
  
  func testDecrement() {
    cpu.registers.a = 10
    I.dec(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 9)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b01000000)
    
    cpu.registers.a = 1
    I.dec(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b11000000)
  }
  
  func testAdd_HL() {
    cpu.registers.hl = 45
    cpu.registers.bc = 45
    
    I.add_hl(.bc)(cpu)
    
    XCTAssertEqual(cpu.registers.hl, 90)
  }
  
  func testAdd_SP() {
    mmu.read8 = 0b11111111
    cpu.registers.sp = 2
    
    I.add_sp()(cpu)
    
    XCTAssertEqual(cpu.registers.sp, 1)
  }
  
  func testSwap() {
    cpu.registers.a = 0b00000001
    cpu.registers.flags.set(z: true, n: true, h: true, c: true)
    I.swap_r(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00010000)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b0)
    
    cpu.registers.a = 0b00010000
    I.swap_r(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000001)
    
    cpu.registers.a = 0b0
    I.swap_r(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssertEqual(cpu.registers.flags.byteValue, 0b10000000)
  }
  
  func testDAA() {
    // Meh, do it later
  }
  
  func testCPL() {
    cpu.registers.a = 0b00000001
    I.cpl()(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11111110)
  }
  
  func testCCF() {
    cpu.registers.flags.c = true
    I.ccf()(cpu)
    XCTAssertEqual(cpu.registers.flags.c, false)
  }
  
  func testSCF() {
    I.scf()(cpu)
    XCTAssertEqual(cpu.registers.flags.c, true)
  }
  
  func testRLCA() {
    cpu.registers.a = 0b10000010
    I.rlca()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000101)
    XCTAssert(cpu.registers.flags.c)
    
    cpu.registers.a = 0b00000010
    I.rlca()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000100)
    XCTAssertFalse(cpu.registers.flags.c)
  }
  
  func testRLA() {
    cpu.registers.a = 0b10000010
    I.rla()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000100)
    XCTAssert(cpu.registers.flags.c)
    
    cpu.registers.a = 0b00000010
    cpu.registers.flags.c = true
    I.rla()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000101)
    XCTAssertFalse(cpu.registers.flags.c)
  }
  
  func testRRCA() {
    cpu.registers.a = 0b10000001
    I.rrca()(cpu)

    XCTAssertEqual(cpu.registers.a, 0b11000000)
    XCTAssert(cpu.registers.flags.c)
    
    cpu.registers.a = 0b00000010
    I.rrca()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b00000001)
    XCTAssertFalse(cpu.registers.flags.c)
  }
  
  func testRRA() {
    cpu.registers.a = 0b10000001
    I.rra()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b01000000)
    XCTAssert(cpu.registers.flags.c)
    
    cpu.registers.a = 0b00000010
    cpu.registers.flags.c = true
    I.rra()(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b10000001)
    XCTAssertFalse(cpu.registers.flags.c)
  }
  
  func testSLA() {
    cpu.registers.a = 0b10000000
    I.sla(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssert(cpu.registers.flags.c)
    XCTAssert(cpu.registers.flags.z)
    
    cpu.registers.a = 0b01000000
    I.sla(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b10000000)
    XCTAssertFalse(cpu.registers.flags.c)
    XCTAssertFalse(cpu.registers.flags.z)
  }
  
  func testSRA() {
    cpu.registers.a = 0b00000001
    I.sra(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssert(cpu.registers.flags.c)
    XCTAssert(cpu.registers.flags.z)
    
    cpu.registers.a = 0b00000010
    I.sra(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertFalse(cpu.registers.flags.c)
    XCTAssertFalse(cpu.registers.flags.z)
    
    cpu.registers.a = 0b10000000
    I.sra(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b11000000)
  }
  
  func testSRL() {
    cpu.registers.a = 0b00000001
    I.srl(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b0)
    XCTAssert(cpu.registers.flags.c)
    XCTAssert(cpu.registers.flags.z)
    
    cpu.registers.a = 0b00000010
    I.srl(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b1)
    XCTAssertFalse(cpu.registers.flags.c)
    XCTAssertFalse(cpu.registers.flags.z)
    
    cpu.registers.a = 0b10000000
    I.srl(.a)(cpu)
    
    XCTAssertEqual(cpu.registers.a, 0b01000000)
  }
  
  func testBit() {
    cpu.registers.flags.z = true
    cpu.registers.a = 0b00000001
    I.bit(0, .a)(cpu)
    
    XCTAssertFalse(cpu.registers.flags.z)
    
    cpu.registers.flags.z = false
    cpu.registers.a = 0b00000000
    I.bit(0, .a)(cpu)
    XCTAssert(cpu.registers.flags.z)
    
    I.bit(1, .a)(cpu)
    XCTAssert(cpu.registers.flags.z)
    
    I.bit(3, .a)(cpu)
    XCTAssert(cpu.registers.flags.z)
    
    I.bit(5, .a)(cpu)
    XCTAssert(cpu.registers.flags.z)
    
    I.bit(7, .a)(cpu)
    XCTAssert(cpu.registers.flags.z)
    
    cpu.registers.flags.z = true
    cpu.registers.a = 0b00001000
    I.bit(3, .a)(cpu)
    
    XCTAssertFalse(cpu.registers.flags.z)
  }
  
  func testSet() {
    cpu.registers.a = 0b00000000
    I.set(0, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00000001)
    I.set(1, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00000011)
    I.set(2, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00000111)
    I.set(3, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00001111)
    I.set(4, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00011111)
    I.set(5, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b00111111)
    I.set(6, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b01111111)
    I.set(7, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11111111)
  }
  
  func testRes() {
    cpu.registers.a = 0b11111111
    I.res(0, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11111110)
    I.res(1, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11111100)
    I.res(2, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11111000)
    I.res(3, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11110000)
    I.res(4, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11100000)
    I.res(5, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b11000000)
    I.res(6, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b10000000)
    I.res(7, .a)(cpu)
    XCTAssertEqual(cpu.registers.a, 0b0)
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
