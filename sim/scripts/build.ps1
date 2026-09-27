param(
    [string]$Program = "add"
)

$Root = Split-Path $PSScriptRoot -Parent
$ProjectRoot = Split-Path $Root -Parent

$Asm = "$ProjectRoot\sim\asm\$Program.S"
$Obj = "$ProjectRoot\sim\asm\$Program.o"
$Elf = "$ProjectRoot\sim\asm\$Program.elf"
$Bin = "$ProjectRoot\sim\asm\$Program.bin"

$linker = "$ProjectRoot\link.ld"

Write-Host "Assembling $Program..."

riscv-none-elf-as -march=rv32i -mabi=ilp32 $Asm -o $Obj
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "Linking..."

riscv-none-elf-ld -T $linker $Obj -o $Elf
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host "Generating binary..."

riscv-none-elf-objcopy -O binary $Elf $Bin
if ($LASTEXITCODE -ne 0) { exit 1 }

Write-Host ""
Write-Host "SUCCESS!"
Write-Host "Generated:"
Write-Host "  $Obj"
Write-Host "  $Elf"
Write-Host "  $Bin"

# Convert BIN to HEX for $readmemh()

$HexFile = "$ProjectRoot\sim\hex\program.hex"

Write-Host "Generating program.hex..."

$bytes = [System.IO.File]::ReadAllBytes($Bin)
$writer = New-Object System.IO.StreamWriter($HexFile, $false)

for ($i = 0; $i -lt $bytes.Length; $i += 4) {
    $instr = "{0:X2}{1:X2}{2:X2}{3:X2}" -f `
        $bytes[$i+3], $bytes[$i+2], $bytes[$i+1], $bytes[$i]

    $writer.WriteLine($instr)
}

$writer.Close()

Write-Host ""
Write-Host "SUCCESS!"
Write-Host "Generated:"
Write-Host "  $Obj"
Write-Host "  $Elf"
Write-Host "  $Bin"
Write-Host "  $HexFile"

# ===============================
# Compile RV32I Processor
# ===============================

Write-Host ""
Write-Host "Compiling RV32I..."

$rtl = Get-ChildItem "$ProjectRoot\rtl" -Recurse -Filter *.v | ForEach-Object { $_.FullName }

$tb = "$ProjectRoot\tb\cpu\top\rv32i_top_tb.v"

iverilog -g2012 `
-o "$ProjectRoot\rv32i_sim" `
$rtl `
$tb

if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation Failed!"
    exit 1
}

Write-Host "Compilation Successful!"

# ===============================
# Run Simulation
# ===============================

Write-Host ""
Write-Host "Running Simulation..."

vvp "$ProjectRoot\rv32i_sim"

Write-Host ""
Write-Host "Simulation Finished!"