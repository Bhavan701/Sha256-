`ifndef Sha256_constants
`define Sha256_constants
// These are the initial hash values i.e H0 to H7 defined by the sha256 standards.
`define H0 32'h6a09e667
`define H1 32'hbb67ae85
`define H2 32'h3c6ef372
`define H3 32'ha54ff53a
`define H4 32'h510e527f
`define H5 32'h9b05688c
`define H6 32'h1f83d9ab
`define H7 32'h5be0cd19
//These are the 64 round constants k0-k63.
`define K0  32'h428a2f98  `define K1  32'h71374491  `define K2  32'hb5c0fbcf  `define K3  32'he9b5dba5  
`define K4  32'h3956c25b  `define K5  32'h59f111f1  `define K6  32'h923f82a4  `define K7  32'hab1c5ed5
`define K8  32'hd807aa98  `define K9  32'h12835b01  `define K10 32'h243185be  `define K11 32'h550c7dc3
`define K12 32'h72be5d74  `define K13 32'h80deb1fe  `define K14 32'h9bdc06a7  `define K15 32'hc19bf174
`define K16 32'he49b69c1  `define K17 32'hefbe4786  `define K18 32'h0fc19dc6  `define K19 32'h240ca1cc
`define K20 32'h2de92c6f  `define K21 32'h4a7484aa  `define K22 32'h5cb0a9dc  `define K23 32'h76f988da
`define K24 32'h983e5152  `define K25 32'ha831c66d  `define K26 32'hb00327c8  `define K27 32'hbf597fc7
`define K28 32'hc6e00bf3  `define K29 32'hd5a79147  `define K30 32'h06ca6351  `define K31 32'h14292967
`define K32 32'h27b70a85  `define K33 32'h2e1b2138  `define K34 32'h4d2c6dfc  `define K35 32'h53380d13
`define K36 32'h650a7354  `define K37 32'h766a0abb  `define K38 32'h81c2c92e  `define K39 32'h92722c85
`define K40 32'ha2bfe8a1  `define K41 32'ha81a664b  `define K42 32'hc24b8b70  `define K43 32'hc76c51a3
`define K44 32'hd192e819  `define K45 32'hd6990624  `define K46 32'hf40e3585  `define K47 32'h106aa070
`define K48 32'h19a4c116  `define K49 32'h1e376c08  `define K50 32'h2748774c  `define K51 32'h34b0bcb5
`define K52 32'h391c0cb3  `define K53 32'h4ed8aa4a  `define K54 32'h5b9cca4f  `define K55 32'h682e6ff3
`define K56 32'h748f82ee  `define K57 32'h78a5636f  `define K58 32'h84c87814  `define K59 32'h8cc70208
`define K60 32'h90befffa  `define K61 32'ha4506ceb  `define K62 32'hbef9a3f7  `define K63 32'hc67178f2
`endif 