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
		oX,
		oY
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
	wire resetn, reset;
	assign resetn = KEY[0];
	
	// dino colour, x and y pixels, and signals
	wire [2:0] dinoColour;
	wire [7:0] dinoX;
	wire [6:0] dinoY;
	wire dinoGo, dinoErase, dinoPlotEn, dinoUpdate, dinoReset, dinoSignal;
	
	// obstacle colour, x and y pixels, and signals
	wire [2:0] obstacleColour;
	wire [7:0] obstacleX;
	wire [6:0] obstacleY;
	wire obstacleGo, obstacleErase, obstaclePlotEn, obstacleUpdate, obstacleReset, obstacleSignal;
	
	// vga colour, x and y pixels, and signals
	wire [2:0] vgaColour;
	wire [7:0] vgaX;
	wire [6:0] vgaY;
	wire vgaGo;
	
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

	output[7:0] oX, oY;
	// Create an Instance of a VGA controller 
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(vgaColour),
			.x(vgaX),
			.y(vgaY),
			.plot(vgaGo),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK)
			);
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	dinoControlpath c(CLOCK_50, resetn, dinoPlotCounter, 
					  dinoXCounter, dinoYCounter, dinoFreq,
					  dinoGo, dinoErase, dinoUpdate, dinoPlotEn, dinoReset);
	
	dinoDataPath d(CLOCK_50, resetn, dinoPlotEn, dinoGo, dinoErase, dinoUpdate, dinoReset, SW[2:0], 
				  dinoX, dinoY, dinoColour, dinoPlotCounter, dinoXCounter, dinoYCounter, dinoFreq, dinoSignal, height, nextHeight, obstacleX, obstacleY, obstaclePlotEn, oX, oY);
				 
	
	obstacleControlpath e(CLOCK_50, resetn, obstaclePlotCounter, 
					  obstacleXCounter, obstacleYCounter, obstacleFreq,
					  obstacleGo, obstacleErase, obstacleUpdate, obstaclePlotEn, obstacleReset);
	
	obstacleDataPath l(CLOCK_50, resetn, obstaclePlotEn, obstacleGo, obstacleErase, obstacleUpdate, obstacleReset, SW[2:0], 
				  obstacleX, obstacleY, obstacleColour, obstaclePlotCounter, obstacleXCounter, obstacleYCounter, obstacleFreq, obstacleSignal, height, nextHeight);
				  
	combinedOut(.clk(CLOCK_50), .colour(vgaColour), .go(vgaGo), .obstacleOPlot(obstaclePlotEn),.dinoOPlot(dinoPlotEn), .obstacleX(obstacleX), .obstacleY(obstacleY), .dinoX(dinoX), .dinoY(dinoY), .vgaX(vgaX), .vgaY(vgaY), .dinoErase(dinoErase), .obstacleErase(obstacleErase), .reset(reset), .resetn(resetn), .obstacleColour(obstacleColour), .dinoColour(dinoColour), .dinoSignal(dinoSignal), .obstacleSignal(obstacleSignal));
	
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
			CLEAR: nextSt = (xCounter == 8'd160 && yCounter == 7'd120) ? RESET : CLEAR;
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
					 output reg dinoSignal,
					 input [15:0] height,
					 input [15:0] nextheight,
					 input [7:0] obstacleX,
					 input [6:0] obstacleY,
					 input obstaclePlotEn,
					 output reg[7:0] oX, oY);
	reg [7:0] xTemp;
	reg [6:0] yTemp;

	always @(posedge clk) 
	begin
		if (reset || !resetn) begin
			X <= 8'd10;
			Y <= 7'd106;
			xTemp <= 8'd10;
			yTemp <= 7'd106;
			plotCounter<= 6'b0;
			xCounter<= 8'b0;
			yCounter <= 7'b0;
			CLR <= 3'b0;
			freq <= 25'd0;
			dinoSignal <= 1'b1;

		end
		else begin
			if (!plotEn) begin
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
//			if (!erase) CLR <= 3'b0;
			
			if (freq == 26'd833333) freq <= 26'd0;
			else freq <= freq + 1;
			
			if (plotEn && obstaclePlotEn) begin
				oX <= xCounter;
				oY <= yCounter;
				if (erase) begin
//					if (xCounter == obstacleX || yCounter == obstacleY) begin
//						CLR <= 3'b111;
//					end
//					else 
					CLR <= 0;
					dinoSignal <= 1'b0;
				end 
				else begin
					CLR <= 3'b111;
					dinoSignal <= 1'b1;
				end 
				if (plotCounter == 6'b10000) plotCounter<= 6'b0;
				else plotCounter <= plotCounter+1;
				X <= xTemp + plotCounter[1:0];
				Y <= yTemp + plotCounter[3:2];
			end
			if (update) begin
				Y <= height;
				yTemp <= height;
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
			CLEAR: nextSt = (xCounter == 8'd160 && yCounter == 7'd120) ? RESET : CLEAR;
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
					 output reg obstacleSignal,
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
			obstacleSignal <= 1'b1;

		end
		else begin
			if (!plotEn) begin
				if (xCounter == 8'd160 && yCounter != 7'd120) begin
					xCounter <= 8'b0;
					yCounter <= yCounter + 1;
				end
				else begin
					xCounter <= xCounter + 1;
					X <= xCounter;
					Y <= yCounter;
					CLR <= 3'b0;
				end
			end
//			if (!erase) CLR <= 3'b0;
			
			if (freq == 26'd833333) freq <= 26'd0;
			else freq <= freq + 1;
			
			if (plotEn) begin
				if (erase) begin 
					CLR <= 0;
					obstacleSignal <= 1'b0;
				end 
				else begin
					CLR <= 3'b111;
					obstacleSignal <= 1'b1;
				end 
				if (plotCounter == 5'b10000) plotCounter<= 6'b0;
				else plotCounter <= plotCounter+1;
				X <= xTemp + plotCounter[1:0];
				Y <= yTemp + plotCounter[3:2];
			end
			if (update) begin
				X <= X - 1;
				xTemp <= xTemp - 1;
			end
		end
	end
endmodule

/*
module combinedOut(
	input clk,
	input colour,
	output reg go,
	input obstacleOPlot,
	input dinoOPlot,
	input[7:0] obstacleX,
	input[6:0] obstacleY,
	input[7:0] dinoX,
	input[6:0] dinoY,
	output reg[7:0] vgaX,
	output reg[6:0]vgaY,
	output reg dinoErase,
	output reg obstacleErase,
	input reset,
	input resetn,
	input [2:0] obstacleColour,
	input [2:0] dinoColour,
	input dinoSignal,
	input obstacleSignal
	);
	
	reg [2:0] currentSt, nextSt;
	
	localparam IDLE = 3'd0,
				  DRAWD = 3'd1,
				  WAIT1 = 3'd2,
				  DRAWO = 3'd3,
				  WAIT2 = 3'd4,
				  ERASE = 3'd5;
				  

	//State Table
	always @(*)
	begin
		case(currentSt)
			IDLE: nextSt = DRAWD;
			DRAWD: begin
				if (!dinoErase) nextSt = DRAWD;
				else nextSt = WAIT1;
			end
			WAIT1: begin
				if (!dinoOPlot) nextSt = WAIT1;
				else nextSt = DRAWO;
			end
			DRAWO: begin
				if (!obstacleErase) nextSt = DRAWO;
				else nextSt = WAIT2;
			end
			WAIT2: begin
				if (!obstacleOPlot) nextSt = WAIT2;
				else nextSt = ERASE;
			end
			ERASE: begin
				if (!dinoErase && !obstacleErase) nextSt = IDLE;
				else nextSt = ERASE;
			end
		
			default: nextSt = IDLE;
		endcase
	end 

	always@(posedge clk)
	begin
		if (currentSt == DRAWD) begin
			vgaX <= dinoX;
			vgaY <= dinoY;
			go <= dinoOPlot;
		end
		else if (currentSt == WAIT1) begin
			go <= dinoOPlot;

		
		end
		else if (currentSt == DRAWO) begin
			vgaX <= obstacleX;
			vgaY <= obstacleY;
			go <= obstacleOPlot;

		end
		else if (currentSt == WAIT2) begin
			go <= dinoOPlot;

		
		end
		else if (currentSt == ERASE) begin
			vgaX <= dinoX;
			vgaY <= dinoY;
			go <= dinoOPlot;

		end
		else begin
		
		end
	end
	
	always @(posedge clk)
   begin
		if (!resetn) currentSt <= IDLE;
      else currentSt <= nextSt;
   end 
endmodule
*/
