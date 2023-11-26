module FSM #(
	parameter CLOCK_FREQUENCY = 25000000

) (
	input Clock,
	input reset,
	inout PS2_CLK,
	inout PS2_DAT
);

	wire viewScore, return, play, jumping, gen, lose, pause;
	wire [7:0] kbData;
	wire ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause;


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
		.ld_pause(ld_pause)
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
		.kbData(kbData)
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


	output reg ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause
);

	reg [5:0] currentState, nextState;

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
			S_LOAD: nextState = S_GENERATE_SCREEN;
			S_GENERATE_SCREEN: nextState = S_GAME;
			S_GAME: begin
							if (lose) nextState = S_CALC_HS;
							else if (jumping) nextState = S_JUMP;
							else if (gen) nextState = S_OBSTACLE;
							else if (pause) nextState = S_PAUSE;
							else nextState = S_GAME;
						end
			
			S_OBSTACLE: nextState = gen ? S_OBSTACLE : S_GAME;
			S_JUMP: begin
				if (lose) nextState = S_CALC_HS;
				else if (jumping) nextState = S_JUMP;
				else if (gen) nextState = S_OBSTACLE;
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
	parameter CLOCK_FREQUENCY = 25000000
) (
	input Clock,
	input reset,
	input ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause,
	input [7:0] kbData,

	output reg viewScore,
	output reg return,
	output reg play,
	output reg jumping,
	output reg gen,
	output reg lose,
	output reg pause
);
	reg [15:0]height;
	reg [15:0]velocity;
	reg [7:0] counter;
	reg[$clog2(CLOCK_FREQUENCY):0] elTime;

	//Keyboard input handlers
	
	// Jumping
	always@(posedge Clock)
	begin
		if (!reset) begin
			height <= 16'd10;
			velocity <= 0;
			counter <= 0;
			jumping <= 0;
			elTime <= 0;
		end
		else begin
			if (kbData == 8'h1D) begin
				if (!jumping) begin
					height <= 16'd10;
					jumping <= 1'b1;
					velocity <= 16'd50;
					counter <= 0;
				end
			end

			if (calc_jump && jumping) begin
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

			if (height[15] == 1'b1) begin
				height <= 16'd10;
				velocity <= 0;
				counter <= 0;
				jumping <= 0;
				elTime <= 0;
			end
		end
	end

	// Pause
	always@(posedge Clock)
	begin
		if(!reset) begin
			pause <= 1'b0;
		end
		else begin
			if (kbData == 8'h76) begin
				if (!ld_pause) begin
					if (ld_game) begin
						pause <= 1'b1;
					end
				end
				else begin
					pause <= 1'b0;
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
			if (kbData == 8'h29) begin
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

endmodule
