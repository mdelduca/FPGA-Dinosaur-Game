
module keyboard(
	input wire PS2_CLK,
	input wire PS2_DAT,
	input resetN,

	output start,
	output parity,
	output stop,
	output reg keyReleased,
	output reg[10:0] data,
	output reg[7:0] heldData, pressedData
	);
	
	reg[3:0] oneCount;
	reg[7:0] currentData, prevData;
	reg[3:0] counter;
	reg error;
	reg flag;

	assign start = data[0];
	assign parity = data[9];
	assign stop = data[10];

	initial begin 
		counter <= 0;
		currentData <= 8'b0;
		prevData <= 8'b0;
		data <= 11'b0;
		oneCount <= 0;
	end

	always@ (negedge PS2_CLK) begin
		error <= 0;
		if (start == 1'b1) begin
			error <= 1'b1;
		end
		if (counter < 11) begin
			oneCount <= oneCount + PS2_DAT;
			data[counter] <= PS2_DAT;
			currentData <= data[8:1];
			counter <= counter + 1;
		end
		else begin 
			counter <= 0;
			data <= 0;
			oneCount <= 0;
		end

		if (resetN || error) begin
			counter <= 0;
			currentData <= 8'b0;
			oneCount <= 0;
			if (resetN) begin
				prevData <= 8'b0;
				heldData <= 8'b0;
				pressedData <= 8'b0;
			end
			data <= 11'b0;
			keyReleased <= 0;
		end
	end

	always@(posedge stop) begin
		if (start != 0 || parity==oneCount[0] || currentData == 0 || currentData == 8'hFF) begin
			error <= 1'b1;
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

	always@(posedge keyReleased) begin
		
	end




endmodule

module keyController
(
	input wire PS2_CLK,
	input wire PS2_DAT,
	input resetN,
	input keyReleased,
	input[7:0] heldData, pressedData,

	output reg jump, pause
);
	
endmodule
