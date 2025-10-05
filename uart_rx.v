`timescale 1ns/1ps

module uart_rx(
    input wire clk,
    input wire reset_n,  

    input wire rx,             
    input wire clk_en,                  

    output reg [7:0] data,     
    output reg ready           
);
   
    parameter oversample_num = 16;   
    localparam sample_point = oversample_num/2;

    parameter idle      = 2'b00;
    parameter start_bit = 2'b01;
    parameter data_bits = 2'b10;
    parameter stop_bit  = 2'b11;


    reg [1:0] state;
    reg [$clog2(oversample_num) - 1 : 0] sample_count;   
    reg [2:0] bit_pos;
    reg [7:0] temp_storage; 
    reg rx_data_sync;
    reg rx_data_prev;   

    // to avoid metastability
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_data_sync <= 1'b1;
            rx_data_prev <= 1'b1;
        end else begin
            rx_data_sync <= rx;
            rx_data_prev <= rx_data_sync;
        end      
    end

    always @(posedge clk or negedge reset_n) begin
        ready <= 1'b0;
        if (!reset_n) begin
            state <= idle;
            sample_count <= 0;
            bit_pos <= 0;
            data <= 8'b0;
            ready <= 1'b0;
            temp_storage <= 8'b0;
        end else begin
            case(state)
            idle: begin
                sample_count <= 0; 
                bit_pos <= 0; 
                temp_storage <= 8'b0;

                if (rx_data_prev == 1'b1 && rx_data_sync == 1'b0) begin
                    state <= start_bit;
                end
            end

            start_bit: begin
                if(clk_en) begin
                    if (sample_count == oversample_num - 1) begin
                        if (rx_data_sync == 1'b0) begin
                            sample_count <= 0;
                            state <= data_bits;                        
                        end else begin 
                            state <= idle;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            end

            data_bits: begin
                if(clk_en) begin
                    if (sample_count == sample_point - 1) begin
                        temp_storage[bit_pos] <= rx_data_sync;
                    end
                    
                    if(sample_count == oversample_num - 1) begin
                        sample_count <= 0;
                        if (bit_pos == 7) begin
                            bit_pos <= 0;
                            state <= stop_bit;
                        end else begin
                            bit_pos <= bit_pos + 1;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            end

            stop_bit: begin
                if(clk_en) begin
                    if (sample_count == oversample_num - 1) begin
                            data <= temp_storage;
                            state <= idle;
                            ready <= 1'b1;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end
            end

            default: begin
                state <= idle;
            end
            endcase
        end
    end

endmodule
