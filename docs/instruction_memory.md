# Instruction Memory

## Purpose

Stores the RV32I program instructions.

## Type

Read Only Memory (ROM)

## Memory Size

256 × 32-bit

## Read Type

Asynchronous

## Program Loading

Uses `$readmemh()` to load instructions from `program.hex`.

## Addressing

Word Addressing (`address[9:2]`)