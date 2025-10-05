`timescale 1ns/1ps

module lsb_top_vivado #(
    parameter IMG_WIDTH = 100,
    parameter IMG_HEIGHT = 100,
    parameter BYTES_PER_PIXEL = 3,
    parameter TOTAL_PIXELS = IMG_WIDTH * IMG_HEIGHT,
    parameter TOTAL_BYTES = TOTAL_PIXELS * BYTES_PER_PIXEL,
    parameter clk_freq = 50_000_000,
    parameter baud_rate = 9600
)(
    input wire clk,
    input wire reset_n,
    
    // for secret data
    input wire uart_rx,
    
    // Image data 
    input wire [7:0] image_byte_in,
    input wire image_byte_valid,
    
    // Output 
    output wire [7:0] embedded_byte_out,
    output wire processing_done,
    
    // signals for debugging
    output wire uart_ready,
    output wire [7:0] uart_data,
    //output wire uart_read,
    output wire [15:0] bytes_processed
);

    // Internal signals
    wire clk_enable;
    wire finish;

    // Instantiate baud rate generator
    baudrate #(
        .clk_freq(clk_freq),
        .baud_rate(baud_rate)
    ) baud_gen (
        .clk(clk),
        .reset_n(reset_n),
        .clk_enable(clk_enable)
    );

    // Instantiate UART receiver for secret data
    uart_rx uart_receiver (
        .clk(clk),
        .reset_n(reset_n),
        .rx(uart_rx),
        .clk_en(clk_enable),
        //.read(uart_read_internal),  // Connect to internal signal
        .data(uart_data),
        .ready(uart_ready)
    );

    // Instantiate LSB algorithm
    lsb_algorithm #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT),
        .BYTES_PER_PIXEL(BYTES_PER_PIXEL)
    ) lsb_embedder (
        .clk(clk),
        .reset_n(reset_n),
        .ready(uart_ready),
        .data(uart_data),
        .image_valid(image_byte_valid),
        .image_byte_in(image_byte_in),
        .image_byte_out(embedded_byte_out),
        .finish(finish)
    );

    assign processing_done = finish;
    assign bytes_processed = lsb_embedder.byte_num;

endmodule