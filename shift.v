/*
Shift Module Accepts the 11:4 bits of the instruction and Bit 25 (I)
Bit 4 >
1 >> Reg shift
0 >> constent amount
bits 6:5 >
LSL 00 Logical shift left
LSR 01 Logical shift right
ASR 10 Arithmetic shift right
ROR 11 Rotate right
bits 11:7 >
Shamt5 or Rs ( lower 8 bits of the register )

bit 25 >> enable the shift or not .. 
the RD2 from the Reg file and perform the shift operation

*/


module shift(Inst,Enable,RD2_input,ALUSrc2_output);
input [7:0] Inst;
input Enable;
input [31:0] RD2_input;
output [31:0] ALUSrc2_output;

wire [4:0] shamt5;
assign shamt5[4:0]=(Inst[0]==0)? Inst[7:3] :5'b00000;

wire [1:0] sh;
assign sh[1:0]=Inst[2:1];
/*
LSL 00 Logical shift left
LSR 01 Logical shift right
ASR 10 Arithmetic shift right
ROR 11 Rotate right
*/

wire [31:0] internal_output;

assign internal_output= (sh[1]==1) ? ( (sh[0]==1)? ( (RD2_input>>shamt5)|(RD2_input<<32-shamt5) ):( (RD2_input>>shamt5)|({32{1'b1}}<<32-shamt5) ) ) : ( (sh[0]==1)? (RD2_input>>shamt5):(RD2_input<<shamt5) );

assign ALUSrc2_output = (Enable==1)? internal_output : RD2_input;

endmodule