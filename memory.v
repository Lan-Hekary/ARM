 
 //instruction memory block
 
module memory(input [31:0] A,output reg [31:0] RD);
reg [31:0]mem[0:31];
integer i;
initial begin
	for(i=0;i<31;i=i+1)
    mem[i]={32{1'b0}};
	$readmemh("inst.txt",mem);
end

always@(A) begin
	RD = mem[A[31:2]];
	end
endmodule

/*
        module rominfr (clk, en, addr, data);
        input       clk;
        input       en;
        input [4:0] addr;
        output reg [3:0] data;
 always @(posedge clk) 
        begin
           if (en)
              case(addr)
                 4’b0000: data <= 4’b0010;
                 4’b0001: data <= 4’b0010;
                 4’b0010: data <= 4’b1110;
                 4’b0011: data <= 4’b0010;
                 4’b0100: data <= 4’b0100;
                 4’b0101: data <= 4’b1010;
                 4’b0110: data <= 4’b1100;
                 4’b0111: data <= 4’b0000;
                 4’b1000: data <= 4’b1010;
                 4’b1001: data <= 4’b0010;
                 4’b1010: data <= 4’b1110;
                 4’b1011: data <= 4’b0010;
                 4’b1100: data <= 4’b0100;
                 4’b1101: data <= 4’b1010;
                 4’b1110: data <= 4’b1100;
                 4’b1111: data <= 4’b0000;
                 default: data <= 4’bXXXX;
              endcase
        end
        endmodule
*/

module datamem
(input [31:0] A,
input [31:0] WD,
input  WE,
output [31:0] RD,
input  clk);

reg [31:0] mem [0:31];
/*
  integer i;
  //integer file_id;
  initial begin
	for(i=0;i<128;i=i+1)
    mem[i]={32{1'b0}};
  //file_id = $fopen("dump.txt");
  end
*/

assign RD = mem[A[6:2]];
always @(posedge clk) begin
if(WE)begin
mem[A[6:2]] <= WD;
	//$display("Hello");
	//$display("%d %b  >>  %d %b\n",A,A,WD,WD);
end
end
endmodule

/*
// DATA memory block
module memory (clock, wr, A, data);
input clock, wr, rd;
input [31:0] A;
inout [7:0] data;
reg [31:0] mem [0:255];
always @(posedge clock)
if (wr)
mem[addr] = data;
assign data = rd ? mem[addr]: 8'bZ;
endmodule
*/
/*
module DataMem(A,RD,WD,WE,Clk);
  parameter Width = 32,
            Depth = 256;
  input [Width-1:0] A;
  input [Width-1:0] WD;
  input WE,Clk;
  output [Width-1:0]RD;
  
  reg [Width-1:0] Data [0:Depth-1];
  
  //        Self Generate Zeros
  integer i;
  integer file_id;
  initial begin
  for(i=0;i<Depth;i=i+1)
    Data[i]={Width{1'b0}};
  file_id = $fopen("dump.txt");
  end

  
  
         Read From File
  initial
  $readmemb("DataMemory.txt", Data);
  
  
  
  assign RD = (A[31:2]<Depth) ? Data[A[31:2]]: {Width{1'bz}};
  //assign RD = (A<Depth) ? Data[A]: {Width{1'bz}};
  
  always @ (posedge Clk) begin
    if(WE)
      begin
        Data[A[31:2]]=WD;
        $fwrite(file_id,"%d %b  >>  %d %b\n",A,A,WD,WD);
      end
  end
  
endmodule
*/
