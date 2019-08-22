module ARM(I, A, B, C, D, E, F, G, DP);
	input wire [7:0] I /* synthesis loc="2,3,4,5,6,7,8,9"*/;
	output wire A;	/* synthesis loc="14" */
	output wire B;	/* synthesis loc="15" */
	output wire C;	/* synthesis loc="16" */
	output wire D;	/* synthesis loc="17" */
	output wire E;	/* synthesis loc="18" */
	output wire F;	/* synthesis loc="19" */
	output wire G;	/* synthesis loc="20" */
	output wire DP; /* synthesis loc="21" */
	
	
	reg [0:6] SEG7;
	always @ (I) begin
	  casez (I)
	    8'b10000000: SEG7 = 7'b1110111; // A
	    8'b11000000: SEG7 = 7'b0110000; // 1
	    8'b1?100000: SEG7 = 7'b1101101; // 2 
	    8'b1??10000: SEG7 = 7'b1111001; // 3 
	    8'b1???1000: SEG7 = 7'b0110011; // 4  
	    8'b1????100: SEG7 = 7'b1011011; // 5
	    8'b1?????10: SEG7 = 7'b1011111; // 6 
	    8'b1??????1: SEG7 = 7'b1110000; // 7
	    8'b0???????: SEG7 = 7'b0111110; // U
	  endcase
	end
	
	assign {A,B,C,D,E,F,G} = ~SEG7;
endmodule

