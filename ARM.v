module ARM(input clk,input reset,input [31:0] inst,input [31:0]ReadData,output  [31:0] DataAdr ,
             output [31:0] WriteData,
             output Write_Enable,output reg [31:0] PC);
    wire[3:0] ALUFlags;
    wire PCSrc,MemtoReg,MemWrite;
    wire [1:0]ALUControl;
    wire ALUSrc;
    wire [1:0]ImmSrc;
    wire RegWrite;
    wire [1:0]RegSrc;
    //reg [31:0] PC;
    initial
        PC=32'b0;
    wire [31:0] PCPlus4,PCPlus8,PC_dash;
    assign PCPlus4=PC+4;
    assign PCPlus8=PCPlus4+4;
    wire [31:0] Result;
    assign PC_dash=(PCSrc==1)?Result:PCPlus4;
    always @(posedge clk,posedge reset)begin
		if(reset) 
			PC=32'b0;
		else
        	PC<=PC_dash;
	end

    control_unit Cu(clk,reset,inst[31:28],inst[27:26],inst[25:20],inst[15:12],ALUFlags,PCSrc,
							MemtoReg,MemWrite,
                    ALUControl,ALUSrc,ImmSrc,RegWrite,RegSrc);
    wire [3:0] RA1;
    assign RA1=(RegSrc[0]==1)?4'd15:inst[19:16];
    wire [3:0] RA2;
    assign RA2=(RegSrc[1]==1)? inst[15:12]:inst[3:0];
    wire [3:0] RA3;
    assign RA3=inst[15:12];

    wire [31:0]  ALUResult;
    wire [31:0] RD1,RD2;
    assign DataAdr = ALUResult;
    assign WriteData=RD2;
    assign Result=(MemtoReg==1)?ReadData:ALUResult;

    register_file R_F(clk,RegWrite,RA1,RA2,RA3,Result,PCPlus8,RD1,RD2);
    wire [31:0] SrcA,SrcB,ExtImm;
    assign SrcA=RD1;
    assign SrcB=(ALUSrc==1)?ExtImm:RD2;
    alu2 alu(SrcA,SrcB,ALUControl,ALUResult,ALUFlags);
    extend ex(ImmSrc,inst[23:0],ExtImm);
	assign Write_Enable=MemWrite;
endmodule