// Code your design here
`include "sha256_msgsched.v"
`include "sha256_consts.v"
`include "sha256_round.v"
`include "sha256_multiround.v"

// Top-level SHA-256 debug wrapper with per-stage output printing

module sha256_top_debug (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,       // Pulse indicating new 512-bit input block
    input  wire [511:0] block_in,      // Input message block (512 bits)
    output wire [255:0] digest_out,    // Final 256-bit SHA-256 hash output
    output wire        valid_out       // Output valid signal after pipeline latency
);

    localparam STAGES = 10;

    // Valid signal pipeline to track input validity through stages
    reg [STAGES-1:0] valid_pipe;

    // Pipeline registers for SHA-256 state variables (a..h)
    reg [31:0] a_pipe [0:STAGES];
    reg [31:0] b_pipe [0:STAGES];
    reg [31:0] c_pipe [0:STAGES];
    reg [31:0] d_pipe [0:STAGES];
    reg [31:0] e_pipe [0:STAGES];
    reg [31:0] f_pipe [0:STAGES];
    reg [31:0] g_pipe [0:STAGES];
    reg [31:0] h_pipe [0:STAGES];

    // Message schedule packed output
    wire [2047:0] W_flat;

    // Instantiate simplified message scheduler (without clk or debug pins)
    sha256_msgsched msgsched (
        .block_in(block_in),
        .W_flat(W_flat)
    );

    // Unpack message schedule into an array
    wire [31:0] W_wire [0:63];
    genvar gi;
    generate
        for (gi = 0; gi < 64; gi = gi + 1) begin : UNPACK_W
            assign W_wire[63 - gi] = W_flat[(2047 - 32 * gi) -: 32];
        end
    endgenerate

    // Round constants array
    wire [31:0] K_arr [0:63];
     assign K_arr[0]  = `K0;  assign K_arr[1]  = `K1;  assign K_arr[2]  = `K2;  assign K_arr[3]  = `K3;
    assign K_arr[4]  = `K4;  assign K_arr[5]  = `K5;  assign K_arr[6]  = `K6;  assign K_arr[7]  = `K7;
    assign K_arr[8]  = `K8;  assign K_arr[9]  = `K9;  assign K_arr[10] = `K10; assign K_arr[11] = `K11;
    assign K_arr[12] = `K12; assign K_arr[13] = `K13; assign K_arr[14] = `K14; assign K_arr[15] = `K15;
    assign K_arr[16] = `K16; assign K_arr[17] = `K17; assign K_arr[18] = `K18; assign K_arr[19] = `K19;
    assign K_arr[20] = `K20; assign K_arr[21] = `K21; assign K_arr[22] = `K22; assign K_arr[23] = `K23;
    assign K_arr[24] = `K24; assign K_arr[25] = `K25; assign K_arr[26] = `K26; assign K_arr[27] = `K27;
    assign K_arr[28] = `K28; assign K_arr[29] = `K29; assign K_arr[30] = `K30; assign K_arr[31] = `K31;
    assign K_arr[32] = `K32; assign K_arr[33] = `K33; assign K_arr[34] = `K34; assign K_arr[35] = `K35;
    assign K_arr[36] = `K36; assign K_arr[37] = `K37; assign K_arr[38] = `K38; assign K_arr[39] = `K39;
    assign K_arr[40] = `K40; assign K_arr[41] = `K41; assign K_arr[42] = `K42; assign K_arr[43] = `K43;
    assign K_arr[44] = `K44; assign K_arr[45] = `K45; assign K_arr[46] = `K46; assign K_arr[47] = `K47;
    assign K_arr[48] = `K48; assign K_arr[49] = `K49; assign K_arr[50] = `K50; assign K_arr[51] = `K51;
    assign K_arr[52] = `K52; assign K_arr[53] = `K53; assign K_arr[54] = `K54; assign K_arr[55] = `K55;
    assign K_arr[56] = `K56; assign K_arr[57] = `K57; assign K_arr[58] = `K58; assign K_arr[59] = `K59;
    assign K_arr[60] = `K60; assign K_arr[61] = `K61; assign K_arr[62] = `K62; assign K_arr[63] = `K63;

    // Outputs from each pipeline stage
    wire [31:0] stage_out_a [0:STAGES-1];
    wire [31:0] stage_out_b [0:STAGES-1];
    wire [31:0] stage_out_c [0:STAGES-1];
    wire [31:0] stage_out_d [0:STAGES-1];
    wire [31:0] stage_out_e [0:STAGES-1];
    wire [31:0] stage_out_f [0:STAGES-1];
    wire [31:0] stage_out_g [0:STAGES-1];
    wire [31:0] stage_out_h [0:STAGES-1];

    // Instantiate pipeline stages
    generate
        genvar si;
        for (si = 0; si < STAGES; si = si + 1) begin : pipeline_stages
            localparam RO = (si < 4) ? 7 : 6;
            sha256_multiround #(.STAGE_NUM(si), .N_ROUNDS(RO)) stage (
                .a_in(a_pipe[si]), .b_in(b_pipe[si]), .c_in(c_pipe[si]), .d_in(d_pipe[si]),
                .e_in(e_pipe[si]), .f_in(f_pipe[si]), .g_in(g_pipe[si]), .h_in(h_pipe[si]),
                .W(W_wire), .K(K_arr),
                .a_out(stage_out_a[si]), .b_out(stage_out_b[si]), .c_out(stage_out_c[si]),
                .d_out(stage_out_d[si]), .e_out(stage_out_e[si]), .f_out(stage_out_f[si]),
                .g_out(stage_out_g[si]), .h_out(stage_out_h[si])
            );
        end
    endgenerate

    // Initial hash values (IVs) as per SHA-256 spec
    reg [31:0] Hreg [0:7];
    initial begin
      Hreg[0] = `H0; Hreg[1] = `H1; Hreg[2] = `H2; Hreg[3] = `H3;
      Hreg[4] = `H4; Hreg[5] = `H5; Hreg[6] = `H6; Hreg[7] = `H7;
    end

    integer j;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_pipe <= 0;
            for (j = 0; j <= STAGES; j = j + 1) begin
                a_pipe[j] <= 32'd0; b_pipe[j] <= 32'd0; c_pipe[j] <= 32'd0; d_pipe[j] <= 32'd0;
                e_pipe[j] <= 32'd0; f_pipe[j] <= 32'd0; g_pipe[j] <= 32'd0; h_pipe[j] <= 32'd0;
            end
        end else begin
            // Shift valid pipeline left and insert valid_in at LSB
            valid_pipe <= {valid_pipe[STAGES-2:0], valid_in};

            // Load initial hash values at pipeline entry on new valid input
            if (valid_in) begin
                a_pipe[0] <= Hreg[0]; b_pipe[0] <= Hreg[1]; c_pipe[0] <= Hreg[2]; d_pipe[0] <= Hreg[3];
                e_pipe[0] <= Hreg[4]; f_pipe[0] <= Hreg[5]; g_pipe[0] <= Hreg[6]; h_pipe[0] <= Hreg[7];
            end

            // Latch pipeline stage outputs into next stage pipeline registers
            for (j = 0; j < STAGES; j = j + 1) begin
                a_pipe[j+1] <= stage_out_a[j];
                b_pipe[j+1] <= stage_out_b[j];
                c_pipe[j+1] <= stage_out_c[j];
                d_pipe[j+1] <= stage_out_d[j];
                e_pipe[j+1] <= stage_out_e[j];
                f_pipe[j+1] <= stage_out_f[j];
                g_pipe[j+1] <= stage_out_g[j];
                h_pipe[j+1] <= stage_out_h[j];

                // Print outputs of each pipeline stage once data is valid
                if (valid_pipe[j]) begin
                    $display("Time %0t: Outputs after stage %0d:", $time, j);
                    $display(" a = %08x", stage_out_a[j]);
                    $display(" b = %08x", stage_out_b[j]);
                    $display(" c = %08x", stage_out_c[j]);
                    $display(" d = %08x", stage_out_d[j]);
                    $display(" e = %08x", stage_out_e[j]);
                    $display(" f = %08x", stage_out_f[j]);
                    $display(" g = %08x", stage_out_g[j]);// Code your design here
`include "constants.vh"
`include "message_scheduler.v"
`include "round_function.v"
`include "round_function2.v"
module sha256_top (input  clk,rst,valid_in,
                         input   [511:0] data_in,      // Input message block (512 bits)
                         output  [255:0] data_out,    // Final 256-bit SHA-256 hash output\
                         output  valid_out       
                         );

    localparam cycle = 10;
  // Valid signal pipeline to track input validity through stages
  reg [cycle-1:0] valid_pipe;
  // Pipeline registers for SHA-256 state variables (a..h)
  reg [31:0] a_pipe [0:cycle];
  reg [31:0] b_pipe [0:cycle];
  reg [31:0] c_pipe [0:cycle];
  reg [31:0] d_pipe [0:cycle];
  reg [31:0] e_pipe [0:cycle];
  reg [31:0] f_pipe [0:cycle];
  reg [31:0] g_pipe [0:cycle];
  reg [31:0] h_pipe [0:cycle];

  // Message schedule packed output
  wire [2047:0] words;
  // Instantiate simplified message scheduler 
  Sha256_messagescheduler msg (.data_in(data_in),.words(words) );
  // Unpack message schedule into an array
  wire [31:0] W_wire [0:63];
  genvar i;
  generate
    for (i = 0; i < 64; i = i + 1) 
      begin
        assign W_wire[i] = words[32 * i+: 32];
      end
  endgenerate
  // Round constants array
  wire [31:0] K [0:63];
  assign K[0]  = `K0;  assign K[1]  = `K1;  assign K[2]  = `K2;  assign K[3]  = `K3;
  assign K[4]  = `K4;  assign K[5]  = `K5;  assign K[6]  = `K6;  assign K[7]  = `K7;
  assign K[8]  = `K8;  assign K[9]  = `K9;  assign K[10] = `K10; assign K[11] = `K11;
  assign K[12] = `K12; assign K[13] = `K13; assign K[14] = `K14; assign K[15] = `K15;
  assign K[16] = `K16; assign K[17] = `K17; assign K[18] = `K18; assign K[19] = `K19;
  assign K[20] = `K20; assign K[21] = `K21; assign K[22] = `K22; assign K[23] = `K23;
  assign K[24] = `K24; assign K[25] = `K25; assign K[26] = `K26; assign K[27] = `K27;
  assign K[28] = `K28; assign K[29] = `K29; assign K[30] = `K30; assign K[31] = `K31;
  assign K[32] = `K32; assign K[33] = `K33; assign K[34] = `K34; assign K[35] = `K35;
  assign K[36] = `K36; assign K[37] = `K37; assign K[38] = `K38; assign K[39] = `K39;
  assign K[40] = `K40; assign K[41] = `K41; assign K[42] = `K42; assign K[43] = `K43;
  assign K[44] = `K44; assign K[45] = `K45; assign K[46] = `K46; assign K[47] = `K47;
  assign K[48] = `K48; assign K[49] = `K49; assign K[50] = `K50; assign K[51] = `K51;
  assign K[52] = `K52; assign K[53] = `K53; assign K[54] = `K54; assign K[55] = `K55;
  assign K[56] = `K56; assign K[57] = `K57; assign K[58] = `K58; assign K[59] = `K59;
  assign K[60] = `K60; assign K[61] = `K61; assign K[62] = `K62; assign K[63] = `K63;
  // output of the each pipeline stages 
  wire [31:0]a_out[0:cycle-1];
  wire [31:0]b_out[0:cycle-1];
  wire [31:0]c_out[0:cycle-1];
  wire [31:0]d_out[0:cycle-1];
  wire [31:0]e_out[0:cycle-1];
  wire [31:0]f_out[0:cycle-1];
  wire [31:0]g_out[0:cycle-1];
  wire [31:0]h_out[0:cycle-1];
  //instantiating the pipe line stages or cycles 
  genvar j;
  generate
    for (j=0;j<cycle;j=j+1)
      begin
        //there are 9 cycles 4 cycles have 7 rounds and rest vae 6 rounds per cycle 
        localparam M = (j<4)?7:6;
        Sha256_roundfnc2 #(.cycle(j), .round(M)) sta (
    .a(a_pipe[j]), .b(b_pipe[j]), .c(c_pipe[j]), 
    .d(d_pipe[j]), .e(e_pipe[j]), .f(f_pipe[j]), 
    .g(g_pipe[j]), .h(h_pipe[j]), 
    .w(W_wire), .k(K), 
    .a1(a_out[j]), .b1(b_out[j]), .c1(c_out[j]), .d1(d_out[j]),
    .e1(e_out[j]), .f1(f_out[j]), .g1(g_out[j]), .h1(h_out[j])
        );
      end 
  endgenerate 
  //initial hash values 
  reg [31:0]Hreg[0:7];
  integer n;
          always@(posedge clk or negedge rst)
            begin
              if(!rst)
                begin
                  valid_pipe=0;
                  Hreg[0]=`H0;Hreg[1]=`H1;Hreg[2]=`H2;Hreg[3]=`H3;Hreg[4]=`H4;Hreg[5]=`H5;Hreg[6]=`H6;Hreg[7]=`H7;
                  for(n=0;n<=cycle;n=n+1)
                    begin
                      a_pipe[n]=32'd0; b_pipe[n]=32'd0; c_pipe[n]=32'd0; d_pipe[n]=32'd0; e_pipe[n]=32'd0; f_pipe[n]=32'd0; g_pipe[n]=32'd0;     
                      h_pipe[n]=32'd0;
                    end 
                end 
              else 
                begin
                  //shifting valid pipeline 
                  valid_pipe = {valid_pipe[cycle-2:0],valid_in};
                  // load the iniial hash values 
                  if (valid_in)
                    begin
                      a_pipe[0]=Hreg[0]; b_pipe[0]=Hreg[1]; c_pipe[0]=Hreg[2]; d_pipe[0]=Hreg[3]; e_pipe[0]=Hreg[4]; f_pipe[0]=Hreg[5];  
                      g_pipe[0]=Hreg[6]; h_pipe[0]=Hreg[7];
                    end 
                  //pipe line stage output to the next stage pipeline registers
                  for(n=0;n<cycle;n=n+1)
                    begin
                      a_pipe[n+1]=a_out[n];
                      b_pipe[n+1]=b_out[n];
                      c_pipe[n+1]=c_out[n];
                      d_pipe[n+1]=d_out[n];
                      e_pipe[n+1]=e_out[n];
                      f_pipe[n+1]=f_out[n];
                      g_pipe[n+1]=g_out[n];
                      h_pipe[n+1]=h_out[n];
                    end 
                end 
            end 
          // valid signal output after all the stages completed 
          assign valid_out=valid_pipe[cycle-1];
          //final output with compressed 
          assign data_out ={a_pipe[cycle]+Hreg[0],
                            b_pipe[cycle]+Hreg[1],
                            c_pipe[cycle]+Hreg[2],
                            d_pipe[cycle]+Hreg[3],
                            e_pipe[cycle]+Hreg[4],
                            f_pipe[cycle]+Hreg[5],
                            g_pipe[cycle]+Hreg[6],
                            h_pipe[cycle]+Hreg[7]} ;
endmodule 
                    $display(" h = %08x", stage_out_h[j]);
                end
            end
        end
    end

    // Output valid signal after all stages complete
    assign valid_out = valid_pipe[STAGES-1];

    // Final digest output calculated as addition of pipeline final state with initial hash
    assign digest_out = {
       a_pipe[STAGES] + Hreg[0],
        b_pipe[STAGES] + Hreg[1],
        c_pipe[STAGES] + Hreg[2],
        d_pipe[STAGES] + Hreg[3],
        e_pipe[STAGES] + Hreg[4],
        f_pipe[STAGES] + Hreg[5],
        g_pipe[STAGES] + Hreg[6],
        h_pipe[STAGES] + Hreg[7]
    };

endmodule
