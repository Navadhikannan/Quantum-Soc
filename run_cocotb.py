from pathlib import Path
from cocotb_tools.runner import get_runner


ROOT = Path(__file__).resolve().parent

print("Starting Cocotb Runner...")
print("Project root:", ROOT)

runner = get_runner("icarus")

print("Building Verilog design...")

runner.build(
    sources=[
        ROOT / "cocotb" / "rtl_test" / "counter.v"
    ],
    hdl_toplevel="counter",
    build_dir=ROOT / "cocotb_sim",
    always=True,
    waves=True,
    verbose=True,
)

print("Running Cocotb test...")

runner.test(
    hdl_toplevel="counter",
    test_module="test_counter",
    test_dir=ROOT / "cocotb",
    waves=True,
)

print("Cocotb run completed.")