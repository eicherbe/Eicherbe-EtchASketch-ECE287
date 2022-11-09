module vga_template(clk, rst, vga_output_data);
	
	input clk, rst;
	output [28:0] vga_output_data;
	
	reg [7:0] r, g, b;
	wire [9:0] x, y;
	
	reg [8:0] shift;
	
	vga disp(clk, rst, r, g, b, x, y, vga_output_data);
	
	always @(posedge clk or negedge rst) begin
	
		if (rst == 1'b0) begin
			
			r <= 0;
			g <= 0;
			b <= 0;
			shift <= 8'b00000001;
			
		end else begin
		
			if (x > 10'd100 && x < 10'd120) begin // if its at horizontal positions 100-120
				if (y > 10'd100 && y < 10'd150) begin // if at vertical positions 100-150
					r <= 8'b00000000;
					g <= 8'b00000000;
					b <= 8'b00000000;
				end
			end else begin
				r <= 8'b11111111;
				g <= 8'b11111111;
				b <= 8'b11111111;
				shift <= {shift[6:0], shift[7] ^ shift[6]};
			end
		end
	end
endmodule
