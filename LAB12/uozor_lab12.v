
module lab12_top (DIP,i_S1_NC,i_S1_NO,i_S2_NC,i_S2_NO,o_TOPRED,o_MIDRED,o_BOTRED,o_DIS1,o_DIS2,o_DIS3,o_DIS4,o_JUMBO,o_LED_YELLOW);

/*

ECE 270 Lab Experiment 12 - Spring 2019

IMPORTANT - Edit in your identifying information below.
Your completed file must be submitted on-line in order to receive credit for this experiment.

Name: Uche Ozor
Login ID: 0029998746
Lab Div: 7

*/

// ====== DO NOT MODIFY BELOW ======

// DIP switches (MSB on the left)
input wire [7:0] DIP /*synthesis loc="26,25,24,23,76,77,78,79"*/;		

// ACTIVE LOW pushbutton contacts 
// S1 is on RIGHT, S2 is on LEFT
input wire i_S1_NC /*synthesis loc="58"*/;		// ACTIVE LOW normally closed (down position)
input wire i_S1_NO /*synthesis loc="59"*/;		// ACTIVE LOW normally opened (up position)
input wire i_S2_NC /*synthesis loc="60"*/;		// ACTIVE LOW normally closed (down position)
input wire i_S2_NO /*synthesis loc="61"*/;		// ACTIVE LOW normally opened (up position)

// ACTIVE LOW red LEDs (MSB..LSB)
output wire [7:0] o_TOPRED /*synthesis loc="28,29,30,31,32,33,39,40"*/;		// ACTIVE LOW first row of LED (from top, MSB on the left)
output wire [7:0] o_MIDRED /*synthesis loc="130,131,132,133,134,135,138,139"*/;	// ACTIVE LOW second row of LED (from top, MSB on the left)
output wire [7:0] o_BOTRED /*synthesis loc="112,111,105,104,103,102,101,100"*/;	// ACTIVE LOW third row of LED (from top, MSB on the left)

// ACTIVE LOW 7-segment displays (DIS4..DIS1)
output wire [6:0] o_DIS1 /*synthesis loc="87,86,85,84,83,81,80"*/;		// ACTIVE LOW right-most 7-segment
output wire [6:0] o_DIS2 /*synthesis loc="98,97,96,95,94,93,88"*/;		// ACTIVE LOW second-right most 7-segment
output wire [6:0] o_DIS3 /*synthesis loc="125,124,123,122,121,120,116"*/;	// ACTIVE LOW second left-most 7-segment
output wire [6:0] o_DIS4 /*synthesis loc="44,48,49,50,51,52,53"*/;		// ACTIVE LOW left-most 7-segment

// ACTIVE LOW jumbo LEDs (RED, YELLOW, GREEN)
output wire [2:0] o_JUMBO /*synthesis loc="142,141,140"*/;		// ACTIVE LOW Jumbo G-Y-R LED (GREEN, YELLOW, RED)
// ACTIVE LOW yellow LEDs (next to pushbuttons, left..right)
output wire [1:0] o_LED_YELLOW /*synthesis loc="62,63"*/;		// ACTIVE LOW yellow LED next to pushbuttons

// ACTIVE HIGH I/O level conversions
wire S1_NC, S1_NO, S2_NC, S2_NO;
wire [7:0] TOPRED;
wire [7:0] MIDRED;
wire [7:0] BOTRED;
wire [6:0] DIS1;
wire [6:0] DIS2;
wire [6:0] DIS3;
wire [6:0] DIS4;
wire [2:0] JUMBO;            // JUMBO_G = [2], JUMBO_Y = [1], JUMBO_R = [0]
wire YEL_LFT, YEL_RGT;

assign S1_NC = ~i_S1_NC;
assign S1_NO = ~i_S1_NO;
assign S2_NC = ~i_S2_NC;
assign S2_NO = ~i_S2_NO;
assign o_TOPRED = ~TOPRED;
assign o_MIDRED = ~MIDRED;
assign o_BOTRED = ~BOTRED;
assign o_DIS1 = ~DIS1;
assign o_DIS2 = ~DIS2;
assign o_DIS3 = ~DIS3;
assign o_DIS4 = ~DIS4;
assign o_JUMBO = ~JUMBO;
assign o_LED_YELLOW = {~YEL_LFT, ~YEL_RGT};

// On-chip oscillator - enable/disable controlled by DIP[1]
wire osc_dis, tmr_rst, osc_out, tmr_out;
assign osc_dis = 1'b0;  
assign tmr_rst = 1'b0; 

defparam I1.TIMER_DIV = "1048576";  // largest clock divisor possible for device = 2 ^ 20
OSCTIMER I1 (.DYNOSCDIS(osc_dis), .TIMERRES(tmr_rst), .OSCOUT(osc_out), .TIMEROUT(tmr_out));

// Frequency divider (for on-chip oscillator)

wire tim_div2;
wire tim_div4;

frequency_divider FDIVBY2 (.clk(tmr_out), .rst(S2BC), .clk_out(tim_div2));
frequency_divider FDIVBY4 (.clk(tim_div2), .rst(S2BC), .clk_out(tim_div4));

// Bounceless switches - routed to (small) yellow LEDs
// RIGHT PB is S1 -> YEL_RGT, LEFT PB is S2 -> YEL_LFT

wire S1BC, S2BC;

bounceless_switch RGTPB(.CLR(S1_NC), .SET(S1_NO), .Q(S1BC));
bounceless_switch LFTPB(.CLR(S2_NC), .SET(S2_NO), .Q(S2BC));

assign YEL_RGT = S1BC;   // right pushbutton will be used for clocking sequence recognizer 
assign YEL_LFT = S2BC;   // left pushbutton will be used for asynchronous reset 

assign BOTRED = DIP;    // display state of DIP switches on bottom row of red LEDs


// ============================ DO NOT MODIFY ABOVE =================================



// Step 1 - Instantiate and test your scrolling display and message string generator (adapted from Lab 10)
//          Modify it so that it includes an enable (EN)
//          Comment out everything in this step once testing is complete

//wire [6:0] lookup;
//wire msgnum;                  // only two messages to select between for this lab
//wire msgenable;               // enable message scroll (and display)

//assign msgnum = DIP[0];      // use for testing Step 1 - comment out afterwards
//assign msgenable = DIP[1];   // use for testing Step 1 - comment out afterwards

//msggen STEP1A(.CLK(tim_div4), .RST(S2BC), .EN(msgenable), .mSEL(msgnum), .inSCORE({4'd7,4'd2}), .outCHAR(lookup));
//dispshift STEP1B(.CLK(tim_div4), .RST(S2BC), .EN(msgenable), .inCHAR(lookup), .outDISP({DIS4,DIS3,DIS2,DIS1}));



// Step 2 - Instantiate your 4-bit linear feedback shift register module (adapted from Lab 11)
//          Use DIP[7] to show/hide its state on MIDRED[3:0]
//          Comment out everything in this step once testing is complete

//wire[3:0] randprice;

//lfsr STEP2(.CLK(S1BC), .RST(S2BC), .EN(1'b1), .qprice(randprice));

//assign MIDRED[3:0] = randprice & {4{DIP[7]}};  // AND with DIP[7] to "show/hide" LFSR state (price)



// Step 3 - Instantiate and test your 4-bit adder/subtractor module 
//          Use DIP[7:4] to enter value for X, and DIP[3:0] to enter value for Y
//          Be sure to comment out the Step 1 test instantiations before proceeding
//          Comment out everything in this step once testing is complete


//wire[3:0] sumout;                  // comment out after testing
//wire cfout, zfout, nfout, vfout;   // comment out after testing

//cla4 STEP3(.X(DIP[7:4]), .Y(DIP[3:0]), .M(S2BC), .S(sumout), .oCF(cfout), .oZF(zfout), .oNF(nfout), .oVF (vfout));
//assign TOPRED[3:0] = sumout;       // comment out after testing
//assign TOPRED[7:4] = {cfout, zfout, nfout, vfout};    // comment out after testing




// Step 4 - Instantiate and test your 4-bit magnitude comparator (X will be LFSR-generated price, Y is guess)
//          Re-instantiate your adder/subtractor in subtract (only) mode
//          Display outputs on JUMBO LEDs: GRN (X=Y), YEL (X>Y), RED (X<Y)
//          Display difference (resulting from subtraction) on TOPRED[3:0]
//          Display points that would be earned for each round on TOPRED[7:4]
//          Comment out everything in this step once testing is complete

//wire[3:0] diffout;
//wire[3:0] mypoints;

//cla4 STEP4A(.X(DIP[7:4]), .Y(DIP[3:0]), .M(1'b1), .S(diffout), .oCF(cfout), .oZF(zfout), .oNF(nfout), .oVF (vfout));
//magcomp STEP4B(.iCF(cfout), .iZF(zfout), .iNF(nfout), .iVF(vfout), .LT(JUMBO[0]), .EQ(JUMBO[2]), .GT(JUMBO[1]), .oPOINTS(mypoints));

//assign TOPRED[3:0] = diffout;   // comment out after testing
//assign TOPRED[7:4] = mypoints;  // comment out after testing




// Step 5 - Instantiate and test your 4-bit round counter
//          Use an instantiation of the "bcd2dis" module (provided) to display round counter on DIS1
//          Comment out everything in this step once testing is complete

//wire[3:0] roundnum;
//wire gmoverf, n_gmoverf;

//assign n_gmoverf = ~gmoverf;

//roundcnt STEP5A(.CLK(S1BC), .RST(S2BC), .gameover(gmoverf), .qrnd(roundnum));
//bcd2dis STEP5B(.inBCD(roundnum), .outDIS(DIS1));



// Step 6 - Instantiate and test your BCD full adder
//          Comment out everything in this step once testing is complete

//wire tenschk;        // comment out after testing
//wire [3:0] oneschk;  // comment out after testing

//bcdfa STEP6(.A(DIP[7:4]), .B(DIP[3:0]), .CIN(1'b1), .COUT(tenschk), .SUM(oneschk));   // comment out after testing
//assign TOPRED[4:0] = {tenschk,oneschk};  // comment out after testing




// Step 7 - Instantiate and test your 2-digit BCD score accumulator
//          Used fixed increment of "3" to test, then comment out after finished testing

//wire [7:0] myscore;

//bcdaccum STEP7(.CLK(S1BC), .RST(S2BC), .EN(n_gmoverf), .iPOINTS(4'b0011), .oSCORE(myscore));  // comment out after testing
//bcd2dis STEP7B(.inBCD(myscore[7:4]), .outDIS(DIS4));
//bcd2dis STEP7C(.inBCD(myscore[3:0]), .outDIS(DIS3));




// Step 8 - Instantiate and test your win/lose detector 
//          Use a winning threshold of 52 points (expressed as a BCD number) to  test
//          Comment out everything in this step once testing is complete

winlose STEP8(.POINTS(DIP[7:0]), .THRESH(8'h52), .oWIN(TOPRED[0]));





// Step 9 - All Verilog modules should now have been independently tested and verified
//          Re-instantiate all the modules with the requisite declarations and wiring, as shown below


wire[3:0] randprice;       // random price (generated by LFSR)
wire[3:0] diffout;         // difference between price and guess (generated by CLA4)
wire[3:0] mypoints;        // points earned on the current round (generated by MAGCOMP)
wire [7:0] myscore;        // score accummulated as game progresses (generated by BCDACCUM)
wire[3:0] roundnum;        // round number (generated by ROUNDCNT)
wire gmoverf, n_gmoverf;   // game over flag and its complement (generated by ROUNDCNT)
wire [6:0] lookup;         // alphanumeric character to scroll (generated by MSGEN)
wire msgnum;               // message number to display corresponding to lose (0) or win (1)     

wire [27:0] scroll_display, play_display;  // 7-segment display for playing game or scrolling message (when game is over)   
wire [2:0] jumbo_leds;     

lfsr STEP9A(.CLK(S1BC), .RST(S2BC), .EN(1'b1), .qprice(randprice));

cla4 STEP9B(.X(randprice), .Y(DIP[3:0]), .M(1'b1), .S(diffout), .oCF(cfout), .oZF(zfout), .oNF(nfout), .oVF (vfout));

magcomp STEP9C(.iCF(cfout), .iZF(zfout), .iNF(nfout), .iVF(vfout), .LT(jumbo_leds[0]), .EQ(jumbo_leds[2]), .GT(jumbo_leds[1]), .oPOINTS(mypoints));

roundcnt STEP9D(.CLK(S1BC), .RST(S2BC), .gameover(gmoverf), .qrnd(roundnum));

bcd2dis STEP9E(.inBCD(roundnum), .outDIS(play_display[6:0]));

bcdaccum STEP9F(.CLK(S1BC), .RST(S2BC), .EN(n_gmoverf), .iPOINTS(mypoints), .oSCORE(myscore));

winlose STEP9G(.POINTS(myscore), .THRESH(8'h52), .oWIN(msgnum));  // NOTE: Winning threshold is set = 52 (base 10), but can be changed

bcd2dis STEP9H(.inBCD(myscore[7:4]), .outDIS(play_display[27:21]));

bcd2dis STEP9I(.inBCD(myscore[3:0]), .outDIS(play_display[20:14]));

msggen STEP9J(.CLK(tim_div4), .RST(S2BC), .EN(gmoverf), .mSEL(msgnum), .inSCORE(myscore), .outCHAR(lookup));

dispshift STEP9K(.CLK(tim_div4), .RST(S2BC), .EN(gmoverf), .inCHAR(lookup), .outDISP(scroll_display));

assign MIDRED[3:0] = randprice & {4{DIP[7]}};  // AND with DIP[7] to "show/hide" LFSR state (price to guess)

assign JUMBO = jumbo_leds & {3{DIP[7]}};  // AND with DIP[7] to "show/hide" status of guess on jumbo LEDs 

assign n_gmoverf = ~gmoverf;

assign play_display[13:7] = 7'b0;    // DIS2 is "dark" during play mode

assign {DIS4,DIS3,DIS2,DIS1} = ({28{gmoverf}} & scroll_display) | ({28{n_gmoverf}} & play_display);



endmodule  // =========== end of top-level module =================================================


// Bounceless switch module (provided)

  module bounceless_switch(CLR, SET, Q);

  input wire CLR;
  input wire SET;
  output reg Q;

  wire CLK;
  wire D;

  assign CLK = 1'b0;
  assign D = 1'b0;

  always @(posedge CLK, posedge SET, posedge CLR)
     begin
	if (CLR == 1'b1) begin
		Q <= 1'b0;
	end else if (SET == 1'b1) begin
		Q <= 1'b1;
	end else begin
		Q <= D;
     end
  end

  endmodule

// Clock frequency divider module (provided)

  module frequency_divider(clk, rst, clk_out);

  input wire clk;
  input wire rst;
  output reg clk_out;

  always @(posedge clk, posedge rst)
  begin
	if (rst == 1'b1) begin
		clk_out <= 0;
	end else begin
		clk_out <= ! clk_out; 
	end
  end 

  endmodule

// BCD to 7-segment display code converter module (provided)

 module bcd2dis(inBCD, outDIS);

 input wire [3:0] inBCD;
 output reg [6:0] outDIS;

// 7-segment display code definitions for BCD digits
  localparam blank = 7'b0000000;
  localparam char0 = 7'b1111110;
  localparam char1 = 7'b0110000;
  localparam char2 = 7'b1101101;
  localparam char3 = 7'b1111001;
  localparam char4 = 7'b0110011;
  localparam char5 = 7'b1011011;
  localparam char6 = 7'b1011111;
  localparam char7 = 7'b1110000;
  localparam char8 = 7'b1111111;
  localparam char9 = 7'b1111011;

  always @ (inBCD) begin
   case(inBCD)
    4'd0: outDIS = char0;
    4'd1: outDIS = char1;
    4'd2: outDIS = char2;
    4'd3: outDIS = char3;
    4'd4: outDIS = char4;
    4'd5: outDIS = char5;
    4'd6: outDIS = char6;
    4'd7: outDIS = char7;
    4'd8: outDIS = char8;
    4'd9: outDIS = char9;
    default: outDIS = blank;
   endcase
 end
 endmodule

// Student-written Verilog modules should be inserted below - do not modify modules provided (above)

// =================================================================================================

// Step 1A - Display shift register (7-segment X 4) - adapted from Lab 10

module dispshift(CLK, RST, EN, inCHAR, outDISP);

  input wire CLK;
  input wire RST;
  input wire EN;
  input wire[6:0] inCHAR;
  output reg [27:0] outDISP;

// Place your code for Step 1A below
 localparam blank = 7'b0000000;
  reg [6:0] Di4 ;
  reg [6:0] Di3 ;
  reg [6:0] Di2;
  reg [6:0] Di1;
	
always @ (posedge CLK, posedge RST) begin 
	if (RST == 1'b1) begin
     	    outDISP <= 27'b0;
	    Di4[6:0] <= 7'b0;
  	    Di3[6:0] <= 7'b0;
  	    Di2[6:0] <= 7'b0;
            Di1[6:0] <= 7'b0;		
        end
	else begin
		if (EN == 1'b1) begin
			Di4[6:0] <= Di3[6:0];
  			Di3[6:0] <= Di2[6:0];
 			Di2[6:0] <= Di1[6:0];
  			Di1[6:0] <= inCHAR;

			outDISP <= {Di4,Di3,Di2,Di1};
		end
		else begin
			 outDISP <= outDISP;
	   		 Di4[6:0] <= Di4[6:0];
  	  		 Di3[6:0] <= Di3[6:0];
  	   		 Di2[6:0] <= Di2[6:0];
           		 Di1[6:0] <= Di1[6:0];
		end
	end
end

  assign STRING = {Di4,Di3,Di2,Di1};




endmodule   // ------------ end of Step 1A


// Step 1B - Message string generator (lookup) - adapted from Lab 10

module msggen(CLK, RST, EN, mSEL, inSCORE, outCHAR);

// mSEL = 0: LOSER
// mSEL = 1: YEAH

 input wire CLK;
 input wire RST;
 input wire EN;                     // message scroll enable
 input wire mSEL;                   // only 2 different messages for this Lab
 
 input wire [7:0] inSCORE;          // 2-digit BCD score: inSCORE[7:4] = tens position, inSCORE[3:0] = ones position
 output reg [6:0] outCHAR;

 wire [6:0] tens, ones;             // BCD score converted to 7-segment display code

 reg [4:0] CQ;
 reg [4:0] next_CQ;

// 7-segment alpha display code definitions
localparam blank = 7'b0000000;
localparam charA = 7'b1110111;
localparam charB = 7'b0011111;
localparam charC = 7'b1001110;
localparam charD = 7'b0111101;
localparam charE = 7'b1001111;
localparam charF = 7'b1000111;
localparam charG = 7'b1111011;
localparam charH = 7'b0110111;
localparam charI = 7'b0010000;
localparam charJ = 7'b0111000;
localparam charL = 7'b0001110;
localparam charN = 7'b0010101;
localparam charO = 7'b0011101;
localparam charP = 7'b1100111;
localparam charR = 7'b0000101;
localparam charS = 7'b1011011;
localparam charU = 7'b0111110;
localparam charY = 7'b0111011;

// State name definitions
localparam A00 = 5'd00;
localparam A01 = 5'd01;
localparam A02 = 5'd02;
localparam A03 = 5'd03;
localparam A04 = 5'd04;
localparam A05 = 5'd05;
localparam A06 = 5'd06;
localparam A07 = 5'd07;
localparam A08 = 5'd08;
localparam A09 = 5'd09;
localparam A10 = 5'd10;
localparam A11 = 5'd11;
localparam A12 = 5'd12;
localparam A13 = 5'd13;
localparam A14 = 5'd14;
localparam A15 = 5'd15;
localparam A16 = 5'd16;
localparam A17 = 5'd17;
localparam A18 = 5'd18;
localparam A19 = 5'd19;

// Place your code for Step 1B below
// Hint: Use instantiations of the bcd2dis module (provided)



reg [3:0] count;
wire [6:0] first;
wire [6:0] second;
reg [6:0] next;

//always @ (*) begin	
	bcd2dis uche(.inBCD(inSCORE[7:4]),.outDIS(first));
	bcd2dis ozor(.inBCD(inSCORE[3:0]),.outDIS(second));
//end

always @ (posedge CLK, posedge RST) begin
	
	if (RST == 1'b1) begin
     	    outCHAR <= {blank,blank,blank,blank,blank,blank,blank};
        end else begin
		outCHAR <= next;
		CQ <= next_CQ;
	end
end

always @ (mSEL) begin
	//count = 4'b0001;
	//if((inSCORE[7:4] >= 4'b0101) && (inSCORE[3:0] >= 4'b0010)) begin
	//	count = 4'b1000;
	//end   /// USE LATER
	if(mSEL == 1) begin
		count = 4'b1000;
	end else begin
		count = 4'b0001;
	end	
end

always @ (CQ,EN) begin
	if(EN == 1'b1) begin
	case (CQ)
	A01: begin next_CQ = A02;
	end
	A02: begin next_CQ = A03;
	end
	A03: begin next_CQ = A04;
	end
	A04: begin 
		if (count == 4'b0001) next_CQ = A05; 
		else if (count == 4'b1000) next_CQ = A12;
	end
	A05: begin next_CQ = A06; 
	end
	A06: begin next_CQ = A07; 
	end
	A07: begin next_CQ = A08; 
	end
	A08: begin 
		if (count == 4'b0001) next_CQ = A09; 
		else if (count == 4'b1000) next_CQ = A13;
	end
	A09: begin next_CQ = A10; 
	end
	A10: begin next_CQ = A11; 
	end
	A11: begin next_CQ = A01; 
	end
	A12: begin next_CQ = A13; 
	end
	A13: begin next_CQ = A14; 
	end
	A14: begin next_CQ = A15; 
	end
	A15: begin next_CQ = A10;
	end
	default: begin next_CQ = A01;
	end
	endcase	
	end
end

always @ (CQ) begin
	case (CQ)
	A01: begin next = blank;
	end
	A02: begin next = first;
	end
	A03: begin next = second;
	end
	A04: begin next = blank;
	end
	A05: begin next = charL;
	end
	A06: begin next = charO;
	end
	A07: begin next = charS;
	end
	A08: begin next = charE;
	end
	A09: begin next = charR;
	end
	A10: begin next = blank;
	end
	A11: begin next = blank;
	end
	A12: begin next = charY;
	end
	A13: begin next = charE;
	end
	A14: begin next = charA;
	end
	A15: begin next = charH;
	end
	endcase
end





endmodule  // ------------ end of Step 1



// Step 2 - 4-bit linear feedback shift register to generate price - adapted from Lab 11
//          Visits all 16 possible states, starting with 0000

module lfsr(CLK, RST, EN, qprice);

input wire CLK, RST, EN; 
output reg [3:0] qprice;

// Place your code for Step 2 below
wire feedback;
assign feedback = qprice[2]^qprice[3] ^ ~(qprice[2] | qprice[1] | qprice[0]); 


always @ (posedge CLK, posedge RST) begin
if(RST == 1'b1)  begin
	qprice <= 8'b0000;
end else if(EN == 1'b1) begin
	qprice <= {qprice[2],qprice[1],qprice[0],feedback};
end
end





endmodule   // ----------- end of Step 2



// Step 3 - 4-bit radix adder/subtractor module with condition codes ("flags")

module cla4(X, Y, M, S, oCF, oZF, oNF, oVF);

 input wire [3:0] X, Y;	        // Operands (X+Y or X-Y)
 input wire M;                  // add/subtract mode: 0-add, 1-subtract
 output wire [3:0] S;	        // Sum outputs
 output wire oCF, oZF, oNF, oVF;    // Condition code outputs

 wire [3:0] C;		        // Carry equations  
 wire [3:0] P, G;

// Place your code for Step 3 below
	assign G = X & (Y ^ {4{M}});
 	assign P = X ^ (Y ^ {4{M}}); 

	assign C[0] = G[0] | M & P[0];
	assign C[1] = G[1] | G[0] & P[1] | M & P[0] & P[1];
	assign C[2] = G[2] | G[1] & P[2] | G[0] & P[1] & P[2] | M & P[0] & P[1] & P[2];
	assign C[3] = G[3] | G[2] & P[3] | G[1] & P[2] & P[3] | G[0] & P[1] & P[2] & P[3] | M & P[0] & P[1] & P[2] & P[3]; 


	assign S[0] = M ^ P[0];
 	assign S[3:1] = C[2:0] ^ P[3:1]; 

assign oCF = C[3];
assign oNF = S[3];
assign oZF = ~S[3] & ~S[2] & ~S[1] & ~S[0];
assign oVF = C[3] ^ C[2];


endmodule   // ----------- end of Step 3



// Step 4 - 4-bit radix magnitude comparator module 
//          Based on flags produced by subtracting (Y) from (X)

module magcomp(iCF, iZF, iNF, iVF, LT, EQ, GT, oPOINTS);

 input wire iCF, iZF, iNF, iVF;
 output wire LT, EQ, GT;
 output reg [3:0] oPOINTS;  // points earned based on each condiition

// Place your code for Step 4 below
  //wire [3:0] bastard;
  //assign bastard = {iCF,iZF,iNF,iVF};


//if(bastard == 4'b1100)begin
	assign EQ = iZF;
//end else if(bastard == 4'b0010 || bastard == 4'b1010 || bastard == 4'b1001) begin
	assign LT = iNF^iVF;
//end else begin
	assign GT = (iVF&&iNF)||(~iVF&&~iNF&&~iZF);
//end
always @ (*) begin
	if(EQ == 1)begin oPOINTS = 4'b1001;    
	end else if(LT == 1)begin oPOINTS = 4'b0000;
	end else if(GT == 1)begin oPOINTS = 4'b0100;
	end
end

endmodule   // ----------- end of Step 4



// Step 5 - 4-bit "round counter" module
//        - Initializes to state 0001
//        - Stops (freezes) after reaches state 1010 (asserts gameover)

module roundcnt(CLK, RST, gameover, qrnd);
 
 input wire CLK, RST;
 output reg [3:0] qrnd;
 output reg gameover;
 reg [3:0] next_qrnd;

// Place your code for Step 5 below

always @ (posedge CLK, posedge RST) begin

	if(RST == 1)begin
		qrnd <= 4'b0001;
	end else begin
		qrnd <= next_qrnd;
	end
end

always @ (CLK) begin
	if(qrnd <= 9) begin
		next_qrnd <= qrnd + 1;
		gameover = 0;
	end else  begin
		gameover = 1;
		next_qrnd <= 10;
	end
end





endmodule   // ----------- end of Step 5



// Step 6 - BCD full-adder module

module bcdfa(A, B, CIN, COUT, SUM);

 input wire [3:0] A, B;
 input wire CIN;
 output wire COUT;
 output wire [3:0] SUM;

 wire [4:0] Z;  // intermediate result
 wire CorFn;    // correction function

// Place your code for Step 6 below
 


//reg [4:0] s2;

//assign SUM = s2[3:0];
//assign COUT = (s2[4]||(s2[3]&&s2[2])||(s2[3]&&s2[1]));
//assign CorFn = COUT;


//always @ ( * ) begin
//    s2 = A + B + CIN;
	assign Z = A + B + CIN;
	//assign SUM = Z[3:0];
	assign COUT = (Z[4]||(Z[3]&&Z[2])||(Z[3]&&Z[1]));
	assign CorFn = COUT;
	assign SUM = (CorFn == 1'b1) ? Z[3:0] + 6:
		   Z[3:0];
//    end
//end



endmodule   // ----------- end of Step 6



// Step 7 - Two-digit BCD score adder/accumulator module
//        - BCD digit iPOINTS is added to 2-digit BCD oSCORE as long as game is NOT over

module bcdaccum(CLK, RST, EN, iPOINTS, oSCORE);

 input wire CLK, RST, EN;
 input wire [3:0] iPOINTS;
 output reg [7:0] oSCORE;
 reg [7:0] next_oSCORE;
 wire tenscarry, hundredscarry;
 wire [7:0] bcdsum;
 
// Place your code for Step 7 below
// HINT: Use two instantiations of bcdfa to construct your 2-digit adder
bcdfa uche(.A(oSCORE[3:0]),.B(iPOINTS),.CIN(1'b0),.COUT(tenscarry),.SUM(bcdsum[3:0]));
bcdfa ozor(.A(1'b0),.B(oSCORE[7:4]),.CIN(tenscarry),.COUT(hundredscarry),.SUM(bcdsum[7:4]));

always @ (posedge CLK, posedge RST) begin
	if(RST == 1'b1) oSCORE <= 8'b0;
	else if (EN == 1 && RST == 1'b0) oSCORE <= next_oSCORE;
end

always @ (*) begin
	if (oSCORE[7:4] < 8 || oSCORE[3:0] < 1) next_oSCORE <= bcdsum;
	else  next_oSCORE <= oSCORE;
end


endmodule   // ----------- end of Step 7


// Step 8 - Win/lose detector module

module winlose(POINTS, THRESH, oWIN);

 input wire [7:0] POINTS;
 input wire [7:0] THRESH;
 output reg oWIN;

// Place your code for Step 8 below

always @ (*) begin
	if (POINTS >= THRESH) begin
		oWIN <= 1;
	end
	else begin
		oWIN <= 0;
	end
end



endmodule   // ----------- end of Step 8


