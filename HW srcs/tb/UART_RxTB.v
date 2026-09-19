`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 02:42:26 PM
// Design Name: 
// Module Name: UART_RxTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_RxTB ();

reg                 Clk ; 
reg                 nRst ;
reg                 Rx ; 
wire    [31 : 0]    wADDR;
wire    [7 : 0]     Data_Out ; 
wire                Data_Ready ; 
wire                Err ;

//reading from file and save them into Data 

reg     [7 : 0]     Data ; 

//creating a constant DELAY for data transfering to consider BAUD_RATE

localparam DELAY = 104166; //      1/9600 ns  

/*

initial begin
    nRst=0;
    #200
    nRst=1;
end

initial begin
    Clk=0;
    forever #10 Clk=~Clk;
end


initial begin
    Rx=1;    // IDLE
    #(DELAY*10)
    file=$fopen("data.txt","r");
        if(file==0)begin
            $display("Error:Could not open file!");
            $finish;
        end
        while(!$feof(file))begin
            status=$fscanf(file,"%d\n",Data);
            #DELAY
            Rx=0;          // START BIT
            for(i=0;i<8;i=i+1)begin
               #DELAY
               Rx <= Data[i];
            end
            #DELAY
            Rx=1;        //STOP BIT
        end
    $fclose(file);
    #DELAY
    $finish;
end
*/

integer file ; 
integer status ; 
integer i ;


initial begin 
    nRst = 0 ; 
    #200
    nRst = 1 ; 
end 

initial begin 
    Clk = 0 ; 
    forever #10 
    Clk = ~Clk ;
end 
 
/*
    assign data to Rx port
*/

initial begin 
    Rx = 1 ;                // creating IDLE mode
    #(DELAY*10);
    
    file = $fopen("data.txt","r");
    if (!file)begin 
        $display("ERROR : Couldn't Open Data file!");
        $finish ;
    end else begin 
        while(!$feof(file))begin
            status = $fscanf(file,"%d\n",Data);
            #(DELAY) ;
            Rx = 0 ;                //START BIT
            for(i = 0 ; i < 8 ; i = i + 1)begin                
                #(DELAY); 
                Rx <= Data[i];   
                
            end 
            #(DELAY);
            Rx = 1 ; //STOP Bit 
            
            
        end 
    end 
    $fclose(file);
    #(DELAY);
    $finish;
end 

UART_Rx UART_RxUT(
    .Clk(Clk) ,  
    .nRst(nRst) , 
    .Rx(Rx) ,
    .Data_Out(Data_Out) ,
    .Data_Ready(Data_Ready) , 
    .Err(Err) ,
    .wADDR(wADDR)

);

endmodule
