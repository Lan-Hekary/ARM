`define Z 0
`define N 1
`define C 2
`define V 3

module CU(input wire [31:0] instruction, input wire [3:0] flags, input wire clock, 
		  output reg PCSrc/*Done*/, output reg MemToReg/*Done*/, output reg MemWrite/*Done*/,
		  output reg [1:0] ALUControl/*Done*/, output reg ALUSrc/*Done*/, output reg [1:0] ImmSrc/*Done*/, 
		  output reg RegWrite/*Done*/, output reg NoWrite /*Done*/);
	reg [3:0] interalflags;
	reg exec;
	always @* begin
		//check cond
		exec = 0;
		case (instruction[31:28])
			4'b0000: if(interalflags[`Z]) exec  = 1;
			4'b0001: if(~interalflags[`Z]) exec = 1;
			4'b0010: if(interalflags[`C]) exec  = 1;
			4'b0011: if(~interalflags[`C]) exec = 1;
			4'b0100: if(interalflags[`N]) exec  = 1;
			4'b0101: if(~interalflags[`N]) exec = 1;
			4'b0110: if(interalflags[`V]) exec  = 1;
			4'b0111: if(~interalflags[`V]) exec = 1;
			4'b1000: if(~interalflags[`Z] & interalflags[`C]) exec   = 1;
			4'b1001: if(interalflags[`Z] | ~interalflags[`C]) exec   = 1;
			4'b1010: if(~(interalflags[`N] ^ interalflags[`V])) exec = 1;
			4'b1011: if(interalflags[`N] ^ interalflags[`V]) exec    = 1;
			4'b1100: if(~interalflags[`Z] & ~(interalflags[`N] ^ interalflags[`V])) exec = 1;
			4'b1101: if(interalflags[`Z] | (interalflags[`N] ^ interalflags[`V])) exec   = 1;
			4'b1110: exec = 1;
			4'b1111: exec = 1'bx;
		endcase

		NoWrite = 0;
		ALUControl = 0;
		ALUSrc = 1;
		MemToReg = 0;
		MemWrite = 0;
		RegWrite = 0;
		case (instruction[27:26])
			2'b00: begin
				if (exec) begin
					RegWrite = 1;
				end
				if (instruction[25]) begin
					ImmSrc = 0;
				end else begin
					ALUSrc = 0;
					ImmSrc = 2'bxx;
				end
				case(instruction[24:21])
					4'b0100: ALUControl = 0;
					4'b0010: ALUControl = 1;
					4'b0000: ALUControl = 2;
					4'b1100: ALUControl = 3;
					4'b1010: begin 
						ALUControl = 1;
						NoWrite = 1;
					end
					default : ALUControl = 2'bxx;
				endcase
				if ((instruction[15:12] == 4'b1111) && RegWrite && exec) 
					PCSrc = 1;
				else
					PCSrc = 0;
			end
			2'b01: begin
				if(instruction[20])
					MemToReg = 1;
					if(exec)
						RegWrite = 1;
				else begin
					MemToReg = 1'bx;
					if(exec)
						MemWrite = 1;
				end
				ImmSrc = 1;
				if ((instruction[15:12] == 4'b1111) && RegWrite && exec) 
					PCSrc = 1;
				else
					PCSrc = 0;
			end
			2'b10: begin
				ImmSrc = 2;
				RegWrite = 0;
				if (exec)
					PCSrc = 1;
				else
					PCSrc = 0;
			end
			default: begin
				PCSrc = 1'bx;
				MemToReg = 1'bx;
				MemWrite = 1'bx;
				ALUControl = 2'bxx;
				ALUSrc = 1'bx;
				ImmSrc = 2'bxx;
				RegWrite = 1'bx;
				NoWrite = 1'bx;
			end
		endcase
	end

	always @(posedge clock)
		//if((instruction[27:26] == 2'b0) && (instruction[20]))
		if(!(|instruction[27:26]) & (instruction[20]))
			interalflags = flags;
		
endmodule