module Sha256_roundfnc(
  input [31:0]a,b,c,d,e,f,g,h,//present hash variables
  input [31:0]kt,//current round constant
  input [31:0]wt,//current message word  
  output [31:0]a1,b1,c1,d1,e1,f1,g1,h1//to update the hash value 
);
  //function for the sigma0 
  function[31:0]sigma0(input[31:0]x);
    sigma0=(x>>2|x<<30)^(x>>13|x<<19)^(x>>22|x<<10);
  endfunction 
  //function for the sigma1 
  function[31:0]sigma1(input[31:0]x);
    sigma1=(x>>6|x<<26)^(x>>11|x<<21)^(x>>25|x<<7);
  endfunction 
  //function for the cha value 
  function[31:0]cha(input[31:0]x,y,z);
    cha=(x&y)^(~x&z);
  endfunction 
  //fumction for the maj value 
  function [31:0]maj(input [31:0]x,y,z);
    maj=(x&y)^(x&z)^(y&z);
  endfunction 
  
  wire[31:0]temp1,temp2;
  assign temp1 = h+sigma1(e)+cha(e,f,g)+kt+wt;
  assign temp2 = sigma0(a)+maj(a,b,c);
  
  //updatig the hash variable for the next round 
  assign a1=temp1+temp2;
  assign b1=a;
  assign c1=b;
  assign d1=c;
  assign e1=d+temp1;
  assign f1=e;
  assign g1=f;
  assign h1=g;
endmodule 