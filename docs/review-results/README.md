
# Quantum-Classical SoC — Simulation Review Results

## Project
Design and Simulation of a RISC-V Based Quantum-Classical
System-on-Chip for Quantum Communication Applications.

## Test Results

| Testbench | Result |
|---|---|
| RV32I core | 4 checks passed, 0 failed |
| RV32I memory / AXI RAM | 7 checks passed, 0 failed |
| QKD engine | 13 checks passed, 0 failed |
| Quantum peripheral | Two transactions completed |
| AXI4-Lite interconnect | 16 checks passed, 0 failed |
| CPU master + AXI slaves | 7 checks passed, 0 failed |
| AXI real-slave system | 13 checks passed, 0 failed |
| SoC top-level wrapper | 4 checks passed, 0 failed |

## QKD Engine Output

- Sifted key length: 32 bits
- Expected sifted key: `810314305A280090`
- Simulated QBER: 0%

## Known Limitation

A deadlock was observed with back-to-back memory operations.
The memory test that passed uses gap instructions between
memory operations. The handshake issue remains to be resolved.

## Scope

These are RTL simulation results from Icarus Verilog.
The SoC wrapper test verifies basic CPU execution through
the wrapper; it does not yet demonstrate CPU-driven,
end-to-end QKD execution.
