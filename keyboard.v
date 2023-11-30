module keyboard #(
	parameter CLOCK_FREQUENCY = 25000000
) (
	input Clock,
	input reset,

	inout PS2_CLK,
	inout PS2_DAT,

	output reg[7:0]	heldData

);

	// Wire connections to PS2_controller
	wire		[7:0]	ps2_key_data;
	wire		[7:0]	pressedData;
	wire				ps2_key_pressed;

	// Internal Registers
	reg			[7:0]	last_data_received;
	reg flag;

	
	// Take in data
	always @(posedge Clock)
	begin
		if (!reset)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end

	// Make sure data is only held while the key is being held down
	always@(posedge Clock)
	begin
		if (!reset) begin
			heldData <= 8'h00;
			flag <= 0;
		end
		else begin
			if (heldData == 0 && flag) begin
				heldData <= ps2_key_data;
			end
			if (last_data_received == heldData && !flag) begin
				heldData <= 0;
			end
			if (ps2_key_pressed == 1'b1) flag <= 1'b1;
			if	(last_data_received == 8'hF0) flag <= 1'b0;
		end

	end


	PS2_Controller PS2 (
	// Inputs
	.Clock			(Clock),
	.reset				(reset),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.transmit		(ps2_key_data),
	.keyPressed	(ps2_key_pressed)
	);

	
endmodule
