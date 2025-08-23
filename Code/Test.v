// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module test_Sha256;
  //Uppercase 
   `define A 8'h41 `define B 8'h42 `define C 8'h43 `define D 8'h44 `define E 8'h45 `define F 8'h46 `define G 8'h47 `define H 8'h48 `define I 8'h49 `define J 8'h4A `define K 8'h4B `define L 8'h4C `define M 8'h4D `define N 8'h4E `define O 8'h4F `define P 8'h50 `define Q 8'h51 `define R 8'h52 `define S 8'h53 `define T 8'h54 `define U 8'h55 `define V 8'h56 `define W 8'h57 `define X 8'h58 `define Y 8'h59 `define Z 8'h5A 
  // Lowercase  
  `define a 8'h61 `define b 8'h62 `define c 8'h63 `define d 8'h64 `define e 8'h65 `define f 8'h66 `define g 8'h67 `define h 8'h68 `define i 8'h69 `define j 8'h6A `define k 8'h6B `define l 8'h6C `define m 8'h6D `define n 8'h6E `define o 8'h6F `define p 8'h70 `define q 8'h71 `define r 8'h72 `define s 8'h73 `define t 8'h74 `define u 8'h75 `define v 8'h76 `define w 8'h77 `define x 8'h78 `define y 8'h79 `define z 8'h7A
  //ports 
  reg clk;
  reg rst;
  reg valid_in;
  reg [511:0]data_in;
  wire [255:0]data_out;
  wire valid_out;
  
  //top module instantiation 
  sha256_top co (.clk(clk),.rst(rst),.valid_in(valid_in),.data_in(data_in),.data_out(data_out),.valid_out(valid_out));
  //15Mhz clk 
  always 
    #33.33 clk=~clk;
  initial begin
    clk=0;
    rst=0;
    #100;
    rst=1;
    #100;
    //inputs 
    data_in=512'h0;
    data_in[511:504]=`a;
    data_in[503:496]=`b;
    data_in[495:488]=`c;
    data_in[487:480]=8'h80;//passing 1bit
    data_in[63:0]=64'd24;//message length
    $display ("data_in=%128h",data_in);
    //pulse valid 
    @(posedge clk)valid_in=1;
    @(posedge clk)valid_in=0;
    wait(valid_out);
    $display ("data_out=%064h",data_out);
    #50 $finish;
  end 
endmodule 