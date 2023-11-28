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
	output reg [8:0] scoreAddress,
	output reg highScoreAddress,
	output reg writeEnS, writeEnHS

);
	scoreMemory sm(.address(scoreAddress), .clock(Clock), .data(score), .q(readScore), .wren(writeEnS || !reset));
	HSMemory hsm(.address(highScoreAddress), .clock(Clock), .data(highScore), .q(readHS), .wren(writeEnHS || !reset));
	
	always@(posedge Clock)
	begin
		if (!reset) begin
			score <= 0;
			highScore <= 0;
			highScoreAddress <= 0;
			scoreKeepTime <= 0;
		end
		highScoreAddress <= 1'b0;
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
	
	always@(negedge calc_hs) begin
		if (scoreAddress[8] != 1) begin
			scoreAddress <= scoreAddress + 1;
		end
		else begin
			scoreAddress <= 0;
		end
	end



endmodule
