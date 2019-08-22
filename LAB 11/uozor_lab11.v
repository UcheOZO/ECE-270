module lab11_top (DIP,i_S1_NC,i_S1_NO,i_S2_NC,i_S2_NO,o_TOPRED,o_MIDRED,o_BOTRED,o_DIS1,o_DIS2,o_DIS3,o_DIS4,o_JUMBO,o_LED_YELLOW);

/*

ECE 270 Lab Experiment 11 - Spring 2019

IMPORTANT - Edit in your identifying information below.
Your completed file must be submitted on-line in order to receive credit for this experiment.

Name: Uche Ozor
Login ID: 0029998740 Station 20
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

// ======================= DO NOT MODIFY ABOVE ============================

// Step 1 - Instantiate and test your scrolling display and message string generator (from Lab 10)
//          Modify it so that a new message starts immediately upon being selected

wire [6:0] lookup;
wire [1:0] msgnum;

//assign msgnum = DIP[1:0]; // comment out after testing

msggen STEP1A(.CLK(tim_div4), .RST(S2BC), .mSEL(msgnum), .outCHAR(lookup));
 
dispshift STEP1B(.CLK(tim_div4), .RST(S2BC), .inCHAR(lookup), .outDISP({DIS4,DIS3,DIS2,DIS1}));

// Step 2 - Instantiate your 3-bit binary counter module with integrated 3:8 decoder
//          It should have both an asynchronous reset (ARST) and a synchronous reset (SRST)
//          Clock this counter using the right pushbutton (S1BC)
//          It should also include an enable (EN)

wire[2:0] pointer;
wire syncrst, cnten;

//assign cnten = DIP[3];    // comment out after testing
//assign syncrst = DIP[2];  // comment out after testing

up_count_decode STEP2(.CLK(S1BC), .ARST(S2BC), .SRST(syncrst), .EN(cnten), .count_state(pointer), .count_decode(MIDRED));

//assign TOPRED[2:0] = pointer;  // comment out after testing


///assign pointer = 3'b111;    //////////////////   I aded this

// Step 3 - Instantiate your 8-bit linear feedback shift register module
//          Use DIP[4] to control the LFSR enable and DIP[5] to show/hide its state
//
wire[7:0] randcombo;

lfsr STEP3(.CLK(tim_div4), .RST(S2BC), .EN(DIP[4]), .qcombo(randcombo));   

assign TOPRED = randcombo & {8{DIP[5]}};  // AND with DIP[5] to "show/hide" LFSR state

// Step 4 - Instantiate your match detector that determines if the "input_combo_bit" matches
//          the corresponding "randcombo" bit (indexed by "pointer")

wire MO;  // MO=1 if input_combo_bit (entered on DIP[7]) matches corresponding random combo bit

 match_detect STEP4(.inBIT(DIP[7]), .rCOMBO(randcombo), .PTR(pointer), .match_out(MO));  /// I added S!BC

 //assign JUMBO[2] = MO;  // comment out after testing

// Step 5 - Instantiate your sequencer recognizer state machine
//          Synchronous relock is controlled by DIP[6]

wire [2:0] jumbo_leds;

 dcl STEP5(.CLK(S1BC), .ARST(S2BC), .inM(MO), .inR(DIP[6]), .outNMSG(msgnum), .outLED(jumbo_leds), .outSRST(syncrst), .outEN(cnten));

 assign JUMBO[2:1] = jumbo_leds[2:1];         // GRN and YEL
 assign JUMBO[0] = tim_div2 & jumbo_leds[0];  // blinking RED


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


// Step 1A - Display shift register (7-segment X 4) - copied from Lab 10

module dispshift(CLK, RST, inCHAR, outDISP);

  input wire CLK;
  input wire RST;
  input wire[6:0] inCHAR;
  output reg [27:0] outDISP;

// Place your code for Step 1A below
 localparam blank = 7'b0000000;
  reg [6:0] Di4 ;
  reg [6:0] Di3 ;
  reg [6:0] Di2;
  reg [6:0] Di1;
	
always @ (posedge CLK, posedge RST) begin 
  Di4[6:0] <= Di3[6:0];
  Di3[6:0] <= Di2[6:0];
  Di2[6:0] <= Di1[6:0];
  Di1[6:0] <= inCHAR;

outDISP <= {Di4,Di3,Di2,Di1};

	if (RST == 1'b1) begin
     	    outDISP <= 27'b0;
	    Di4[6:0] <= 7'b0;
  	    Di3[6:0] <= 7'b0;
  	    Di2[6:0] <= 7'b0;
            Di1[6:0] <= 7'b0;		
        end
end

  assign STRING = {Di4,Di3,Di2,Di1};


endmodule   // ------------ end of Step 1A


// Step 1B - Message string generator (lookup) - adapted from Lab 10
// Modify it so that a newly selected message starts immediately when mSEL changes

module msggen(CLK, RST, mSEL, outCHAR);

// mSEL = 0: blank
// mSEL = 1: SECURE
// mSEL = 2: OPEN
// mSEL = 3: ERROR

 input wire CLK;
 input wire RST;
 input wire [1:0] mSEL;
 output reg [6:0] outCHAR;
 reg [5:0] CQ;
 reg [5:0] next_CQ;
 reg [6:0] next;

// 7-segment display code definitions
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
localparam A00 = 6'd00;
localparam A01 = 6'd01;
localparam A02 = 6'd02;
localparam A03 = 6'd03;
localparam A04 = 6'd04;
localparam A05 = 6'd05;
localparam A06 = 6'd06;
localparam A07 = 6'd07;
localparam A08 = 6'd08;
localparam A09 = 6'd09;
localparam A10 = 6'd10;
localparam A11 = 6'd11;
localparam A12 = 6'd12;
localparam A13 = 6'd13;
localparam A14 = 6'd14;
localparam A15 = 6'd15;
localparam A16 = 6'd16;
localparam A17 = 6'd17;
localparam A18 = 6'd18;
localparam A19 = 6'd19;
localparam A20 = 6'd20;
localparam A21 = 6'd21;

// Place your code for Step 1B below

reg [3:0] count;

always @ (posedge CLK) begin
	outCHAR <= next;
	CQ <= next_CQ;
	if (RST == 1'b1) begin
     	    outCHAR <= {blank,blank,blank,blank,blank,blank,blank};
        end 
end

always @ (mSEL) begin
if(RST == 0) begin
count = (mSEL == 2'b00) ? 4'b0001:
	        (mSEL == 2'b01) ? 4'b0010:
		 (mSEL == 2'b10) ? 4'b0100:
		 		 4'b1000;
end
end

always @ (outCHAR, mSEL) begin
	case (CQ)
	A00: begin 
		 next = blank;
		if (count == 4'b0001) next_CQ = A00;
		else if (count == 4'b0010) next_CQ = A01;
		else if (count == 4'b0100) next_CQ = A09;
		else if (count == 4'b1000) next_CQ = A15;
	end
	A01: begin 
		next = charS;
		if (count == 4'b0001) next_CQ = A00;
		else if (count == 4'b0010) next_CQ = A02;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A02: begin 
		next = charE;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A03;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A03: begin 
		next = charC;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A04;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A04: begin 
		next = charU;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A05;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A05: begin 
		next = charR;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A06;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A06: begin 
		next = charE;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A07;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A07: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A08;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A08: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A09: begin 
		next = charO;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A10;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A10: begin 
		next = charP;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A11;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A11: begin 
		next = charE;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A12;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A12: begin 
		next = charN;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A13;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A13: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A14;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A14: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end
	A15: begin 
		next = charE;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A16;
	end
	A16: begin 
		next = charR;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A17;
	end
	A17: begin 
		next = charR;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A18;
	end
	A18: begin 
		next = charO;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A19;
	end
	A19: begin 
		next = charR;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A20;
	end
	A20: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A21;
	end
	A21: begin 
		next = blank;
		if (count == 4'b0001) next_CQ = A00; 
		else if (count == 4'b0010) next_CQ = A00;
		else if (count == 4'b0100) next_CQ = A00;
		else if (count == 4'b1000) next_CQ = A00;
	end


endcase
	
end


endmodule  // ------------ end of Step 1B


// Step 2 - Binary up counter with integrated decoder - adapted from Lab 9
// Decoded outputs are used as a "pointer" to the current combination digit

  module up_count_decode(CLK, ARST, SRST, EN, count_state, count_decode);

  input wire CLK;
  input wire ARST;   // asynchronous reset
  input wire SRST;   // synchronous reset
  input wire EN;     // counter enable
  output reg [2:0] count_state;
  output reg [7:0] count_decode;
  reg [2:0] next_count_state;
  reg [7:0] next_count_decode;

// Place your code for Step 2 below
always @ (posedge CLK, posedge ARST) begin
//count_decode <= next_count_decode;
count_state <= next_count_state;
if (ARST == 1'b1) begin
//     	    count_decode <= 8'b00000000;
	    count_state <= 3'b000;
end
else if (SRST == 1'b1) begin
//	count_decode <= 8'b00000000;
	    count_state <= 3'b000;
end
end


always @ (count_state, EN) begin
if(EN == 1'b1) begin
	case (count_state)
		3'b000: begin
			 next_count_state = 3'b001;
			 count_decode = 8'b00000001;
		end
		3'b001: begin
			 next_count_state = 3'b010;
			 count_decode = 8'b00000010;
		end
		3'b010: begin
			 next_count_state = 3'b011;
			 count_decode = 8'b00000100;
		end
		3'b011: begin
			 next_count_state = 3'b100;
			 count_decode = 8'b00001000;
		end
		3'b100: begin
			 next_count_state = 3'b101;
			 count_decode = 8'b00010000;
		end
		3'b101: begin
			 next_count_state = 3'b110;
			 count_decode = 8'b00100000;
		end
		3'b110: begin
			 next_count_state = 3'b111;
			 count_decode = 8'b01000000;
		end
		3'b111: begin
			 next_count_state = 3'b000;
			 count_decode = 8'b10000000;
		end
	endcase
end
end



  endmodule   // ----------- end of Step 2



// Step 3 - Linear feedback shift register to generate random combination

module lfsr(CLK, RST, EN, qcombo);

input wire CLK, RST, EN; 
output reg [7:0] qcombo;
wire feedback;

assign feedback = (qcombo[4]^qcombo[3]^qcombo[2]^qcombo[0]); 
// Place your code for Step 3 below





always @ (posedge CLK, posedge RST) begin
if(RST == 1'b1)  begin
	qcombo <= 8'b11111111;
end else if(EN == 1'b1) begin
	qcombo <= {qcombo[6],qcombo[5],qcombo[4],qcombo[3],qcombo[2],qcombo[1],qcombo[0],feedback};
end
end



/*
assign feedback = (qcombo[4]^qcombo[3]^qcombo[2]^qcombo[0]); 
// Place your code for Step 3 below
always @ (posedge CLK, posedge RST) begin
if(RST == 1'b1)  begin
	qcombo <= 8'b11111111;
end else begin
if(EN == 1'b1) begin
	qcombo <=  qcombo << 1;
qcombo[0] <= feedback;
// {qcombo[6],qcombo[5],qcombo[4],qcombo[3],qcombo[2],qcombo[1],qcombo[0],feedback};
end else
	qcombo <= qcombo;
end
end
*/

endmodule   // ----------- end of Step 3



// Step 4 - Combination match detector

module match_detect(inBIT, rCOMBO, PTR, match_out);

input wire inBIT;
input wire [7:0] rCOMBO;
input wire [2:0] PTR;
input wire clocker;
output reg match_out;


// Place your code for Step 4 below


always @ (inBIT,PTR) begin
	if (inBIT == rCOMBO[PTR]) begin
		match_out <= 1;
	end else begin
		match_out <= 0;
	end 
end	  

endmodule   // ----------- end of Step 4


// Step 5 - Sequence recognizer (digital combination lock) state machine

module dcl(CLK, ARST, inM, inR, outNMSG, outLED, outSRST, outEN);

input wire CLK, ARST;
input wire inM;  // match input (inM = 1 if corresponding bits of combo match)
input wire inR;  // (synchronous) relock control input
output reg [1:0] outNMSG;  // number of message to scroll
output reg [2:0] outLED;  // GRN[2], YEL[1], RED[0]
output reg outSRST;  // synchronous reset for combination pointer
output reg outEN;  // enable control for combination pointer
reg [3:0] qstate, next_qstate;  // state of combination detector
reg [2:0] UoutLED;
reg [1:0] UoutNMSG;

localparam SECURE = 4'd0;
localparam ENTER1 = 4'd1;
localparam ENTER2 = 4'd2;
localparam ENTER3 = 4'd3;
localparam ENTER4 = 4'd4;
localparam ENTER5 = 4'd5;
localparam ENTER6 = 4'd6;
localparam ENTER7 = 4'd7;
localparam OPEN   = 4'd8;
localparam ERROR  = 4'd9;

// Place your code for Step 5 below
always @ (posedge CLK,posedge ARST) begin
	if(ARST == 1'b1) begin
		qstate<= SECURE;			
	end else if((qstate != OPEN) && (inM == 1'b0))begin
		qstate <= ERROR;
	end else begin
		qstate <= next_qstate;
	end

	
end

always @ (qstate) begin
	if(CLK == 1'b1 || ARST == 1'b1)begin
		case (qstate)
			SECURE: begin	next_qstate <= ENTER1; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER1: begin   next_qstate <= ENTER2; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER2: begin	next_qstate <= ENTER3; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER3: begin   next_qstate <= ENTER4; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER4: begin	next_qstate <= ENTER5; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER5: begin	next_qstate <= ENTER6; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER6: begin	next_qstate <= ENTER7; if(inR == 1)begin next_qstate <= SECURE; end end
			ENTER7: begin	next_qstate <= OPEN;   if(inR == 1)begin next_qstate <= SECURE; end end
			OPEN:   begin	next_qstate <= OPEN;   if(inR == 1)begin next_qstate <= SECURE; end end
			ERROR:  begin	next_qstate <= ERROR;  end
		endcase
	end
end

always @ (qstate) begin
	if(CLK == 1'b1 || ARST == 1'b1)begin
		case (qstate)
			SECURE: begin  outNMSG <= 2'b01; outLED <= 3'b000; outEN <= 1'b0; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER1: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER2: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER3: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER4: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER5: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER6: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			ENTER7: begin  outNMSG <= 2'b00; outLED <= 3'b010; outEN <= 1'b1; outSRST <= 1'b0; if(inR == 1)begin outSRST <= 1'b1; end end
			OPEN:   begin  outNMSG <= 2'b10; outLED <= 3'b100; outEN <= 1'b0; outSRST <= 1'b1; if(inR == 1)begin outSRST <= 1'b1; end end
			ERROR:  begin  outNMSG <= 2'b11; outLED <= 3'b001; outEN <= 1'b0; outSRST <= 1'b1; end
		endcase		
	end
end

endmodule   // ----------- end of Step 5
