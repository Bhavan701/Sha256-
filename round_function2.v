module Sha256_roundfnc2 #(parameter cycle=0,//current cycle i.e 0-9
                          parameter round=7//the number of rounds in one cycle 
                         )(input [31:0]a,b,c,d,e,f,g,h, 
                           input [31:0]w[0:63],//message array of 64 words
                           input [31:0]k[0:63],// round constant of 64 words 
                           output [31:0]a1,b1,c1,d1,e1,f1,g1,h1
                          );
  //To caluclate the starting index of the stage  
  localparam index = (cycle<4)?cycle*7:28+(cycle-4)*6;
  // acts like the wire that stores the 8 hash values of different rounds 
  wire [31:0] a2[0:round];
  wire [31:0] b2[0:round];
  wire [31:0] c2[0:round];
  wire [31:0] d2[0:round];
  wire [31:0] e2[0:round];
  wire [31:0] f2[0:round];
  wire [31:0] g2[0:round];
  wire [31:0] h2[0:round];
  //initializing 
  assign a2[0]=a;
  assign b2[0]=b;
  assign c2[0]=c;
  assign d2[0]=d;
  assign e2[0]=e;
  assign f2[0]=f;
  assign g2[0]=g;
  assign h2[0]=h;
  //to make rounds per cycle 
  genvar i;
  generate 
    for(i=0;i<round;i=i+1)
      begin
     Sha256_roundfnc rou(
    .a(a2[i]),.b(b2[i]),.c(c2[i]),.d(d2[i]),.e(e2[i]),.f(f2[i]),.g(g2[i]),.h(h2[i]),
    .kt(k[index+i]), .wt(w[index+i]),
    .a1(a2[i+1]),.b1(b2[i+1]),.c1(c2[i+1]),.d1(d2[i+1]),
    .e1(e2[i+1]),.f1(f2[i+1]),.g1(g2[i+1]),.h1(h2[i+1])
);
      end 
  endgenerate 
  //output i.e updated 8 hash values after all the rounds in the stage completed 
  assign a1 = a2[round];
  assign b1 = b2[round];
  assign c1 = c2[round];
  assign d1 = d2[round];
  assign e1 = e2[round];
  assign f1 = f2[round];
  assign g1 = g2[round];
  assign h1 = h2[round];
endmodule 