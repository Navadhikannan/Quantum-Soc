OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
    ROM (rx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
    . = ORIGIN(ROM);

    .text :
    {
        *(.text*)
    } > ROM

    .rodata :
    {
        *(.rodata*)
    } > ROM

    .data :
    {
        *(.data*)
    } > ROM

    .bss :
    {
        *(.bss*)
        *(COMMON)
    } > ROM
}