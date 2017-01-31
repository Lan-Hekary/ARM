module single_cycle(input clk,input enable,output LED1,output reg LED2,LED3);

reg [32:0] cnt = 0;
reg number=0;
reg start=0;
reg stop=0;
reg reset=0;
wire debug1,debug2;

single_cycle_top sc(number,reset,debug1,debug2);

always @(negedge enable,posedge stop)begin
	if(stop)
		start=0;
	else begin
		if(!enable) 
			start=1;
		else
			start=0;
	end
end

always @(posedge clk)begin
	cnt <= cnt + 1'b1;
end

always @(posedge cnt[21]) begin
	if(!start) begin
		number=0;
		stop=0;
		reset=1;
	end else begin
		reset=0;
		number = ~number;
		if(debug1&&debug2)
			stop=1;
	end
end
always @(debug1, debug2,start) begin
	if(start) begin
		LED2=~debug1;
		LED3=~debug2;
	end
end

assign LED1 = !number;

endmodule 

module single_cycle_tp(input clk,reset,output y,z);
reg [3:0]cnt;
assign y=cnt[2];
assign z=cnt[3];
always@(negedge clk,posedge reset) begin
	if(reset)
	cnt<=0;
	else
	cnt<=cnt+1'b1;
    end
endmodule

module single_cycle_top(clk,reset,debug1,debug2);
    input clk;
	input reset;
	output reg debug1,debug2;
    wire [31:0] instruction,PC;
    wire [31:0] DataAdr,WriteData,ReadData;
    wire Write_Enable;
    memory im(PC,instruction);
    datamem dm(DataAdr,WriteData,Write_Enable,ReadData,clk);
    ARM proc(clk,reset,instruction,ReadData,DataAdr,WriteData,Write_Enable,PC);
	
	always@(negedge clk,posedge reset) begin
	if(reset) begin
		debug1=0;
		debug2=0;
	end else begin
		if((WriteData==8'h00000007)&(DataAdr==8'h00000014))
			debug1=1;
		if((WriteData==8'h00000007)&(DataAdr==8'h0000001A))
			debug2=1;
		end
    end
endmodule