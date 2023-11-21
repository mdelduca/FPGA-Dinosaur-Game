
module keyboard(
	input wire clk,
	input wire PS2C,
	input wire PS2D,
	input wire[10:0] data,
	input start,
	input parity,
	input stop
	);
	
	reg[7:0] currentData, prevData;
	reg[3:0] counter;

	always@ (negedge PS2C)



endmodule
