`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:11:32 PM
// Design Name: 
// Module Name: UART_Rx
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


module UART_Rx #(
    parameter DATA_WIDTH = 8 , 
    parameter BAUD_RATE = 9600 , 
    parameter CLOCK_FREQUENCY = 50_000_000 , 
    parameter ADDR = 32 
)
(
    input                                   Clk , 
    input                                   nRst , 
    input                                   Rx , 
    output reg [ DATA_WIDTH-1 : 0 ]         Data_Out ,
    output reg                              Data_Ready , 
    output reg                              Err , 
    output reg [ ADDR-1 : 0 ]               wADDR 
    );
localparam BAUD_TICK = CLOCK_FREQUENCY / BAUD_RATE ;

localparam IDLE = 2'b00 ;
localparam START = 2'b01 ;
localparam DATA = 2'b10 ;
localparam STOP = 2'b11 ;
  
reg [15 : 0 ]                       baud_counter ; 
reg [ 3 : 0 ]                       bit_count ; 
reg [ DATA_WIDTH-1 : 0 ]            shift_reg ; 
reg [ 1 : 0 ]                       current_state ;
reg [ 1 : 0 ]                       next_state ; 

always @( posedge Clk or negedge nRst ) begin 

    if (!nRst) begin 
        current_state <= IDLE ;
    end else begin  
        current_state <= next_state ;
    end 
end           
always @( posedge Clk or negedge nRst )begin
    
    if(!nRst) begin 
        baud_counter <= 0 ; 
        bit_count <= 0 ; 
        shift_reg <= 0 ; 
        Data_Ready <= 0 ; 
        Err <= 0 ; 
        Data_Out <= 0 ; 
        next_state <= IDLE ;
        wADDR <= -1 ;  
    end 
    else begin
        case (current_state)  

            /*
            * IDLE Mode needs for every cycle of Recieving
            * shift register has to be clean up , if we don't 
            * we could have some bits of rececnt transfers
            */
            IDLE : begin 
                Data_Ready <= 0 ; 
                baud_counter <= 0 ;
                shift_reg <= 0 ;
                if(!Rx)
                    next_state <= START ; 
            end 
            START : begin 
                if ( baud_counter == BAUD_TICK/2 )begin
                    baud_counter <= 0 ;
                    next_state <= DATA ; 
                    Err <= 0 ; 
                end else begin
                    baud_counter = baud_counter + 1 ;  
                end 
            end 
            DATA : begin 
                if (baud_counter == BAUD_TICK) begin
                    shift_reg[bit_count] <= Rx ;        // Receiving data from Rx and store them into shift reg 
                    bit_count = bit_count + 1 ;         // every time we receive data we have to add '1' to the bit counter  
                    baud_counter = 0 ;                  // rst baud counter 
                end else begin
                    baud_counter = baud_counter + 1 ; 
                end 
                if ( bit_count == DATA_WIDTH ) begin    // ending sampling data 
                    next_state <= STOP ;                // changing state 
                    bit_count = 0 ;                     // reset bit count for next sampling cycle 
                end 
            end 
            STOP : begin 
            if ( baud_counter == BAUD_TICK/2 )begin
                if (Rx) begin                            /* if our baud rates matchs at the end of every sampling cycle we have to 
                                                            send stop bit otherwise our baud rate mismatches */
                    Data_Out <= shift_reg ; 
                    Data_Ready <= 1 ; 
                    next_state <= IDLE ;
                    if( wADDR < 32 ) begin 
                        wADDR <= wADDR + 4 ; 
                    end else begin 
                        wADDR <= 0 ;
                    end 
                end else begin 
                    Err <= 1 ; 
                    next_state <= IDLE ;            /* Stop bit Needs for matched BAUD_RATES */  
                end 
                end else begin 
                    baud_counter = baud_counter + 1 ;
                end 
            end
            default : begin 
                next_state <= IDLE ; 
            end 
        endcase 
    end 
end                   
    
endmodule
