# Next-PC Logic

## Purpose

Computes the next instruction address.

## Priority

1. Jump
2. Branch
3. Sequential (PC + 4)

## Inputs

- current_pc
- branch_taken
- branch_target
- jump_taken
- jump_target

## Output

- next_pc

## Version

v1.0