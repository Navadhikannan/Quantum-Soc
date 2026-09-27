from pathlib import Path
from cocotb_tools.runner import get_runner


ROOT = Path(__file__).resolve().parent

print("Starting Quantum AXI Cocotb Runner...")
print("Project root:", ROOT)

runner = get_runner("icarus")

print("Building quantum_axi_slave...")

runner.build(
    sources=[
      ROOT / "rtl" / "quantum" / "quantum_axi_slave.v"
    ],
    hdl_toplevel="quantum_axi_slave",
    build_dir=ROOT / "cocotb_sim_axi",
    always=True,
    waves=True,
    verbose=True,
)

print("Running Cocotb test...")

runner.test(
    hdl_toplevel="quantum_axi_slave",
    test_module="test_quantum_axi_slave",
    test_dir=ROOT / "cocotb",
    waves=True,
)

print("Quantum AXI Cocotb run completed.")