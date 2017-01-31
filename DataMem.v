/*
A >> Address
RD >> Read Bus
WD >> Write Bus
WE >> Write Enable before the Clock
Clk >> to Perform Write only if WE is High 
*/
module DataMem(A,RD,WD,WE,Clk);
  parameter Width = 32,
            Depth = 128;
  input [Width-1:0] A;
  input [Width-1:0] WD;
  input WE,Clk;
  output [Width-1:0]RD;
  
  reg [Width-1:0] Data [0:Depth-1];
  
  //        Self Generate Zeros
  integer i;
  //integer file_id;
  initial begin
  for(i=0;i<Depth;i=i+1)
    Data[i]={Width{1'b0}};
  //file_id = $fopen("dump.txt");
  end

  
  
  /*        Read From File
  initial
  $readmemb("DataMemory.txt", Data);
  */
  
  
  assign RD = (A[31:2]<Depth) ? Data[A[31:2]]: {Width{1'bz}};
  //assign RD = (A<Depth) ? Data[A]: {Width{1'bz}};
  
  always @ (posedge Clk) begin
    if(WE)
      begin
        Data[A[31:2]]=WD;
        //$fwrite(file_id,"%d %b  >>  %d %b\n",A,A,WD,WD);
      end
  end
  
endmodule
/*
module DataMem_TB();
  reg [31:0] A;
  reg [31:0] WD;
  reg WE,Clk;
  wire [31:0]RD;
  
  DataMem #(8,8) inst(A,RD,WD,WE,Clk);
  
  
  initial
  begin
    Clk=0;WE=1;A=32'b0;WD=32'b1;
    #1
    repeat(255)begin
    #10  A = A + 32'b1; WD = WD + 32'b1;
    end
    #5 A=32'b0;
    
  end
  
  always
    #5 Clk=~Clk;
endmodule
*/