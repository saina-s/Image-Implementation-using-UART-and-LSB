module lsb_algorithm #(
    parameter IMG_WIDTH = 100,
    parameter IMG_HEIGHT = 100,
    parameter BYTES_PER_PIXEL = 3,  // RGB
    parameter TOTAL_PIXELS = IMG_WIDTH * IMG_HEIGHT,
    parameter TOTAL_BYTES = TOTAL_PIXELS * BYTES_PER_PIXEL
)(
    input wire clk,
    input wire reset_n,
    
    input wire ready,           // UART data ready signal
    input wire [7:0] data,      // UART received data (secret message)
    
    // Image data input 
    input wire image_valid,     // Image byte valid signal
    input wire [7:0] image_byte_in,
    
    // Embedded image output
    output reg [7:0] image_byte_out,
    output reg finish
);

    reg [15:0] byte_num; 
    reg [2:0] bit_count;
    reg [7:0] secret_byte;
    reg secret_byte_valid;
    reg prev_ready;
    reg dot_found;
    reg embedding_active;

    reg [15:0] uart_bytes_received;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_ready <= 1'b0;
            secret_byte_valid <= 1'b0;
            secret_byte <= 8'h00;
            uart_bytes_received <= 16'h0;
            dot_found <= 1'b0;
        end else begin
            prev_ready <= ready;
            
            // Detect rising edge of ready signal
            if (ready && !prev_ready) begin
                secret_byte <= data;
                secret_byte_valid <= 1'b1;
                uart_bytes_received <= uart_bytes_received + 1;
                
                // Check for (dot) byte
                if (data == 8'h2E) begin // ASCII '.'
                    dot_found <= 1'b1;
                    $display("LSB: Received dot (.), will stop after embedding it");
                end
                
                $display("LSB: Received UART byte 0x%02X ('%c'), total: %d", 
                         data, data, uart_bytes_received + 1);
            end
            
            // Clear secret_byte_valid when we finish embedding current byte
            if (secret_byte_valid && image_valid && bit_count == 3'd7) begin
                secret_byte_valid <= 1'b0;
                $display("LSB: Finished embedding byte 0x%02X", secret_byte);
            end
        end
    end

    // Main LSB logic
    always @(posedge clk or negedge reset_n) begin 
        if (!reset_n) begin
            byte_num <= 16'd0;
            bit_count <= 3'd0;
            image_byte_out <= 8'd0;
            finish <= 1'b0;
            embedding_active <= 1'b0;
        end else begin
            if (byte_num < TOTAL_BYTES && image_valid && !finish) begin
                embedding_active <= 1'b1;
                if (secret_byte_valid) begin
                    image_byte_out <= {image_byte_in[7:1], secret_byte[bit_count]};
                    
                    $display("LSB: Embedding bit %d of byte 0x%02X (bit=%b) into image byte 0x%02X -> 0x%02X", 
                             bit_count, secret_byte, secret_byte[bit_count], 
                             image_byte_in, {image_byte_in[7:1], secret_byte[bit_count]});
                
                    if (bit_count < 3'd7) begin
                        bit_count <= bit_count + 1;
                    end else begin
                        bit_count <= 3'd0;  // Reset for next secret byte
                        
                        if (dot_found) begin
                            finish <= 1'b1;
                            $display("LSB: Embedding complete - dot processed");
                        end
                    end
                end else begin
                    // No secret data available, pass image byte unchanged
                    image_byte_out <= image_byte_in;
                end 
                
                byte_num <= byte_num + 1;
                
            end else if (byte_num >= TOTAL_BYTES) begin
                // Processing complete - end of image
                image_byte_out <= image_byte_in;
                finish <= 1'b1;
                $display("LSB: Embedding complete - end of image reached");
            end else begin
                // Pass when not active
                image_byte_out <= image_byte_in;
            end
        end
    end

endmodule