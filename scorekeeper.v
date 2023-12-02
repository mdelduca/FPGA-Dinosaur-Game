module scorekeeper #(
	parameter CLOCK_FREQUENCY = 25000000
) (
	input Clock,
	input reset,
	input ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause,
	input [7:0] kbData,

	input viewScore,
	input return,
	input play,
	input jumping,
	input gen,
	input lose,
	input pause,
	
	output reg[$clog2(CLOCK_FREQUENCY):0] scoreKeepTime,
	output reg [31:0] score, highScore,

	output [31:0] readScore, readHS,
	output reg [7:0] scoreAddress,
	output reg highScoreAddress,
	output reg writeEnS, writeEnHS

);
	scoreMemory sm(.address(scoreAddress), .clock(Clock), .data(score), .q(readScore), .wren(writeEnS || !reset));
	HSMemory hsm(.address(highScoreAddress), .clock(Clock), .data(highScore), .q(readHS), .wren(writeEnHS || !reset));
	
	reg currentLoad, prevLoad;
	wire posedgeLoadPlay;
	reg incremented;

	always@(posedge Clock)
	begin
		prevLoad <= currentLoad;
		currentLoad <= ld_play;
	end

	assign posedgeLoadPlay = (currentLoad == 1'b1 && prevLoad == 1'b0);

	always@(posedge Clock)
	begin
		if (!reset)
		begin
			scoreAddress <= 1'b0;
			incremented <= 1'b0;
		end
		else if (posedgeLoadPlay) begin
			if (!ld_pause && !incremented) begin
				if (scoreAddress != 8'b11111111) begin
					scoreAddress <= scoreAddress + 1;
					incremented <= 1'b1;
				end
				else begin
					scoreAddress <= 0;
				end
			end
		end

		if (reset_game)
		begin
			incremented <= 1'b0;
		end
	end

	always@(posedge Clock)
	begin
		if (!reset) begin
			score <= 0;
			highScore <= 0;
			highScoreAddress <= 0;
			scoreKeepTime <= 0;
		end
		highScoreAddress <= 1'b0;
		if (reset_game) begin
			writeEnS <= 1'b1;
		end
		
		if (load_game) begin
			score <= 0;
		end
		
		if (ld_game || calc_jump) begin
			writeEnS <= 1'b1;
			if (scoreKeepTime != 0) begin 
				scoreKeepTime <= scoreKeepTime - 1;
			end
			else begin
				scoreKeepTime <= CLOCK_FREQUENCY/10 - 1;
				score <= score + 1;
			end
		end
		else begin
			writeEnS <= 1'b0;
		end
		
		if (!(ld_game || calc_jump) && !writeEnS) begin
			score <= 0;
		end
		if (calc_hs) begin
			writeEnS <= 1'b0;
			if (readHS < readScore) begin
				writeEnHS <= 1'b1;
				highScore <= readScore;
			end
		end else begin
			writeEnHS <= 1'b0;
		end
	end
	
	// always@(posedge ld_play) begin
	// 	if (!ld_pause) begin
	// 		if (scoreAddress != 8'b11111111) begin
	// 			scoreAddress <= scoreAddress + 1;
	// 		end
	// 		else begin
	// 			scoreAddress <= 0;
	// 		end
	// 	end
	// end



endmodule
