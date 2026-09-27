.section .text
.global _start

_start:
    # x2 = Quantum peripheral base address
    lui   x2, 0x80000

    # Start quantum operation
    addi  x1, x0, 1
    sw    x1, 0(x2)

wait:
    # Read STATUS
    lw    x3, 4(x2)

    # Check DONE bit (bit 1)
    andi  x4, x3, 2

    # If DONE = 0, keep waiting
    beq   x4, x0, wait

    # Quantum operation completed
    # Read generated key
    lw    x5, 8(x2)       # KEY_LO
    lw    x6, 12(x2)      # KEY_HI
    lw    x7, 16(x2)      # KEY_LENGTH

done:
    j     done
