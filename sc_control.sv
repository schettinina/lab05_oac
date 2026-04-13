// =============================================================================
// sc_control.sv
// Main Control Unit - single-cycle RISC-V (Section 4.4 - Patterson & Hennessy)
//
// Decodes the 7-bit opcode and asserts control signals for the datapath.
//
// Supported instructions:
//   R-type  (0110011): add, sub, and, or, slt
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//
// Control signal summary:
//
//   Signal    | R-type | lw | sw | beq
//   ----------|--------|----|----|-----
//   ALUSrc    |   0    |  1 |  1 |  0    0=reg, 1=imm
//   MemtoReg  |   0    |  1 |  - |  -    0=ALU, 1=mem
//   RegWrite  |   1    |  1 |  0 |  0
//   MemRead   |   0    |  1 |  0 |  0
//   MemWrite  |   0    |  0 |  1 |  0
//   Branch    |   0    |  0 |  0 |  1
//   ALUOp[1]  |   1    |  0 |  0 |  0
//   ALUOp[0]  |   0    |  0 |  0 |  1
//
//   ALUOp encoding:
//     2'b00 = Load/Store (force ADD)
//     2'b01 = Branch     (force SUB)
//     2'b10 = R-type     (ALU Control decodes Funct3/Funct7)
// =============================================================================

`timescale 1ns / 1ps

module sc_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [1:0] ALUOp
);

    localparam R_TYPE = 7'b0110011; // add, sub, and, or, slt
    localparam LOAD   = 7'b0000011; // lw
    localparam STORE  = 7'b0100011; // sw
    localparam BRANCH = 7'b1100011; // beq

    always_comb begin
        // Safe defaults: nenhuma escrita em registrador ou memória.
        // Evita latches e garante comportamento seguro para opcodes inválidos.
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (Opcode)

            // -----------------------------------------------------------------
            // R-type: add, sub, and, or, slt
            //   - 2º operando vem do registrador (ALUSrc = 0)
            //   - ALU Control decide a operação via funct3/funct7 (ALUOp = 10)
            //   - Resultado da ALU escrito no registrador destino (MemtoReg = 0)
            // -----------------------------------------------------------------
            R_TYPE: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end

            // -----------------------------------------------------------------
            // Load (lw)
            //   - Endereço = rs1 + imediato (ALUSrc = 1, ALUOp = 00 -> ADD)
            //   - Dado lido da memória vai para o registrador (MemtoReg = 1)
            // -----------------------------------------------------------------
            LOAD: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // -----------------------------------------------------------------
            // Store (sw)
            //   - Endereço = rs1 + imediato (ALUSrc = 1, ALUOp = 00 -> ADD)
            //   - Nenhuma escrita em registrador; MemtoReg = don't care (X)
            // -----------------------------------------------------------------
            STORE: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0; // don't care
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end

            // -----------------------------------------------------------------
            // Branch (beq)
            //   - ALU subtrai rs1 - rs2 para checar igualdade (ALUOp = 01)
            //   - 2º operando vem do registrador (ALUSrc = 0)
            //   - Nenhuma escrita em registrador ou memória
            // -----------------------------------------------------------------
            BRANCH: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0; // don't care
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            default: ; // sinais permanecem nos valores padrão seguros
        endcase
    end

endmodule
