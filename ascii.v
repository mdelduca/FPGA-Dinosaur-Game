`timescale 1ns/1ns

// dinoStillWidth = 22px
// dinoStillHeight = 26px

/*

____________111111111_
___________11111111111
___________1111_111111
___________11111111111
___________11111111111
___________11111111111
___________11111111111
___________1111111____
___________1111111111_
__________11111111____
1_________1111111_____
1________11111111_____
11______111111111111__
111_____111111111__1__
1111___1111111111_____
11111111111111111_____
1111111111111111______
_111111111111111______
__1111111111111_______
____1111111111________
____111111111_________
_____111_11___________
_____111_11___________
_____11___1___________
_____1____1___________
_____11___111_________



*/

// dinoRunOneWidth = 22px
// dinoRunOneHeight = 26px

/*

____________111111111_
___________11111111111
___________1111_111111
___________11111111111
___________11111111111
___________11111111111
___________11111111111
___________1111111____
___________1111111111_
__________11111111____
1_________1111111_____
1________11111111_____
11______111111111111__
111_____111111111__1__
1111___1111111111_____
11111111111111111_____
1111111111111111______
_111111111111111______
__1111111111111_______
____1111111111________
____111111111_________
_____111_11___________
_____1___11___________
_____111__1___________
__________1___________
__________111_________



*/


// dinoCrouchWidth = 22px
// dinoCrouchHeight = 26px

/*

____________111111111_
___________11111111111
___________1111_111111
___________11111111111
___________11111111111
___________11111111111
___________11111111111
___________1111111____
___________1111111111_
__________11111111____
1_________1111111_____
1________11111111_____
11______111111111111__
111_____111111111__1__
_111___1111111111_____
__111111111111111_____
____1111111111________
____111111111_________
_____111_11___________
_____1___11___________
_____111__1___________
__________1___________
__________111_________



*/

// dinoDeadWidth = 22px
// dinoDeadHeight = 26px

/*

____________111111111_
___________111___11111
___________111_1_11111
___________111___11111
___________11111111111
___________11111111111
___________11111111111
___________1111111111_
___________1111111____
__________11111111____
1_________1111111_____
1________11111111_____
11______111111111111__
111_____111111111__1__
1111___1111111111_____
11111111111111111_____
1111111111111111______
_111111111111111______
__1111111111111_______
____1111111111________
____111111111_________
_____111_11___________
_____111_11___________
_____11___111_________
_____1________________
_____11_______________



*/

// smallCactusOneWidth = 15px
// smallCactusOneHeight = 13px

/*

_______1_______
______111____1_
_____11111__111
_____11111__111
_1___11111__111
111__11111__111
111__11111__111
111__111111111_
111__111111111_
111__11111_____
_111111111_____
___1111111_____
_____11111_____

*/

// smallCactusTwoWidth = 15px
// smallCactusTwoHeight = 13px

/*

_______1_______
_1____111____1_
111__11111__111
111__11111__111
111__11111__111
111__11111__111
_11__11111__11_
_1111111111111_
__11111111111__
_____11111_____
_____11111_____
_____11111_____
_____11111_____

*/

// largeCactusOneWidth = 15px
// largeCactusOneHeight = 20x

/*

_______1_______
_1____111____1_
111__11111__111
111__11111__111
111__11111__111
111__11111__111
_11__11111__111
_111111111__111
__11111111__111
_____11111__111
_____11111__11_
_____111111111_
_____11111111__
_____11111_____
_____11111_____
_____11111_____
_____11111_____
_____11111_____
_____11111_____
_____11111_____

*/

// largeCactusTwoWidth = 17px
// largeCactusTwoHeight = 20x

/*

________1________
__1____111____1__
_111__11111__111_
_111__11111__111_
_111__11111__111_
_111__11111__111_
_111__11111__11__
__11__111111111__
__111111111111___
___11111111______
______11111______
______11111______
______11111______
______11111______
______11111______
______11111______
______11111______


*/

// BirdOneWidth = 17px
// BirdTwoHeight = 13px

/*

_________1__________
_________11_________
_________1111_______
_________1111_______
_____1___11111______
___111___111111_____
_111111___111111____
11111111___11111____
______11___111111___
______11111111111111
_______111111111____
________1111111111__
_________1111111____


*/

// BirdTwoWidth = 17px
// BirdTwoHeight = 15px

/*

_____1______________
___111______________
_111111_____________
11111111____________
______11____________
______11111111111111
_______111111111____
_____1111111111111__
_____11111111111____
_____111111_________
____111111__________
____11111___________
____1111____________
____1111____________
____11______________


*/

*/

// use height as inputs for dinosaur
// generate obstacles
// stop updating pixels when paused
// view highscore while game is being played
// create all other screen states
/*

ld_generate = 1'b1;
				end
				
			S_GAME: begin
				ld_game = 1'b1;
				end
				
			S_JUMP: begin
				calc_jump = 1'b1;
				end
				
			S_OBSTACLE: begin
				create_obs = 1'b1;
				end
				
			S_PAUSE: begin
				ld_pause = 1'b1;

*/

module SquareAnimation(	
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
		VGA_B   						   //	VGA Blue[9:0]
	);

	input		    CLOCK_50;			//	50 MHz
	input	 [3:0] KEY;					// Keys
	input  [9:0] SW;					// Switches
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
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	wire go, erase, plotEn, update, reset;
	assign resetn = KEY[0];
	
	wire [5:0] plotCounter;
	wire [7:0] xCounter;
	wire [6:0] yCounter;
	wire [25:0] freq;

	// Create an Instance of a VGA controller 
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(go),
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
			
	controlPath c(CLOCK_50, resetn, plotCounter, 
					  xCounter, yCounter, freq,
					  go, erase, update, plotEn, reset);
	
	dataPath d(CLOCK_50, resetn, plotEn, go, erase, update, reset, SW[2:0], 
				  x, y, colour, plotCounter, xCounter, yCounter, freq);
endmodule

module controlPath(input clk, resetn,  
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
				if (freq < 26'd12499999) nextSt = WAIT;
				else nextSt = ERASE;
			end
			ERASE: begin
				if (plotCounter <= 6'd15) nextSt = ERASE;
				else nextSt = UPDATE;
			end
			UPDATE: nextSt = DRAW;
			CLEAR: nextSt = (xCounter == 8'd000 & yCounter == 7'd119) ? RESET : CLEAR;
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

module dataPath(input clk, resetn, plotEn, go, erase, update, reset,
					 input [2:0] clr,
					 output reg [7:0] X,
					 output reg [6:0] Y,
					 output reg [2:0] CLR,
					 output reg [5:0] plotCounter,
					 output reg [7:0] xCounter,
					 output reg [6:0] yCounter, 
					 output reg [25:0] freq );
	reg [7:0] xTemp;
	reg [6:0] yTemp;
	reg opX, opY;
	always @(posedge clk) 
	begin
		if (reset || !resetn) begin
			X <= 8'd000;
			Y <= 7'd119;
			xTemp <= 8'd000;
			yTemp <= 7'd119;
			plotCounter<= 6'b0;
			xCounter<= 8'b0;
			yCounter <= 7'b0;
			CLR <= 3'b0;
			freq <= 25'd0;
			opX <= 1'b0;
			opY <= 1'b1;
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
					CLR <= 3'b0; 
				end
			end
			if (!erase) CLR <= clr;
			
			if (freq == 26'd12499999) freq <= 26'd0;
			else freq <= freq + 1;
			
			if (plotEn) begin
				if (erase) CLR <= 0;
				else CLR <= clr;
				if (plotCounter == 6'b10000) plotCounter<= 6'b0;
				else plotCounter <= plotCounter+1;
				X <= xTemp + plotCounter[1:0];
				Y <= yTemp + plotCounter[3:2];
			end
			if (update) begin
				if (X == 8'b0) opX = 1;
				if (X == 8'd156) opX = 0;
				if (Y == 7'b0) opY = 1;
				if (Y == 7'd116) opY = 0;
				
				if (opY == 1'b1) begin
					Y <= Y + 1;
					yTemp <= yTemp + 1;
				end
				if (opY == 1'b0) begin
					Y <= Y - 1;
					yTemp <= yTemp - 1;
				end
			end
		end
	end
endmodule
