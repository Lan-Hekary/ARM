module decoder(input [1:0] op,input [5:0] funct,input [3:0]rd,
                    output reg [1:0] flagw,output wire pcs,output wire regw,
                    output wire memw,output wire memtoreg,output wire alusrc,
                    output wire [1:0] immsrc,output wire [1:0] regsrc,output reg[1:0] alucontrol ,output wire nowrite
                    );
  reg [9:0] control;
  wire aluop;
  wire branch;
  always @*
  case(op)
    2'b00: if(funct[5]) control=10'b0001001001;   //data processing with immediate
           else         control=10'b0000001001;   //data processing with register
    2'b01: if(funct[0]) control=10'b0101011000;   //LDR indtruction
           else         control=10'b0011010100;   //STR instruction
    2'b10:              control=10'b1001100010;   //branching
	 default:control=10'bxxxxxxxxxx;
   endcase
  assign {branch,memtoreg,memw,alusrc,immsrc,regw,regsrc,aluop} = control; // concatination for changing output of module
  always @*
  if(aluop)begin
  case(funct[4:1])
    4'd4 :  alucontrol=0;   //add
    4'd2 :  alucontrol=1;   //sub
    4'd0 :  alucontrol=2;   //and
    4'd12:  alucontrol=3;   //or
    4'd10:  alucontrol=1;   //subtract for CMP instruction
    default:alucontrol=2'bxx;
  endcase
   flagw[1]=funct[0];        //s=1 update all flags
   flagw[0] = funct[0] & (alucontrol == 0 | alucontrol == 1);     //update c&v only while sub and add
  end
else begin          //no alu operation
   flagw=0;
   alucontrol=0; 
 end   
 assign pcs =((rd == 15) & regw) | branch ;        //if write to pc register or branching instruction
 assign nowrite = (funct[4:1]==10);       
endmodule

module conditional_logic(input clk,input reset,input [3:0] cond,input [3:0]aluflags,input [1:0] flagw ,input pcs,
                          input wire regsw,input memw,input nowrite,output reg condex,
                          output wire PCSrc,output wire RegWrite ,output wire MemWrite);
            wire [3:0] flags;                 //current flags
            wire n,z,c,v;
            wire [1:0]flagwrite; 
			assign flagwrite= flagw & {2{condex}};       
            flip_flop  f1 (clk,reset,flagwrite[0],aluflags[1:0],flags[1:0]);
            flip_flop  f2 (clk,reset,flagwrite[1],aluflags[3:2],flags[3:2]); 
            assign {n,z,c,v} = flags; 
            always@(*)
                case(cond)
                    4'b0000:  condex=z;    //EQ        equal
                    4'b0001:  condex=~z;   //NE        not equal
                    4'b0010:  condex=c;    //CS/HS     a>b or the same
                    4'b0011:  condex=~c;   //CC/LO     a<c the same unsigned
                    4'b0100:  condex=n;    //MI        negative
                    4'b0101:  condex=~n;   //PL        positive or zero
                    4'b0110:  condex=v;    //VS        overflow
                    4'b0111:  condex=~v;    //VC        no overflow
                    4'b1000:  condex= ~z & c; //HI      a>b  
                    4'b1001:  condex= ~c | z; //ls      a<b or same
                    4'b1010:  condex=~(n^v);  //GE      a>b signed or equal
                    4'b1011:  condex=n^v;     //LT      a<b signed
                    4'b1100:  condex=~z & ~(n ^ v);  //GT      a>b signed or equal
                    4'b1101:  condex=~z & ~(n ^ v);     //a>b signed
                    4'b1110:  condex=1'b1;             //non conditional
                    default:  condex=1'bx;
                endcase  
                assign PCSrc = pcs & condex; 
                assign RegWrite = regsw & condex & (~ nowrite); 
                assign MemWrite = memw & condex;  
                
          endmodule

module flip_flop(input clk,input reset,input en,input [1:0] d,output reg [1:0] q);
    always @(posedge clk) begin
    if(reset) q<=0;
    else begin
		if(en) q <= d;
		end
	end
endmodule

module control_unit(input Clk,input reset,input [3:0] Cond,input [1:0] Op,input [5:0] Funct,input [3:0] Rd,input [3:0]ALUFlags,
                output wire PCSrc,output wire MemtoReg,output wire MemWrite,output wire [1:0]ALUControl,
                output wire ALUSrc,output wire [1:0]ImmSrc,output wire RegWrite,output wire [1:0]RegSrc);
      wire [1:0]Flagw;
      wire PCS,RegW,MemW;
      wire nowrite;
      wire condex;
      decoder d1(Op,Funct,Rd,Flagw,PCS,RegW,MemW,MemtoReg,ALUSrc,ImmSrc,RegSrc,ALUControl,nowrite);
      conditional_logic c1(Clk,reset,Cond,ALUFlags,Flagw,PCS,RegW,MemW,nowrite,condex,PCSrc,RegWrite,MemWrite);
endmodule