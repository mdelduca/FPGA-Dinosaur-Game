module screen(	
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
		ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause,
		kill

	);
	input ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause;
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
	output reg kill;
	
	// dino colour, x and y pixels, and signals
	wire [2:0] dinoColour;
	reg [7:0] dinoX;
	reg [15:0] dinoY;
	wire dinoGo, dinoErase, dinoPlotEn, dinoUpdate, dinoReset, dinoSignal;
	
	// obstacle colour, x and y pixels, and signals
	wire [2:0] obstacleColour;
	reg [7:0] obstacleX;
	reg [6:0] obstacleY;
	reg [4:0] obstacleH;
	reg [3:0] obstacleW;
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

	// Create an Instance of a VGA controller 
	assign oX = currentSt;
	assign oY = nextSt;
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
		wire vsposedge;
		wire vsnegedge;
	
		reg lastVS;
		reg currVS;

	
		assign vsposedge = (lastVS == 1'b0 && currVS == 1'b1);
		assign vsnegedge = (lastVS == 1'b1 && currVS == 1'b0);
		
		reg [7:0] xBG;
		reg [6:0] yBG;
		reg[2:0] col;
		reg bgGo;
		
		reg [14:0] add1;
		reg [14:0] add2;
		reg [14:0] add3;

		wire [3:0] read1;
		wire [3:0] read2;
		wire [3:0] read3;

		reg[17:0] obsHC;
		reg[15:0] obsWC;
		reg [2:0] currentSt, nextSt;
		reg done;
		reg [25:0] freq;

		loseScreen ls(add1, CLOCK_50, read1);
		menuScreen ms(add2, CLOCK_50, read2);
		background bg(add3, CLOCK_50, read3);

//		assign vgaX = ld_menu || ld_score ? xBG : 0;
//		assign vgaY = ld_menu || ld_score? yBG : 0;
//		assign vgaColour = ld_menu || ld_score? col : 0;
//		assign vgaGo = ld_menu || ld_score? bgGo : 0;
		
		
		assign vgaX = xBG;
		assign vgaY = yBG;
		assign vgaColour = col;
		assign vgaGo = bgGo;
		
		initial begin
			xBG <= 0;
			yBG <= 0;
			bgGo <= 0;
			dinoX <= 7'd10;
			dinoY <= 15'd106;
			obstacleX <= 7'd150 - obstacleW;
			obstacleY <= 7'd106 - obstacleH;
			obstacleW <= 7'd3;
			obstacleH <= 7'd10;
		end
		
		always@(posedge CLOCK_50) begin
			if (obsHC < 19'b111111111111111111) begin
				obsHC <= obsHC + 1;
			end
			else begin
				obsHC <= 0;
			end
		end
		
		always@(posedge CLOCK_50) begin
			if (obsWC < 17'b1111111111111111) begin
				obsWC <= obsWC + 1;
			end
			else begin
				obsWC <= 0;
			end
		end
		
		always@(posedge CLOCK_50)
		begin
			lastVS	<= currVS;
			currVS		<= VGA_VS;
		end
		
		always@(posedge CLOCK_50) begin
			if (ld_game || calc_jump) begin
				if (obstacleX <= dinoX + 3) begin
					if (obstacleY - obstacleH  <= dinoY + 3) begin
						kill <= 1'b1;
					end
				end
			end
			else if (ld_menu) begin
				kill <= 0;
			end
		end
		
		always@(posedge CLOCK_50) begin
			if (!calc_jump) begin
				dinoY <= 15'd106;
			end
			if (create_obs) begin
				obstacleX <= 8'd130;
				obstacleY <= 7'd106;
			end
		
		
			if (vsnegedge) begin
				bgGo <= 1'b1;
				if (!ld_pause) begin obstacleX <= obstacleX - 3; end
				obstacleY <= obstacleY;
				if (obstacleX == 159) begin
					obstacleH <= {obsHC[17:15], 1'b1, obsWC[3]};
					obstacleW <= {obsWC[15:13], 1'b1};

				end
			end
			if (bgGo) begin
				dinoX <= dinoX;
				dinoY <= height;
				if (ld_menu) begin
					if (yBG < 7'd120) begin
						if (xBG < 8'd160) begin
							col <= read2;
							add2 <= add2 + 1;
							xBG <= xBG + 1;
						end
						else begin
							xBG <= 0;
							yBG <= yBG + 1;
						end
					end
					else begin
						yBG <= 0;
						add2 <= 0;
						bgGo <= 1'b0;

					end
				end
				
				else if (ld_score) begin
					if (yBG < 7'd120) begin
						if (xBG < 8'd160) begin
							col <= read1;
							add1 <= add1 + 1;
							xBG <= xBG + 1;
						end
						else begin
							xBG <= 0;
							yBG <= yBG + 1;
						end
					end
					else begin
						yBG <= 0;
						add1 <= 0;
						bgGo <= 1'b0;

					end
				end

				else if (ld_generate || ld_game || calc_jump) begin
						if (yBG < 7'd120) begin
							if (xBG < 8'd160) begin
								if (yBG == 7'd110 || ((xBG >= obstacleX && xBG <= obstacleX + obstacleW) && (yBG >= obstacleY - obstacleH + 3 && yBG <= obstacleY + 3)) || ((xBG >= dinoX && xBG <= dinoX + 3) && (yBG >= dinoY && yBG <= dinoY + 3))) begin
										col <= 3'b000;
								end else col <= read3;
								add3 <= add3 + 1;
								xBG <= xBG + 1;
							end
							else begin
								xBG <= 0;
								yBG <= yBG + 1;
							end
						end
						else begin
							yBG <= 0;
							done <= 1'b1;
							bgGo <= 1'b0;
							add3 <= 0;

						end
					end
					
				else if (ld_pause) begin
					if (yBG < 7'd120) begin
						if (xBG < 8'd160) begin
							if (yBG == 7'd110 || ((xBG >= obstacleX && xBG <= obstacleX + obstacleW) && (yBG >= obstacleY - obstacleH + 3 && yBG <= obstacleY + 3)) || ((xBG >= dinoX && xBG <= dinoX + 3) && (yBG >= dinoY && yBG <= dinoY + 3))) begin
								col <= 3'b000;
							end else col <= read3;
							add3 <= add3 + 1;
							xBG <= xBG + 1;
						end
						else begin
							xBG <= 0;
							yBG <= yBG + 1;
						end
					end
					else begin
						yBG <= 0;
						add3 <= 0;
						bgGo <= 1'b0;

					end
				end
					
					else begin
						if (yBG < 7'd120) begin
							col <= 0;
							if (xBG < 8'd160) begin
								xBG <= xBG + 1;
							end
							else begin
								xBG <= 0;
								yBG <= yBG + 1;
							end
						end
						else begin
							yBG <= 0;
							done <= 1'b0;
							bgGo <= 1'b0;
						end
					end
				
			end
		end
		
	

endmodule
