//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//
module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,		// On Board Keys
		SW,
		LEDR,
//		HEX0,
//		HEX1,
//		HEX2,
//		HEX3,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		height
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input[9:0] SW;
	input[9:0] LEDR;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	input [6:0] height;
	wire writeEn;
	wire[6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(height),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	p2 p2(.iClock(CLOCK_50), .iResetn(KEY[0]), .iPlotBox(!KEY[1]), .iBlack(!KEY[2]), .iLoadX(!KEY[3]), .iXY_Coord(SW[6:0]), .iColour(SW[9:7]), .oX(x), .oY(y), .oColour(colour), .oPlot(writeEn), .oDone(LEDR[0]));
//	output[6:0] HEX0;
//	output[6:0] HEX1;
//	output[6:0] HEX2;
//	output[6:0] HEX3;
//
//	hex_decoder h0(x[3:0], HEX0);
//	hex_decoder h1(x[7:4], HEX1);
//	hex_decoder h2(y[3:0], HEX2);
//	hex_decoder h3(y[6:4], HEX3);

endmodule
	
//module part2(input CLOCK_50, input[3:0] KEY, input[9:0] SW, output[7:0] oX, output[6:0] oY, output[2:0] oColour, output oPlot, output oDone);
//	p2 p2(.iClock(CLOCK_50), .iResetn(KEY[0]), .iPlotBox(KEY[1]), .iBlack(KEY[2]), .iLoadX(KEY[3]), .iXY_Coord(SW[6:0]), .iColour(SW[9:7]), .oX(oX), .oY(oY), .oColour(oColour), .oPlot(oPlot), .oDone(oDone));
//endmodule

module p2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame


   //
   // Your code goes here
   //
	
	wire[7:0] maxX;
	wire[6:0] maxY;
	wire ld_x, ld_b, ld_y, ld_c, ld_l, calculate;
	wire YDone;
	wire XDone;


	ctrl #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) C0(
		.iResetN(iResetn),
		.iPlotBox(iPlotBox),
		.iBlack(iBlack),
		.iColour(iColour),
		.iLoadX(iLoadX),
		.iXY_Coord(iXY_Coord),
		.Clock(iClock),
		.maxX(maxX),
		.maxY(maxY),
		.YDone(YDone),
		.XDone(XDone),
		
		.oPlot(oPlot),
		.oDone(oDone),
		.ld_x(ld_x), 
		.ld_b(ld_b), 
		.ld_y(ld_y), 
		.ld_c(ld_c), 
		.ld_l(ld_l), 
		.calculate(calculate)
	);
	
	datapath #(.X_SCREEN_PIXELS(X_SCREEN_PIXELS), .Y_SCREEN_PIXELS(Y_SCREEN_PIXELS)) D0(
		.iResetN(iResetn),
		.iPlotBox(iPlotBox),
		.iBlack(iBlack),
		.iColour(iColour),
		.iLoadX(iLoadX),
		.iXY_Coord(iXY_Coord),
		.Clock(iClock),
		.ld_x(ld_x), 
		.ld_b(ld_b), 
		.ld_y(ld_y), 
		.ld_c(ld_c), 
		.ld_l(ld_l),
		.calculate(calculate),
		
		.oX(oX),
		.oY(oY),
		.oColour(oColour),
		.maxX(maxX),
		.maxY(maxY),
		.YDone(YDone),
		.XDone(XDone),
		.oDone(oDone)
	);

	
	
	
	
	
	
endmodule // part2

module ctrl #(parameter X_SCREEN_PIXELS = 8'd160, parameter Y_SCREEN_PIXELS = 7'd120) (
	input iResetN,
	input iPlotBox,
	input iBlack,
	input[2:0] iColour,
	input iLoadX,
	input[6:0] iXY_Coord,
	input Clock,
	input[7:0] maxX,
	input[6:0] maxY,
	input YDone,
	input XDone,
	
	input oDone,
	output reg oPlot,
	output reg ld_x, ld_b, ld_y, ld_c, ld_l, calculate
	);
	
	
	
	reg [5:0] currentState, nextState;

	localparam  DEFAULT        = 5'd0,
					S_LOAD_X		   = 5'd1,
					S_LOAD_Y_C     = 5'd2,
					S_LOAD_BLACK   = 5'd3,
					S_DRAW	      = 5'd4,
					S_LOAD 			= 5'd5;
	
	always@(*)
	begin: state_table
		case (currentState)
		
			DEFAULT: begin
							if (iLoadX) nextState = S_LOAD_X;
							else if (iPlotBox) nextState = S_LOAD_Y_C;
							else if (iBlack) nextState = S_LOAD_BLACK;
							else nextState = DEFAULT;
						end
			S_LOAD_X: nextState = iLoadX ? S_LOAD_X : DEFAULT;
			
			S_LOAD_Y_C: nextState = iPlotBox ? S_LOAD_Y_C : S_LOAD;
			
			S_LOAD_BLACK: nextState = iBlack ? S_LOAD_BLACK : S_DRAW;
						
			S_LOAD: nextState = S_DRAW;
			S_DRAW: nextState = (oDone) ? DEFAULT : S_DRAW;

			
			default:     nextState = DEFAULT;
		endcase
	end

	
	always@(*)
	begin: outputLogic
		ld_x = 1'b0;
		ld_b = 1'b0;
		ld_y = 1'b0;
		ld_c = 1'b0;
		ld_l = 1'b0;
		calculate = 1'b0;
		oPlot = 1'b1;

		case (currentState)
			S_LOAD_X: begin
				ld_x = 1'b1;
				end
			S_LOAD_Y_C: begin
				ld_y = 1'b1;
				ld_c = 1'b1;
				end
			S_LOAD_BLACK: begin
				ld_b = 1'b1;
				end
			S_LOAD: begin
				ld_l = 1'b1;
				end	

			
			S_DRAW: begin
				oPlot = 1'b1;
				calculate = 1'b1;
				end

		endcase
		
	
	end
	
	
	always@(posedge Clock)
	begin: state_progression
		if(!iResetN)
			currentState <= DEFAULT;
		else 
			currentState <= nextState;
	end
	
	
endmodule



module datapath #(parameter X_SCREEN_PIXELS = 8'd160, parameter Y_SCREEN_PIXELS = 7'd120) (
	input iResetN,
	input iPlotBox,
	input iBlack,
	input[2:0] iColour,
	input iLoadX,
	input[6:0] iXY_Coord,
	input Clock,
	input ld_x, ld_b, ld_y, ld_c, ld_l, calculate,

	output reg[7:0] oX,
	output reg[6:0] oY,
	output reg[2:0] oColour,
	output reg[7:0] maxX,
	output reg[6:0] maxY,
	output reg YDone,
	output reg XDone,
	output reg oDone
	);

	
	reg[7:0] storeX;
	reg[6:0] storeY;
	
	always@(posedge Clock) begin
		if (!iResetN || ld_b) begin
			oX <= 8'b00000000;
			oY <= 7'b0000000;
			XDone <= 1'b0;
			YDone <= 1'b0;
			oColour <= 3'b000;
			maxX <= X_SCREEN_PIXELS;
			maxY <= Y_SCREEN_PIXELS;
			oDone <= 1'b0;
		end
		else begin
			if (ld_x && iLoadX) begin
				oX <= iXY_Coord;
				storeX <= iXY_Coord;
				end
			if (ld_y && iPlotBox) begin
				oY <= iXY_Coord;
				storeY <= iXY_Coord;
				end
			if (ld_c && iPlotBox) begin
				oColour <= iColour;
				end
			if (ld_l) begin
				XDone <= 1'b0;
				YDone <= 1'b0;
				maxX <= oX + 3;
				maxY <= oY + 3;
				oDone <= 1'b0;
				end
				
			if (calculate) begin
				if (oY == maxY) YDone <= 1'b1;
				
				if (oX == maxX) begin
					if (YDone) begin
						XDone <= 1'b1;
						oDone <= 1'b1;
					end
					else begin
						oX <= storeX;
						oY <= oY + 1;
					end
				end
				else oX <= oX + 1;
			end
		end
	end
endmodule
