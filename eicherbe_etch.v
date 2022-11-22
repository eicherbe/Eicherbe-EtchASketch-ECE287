module eicherbe_etch(memSelect, wren, clk, rst, left, right, up, down, vga_output_data);
	input [1:0] memSelect;
	input wren;
	input left, right, up, down;
	input clk, rst;
	output [28:0] vga_output_data;
	
	reg [7:0] r, g, b;
	wire [9:0] x, y;
	reg slow_clk;
	reg [25:0] counter;
	reg [7:0] x_pointer;
	reg [6:0] y_pointer;
		
		
		
	vga disp(clk, rst, r, g, b, x, y, vga_output_data);
	
	wire [7:0] reduced_x;
	assign reduced_x = x[9:2]; // 159 usable pixels
	wire [7:0] reduced_y;
	assign reduced_y = y[9:2]; // 119 usable pixels
	
	wire [13:0] rdaddress;
	assign rdaddress = reduced_x + 160 * reduced_y;	
	
	wire [13:0] wraddress;
	assign wraddress = x_pointer + 160 * y_pointer;
	
	reg q;
	wire q1, q2, q3;
	reg enable1, enable2, enable3;
	
	// FSM Signals and Params
	reg [1:0] S;
	reg [1:0] NS;
	
	// Instantiate IP memory for each pixel on screen
		memory mem1(clk, 1'd1, rdaddress, wraddress, enable1, q1);
		
		memory mem2(clk, 1'd1, rdaddress, wraddress, enable2, q2);
		
		memory mem3(clk, 1'd1, rdaddress, wraddress, enable3, q3);
	
	
	
	always @(posedge clk or negedge rst) begin
	
		if (rst == 1'b0) begin
			
			r <= 0;
			g <= 0;
			b <= 0;			
			
		
		end else begin
		
		
		case(memSelect) // switches 0, 1
			2'd00: begin
					q <= q1;
					if(wren == 1'b1)
						enable1 <= 1'b1;
					else
					begin
						enable1 <= 1'b0;
					end
					enable2 <= 1'b0;
					enable3 <= 1'b0;
					end
					
			2'd01: begin
					q <= q2;
					if(wren == 1'b1)
						enable2 <= 1'b1;
					else
					begin
						enable2 <= 1'b0;
					end
					enable1 <= 1'b0;
					enable3 <= 1'b0;
					end
					
			2'd10: begin
					q <= q3;
					if(wren == 1'b1)
						enable3 <= 1'b1;
					else
					begin
						enable3 <= 1'b0;
					end
					enable1 <= 1'b0;
					enable2 <= 1'b0;
					end
					
			default: begin
					q <= q;
					enable1 <= 1'b0;
					enable2 <= 1'b0;
					enable3 <= 1'b0;
					end
		endcase
	
		counter <= counter + 1'b1;
		if (counter == 26'd10000000) begin
			slow_clk <= 1'd1;
			counter <= 1'd0;
		end else begin
			slow_clk <= 1'd0;
		end
	
		r <= {~q,~q,~q,~q,~q,~q,~q,~q};
		g <= {~q,~q,~q,~q,~q,~q,~q,~q};
		b <= {~q,~q,~q,~q,~q,~q,~q,~q};
		end
	end
	
	always @(posedge slow_clk or negedge rst) begin
	
		if (rst == 1'b0) begin
		
			x_pointer <= 8'd80;
			y_pointer <= 7'd60;
		
		end else begin
		
		
			if (left == 1'b0) begin

				x_pointer <= x_pointer - 1'b1;
				
			end
			
			if (up == 1'b0) begin

				y_pointer <= y_pointer + 1'b1;


			end
			
			if (right == 1'b0) begin

				x_pointer <= x_pointer + 1'b1;
				
			end
			
			if (down == 1'b0) begin

				y_pointer <= y_pointer - 1'b1;


			end
			
			

		end
	
	end
	
endmodule
