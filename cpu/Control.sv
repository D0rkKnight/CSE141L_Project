// control decoder
module Control #(parameter opwidth = 3, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite, Halt,
  output logic[opwidth:0] ALUOp,	   // for up to 8 ALU operations
  output logic[1:0] RegDst,
  output logic[2:0] rd_addrA, rd_addrB);      // destination register address

always_comb begin
// defaults
  RegDst   =	'b0;   // 0: 0th register  1: rs 2: rt
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b0111; // y = a+0; nop

  rd_addrA = instr[2:0];
  rd_addrB = instr[4:3];

// sample values only -- use what you need
case(instr[8:5])    // override defaults with exceptions
  4'b0000:  //load
    begin                       
      MemtoReg = 'b1;
      RegDst = 1;
    end
  4'b0001:  //store
    begin                       
      RegWrite = 'b0;
      MemWrite = 'b1;
    end
  4'b0010:  //xor
    begin
      ALUOp = 'b0001;
    end
  4'b0011:  //bne
    begin
      ALUOp = 'b0010;
      Branch = 'b1;
      RegWrite = 'b0;
      rd_addrB = 3'b0;
    end 
  4'b0100:  //add
    begin
      ALUOp = 'b0011;
    end 
  4'b0101:  //mv
    begin
      RegDst = 2;
      ALUOp = 'b0110; //Passthrough b
    end
  4'b0110:  //lshift
    begin
      ALUOp = 'b0100;
      ALUSrc = 'b1;
      RegDst = 1;
    end
  4'b0111:  //rshift
    begin
      ALUOp = 'b0101;
      ALUSrc = 'b1;
      RegDst = 1;
    end
  4'b1000:  //loadi
    begin
      // ALUOp = 'b0110;
      ALUOp = 'b0111; // Passthrough a
      ALUSrc = 'b1;
      RegDst = 1;
    end
  4'b1001:  //pari
    begin
      ALUOp = 'b1000;
      RegDst = 2;
    end
  4'b1010: // halt
    begin
      Halt = 'b1;
    end
  4'b1011:  // or
    begin
      ALUOp = 'b1010;
    end
  4'b1100:  // sub
    begin
      ALUOp = 'b1011;
    end
  4'b1101:  // lsr
    begin
      ALUOp = 'b0100;
      // ALUSrc = 'b1; lsr uses register
      RegDst = 1;
    end  
  4'b1110:  // rsr
    begin
      ALUOp = 'b0101;
      // ALUSrc = 'b1; lsr uses register
      RegDst = 1;
    end
endcase

end
	
endmodule