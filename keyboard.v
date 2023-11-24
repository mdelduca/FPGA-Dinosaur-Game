
module keyboard (
	// Inputs
	CLOCK_50,
	KEY,
	LEDR,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
parameter CLOCK_FREQUENCY = 25000000;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;
output		[9:0] LEDR;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
reg		[7:0]	heldData;
wire		[7:0]	pressedData;
reg flag;

wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;
reg [15:0]height;
reg [15:0]velocity;
reg [7:0] counter;
reg[$clog2(CLOCK_FREQUENCY):0] elTime;
reg jumping;
// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

assign LEDR[8] = heldData == 8'h1C;
assign LEDR[7] = heldData == 8'h0;
assign LEDR[6] = jumping == 1'b1;
assign LEDR[9] = flag == 1'b1;
assign LEDR[2] = height < 16'd10;
assign LEDR[0] = height > 16'd10;
assign LEDR[1] = height == 16'd10;

assign LEDR[5] = velocity < 16'd50;
assign LEDR[3] = velocity > 16'd50;
assign LEDR[4] = velocity == 16'd50;




always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

always@(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0) begin
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

always@(posedge CLOCK_50)
begin
	if (heldData == 8'h1C) begin
		if (!jumping) begin
			height <= 16'd10;
			jumping <= 1'b1;
			velocity <= 16'd50;
			counter <= 0;
		end
	end
	if (jumping) begin
		if (elTime != 0) begin 
			elTime <= elTime - 1;
		end
		else begin
			elTime <= CLOCK_FREQUENCY/4 - 1;
			counter <= counter + 1;
			height <= height + (velocity*counter);
			velocity <= velocity - counter;
		end

	end
	if (height[15] == 1'b1 || !KEY[0]) begin
		height <= 16'd10;
		velocity <= 0;
		counter <= 0;
		jumping <= 0;
		elTime <= 0;
	end
end
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(height[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(height[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);

Hexadecimal_To_Seven_Segment Segment2 (
	// Inputs
	.hex_number			(height[11:8]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX2)
);

Hexadecimal_To_Seven_Segment Segment3 (
	// Inputs
	.hex_number			(height[15:12]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX3)
);

Hexadecimal_To_Seven_Segment Segment4 (
	// Inputs
	.hex_number			(counter[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX4)
);

Hexadecimal_To_Seven_Segment Segment5 (
	// Inputs
	.hex_number			(counter[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX5)
);



endmodule
