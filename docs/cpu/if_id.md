# IF/ID Pipeline Register

## Purpose

Stores the fetched instruction and PC
between the Fetch and Decode stages.

## Inputs

- clk
- reset
- write_enable
- pc_in
- instruction_in

## Outputs

- pc_out
- instruction_out

## Function

Transfers IF stage outputs to the
Decode stage every clock cycle.

Supports pipeline stall using
write_enable.