
module dinogame (
	// Inputs
	CLOCK_50,
	KEY,
	LEDR,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	disp
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
parameter CLOCK_FREQUENCY = 25000000;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;
output		[9:0] LEDR;
output [31:0] disp;
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires

wire viewScore, return, play, jumping, gen, lose, pause;
wire [7:0] kbData;
wire ld_menu, ld_score, ld_play, reset_game, load_game, ld_generate, ld_game, calc_jump, create_obs, calc_hs, ld_pause;
wire [5:0] currentState, nextState;
wire [15:0]height;
wire [15:0]velocity;
wire [7:0] counter;
wire [$clog2(CLOCK_FREQUENCY):0] elTime;
wire pauseFlag;

wire[$clog2(CLOCK_FREQUENCY):0] scoreKeepTime;
wire[31:0] score, highScore;

wire[31:0] readScore, readHS;
wire[8:0] scoreAddress;
wire highScoreAddress;
wire writeEnS, writeEnHS;
wire kill;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

assign kill = ~KEY[3];
//assign LEDR[8] = kbData == 8'h1C;
//assign LEDR[7] = kbData == 8'h0;
//assign LEDR[6] = jumping == 1'b1;
//assign LEDR[2] = height < 16'd10;
//assign LEDR[0] = height > 16'd10;
//assign LEDR[1] = height == 16'd10;
//
//assign LEDR[5] = velocity < 16'd50;
//assign LEDR[3] = velocity > 16'd50;
//assign LEDR[4] = velocity == 16'd50;
//assign LEDR[0] = ld_menu;
//assign LEDR[9] = ld_play;
//assign LEDR[2] = ld_pause;
//assign LEDR[3] = pause;
//assign LEDR[4] = pauseFlag;
//assign LEDR[6] = viewScore;

assign LEDR[0] = writeEnS;
assign LEDR[9] = writeEnHS;
assign LEDR[2] = scoreAddress == 0;

assign LEDR[6] = viewScore;
assign LEDR[7] = disp == highScore;
assign LEDR[8] = kill;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

FSM #(
	.CLOCK_FREQUENCY(CLOCK_FREQUENCY)
) FSM (
	.Clock(CLOCK_50),
	.reset(KEY[0]),
	.PS2_CLK(PS2_CLK),
	.PS2_DAT(PS2_DAT),
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
	.currentState(currentState),
	.nextState(nextState),
	.height(height),
	.velocity(velocity),
	.counter(counter),
	.elTime(elTime),
	.pauseFlag(pauseFlag),
	.kill(kill)
);

scorekeeper #(
	.CLOCK_FREQUENCY(CLOCK_FREQUENCY)
) scorekeeper (
	.Clock(CLOCK_50),
	.reset(KEY[0]),
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
	.scoreKeepTime(scoreKeepTime),
	.score(score),
	.highScore(highScore),
	.readScore(readScore),
	.readHS(readHS),
	.scoreAddress(scoreAddress),
	.highScoreAddress(highScoreAddress),
	.writeEnS(writeEnS),
	.writeEnHS(writeEnHS)

);

assign disp = currentState == 5'd1 ? highScore : score;

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(disp[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(disp[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);

Hexadecimal_To_Seven_Segment Segment2 (
	// Inputs
	.hex_number			(disp[11:8]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX2)
);

Hexadecimal_To_Seven_Segment Segment3 (
	// Inputs
	.hex_number			(disp[15:12]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX3)
);

Hexadecimal_To_Seven_Segment Segment4 (
	// Inputs
	.hex_number			(scoreAddress[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX4)
);

Hexadecimal_To_Seven_Segment Segment5 (
	// Inputs
	.hex_number			(scoreAddress[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX5)
);



endmodule
