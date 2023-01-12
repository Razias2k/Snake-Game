`timescale 1ns / 1ps



module snake_parts (
  input [9:0] pixel_row, pixel_column,
  input clk, VGA_clk, apple_eat,
  input BTNU, BTND, BTNL, BTNR, SWRES, SWPAUSE,
  output reg body_on, head_on, collided
);

  wire [9:0] head_size;
  reg [125:0] length;
  reg is_on [299:0];
  reg [9:0] snake_y_motion, snake_y_pos [299:0], snake_x_motion, snake_x_pos [299:0];
  integer a,i,j,k;

  // fix the ball size and horizontal position
  assign head_size = 10'd10;
  
  always @ (posedge VGA_clk) begin
    if (!SWRES) begin
        length = 5'd8;
        for (a = 0; a < 300; a = a + 1) begin
            if (a < length) begin
                is_on[a] = 1;
            end else
                is_on[a] = 0;
        end
     end
     if (apple_eat) begin
        if (length < 300) begin
            is_on[length] = 1;
            length = length + 2;
        end
     end
  end
 
  
  
  //begin snake movement, snake always starts center screen x axis
  
  always @ (posedge clk) begin
    if (!SWRES) begin
        for ( i = 3; i >= 0; i = i - 1) begin
            snake_y_pos[i] = 10'd240;
            snake_x_pos[i] = 10'd50 - (i * 10'd10);
        end 
        snake_x_motion = 10'd3;
        snake_y_motion = 10'd0;  
        collided = 1'b0;      
    end    
   
   //put button inputs here
   
   if (BTNU) begin
        if(snake_y_motion != 10'd3) begin
            snake_x_motion = 10'd0;
            snake_y_motion = -10'd3;
        end
    end
    else if (BTNL) begin
        if(snake_x_motion != 10'd3) begin
            snake_y_motion = 10'd0;
            snake_x_motion = -10'd3;
        end
    end
    else if (BTND) begin
        if(snake_y_motion != -10'd3) begin
            snake_x_motion = 10'd0;
            snake_y_motion = 10'd3;
        end
    end
    else if (BTNR) begin
        if(snake_x_motion != -10'd3) begin
            snake_y_motion = 10'd0;
            snake_x_motion = 10'd3;
        end
    end
   
    
    
    //collision detection, stops snake head when it hits the wall
    if((snake_x_pos[0] <= 10 || snake_x_pos[0] > 625) | ( snake_y_pos[0] <= 10 | snake_y_pos[0] > 465)) begin
        collided = 1'b1;
    end
    
    for (j = 299; j > 0; j = j - 1) begin
        if (is_on[j]) begin
            if((snake_x_pos[0] == snake_x_pos[j]) & (snake_y_pos[0] == snake_y_pos[j])) begin
                collided = 1'b1;
            end
        end
    end
    
    if (!SWPAUSE && !collided) begin
        for (j = 299; j > 0; j = j - 1) begin
            snake_x_pos[j] = snake_x_pos[j-1];
            snake_y_pos[j] = snake_y_pos[j-1];
        end
        snake_y_pos[0] = snake_y_pos[0] + snake_y_motion;
        snake_x_pos[0] = snake_x_pos[0] + snake_x_motion;
    end
  end

  // based on the current pixels and the current position of the ball, determine whether you should show the ball or the background
  always @ (*) begin
    body_on = 1'b0;
    head_on = 1'b0;
    for ( k = 299; k > 0; k = k - 1) begin
        if (is_on[k]) begin
           if ((snake_x_pos[k] <= (pixel_column + head_size)) && (snake_x_pos[k] >= pixel_column) && (snake_y_pos[k] <= (pixel_row + head_size)) && ((snake_y_pos[k]) >= pixel_row)) begin
              body_on = 1'b1;
           end
        end
    end
    if ((snake_x_pos[0] <= (pixel_column + head_size)) && (snake_x_pos[0] >= pixel_column) && (snake_y_pos[0] <= (pixel_row + head_size)) && ((snake_y_pos[0]) >= pixel_row)) begin
          head_on = 1'b1;
    end
  end

endmodule
