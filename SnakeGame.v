`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module SnakeGame (
  input CLK100MHZ,
  input [3:0] BTN,
  input [2:0] SW,
  output [3:0] VGA_RED, VGA_GREEN, VGA_BLUE,
  output VGA_HS, VGA_VS
);
  
  wire [9:0] pixel_row_int, pixel_col_int;
  wire red_data, green_data, blue_data, vga_red_int, vga_green_int, vga_blue_int, video_blank_int, video_clock_int, v_sync_int, h_sync_int, clk25M;
  wire border_on_top, apple_on_top, body_on, head_on;
  wire apple_update;
  wire [9:0] rand_x, rand_y;
  reg moveSnake;
  reg apple_eat = 0;
  reg [25:0] counter = 0;
  // generate 25 MHz clock from board oscillator
  ip_clk_gen clk_25M_gen (
    .clk_out1(clk_25M),
    .clk_in1(CLK100MHZ)
  );

  // instantiate the vga_sync module to control the VGA protocol
  vga_sync vga_sync_inst (
    .clock_25mhz(clk_25M),
    .red(red_data),
    .green(green_data),
    .blue(blue_data),
    .red_out(vga_red_int),
    .green_out(vga_green_int),
    .blue_out(vga_blue_int),
    .horiz_sync_out(h_sync_int),
    .vert_sync_out(v_sync_int),
    .pixel_row(pixel_row_int),
    .pixel_col(pixel_col_int)
  );

  assign VGA_VS = v_sync_int;
  assign VGA_HS = h_sync_int;
  assign VGA_RED = {4{vga_red_int}};
  assign VGA_GREEN = {4{vga_green_int}};
  assign VGA_BLUE = {4{vga_blue_int}};
  
 
  border border_inst (
  .pixel_row(pixel_row_int),
  .pixel_col(pixel_col_int),
  .border_on(border_on_top)
  );
  
  apple apple_inst (
    .pixel_row(pixel_row_int),
    .pixel_column(pixel_col_int),
    .x_clock(CLK100MHZ),
    .y_clock(clk_25M),
    .vert_sync(v_sync_int),
    .apple_eat(apple_eat),
    .is_apple(apple_on_top)
  );
  
  always @ (clk_25M) begin
    apple_eat <= (head_on & apple_on_top);
  end
  
    snake_parts parts_inst (
    .pixel_row(pixel_row_int),
    .pixel_column(pixel_col_int),
    .clk(v_sync_int),
    .VGA_clk(clk_25M),
    .apple_eat(apple_eat),
    .SWRES(SW[0]),
    .SWPAUSE(SW[1]),
    .BTNU(BTN[0]),
    .BTNL(BTN[1]),
    .BTNR(BTN[2]),
    .BTND(BTN[3]),
    .body_on(body_on),
    .head_on(head_on),
    .collided(collided)
  );
  
  
  
  //color stuff, screen goes red when collision is detected, apple red, border blue, snake head and body are green
  
  assign red_data = ~SW[0] ? 4'b0000 : (collided | apple_on_top) ? 4'b1111 : 4'b0000;
  assign blue_data = (~SW[0] | collided) ? 4'b0000 : border_on_top ? 4'b1111 : 4'b0000;
  assign green_data = (~SW[0] | collided) ? 4'b0000 : (head_on | body_on) ? 4'b1111 : 4'b0000;
  
  
  
  

endmodule
