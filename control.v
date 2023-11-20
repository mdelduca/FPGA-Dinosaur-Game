module control(
input Clock,
input viewScore,
input return,
input play,
input jump,
input gen,
input lose,
input pause,
input reset
);


reg [5:0] currentState, nextState;

	localparam  MENU	       		   = 5'd0,
					S_SCORE		   		= 5'd1,
					S_PLAY		 		   = 5'd2,
					S_RESET		 		   = 5'd3,
					S_LOAD					= 5'd4,
					S_GENERATE_SCREEN		= 5'd5,
					s_GAME					= 5'd6,
					S_JUMP					= 5'd7,
					S_OBSTACLE				= 5'd8,
					S_CALC_HS				= 5'd9,
					S_PAUSE					= 5'd10;
	always@(*)
	begin: state_table
		case (currentState)
		
			MENU: begin
							if (score) nextState = S_SCORE;
							else if (play) nextState = S_PLAY;
							else nextState = MENU;
						end
			S_PLAY: nextState = S_RESET;
			S_RESET: nextState = S_LOAD;
			S_LOAD: nextState = S_GENERATE_SCREEN;
			S_GENERATE_SCREEN: nextState = S_GAME;
			S_GAME: begin
							if (lose) nextState = S_CALC_HS;
							else if (jump) nextState = S_JUMP;
							else if (gen) nextState = S_OBSTACLE;
							else if (pause) nextState = S_PAUSE;
							else nextState = S_GAME;
						end
			
			S_OBSTACLE: nextState = gen ? S_OBSTACLE : S_GAME;
			S_JUMP: begin
				if (lose) nextState = S_CALC_HS;
				else if (jump) nextState = S_JUMP;
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
		
		case (currentState)
			MENU: begin
				end
			S_PLAY: begin
				end
			S_RESET: begin
				end
			S_LOAD: begin
				end
			S_GENERATE_SCREEN: begin
				end
			S_GAME: begin
				end
			S_JUMP: begin
				end
			S_OBSTACLE: begin
				end
			S_PAUSE: begin
				end
			S_CALC_HS: begin
				end
			S_SCORE: begin
				end
		endcase
		
	
	end
	
	
	always@(posedge Clock)
	begin: state_progression
		if(reset)
			currentState <= MENU;
		else 
			currentState <= nextState;
	end
	
	
endmodule
