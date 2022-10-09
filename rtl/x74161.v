//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2022, Pierre Cornier (Pierco)
//------------------------------------------------------------------------------

module x74161 (
        input            cl_n,
        input            clk,
        input            ld_n,
        input            ep,
        input            et,
        input      [3:0] P,
        output reg [3:0] Q,
        output           co
    );

    wire [3:0] nq = Q + 4'd1;
    assign co = et & (&Q);

    always @(posedge clk) begin
        if (~cl_n)          Q <= 4'd0;
        if (~ld_n)          Q <= P;
        if (ld_n & ep & et) Q <= nq;
    end

endmodule
