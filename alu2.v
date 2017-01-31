/*module xor3(input a ,input b,input c,output x);
   assign x=a^b^c;
endmodule
module alu2(input wire [31:0] srca,input wire [31:0]srcb,
  input wire [1:0] alucontrol,
  output reg[31:0] aluresult,output reg[3:0]aluflags);
  reg [31:0]sum;
  reg cout;
  wire [31:0]srcbc=~srcb;
  wire xa;
  xor3 aa(alucontrol[0],srca[31],srca[31],xa);
  always@(*) 
  begin
      if(alucontrol[0]) {cout,sum}=srca+srcbc+1;
      else              {cout,sum}=srca+srcb;
      case (alucontrol)
          2'b00: aluresult=sum;
          2'b01: aluresult=sum;
          2'b10: aluresult=srca & srcb;
          2'b11: aluresult=srca | srcb;
      endcase
      aluflags[3:2]={aluresult[31],aluresult==0};                             //n,z flags
      aluflags[1]= cout & ~alucontrol[1];                                     //carry out flag c
      
      aluflags[0]= xa & (~alucontrol[1] & (aluresult[31] ^ srca[31]) );     //overflow flag v
  end  
endmodule*/

module alu2(input wire [31:0] srca,input wire [31:0]srcb,
input wire [1:0] alucontrol,
output reg[31:0] aluresult,output wire[3:0]aluflags);
reg [31:0]sum;
reg cout;
wire [31:0]srcbc=~srcb;
always@(*) begin
if(alucontrol[0]) {cout,sum}=srca+srcbc+1;
else {cout,sum}=srca+srcb;
case (alucontrol)
2'b00: aluresult=sum;
2'b01: aluresult=sum;
2'b10: aluresult=srca & srcb;
2'b11: aluresult=srca | srcb;
endcase
end
assign aluflags[3:2]={aluresult[31],aluresult==0}; //n,z flags
assign aluflags[1]= cout & ~alucontrol[1]; //carry out flag c

assign aluflags[0]= (~(alucontrol[0]^srca[31]^srca[31])) & (~alucontrol[1]) & (aluresult[31] ^ srca[31]) ; //overflow flag v 
endmodule