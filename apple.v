`timescale 1ns / 1ps

module apple (
input x_clock, y_clock,
  input [9:0] pixel_row, pixel_column,
  input vert_sync, apple_eat,
  output reg is_apple
);
    reg [9:0] rand_x, rand_y;
    
    //starting location of apple
    reg [9:0] apple_x = 10'd400, apple_y = 10'd300;
    
    always @ (posedge x_clock) begin
        if (rand_x < 620) begin
            rand_x = rand_x + 10;
        end else begin
            rand_x = 20;
        end
    end
    
    always @ (posedge y_clock) begin
        if (rand_y < 460) begin
            rand_y = rand_y + 10;
        end else begin
            rand_y = 20;
        end
    end
    
    
    //logic to (hopefully) produce random apple upon consumption
    always @ (posedge y_clock) begin
        if (apple_eat) begin
            apple_x <= rand_x;
            apple_y <= rand_y;
        end
    end
    
    always @ (*) begin   
        is_apple <= ((apple_x <= (pixel_column + 8)) && (apple_x >= pixel_column) && (apple_y <= (pixel_row + 8)) && ((apple_y) >= pixel_row));
	end
	
endmodule
