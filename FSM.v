module FSM #(
	parameter CLOCK_FREQUENCY = 25000000

) (
	input Clock,
	input reset,
	inout PS2_CLK,
	inout PS2_DAT,
	input kill,

	output viewScore, return, play, jumping, gen, lose, pause,
	output [7:0] kbData,
	output [5:0] currentState, nextState,
	output [15:0]height, nextHeight,
	output [15:0]velocity,
	output [7:0] counter,
	output [$clog2(CLOCK_FREQUENCY):0] elTime,
	output ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause,
	output pauseFlag

);
	control control(
		.Clock(Clock),
		.reset(reset),
		.viewScore(viewScore),
		.return(return),
		.play(play),
		.jumping(jumping),
		.gen(gen),
		.lose(lose),
		.pause(pause),
		.ld_menu(ld_menu), 
		.ld_score(ld_score), 
		.ld_play(ld_play), 
		.reset_game(reset_game), 
		.load_game(load_game), 
		.ld_generate(ld_generate), 
		.ld_game(ld_game), 
		.calc_jump(calc_jump), 
		.create_obs(create_obs), 
		.calc_hs(calc_hs),
		.ld_pause(ld_pause),
		.currentState(currentState),
		.nextState(nextState)
	);

	KBDatapath #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY))KBDatapath(
		.Clock(Clock),
		.reset(reset),
		.viewScore(viewScore),
		.return(return),
		.play(play),
		.jumping(jumping),
		.gen(gen),
		.lose(lose),
		.pause(pause),
		.ld_menu(ld_menu), 
		.ld_score(ld_score), 
		.ld_play(ld_play), 
		.reset_game(reset_game), 
		.load_game(load_game), 
		.ld_generate(ld_generate), 
		.ld_game(ld_game), 
		.calc_jump(calc_jump), 
		.create_obs(create_obs), 
		.calc_hs(calc_hs),
		.ld_pause(ld_pause),
		.kbData(kbData),
		.height(height),
		.nextHeight(nextHeight),
		.velocity(velocity),
		.counter(counter),
		.elTime(elTime),
		.pauseFlag(pauseFlag),
		.kill(kill)
	);

	keyboard #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY))keyboard(
		.Clock(Clock), 
		.reset(reset), 
		.PS2_CLK(PS2_CLK), 
		.PS2_DAT(PS2_DAT), 
		.heldData(kbData)
	);
endmodule

module control(
	input Clock,
	input reset,
	input viewScore,
	input return,
	input play,
	input jumping,
	input gen,
	input lose,
	input pause,
	
	output reg [5:0] currentState, nextState,



	output reg ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause
);

	localparam  	MENU	       		 	= 5'd0,
					S_SCORE		   			= 5'd1,
					S_PLAY		 		    = 5'd2,
					S_RESET		 		    = 5'd3,
					S_LOAD					= 5'd4,
					S_GENERATE_SCREEN		= 5'd5,
					S_GAME					= 5'd6,
					S_JUMP					= 5'd7,
					S_OBSTACLE				= 5'd8,
					S_CALC_HS				= 5'd9,
					S_PAUSE					= 5'd10;
	always@(*)
	begin: state_table
		case (currentState)
		
			MENU: begin
							if (viewScore) nextState = S_SCORE;
							else if (play) nextState = S_PLAY;
							else nextState = MENU;
						end
			S_PLAY: nextState = S_RESET;
			S_RESET: nextState = S_LOAD;
			S_LOAD: nextState = S_OBSTACLE;
			S_OBSTACLE: nextState = S_GENERATE_SCREEN;
			S_GENERATE_SCREEN: nextState = S_GAME;
			S_GAME: begin
							if (lose) nextState = S_CALC_HS;
							else if (jumping) nextState = S_JUMP;
							else if (pause) nextState = S_PAUSE;
							else nextState = S_GAME;
						end
			
			S_JUMP: begin
				if (lose) nextState = S_CALC_HS;
				else if (jumping) nextState = S_JUMP;
				else nextState = S_GAME;
			end
			
			S_PAUSE: nextState = pause ? S_PAUSE : S_GAME;
			S_CALC_HS: nextState = S_SCORE;
			S_SCORE: nextState = return ? MENU : S_SCORE;

			default:     nextState = MENU;
		endcase
	end

	
	always@(*)
	begin: outputLogic
		ld_menu = 1'b0;
		ld_score = 1'b0;
		ld_play = 1'b0;
		reset_game = 1'b0;
		load_game = 1'b0;
		ld_generate = 1'b0;
		ld_game = 1'b0;
		calc_jump = 1'b0;
		create_obs = 1'b0;
		calc_hs = 1'b0;
		ld_pause = 1'b0;
		case (currentState)
			MENU: begin
				ld_menu = 1'b1;
				end
				
			S_PLAY: begin
				ld_play = 1'b1;
				end
				
			S_RESET: begin
				reset_game = 1'b1;
				end
				
			S_LOAD: begin
				load_game = 1'b1;
				end
				
			S_GENERATE_SCREEN: begin
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
				end
				
			S_CALC_HS: begin
				calc_hs = 1'b1;
				end
				
			S_SCORE: begin
				ld_score = 1'b1;
				end
		endcase
		
	
	end
	
	
	always@(posedge Clock)
	begin: state_progression
		if(!reset)
			currentState <= MENU;
		else 
			currentState <= nextState;
	end
	
	
endmodule


module KBDatapath #(
	parameter CLOCK_FREQUENCY = 25000000,
	parameter FPS = 1200000
) (
	input Clock,
	input reset,
	input ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause,
	input [7:0] kbData,
	input kill,

	output reg viewScore,
	output reg return,
	output reg play,
	output reg jumping,
	output reg gen,
	output reg lose,
	output reg pause,
	output reg [15:0]height, nextHeight,
	output reg [15:0]velocity,
	output reg [7:0] counter,
	output reg[$clog2(CLOCK_FREQUENCY):0] elTime,
	output reg pauseFlag


);
	initial begin
			height <= 16'd106;
			nextHeight <= 16'd106;
	end
	
	//Keyboard input handlers
	reg[21:0] jumpTimer;
	// Jumping
	always@(posedge Clock)
	begin
		if (!reset || ld_menu) begin
			height <= 16'd106;
			nextHeight <= 16'd106;
			velocity <= 0;
			counter <= 0;
			jumping <= 0;
			elTime <= 0;
			jumpTimer <= 0;
		end
		else begin
			if (kill) begin
				lose <= 1'b1;
			end else begin
				lose <= 1'b0;
			end
			if (kbData == 8'h29) begin
				if (!(ld_game || calc_jump)) begin
					jumping <= 1'b0;
				end
				else if (!jumping) begin
					height <= 16'd106;
					nextHeight <= 16'd106;
					jumping <= 1'b1;
					velocity <= 16'd6;
					counter <= 0;
				end
			end

			if (calc_jump && jumping) begin
				if (elTime != 0) begin 
					elTime <= elTime - 1;
				end
				else begin
					elTime <= CLOCK_FREQUENCY/10 - 1;
					counter <= counter + 1;
					velocity <= velocity - counter;
				end

				if (jumpTimer != 0) begin 
					jumpTimer <= jumpTimer - 1;
				end
				else begin
					jumpTimer <= 21'd833333;
					height <= nextHeight;
					nextHeight <= nextHeight - (velocity*counter);
				end
			end

			if (nextHeight > 16'd106) begin
				height <= 16'd106;
				nextHeight <= 16'd106;
				velocity <= 0;
				counter <= 0;
				jumping <= 0;
				elTime <= 0;
				jumpTimer <= 0;
			end
		end
	end
	
	// Pause
	always@(posedge Clock)
	begin
		if(!reset) begin
			pause <= 1'b0;
			pauseFlag <= 1'b0;
		end
		else begin
			if (kbData == 8'h76) begin
				if (!ld_pause) begin
					if (ld_game) begin
						pauseFlag <= 1'b1;
					end
				end
				if (ld_pause) begin
					pauseFlag <= 1'b1;
				end
			end
			
			if (kbData == 8'h00) begin
				if (ld_pause && pauseFlag) begin
					pauseFlag <= 1'b0;
					pause <= 1'b0;
				end
				else if (pauseFlag) begin
					pauseFlag <= 1'b0;
					pause <= 1'b1;
				end
			end
		end
	end


	// Return
	always@(posedge Clock)
	begin
		if(!reset) begin
			return <= 1'b0;
		end
		else begin
			if (kbData == 8'h59) begin
				if (ld_score) begin
					return <= 1'b1;
				end
				else begin
					return <= 1'b0;
				end
			end
			else begin
				return <= 1'b0;
			end
		end
	end

	// View Score
	always@(posedge Clock)
	begin
		if(!reset) begin
			viewScore <= 1'b0;
		end
		else begin
			if (kbData == 8'h16) begin
				if (ld_menu) begin
					viewScore <= 1'b1;
				end
				else begin
					viewScore <= 1'b0;
				end
			end
			else begin
				viewScore <= 1'b0;
			end
		end
	end

		// Play
	always@(posedge Clock)
	begin
		if(!reset) begin
			play <= 1'b0;
		end
		else begin
			if (kbData == 8'h5A) begin
				if (ld_menu) begin
					play <= 1'b1;
				end
				else begin
					play <= 1'b0;
				end
			end
			else begin
				play <= 1'b0;
			end
		end
	end
	
endmodule 