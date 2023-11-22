
module keyboard(
	input wire clk,
	input wire PS2C,
	input wire PS2D,
	input start,
	input parity,
	input stop,
	input resetN,

	output reg[7:0] heldData, pressedData,
	output reg[10:0] data
	);
	
	reg[7:0] currentData, prevData, heldData, pressedData;
	reg[3:0] counter;
	reg error;
	reg keyReleased;

	assign start = data[0];
	assign currentData = data[8:1];
	assign parity = data[9];
	assign stop = data[10];

	initial begin 
		counter <= 0;
		currentData <= 8'b0;
		prevData <= 8'b0;
		data <= 11'b0;
		start <= 0;
		parity <= 0;
		stop <= 0;
		resetN <= 0;
		error <= 0
	end

	always@ (negedge PS2C) begin

		resetN <= 0;

		if (counter < 11) begin
			data[counter] <= PS2D;
			counter <= counter + 1;
		end
		else counter <= 0;

		// case(counter)
		// 	1'b0000: data[0] <= PS2D;
		// 	1'b0001: data[1] <= PS2D;
		// 	1'b0010: data[2] <= PS2D;
		// 	1'b0011: data[3] <= PS2D;
		// 	1'b0100: data[4] <= PS2D;
		// 	1'b0101: data[5] <= PS2D;
		// 	1'b0110: data[6] <= PS2D;
		// 	1'b0111: data[7] <= PS2D;
		// 	1'b1000: data[8] <= PS2D;
		// 	1'b1001: data[9] <= PS2D;
		// 	1'b1010: data[10] <= PS2D;
		// endcase

		if (resetN || error) begin
			counter <= 0;
			currentData <= 8'b0;
			if (resetN) begin
				prevData <= 8'b0;
				heldData <= 8'b0;
				pressedData <= 8'b0;
			end
			data <= 11'b0;
			error <= 0;
			keyReleased <= 0;
		end
	end

	always@(posedge stop) begin
		if (start != 0 || parity ^ currentData[0]) begin
			error = 1'b1;
		end
		else begin
			if (prevData == 8'hF0) begin
				if (currentData == heldData) begin 
					keyReleased <= 1'b1;
					currentData <= 0;
					prevData <= 0;
					heldData <= pressedData;
				end
				else if (currentData == pressedData) begin
					keyReleased <= 1'b1;
					keyReleased <= 1'b1;
					currentData <= 0;
					prevData <= 0;
					pressedData <= 0;
				end
				else begin
					if (heldData == 0) begin
						heldData <= pressedData;
					end
					pressedData <= prevData;
					prevData <= currentData;
					currentData <= 0;
				end
			end
			else begin
				if (heldData == 0) begin
					heldData <= pressedData;
				end
				pressedData <= prevData;
				prevData <= currentData;
				currentData <= 0;
			end
		end
	end

	// always@(posedge keyReleased) begin
		
	// end




endmodule
