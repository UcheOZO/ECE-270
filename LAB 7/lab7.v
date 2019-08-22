/* Hexadecimal 7-Segment Decoder for 22V10 */
module LAB7(I, A, B, C, D, E, F, G, DP);
	input wire [0:7] I /* synthesis loc="2,3,4,5,6,7,8,9" */;
	output wire A;	/* synthesis loc="14" */
	output wire B;	/* synthesis loc="15" */
	output wire C;	/* synthesis loc="16" */
	output wire D;	/* synthesis loc="17" */
	output wire E;	/* synthesis loc="18" */
	output wire F;	/* synthesis loc="19" */
	output wire G;	/* synthesis loc="20" */
	output wire DP; /* synthesis loc="21" */
	
	
	assign DP = ~I[7];
	assign G = ~I[6];
	assign F = ~I[5];
	assign E = ~I[4];
	assign D = ~I[3];
	assign C = ~I[2];
	assign B = ~I[1];
	assign A = ~I[0];
	
endmodule


