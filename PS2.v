
module PS2_Controller(
	input Clock,
	input reset,

	inout PS2_CLK,
	inout PS2_DAT,


//		 ld_start, ld_data, ld_parity, ld_end,
	output	reg[7:0] transmit,
	output	reg keyPressed

	
);
	reg[7:0] data;
	reg [7:0] breakCode;
	reg [4:0] currentState, nextState;
	reg[3:0] counter;
	reg lastPS2CLK;
	reg currPS2CLK;

	reg rawData;
//	reg[7:0] transmit;
	reg start;
	reg parity;
	reg stop;
	wire ps2posedge;
	wire ps2negedge;
	
	assign ps2posedge = (lastPS2CLK == 1'b0 && currPS2CLK == 1'b1);
	assign ps2negedge = (lastPS2CLK == 1'b1 && currPS2CLK == 1'b0);

	

	localparam  	IDLE	       		= 5'd0,
//						START		 		   = 5'd1,
						DATA		 		   = 5'd2,
						PARITY				= 5'd3,
						STOP					= 5'd4,
						DONE					= 5'd5,
						DATA0		 		   = 5'd6,
						DATA1		 		   = 5'd7,
						DATA2		 		   = 5'd8,
						DATA3		 		   = 5'd9,
						DATA4		 		   = 5'd10,
						DATA5		 		   = 5'd11,
						DATA6		 		   = 5'd12,
						DATA7		 		   = 5'd13;
	always@(posedge Clock)
	begin
		lastPS2CLK	<= currPS2CLK;
		currPS2CLK		<= PS2_CLK;
		
		rawData <= PS2_DAT;
	end
	
	always@(posedge Clock)
	begin
		if (currentState != DATA) begin
			counter <= 3'd0;
		end
		else begin
			if (currentState == DATA && ps2posedge) begin
				counter <= counter + 1;
			end
		end
	end
	
	always@(posedge Clock)
	begin
		if (!reset) begin
			breakCode <= 8'h00;
		end
		if (data == 8'hF0) begin
			breakCode <= 8'hF0;
		end
	end
	
	always@(posedge Clock)
	begin
		if (!reset) begin
			keyPressed <= 1'b0;
		end
		else if (currentState == STOP && ps2posedge) begin
			keyPressed <= 1'b1;
		end
		else begin
			keyPressed <= 1'b0;

		end
	end
	
		
	always@(*)
	begin: state_table
		case (currentState)
			IDLE: begin
				if (ps2posedge == 1'b1 && rawData == 1'b0) begin
					start <= rawData;
					nextState = DATA0;
				end
				else begin
					nextState = IDLE;
				end
			end

			
			DATA0: begin
				if (ps2posedge == 1'b1) begin
					data[0] <= rawData;
					nextState = DATA1;
				end
				else begin
					nextState = DATA0;
				end
			end
			
			DATA1: begin
				if (ps2posedge == 1'b1) begin
					data[1] <= rawData;
					nextState = DATA2;
				end
				else begin
					nextState = DATA1;
				end
			end
			
			DATA2: begin
				if (ps2posedge == 1'b1) begin
					data[2] <= rawData;
					nextState = DATA3;
				end
				else begin
					nextState = DATA2;
				end
			end
		
			DATA3: begin
				if (ps2posedge == 1'b1) begin
					data[3] <= rawData;
					nextState = DATA4;
				end
				else begin
					nextState = DATA3;
				end
			end
			
			DATA4: begin
				if (ps2posedge == 1'b1) begin
					data[4] <= rawData;
					nextState = DATA5;
				end
				else begin
					nextState = DATA4;
				end
			end
			
			DATA5: begin
				if (ps2posedge == 1'b1) begin
					data[5] <= rawData;
					nextState = DATA6;
				end
				else begin
					nextState = DATA5;
				end
			end
			
			DATA6: begin
				if (ps2posedge == 1'b1) begin
					data[6] <= rawData;
					nextState = DATA7;
				end
				else begin
					nextState = DATA6;
				end
			end
		
			DATA7: begin
				if (ps2posedge == 1'b1) begin
					data[7] <= rawData;
					nextState = PARITY;
				end
				else begin
					nextState = DATA7;
				end
			end
			
			PARITY: begin
				if (ps2posedge == 1'b1) begin
					parity <= rawData;
					nextState = STOP;
				end
				else begin
					nextState = PARITY;
				end
			end
			
			STOP: begin
				if (ps2posedge == 1'b1 && rawData == 1'b1) begin
					stop <= rawData;
					nextState = DONE;
				end
				else begin
					nextState = STOP;
				end
			end
			
			DONE: begin
				if (start == 1'b0 && stop == 1'b1) begin
					transmit <= data;
					nextState = IDLE;
				end
				else begin
					nextState = DONE;
				end
			end
			
			default: nextState = IDLE;
			
		endcase
	end

	
	always@(posedge Clock)
	begin: state_progression
		if(!reset)
			currentState <= IDLE;
		else 
			currentState <= nextState;
	end
	
endmodule
