// Radix-4 Booth Multiplier for Vivado
// Designed for 8-bit Signed Multiplication
module radix4_multiplier (
    input  signed [7:0] X, // Multiplicand
    input  signed [7:0] Y, // Multiplier
    output signed [15:0] P // Product
);

    wire [15:0] pp[0:3]; // Array for 4 Partial Products
    reg  [15:0] sum;
    integer i;

    // Internal function to generate partial products based on Booth Encoding
    function signed [15:0] get_pp;
        input [2:0] code;
        input signed [7:0] m_cand;
        begin
            case(code)
                3'b000, 3'b111 : get_pp = 16'sd0;           //  0
                3'b001, 3'b010 : get_pp = $signed(m_cand);  // +X
                3'b011         : get_pp = $signed(m_cand) <<< 1; // +2X
                3'b100         : get_pp = -($signed(m_cand) <<< 1); // -2X
                3'b101, 3'b110 : get_pp = -$signed(m_cand); // -X
                default: get_pp = 16'sd0;
            endcase
        end
    endfunction

    // Generate and Shift Partial Products
    // Using a 1-bit overlap for the 3-bit window: {Y[2i+1], Y[2i], Y[2i-1]}
    assign pp[0] = get_pp({Y[1], Y[0], 1'b0}, X);
    assign pp[1] = get_pp({Y[3], Y[2], Y[1]}, X) <<< 2;
    assign pp[2] = get_pp({Y[5], Y[4], Y[3]}, X) <<< 4;
    assign pp[3] = get_pp({Y[7], Y[6], Y[5]}, X) <<< 6;

    assign P = pp[0] + pp[1] + pp[2] + pp[3];

endmodule
