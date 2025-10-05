`timescale 1ns / 1ps

module baudrate (
    input wire clk,
    input wire reset_n, //active_low
    output reg clk_enable //clock enable pulse at 16x baud --> 16 times oversampling
);
    parameter clk_freq = 50_000_000; 
    parameter baud_rate = 9600;
    parameter oversample_num = 16;
    
    //since 50_000_000 / (9600 * 16) = 325.52, 0.52 is a small error that should be ignored
    localparam limit = clk_freq / (baud_rate * oversample_num) - 1 ;

    reg [$clog2(limit + 1) - 1 : 0] baud_clk_counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            baud_clk_counter <= 0;
            clk_enable <= 1'b0;
        end else begin
            if (baud_clk_counter == limit) begin
                baud_clk_counter <= 0;
                clk_enable <= 1'b1;
            end else begin
                baud_clk_counter <= baud_clk_counter + 1;
                clk_enable <= 1'b0;
            end
        end     
    end
    
endmodule