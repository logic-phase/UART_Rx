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
                    shift_reg[bit_count] <= Rx ;        // @ 58 mins of session 3-4 Zivarian implemented this section in another type with concatanation {,}
                    bit_count = bit_count + 1 ;
                    baud_counter = 0 ; 
                end else begin
                    baud_counter = baud_counter + 1 ; 
                end 
                if ( bit_count == DATA_WIDTH ) begin
                    next_state <= STOP ;  
                    bit_count = 0 ;
                end 
            end 
            STOP : begin 
            if ( baud_counter == BAUD_TICK/2 )begin
                if (Rx) begin
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
                    next_state <= IDLE ;            /* I left the coding @ this section 
                                                    Question : why if Rx isn't 1 we have Err ? is this our coding ? */  
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
