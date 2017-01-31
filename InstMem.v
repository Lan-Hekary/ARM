/*
A >> Address
RD >> Read Bus
*/
module InstMem(A,RD);
  parameter Width = 32,
            Depth = 256;
  input [7:0] A;
  output [Width-1:0]RD;
  
  reg [Width-1:0] Data [0:Depth-1];
  
  /*        Self Generate Zeros
  integer i;
  initial
  for(i=0;i<Depth;i=i+1)
    Data[i]={Width{1'b0}};
  */
  
  //        Read From File
  initial
  $readmemh("InstructionMemory.txt", Data);
  
  
  assign RD = (A<Depth) ? Data[A]: {Width{1'bz}};
  
endmodule