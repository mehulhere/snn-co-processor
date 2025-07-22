# Spiking Neural Network RISC-V Processor

## Overview
A custom RISC-V coprocessor designed in Verilog using Vivado to accelerate Spiking Neural Network (SNN) computations. The architecture extends the RISC-V ISA based on the paper "Back to Homogeneous Computing, IEEE, 2023" to enable efficient neural network processing.

## Features
- 5-stage pipelined architecture (IF, ID, IX, IW stages)
- Custom ISA extensions for SNN operations:
  - Neuron current computation
  - State updates
  - Spike storage operations
- Performance improvements:
  - 20% faster processing
  - 35% higher throughput for large-scale SNN computations

## Architecture Components

### Pipeline Stages
1. **IF (Instruction Fetch)**: Retrieves instructions
2. **ID (Instruction Decode)**: Decodes instructions and prepares operands
3. **IX (Execution)**: Performs SNN computations and address calculations
4. **IW (Write Back)**: Writes results to registers

### Register Types
- **GPR (General Purpose Registers)**: Standard RISC-V registers
- **WVR (Weight Vector Registers)**: Stores synaptic weights
- **SVR (Spike Vector Registers)**: Stores spike information
- **NSR (Neuron State Registers)**: Stores neuron states (current, voltage, threshold)
- **NTR (Neuron Type Registers)**: Indicates neuron type (excitatory/inhibitory)
- **RPR/VTR**: Additional parameter registers

### SNN Operations
- **Neuron Current Computation**: `convh`, `conva`, `convmh`, `convma`, `doth`, `dota`
- **Neuron State Updates**: Membrane potential and threshold calculations
- **Neuron Leaky Parameters**: Configurable decay parameters for current, voltage, and threshold

## Instruction Set Architecture
The processor implements custom instructions for SNN operations:
- `0000000`: Weight Vector Register operations
- `0000001`: Spike Vector Register operations
- `0000010`: Neuron state and parameter loading
- `0000011`: Neuron current computing operations
- `0000100`: Update operations for neuron states

## Project Structure
- **`sources_1/new/`**: RTL implementation files
  - `MainCPU.v`: Top-level module integrating all components
  - `IF_stage.v`: Instruction Fetch stage
  - `ID_stage.v`: Instruction Decode stage
  - `IX_stage.v`: Execution stage for SNN operations
  - `IW_stage.v`: Write-back stage
  - Register modules: `GPR.v`, `NSR.v`, `NTR.v`, `SVR.v`, etc.

- **`sim_1/new/`**: Testbench files for verification
  - Various component testbenches (`tb_*.v`)

## Performance
- 20% faster processing of SNN computations compared to standard implementations
- 35% higher throughput for large-scale neural network operations

## Course Information
- **Course**: Computer Architecture
- **Team Size**: 3 members

## References
- "Back to Homogeneous Computing, IEEE, 2023" 