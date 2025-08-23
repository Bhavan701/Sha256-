module Sha256_messagescheduler( 
  input [511:0] data_in,//512 bit message
  output reg[2047:0]words//64 words that has each word of 32bits i.e 64*32=2048 bits 
);
  //function for the rotate right
  function [31:0]rotr(input [31:0]x,input integer n);
    rotr =(x>>n)|(x<<(32-n));
  endfunction 
  //function to shift right 
  function [31:0]shiftr(input [31:0]x,input integer n);
    shiftr =(x>>n);
  endfunction 
  //to hold the 2047 bits in 64 words 
  reg[31:0]w[0:63];
  integer i;
  always@(data_in)
    begin
      //Generating the first 16 words of the 64 words
      for(i=0;i<16;i=i+1)
        w[i]=data_in[511-(32*i)-:32];
      //Generating remainig words
      for(i=16;i<64;i=i+1)
        begin
          w[i]=w[i-16]+(rotr(w[i-15],7)^rotr(w[i-15],18)^shiftr(w[i-15],3))+w[i-7]+(rotr(w[i-2],17)^rotr(w[i-2],19)^shiftr(w[i-2],10));
        end 
  //converting the stored 64 words into the vector 
      words=2048'b0;
      for(i=0;i<64;i=i+1)
        words[32*i+:32]=w[i];
    end 
endmodule 