module pipelined_adder_8bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       cin,
    output reg  [7:0] sum,
    output reg        cout
);

    // =========================================================================
    // Stage 1 Registers & Internal Signals
    // =========================================================================
    wire [3:0] stage1_sum_low;
    wire       stage1_c4;

    reg  [3:0] reg_sum_low;
    reg        reg_c4;
    reg  [3:0] reg_a_high;
    reg  [3:0] reg_b_high;

    // Stage 1 Logic: Add lower 4 bits
    assign {stage1_c4, stage1_sum_low} = a[3:0] + b[3:0] + cin;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_sum_low <= 4'h0;
            reg_c4      <= 1'b0;
            reg_a_high  <= 4'h0;
            reg_b_high  <= 4'h0;
        end else begin
            reg_sum_low <= stage1_sum_low;
            reg_c4      <= stage1_c4;
            reg_a_high  <= a[7:4]; // Buffer upper bits for Stage 2 alignment
            reg_b_high  <= b[7:4];
        end
    end

    // =========================================================================
    // Stage 2 Registers & Internal Signals
    // =========================================================================
    wire [3:0] stage2_sum_high;
    wire       stage2_cout;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum  <= 8'h00;
            cout <= 1'b0;
        end else begin
            sum  <= {stage2_sum_high, reg_sum_low}; // Concatenate upper and lower sums
            cout <= stage2_cout;
        end
    end
    // Stage 2 Logic: Add upper 4 bits using Stage 1 carry
    assign {stage2_cout, stage2_sum_high} = reg_a_high + reg_b_high + reg_c4;
endmodule
