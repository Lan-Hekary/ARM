`define BUSWIDTH 32

module shifter(input wire /*signed*/ [`BUSWIDTH - 1:0] a, input wire [6:0] shift, 
               output reg [`BUSWIDTH - 1:0] b);

	always @* begin
		reg [2 * `BUSWIDTH - 1:0] c;
		case(shift[1:0])
			2'b00: b = a << shift[6:2];
			2'b01: b = a >> shift[6:2];
			//2'b10: begin c = {{`BUSWIDTH{a[31]}}, a}; b = c >> shift[6:2]; end
			2'b10: b = {{`BUSWIDTH{a[31]}}, a} >> shift[6:2];	//More straightforward
			//2'b10: b = a >>> shift[6:2];
			//2'b11: begin c = {a, a}; b = c >> shift[6:2]; end
			//2'b11: b = (a << shift[6:2]) | (a >> (~shift[6:2] + 1));
			2'b11: b = {a, a} >> (shift[6:2]); //Internet trick
			//default: begin if(!shift[0]) c = {a, a}; else c = {{`BUSWIDTH{a[31]}}, a}; b = c >> shift[6:2]; end
		endcase
	end
endmodule
