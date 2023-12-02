module part2(	
		CLOCK_50,						//	On Board 50 MHz
		SW, 								// On Board Switches
		KEY,							   // On Board Keys
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						   //	VGA Blue[9:0]
		height,
	);

	input		    CLOCK_50;			//	50 MHz
	input	 [3:0] KEY;					// Keys
	input  [9:0] SW;					// Switches
	input  [15:0] height;
	output		 VGA_CLK;   		//	VGA Clock
	output		 VGA_HS;				//	VGA H_SYNC
	output		 VGA_VS;				//	VGA V_SYNC
	output		 VGA_BLANK_N;		//	VGA BLANK
	output		 VGA_SYNC_N;		//	VGA SYNC
	output [7:0] VGA_R;   			//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output [7:0] VGA_G;	 			//	VGA Green[7:0]
	output [7:0] VGA_B;   			//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] dinoColour;
	wire [2:0] obstacleColour;
	wire [2:0] vgaColour;
	wire [7:0] vgaX;
	wire [6:0] vgaY;
	wire [7:0] dinoX;
	wire [6:0] dinoY;
	wire [7:0] obstacleX;
	wire [6:0] obstacleY;
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	wire dinoGo, dinoErase, dinoPlotEn, dinoUpdate, dinoReset;
	wire obstacleGo, obstacleErase, obstaclePlotEn, obstacleUpdate, obstacleReset;
	wire reset;
	assign resetn = KEY[0];
	
	// dino global variables
	wire [5:0] dinoPlotCounter;
	wire [7:0] dinoXCounter;
	wire [6:0] dinoYCounter;
	wire [25:0] dinoFreq;
	
	// obstacle global variables
	wire [5:0] obstaclePlotCounter;
	wire [7:0] obstacleXCounter;
	wire [6:0] obstacleYCounter;
	wire [25:0] obstacleFreq;

	// Create an Instance of a VGA controller 
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(obstacleColour),
			.x(obstacleX),
			.y(obstacleY),
			.plot(obstacleGo),
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
			
//	dinoControlpath c(CLOCK_50, resetn, dinoPlotCounter, 
//					  dinoXCounter, dinoYCounter, dinoFreq,
//					  dinoGo, dinoErase, dinoUpdate, dinoPlotEn, dinoReset);
//	
//	dinoDataPath d(CLOCK_50, resetn, dinoPlotEn, dinoGo, dinoErase, dinoUpdate, dinoReset, SW[2:0], 
//				  dinoX, dinoY, dinoColour, dinoPlotCounter, dinoXCounter, dinoYCounter, dinoFreq, height, nextHeight);
				 
	
	obstacleControlpath e(CLOCK_50, resetn, obstaclePlotCounter, 
					  obstacleXCounter, obstacleYCounter, obstacleFreq,
					  obstacleGo, obstacleErase, obstacleUpdate, obstaclePlotEn, obstacleReset);
	
	obstacleDataPath l(CLOCK_50, resetn, obstaclePlotEn, obstacleGo, obstacleErase, obstacleUpdate, obstacleReset, SW[2:0], 
				  obstacleX, obstacleY, obstacleColour, obstaclePlotCounter, obstacleXCounter, obstacleYCounter, obstacleFreq, height, nextHeight);
				  
//	combinedOut(.clk(CLOCK_50), .colour(colour), .go(go), .obstacleOPlot(obstaclePlotEn),.dinoOPlot(dinoPlotEn), .obstacleX(obstacleX), .obstacleY(obstacleY), .dinoX(dinoX), .dinoY(dinoY), .vgaX(vgaX), .vgaY(vgaY), .dinoErase(dinoErase), .obstacleErase(obstacleErase), .reset(reset), .resetn(resetn), .obstacleColour(obstacleColour), .dinoColour(dinoColour));
endmodule

module dinoControlpath(input clk, resetn,  
						 input [5:0] plotCounter,
						 input [7:0] xCounter,
						 input [6:0] yCounter,
						 input [25:0] freq,
						 output reg go, erase, update, plotEn, reset );
	reg [2:0] currentSt, nextSt;
	
	localparam RESET = 3'b0,
				  DRAW = 3'b001,
				  WAIT = 3'b010,
				  ERASE = 3'b011,
				  UPDATE = 3'b100,
				  CLEAR = 3'b101;

	//State Table
	always @(*)
	begin
		case(currentSt)
			RESET: nextSt = DRAW;
			DRAW: begin
				if (plotCounter <= 6'd15) nextSt = DRAW;
				else nextSt = WAIT;
			end
			WAIT: begin
				if (freq < 26'd833333) nextSt = WAIT;
				else nextSt = ERASE;
			end
			ERASE: begin
				if (plotCounter <= 6'd15) nextSt = ERASE;
				else nextSt = UPDATE;
			end
			UPDATE: nextSt = DRAW;
			CLEAR: nextSt = (xCounter == 8'd160 & yCounter == 7'd120) ? RESET : CLEAR;
			default: nextSt = RESET;
		endcase
	end 

	//Control signals
	always @(*)
	begin
		//RESET all enable signals
		go = 1'b0;
		update = 1'b0;
		reset = 1'b0;
		erase = 1'b0;
		plotEn = 1'b0;
		
		case(currentSt)
			RESET: reset = 1'b1;
			DRAW: begin
				go  = 1'b1;
				erase = 1'b0;
				plotEn = 1'b1;
			end
			ERASE: begin
				go  = 1'b1;
				erase = 1'b1;
				plotEn = 1'b1;
				end
			UPDATE: update = 1'b1;
			CLEAR: begin
				erase = 1'b1;
				go = 1'b1;
			end
		endcase
	end

	// Control current state
   always @(posedge clk)
   begin
		if (!resetn) currentSt <= CLEAR;
      else currentSt <= nextSt;
   end 
endmodule 

module dinoDataPath(input clk, resetn, plotEn, go, erase, update, reset,
					 input [2:0] clr,
					 output reg [7:0] X,
					 output reg [6:0] Y,
					 output reg [2:0] CLR,
					 output reg [5:0] plotCounter,
					 output reg [7:0] xCounter,
					 output reg [6:0] yCounter, 
					 output reg [25:0] freq,
					 input [15:0] height,
					 input [15:0] nextheight);
	reg [7:0] xTemp;
	reg [6:0] yTemp;

	always @(posedge clk) 
	begin
		if (reset || !resetn) begin
			X <= 8'd10;
			Y <= 7'd10;
			xTemp <= 8'd10;
			yTemp <= 7'd10;
			plotCounter<= 6'b0;
			xCounter<= 8'b0;
			yCounter <= 7'b0;
			CLR <= 3'b0;
			freq <= 25'd0;

		end
		else begin
			if (erase & !plotEn) begin
				if (xCounter == 8'd160 && yCounter != 7'd120) begin
					xCounter <= 8'b0;
					yCounter <= yCounter + 1;
				end
				else begin
					xCounter <= xCounter + 1;
					X <= xCounter;
					Y <= yCounter;
					if (Y == 7'd111) CLR <= 3'b111; 
					else CLR <= 3'b0;
				end
			end
			if (!erase) CLR <= 3'b0;
			
			if (freq == 26'd833333) freq <= 26'd0;
			else freq <= freq + 1;
			
			if (plotEn) begin
				if (erase) CLR <= 0;
				else CLR <= 3'b111;
				if (plotCounter == 6'b10000) plotCounter<= 6'b0;
				else plotCounter <= plotCounter+1;
				X <= xTemp + plotCounter[1:0];
				Y <= yTemp + plotCounter[3:2];
			end
			if (update) begin
				Y <= height - 4;
				yTemp <= height - 4;
			end
		end
	end
endmodule 

module obstacleControlpath(input clk, resetn,  
						 input [5:0] plotCounter,
						 input [7:0] xCounter,
						 input [6:0] yCounter,
						 input [25:0] freq,
						 output reg go, erase, update, plotEn, reset );
	reg [2:0] currentSt, nextSt;
	
	localparam RESET = 3'b0,
				  DRAW = 3'b001,
				  WAIT = 3'b010,
				  ERASE = 3'b011,
				  UPDATE = 3'b100,
				  CLEAR = 3'b101;

	//State Table
	always @(*)
	begin
		case(currentSt)
			RESET: nextSt = DRAW;
			DRAW: begin
				if (plotCounter <= 6'd15) nextSt = DRAW;
				else nextSt = WAIT;
			end
			WAIT: begin
				if (freq < 26'd833333) nextSt = WAIT;
				else nextSt = ERASE;
			end
			ERASE: begin
				if (plotCounter <= 6'd15) nextSt = ERASE;
				else nextSt = UPDATE;
			end
			UPDATE: nextSt = DRAW;
			CLEAR: nextSt = (xCounter == 8'd160 & yCounter == 7'd120) ? RESET : CLEAR;
			default: nextSt = RESET;
		endcase
	end 

	//Control signals
	always @(*)
	begin
		//RESET all enable signals
		go = 1'b0;
		update = 1'b0;
		reset = 1'b0;
		erase = 1'b0;
		plotEn = 1'b0;
		
		case(currentSt)
			RESET: reset = 1'b1;
			DRAW: begin
				go  = 1'b1;
				erase = 1'b0;
				plotEn = 1'b1;
			end
			ERASE: begin
				go  = 1'b1;
				erase = 1'b1;
				plotEn = 1'b1;
				end
			UPDATE: update = 1'b1;
			CLEAR: begin
				erase = 1'b1;
				go = 1'b1;
			end
		endcase
	end

	// Control current state
   always @(posedge clk)
   begin
		if (!resetn) currentSt <= CLEAR;
      else currentSt <= nextSt;
   end 
endmodule 

module obstacleDataPath(input clk, resetn, plotEn, go, erase, update, reset,
					 input [2:0] clr,
					 output reg [7:0] X,
					 output reg [6:0] Y,
					 output reg [2:0] CLR,
					 output reg [5:0] plotCounter,
					 output reg [7:0] xCounter,
					 output reg [6:0] yCounter, 
					 output reg [25:0] freq,
					 input [15:0] height,
					 input [15:0] nextheight);
	reg [7:0] xTemp;
	reg [6:0] yTemp;

	always @(posedge clk) 
	begin
		if (reset || !resetn) begin
			X <= 8'd100;
			Y <= 7'd106;
			xTemp <= 8'd100;
			yTemp <= 7'd106;
			plotCounter<= 6'b0;
			xCounter<= 8'b0;
			yCounter <= 7'b0;
			CLR <= 3'b0;
			freq <= 25'd0;

		end
		else begin
			if (erase & !plotEn) begin
				if (xCounter == 8'd160 && yCounter != 7'd120) begin
					xCounter <= 8'b0;
					yCounter <= yCounter + 1;
				end
				else begin
					xCounter <= xCounter + 1;
					X <= xCounter;
					Y <= yCounter;
					if (Y == 7'd111) CLR <= 3'b111; 
					else CLR <= 3'b0;
				end
			end
			if (!erase) CLR <= 3'b0;
			
			if (freq == 26'd833333) freq <= 26'd0;
			else freq <= freq + 1;
			
			if (plotEn) begin
				if (erase) CLR <= 0;
				else CLR <= 3'b111;
				if (plotCounter == 6'b10000) plotCounter<= 6'b0;
				else plotCounter <= plotCounter+1;
				X <= xTemp + plotCounter[1:0];
				Y <= yTemp + plotCounter[3:2];
			end
			if (update) begin
				X <= X - 1;
				xTemp <= xTemp - 1;
				Y <= height;
				yTemp <= height;
			end
		end
	end
endmodule

module combinedOut(clk, colour, go, obstacleOPlot,dinoOPlot, obstacleX, obstacleY, dinoX, dinoY, vgaX, vgaY, dinoErase, obstacleErase, reset, resetn, obstacleColour, dinoColour);

	input clk, obstacleOPlot, dinoOPlot, dinoErase, obstacleErase, reset, resetn;
	input [7:0] obstacleX, dinoX;
	input [6:0] obstacleY, dinoY;
	
	output reg [7:0] vgaX;
	output reg [6:0] vgaY;
	output reg go;
	output reg [2:0] colour, obstacleColour, dinoColour;
	
	reg [24:0] freq;

	reg [7:0] xTemp, xCounter;
	reg [6:0] yTemp, yCounter;

	always @(posedge clk) 
	begin
		if (reset || !resetn) begin
			vgaX <= 8'd0;
			vgaY <= 7'd0;
			xTemp <= 8'd0;
			yTemp <= 7'd0;
			xCounter<= 8'b0;
			yCounter <= 7'b0;
			colour <= 3'b0;
			freq <= 25'd0;

		end
		else begin
			if ((dinoErase || obstacleErase) & !(obstacleOPlot || dinoOPlot)) begin
				if (xCounter == 8'd160 && yCounter != 7'd120) begin
					xCounter <= 8'b0;
					yCounter <= yCounter + 1;
				end
				else begin
					xCounter <= xCounter + 1;
					vgaX <= xCounter;
					vgaY <= yCounter;
				end
			end
			if (!(dinoErase || obstacleErase)) colour <= 3'b0;
			
			if (freq == 26'd833333) freq <= 26'd0;
			else freq <= freq + 1;
			
			if ((obstacleOPlot && dinoOPlot) && (obstacleColour == 3'b111) && (dinoColour == 3'b111)) begin
				if ((dinoErase || obstacleErase)) colour <= 0;
				else colour <= 3'b100;
				vgaX <= xTemp + 1;
				vgaY <= yTemp + 1;
				go <= 1'b1;
			end
			
			if (obstacleOPlot) begin
				if (obstacleErase) colour <= 0;
				else colour <= 3'b111;
				vgaX <= obstacleX;
				vgaY <= obstacleY;
				go <= 1'b1;
			end
			
			if (dinoOPlot) begin
				if (dinoErase) colour <= 0;
				else colour <= 3'b111;
				vgaX <= dinoX;
				vgaY <= dinoY;
				go <= 1'b1;
			end
		end
	end

endmodule 
