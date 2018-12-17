import Foundation

func main() {
  let mmu = MMU()
  let cpu = CPU(mmu: mmu)
  
  while true {
    cpu.execute()
  }
}

main()

