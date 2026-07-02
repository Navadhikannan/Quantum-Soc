# Instruction Set Specification

## Processor

QCP-32

## ISA

RV32I Base Integer Instruction Set

## Phase 1 Instructions

### Arithmetic
- ADD
- SUB
- AND
- OR
- XOR
- SLT
- SLTU

### Immediate
- ADDI
- ANDI
- ORI
- XORI
- SLTI

### Shift
- SLL
- SRL
- SRA
- SLLI
- SRLI
- SRAI

### Memory
- LW
- SW

### Branch
- BEQ
- BNE
- BLT
- BGE

### Jump
- JAL
- JALR

### Upper Immediate
- LUI
- AUIPC

## Interface

The processor communicates with the Quantum-Classical SoC through memory-mapped I/O registers. No custom quantum instructions are added in Version 1.