//------------------------------------------------------------------------------
// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileType: SOURCE
// SPDX-FileCopyrightText: (c) 2022, Pierre Cornier (Pierco)
//------------------------------------------------------------------------------

module bankpanic(
        input reset,
        input clk_sys,

        input [7:0] p1,
        input [7:0] p2,
        input [7:0] p3,
        input [7:0] dsw,

        input [7:0]  ioctl_index,
        input        ioctl_download,
        input [26:0] ioctl_addr,
        input [15:0] ioctl_dout,
        input        ioctl_wr,

        output [2:0] red,
        output [2:0] green,
        output [1:0] blue,
        output reg   vb,
        output       hb,
        output       vs,
        output reg   hs,
        output       ce_pix,
        input  [4:0] hoffs,

        output [15:0] sound

    );

    /******** LOAD ROMs ********/

    wire [7:0]  mcpu_rom_data     = ioctl_dout[7:0];
    wire [13:0] mcpu_rom0_addr    = ioctl_download ? ioctl_addr : mcpu_addr[13:0];
    wire        mcpu_rom0_wren_a  = ioctl_download && ioctl_addr < 27'h4000 ? ioctl_wr : 1'b0;
    wire [13:0] mcpu_rom1_addr    = ioctl_download ? ioctl_addr : mcpu_addr[13:0];
    wire        mcpu_rom1_wren_a  = ioctl_download && ioctl_addr < 27'h8000 ? ioctl_wr : 1'b0;
    wire [13:0] mcpu_rom2_addr    = ioctl_download ? ioctl_addr : mcpu_addr[13:0];
    wire        mcpu_rom2_wren_a  = ioctl_download && ioctl_addr < 27'hc000 ? ioctl_wr : 1'b0;
    wire [13:0] mcpu_rom3_addr    = ioctl_download ? ioctl_addr : mcpu_addr[13:0];
    wire        mcpu_rom3_wren_a  = ioctl_download && ioctl_addr < 27'hf000 ? ioctl_wr : 1'b0;

    wire [7:0]  col_data      = ioctl_dout;
    wire [7:0]  fg_color_addr = ioctl_download ? ioctl_addr - 27'h20020 : rc_addr;
    wire        fg_color_wren = ioctl_download && ioctl_addr >= 27'h20020 && ioctl_addr < 27'h20120 ? ioctl_wr : 1'b0;
    wire [7:0]  bg_color_addr = ioctl_download ? ioctl_addr - 27'h20120 : sc_addr;
    wire        bg_color_wren = ioctl_download && ioctl_addr >= 27'h20120 && ioctl_addr < 27'h20220 ? ioctl_wr : 1'b0;
    wire [4:0]  pal_addr      = ioctl_download ? ioctl_addr - 27'h20000 : { back, col };
    wire        pal_wren      = ioctl_download && ioctl_addr >= 27'h20000 && ioctl_addr < 27'h20020 ? ioctl_wr : 1'b0;

    wire [7:0]  gfx_rom_data     = ioctl_dout;
    wire [12:0] gfx_rom1_addr    = ioctl_download ? ioctl_addr - 27'h10000 : rca[12:0];
    wire        gfx_rom1_wren_a  = ioctl_download && ioctl_addr >= 27'h10000 && ioctl_addr < 27'h12000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom2_addr    = ioctl_download ? ioctl_addr - 27'h12000 : rca[12:0];
    wire        gfx_rom2_wren_a  = ioctl_download && ioctl_addr >= 27'h12000 && ioctl_addr < 27'h14000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom3_addr    = ioctl_download ? ioctl_addr - 27'h14000 : sca[12:0];
    wire        gfx_rom3_wren_a  = ioctl_download && ioctl_addr >= 27'h14000 && ioctl_addr < 27'h16000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom4_addr    = ioctl_download ? ioctl_addr - 27'h16000 : sca[12:0];
    wire        gfx_rom4_wren_a  = ioctl_download && ioctl_addr >= 27'h16000 && ioctl_addr < 27'h18000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom5_addr    = ioctl_download ? ioctl_addr - 27'h18000 : sca[12:0];
    wire        gfx_rom5_wren_a  = ioctl_download && ioctl_addr >= 27'h18000 && ioctl_addr < 27'h1a000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom6_addr    = ioctl_download ? ioctl_addr - 27'h1a000 : sca[12:0];
    wire        gfx_rom6_wren_a  = ioctl_download && ioctl_addr >= 27'h1a000 && ioctl_addr < 27'h1c000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom7_addr    = ioctl_download ? ioctl_addr - 27'h1c000 : sca[12:0];
    wire        gfx_rom7_wren_a  = ioctl_download && ioctl_addr >= 27'h1c000 && ioctl_addr < 27'h1e000 ? ioctl_wr : 1'b0;
    wire [12:0] gfx_rom8_addr    = ioctl_download ? ioctl_addr - 27'h1e000 : sca[12:0];
    wire        gfx_rom8_wren_a  = ioctl_download && ioctl_addr >= 27'h1e000 && ioctl_addr < 27'h20000 ? ioctl_wr : 1'b0;

    /******** RGB ********/

    reg [7:0] color;
    always @(posedge clk_sys)
        if (clk_en_514)
            color <= u8H[2] ? pal_data : 8'd0;

    assign ce_pix = clk_en_514;
    assign { blue, green, red } = color;

    /******** CLOCKS ********/

    // 36/14         =2.5714
    // 36/7          =5.1429

    wire clk_en_257, clk_en_514;
    clk_en #(13)  mcpu_clk_en(clk_sys, clk_en_257);
    clk_en #(6) pxl_clk_en(clk_sys, clk_en_514);


    /******** PAL 315-5074 ********/

    wire rld_n      = ~(&sh[1:0] & hcount[8]);
    wire rch_set_n  = ~(sh[0] & ~sh[1] & sh[2] & hcount[8]);
    wire rcol_set_n = ~(sh[0] & sh[1] & ~sh[2] & hcount[8]);
    wire rad_sel_n  = hcount[8] & ~vb;
    wire sld_n      = ~(&hcount[2:0] & hcount[8]);
    wire sch_set_n  = ~(hcount[0] & ~hcount[1] & ~hcount[2] & hcount[8]);
    wire scol_set_n = ~(hcount[0] & hcount[1] & ~hcount[2] & hcount[8]);
    wire sad_sel_n  = ~hcount[2] & ~vb;

    /******** PAL 315-5075 ********/

    reg cpusel_n;
    reg o13; // cpu wait
    reg rf16, rf15, rf14, rf13;

    wire pre = ~hcount[8];
    reg oldh2;
    always @(posedge clk_sys) begin
        oldh2 <= hcount[2];
        if (~pre)
            cpusel_n <= 1'b1;
        if (pre & ~oldh2 & hcount[2]) begin
            cpusel_n <= hcount[5] & hs;
        end
    end

    wire srwr_n = ~((vb & ~sram_cs_n & ~mcpu_wr_n)
                    | (~sram_cs_n & ~mcpu_wr_n & rf16));
    wire rrwr_n = ~((vb & ~rram_cs_n & ~mcpu_wr_n)
                    | (~rram_cs_n & sram_cs_n & ~mcpu_wr_n & ~hcount[8] & ~cpusel_n)
                    | (~rram_cs_n & ~mcpu_wr_n & ~hcount[8] & ~cpusel_n & rf15));


    always @(posedge clk_en_514) begin
        o13 <= ~((~vb & ~sram_cs_n & ~rf15)
                 | (~vb & ~rram_cs_n & cpusel_n));
        rf14 <= ~vb & ~sram_cs_n & ~rf15;
        rf15 <= (rf15 & ~sram_cs_n)
             | (hcount[0] & hcount[1] & ~hcount[2] & rf14);
        rf16 <= (rf16 & ~sram_cs_n)
             | (~sram_cs_n & rf15);
    end


    /******** VIDEO ********/

    wire [8:0] hcount;
    wire [8:0] vcount;
    wire u1D_co;
    wire u1E_co;
    wire u1G_co;
    wire u1H_co;

    reg h0;
    always @(posedge clk_en_514)
        h0 <= ~h0;

    assign hcount[0] = h0;
    assign hb = hcount[8:0] > 192 && hcount[8:0] <= 256 + 32;

    x74161 u1G(
               .cl_n ( 1'b1        ),
               .clk  ( clk_en_514  ),
               .ld_n ( ~u1G_co     ),
               .ep   ( u1H_co      ),
               .et   ( u1H_co      ),
               .P    ( 4'b0110     ),
               .Q    ( hcount[8:5] ),
               .co   ( u1G_co      )
           );

    x74161 u1H(
               .cl_n ( 1'b1        ),
               .clk  ( clk_en_514  ),
               .ld_n ( 1'b1        ),
               .ep   ( h0          ),
               .et   ( h0          ),
               .P    ( 4'b0        ),
               .Q    ( hcount[4:1] ),
               .co   ( u1H_co      )
           );

    // 1C
    wire [8:0] hc2 = hcount - hoffs;
    always @(posedge clk_sys) begin
        if (~oldh2 & hc2[2]) begin
            if (hc2[8])
                hs <= 1'b0;
            else
                hs <= ~|hc2[5:4];
        end
    end

    reg phs, v0;
    wire vclk = hs & ~phs;
    always @(posedge clk_en_514) begin
        phs <= hs;
        if (vclk)
            v0 <= ~v0;
    end

    reg pv4;
    always @(posedge clk_en_514) begin
        pv4 <= vcount[4];
        if (~pv4 & vcount[4])
            vb <= &vcount[7:5];
    end

    assign vs = vcount[8];
    assign vcount[0] = v0;

    x74161 u1D(
               .cl_n ( 1'b1        ),
               .clk  ( vclk        ),
               .ld_n ( ~u1D_co     ),
               .ep   ( u1E_co      ),
               .et   ( u1E_co      ),
               .P    ( 4'b0111     ),
               .Q    ( vcount[8:5] ),
               .co   ( u1D_co      )
           );

    x74161 u1E(
               .cl_n ( 1'b1        ),
               .clk  ( vclk        ),
               .ld_n ( ~u1D_co     ),
               .ep   ( v0          ),
               .et   ( v0          ),
               .P    ( 4'b1100     ),
               .Q    ( vcount[4:1] ),
               .co   ( u1E_co      )
           );


    /******** MCPU ********/

    wire wait_n = o13 & rdy_n;

    reg   [7:0] mcpu_din;
    wire [15:0] mcpu_addr;
    wire  [7:0] mcpu_dout;
    wire        mcpu_rd_n;
    wire        mcpu_wr_n;
    wire        mcpu_m1_n;
    wire        mcpu_mreq_n;
    wire        mcpu_iorq_n;
    wire        mcpu_rfsh_n;
    reg         mcpu_nmi_n;
    wire        mcpu_wait_n = wait_n;

    // u8H is used by the CPU to reset NMI state

    reg oldvb;
    always @(posedge clk_sys) begin
        oldvb <= vb;
        if (~oldvb & vb & u8H[4]) begin
            mcpu_nmi_n <= 1'b0;
        end
        if (~u8H[4])
            mcpu_nmi_n <= 1'b1;
    end

    tv80s mcpu(
              .reset_n ( ~reset      ),
              .clk     ( clk_sys     ),
              .cen     ( clk_en_257  ),
              .wait_n  ( mcpu_wait_n ),
              .int_n   ( 1'b1        ),
              .nmi_n   ( mcpu_nmi_n  ),
              .busrq_n ( 1'b1        ),
              .m1_n    ( mcpu_m1_n   ),
              .mreq_n  ( mcpu_mreq_n ),
              .iorq_n  ( mcpu_iorq_n ),
              .rd_n    ( mcpu_rd_n   ),
              .wr_n    ( mcpu_wr_n   ),
              .rfsh_n  ( mcpu_rfsh_n ),
              .halt_n  (             ),
              .busak_n (             ),
              .A       ( mcpu_addr   ),
              .di      ( mcpu_din    ),
              .dout    ( mcpu_dout   )
          );

    /******** MCPU MEMORY CS ********/

    wire [3:0] u7A_Y1;
    wire [3:0] u7A_Y2;
    wire [3:0] u7B_Y1;
    wire [3:0] u7B_Y2;

    x74139 u7A(
               .E1 ( u7B_Y2[3]               ),
               .A1 ( { mcpu_addr[13], 1'b0 } ),
               .O1 ( u7A_Y1                  ),
               .E2 ( u7A_Y1[2]               ),
               .A2 ( mcpu_addr[12:11]        ),
               .O2 ( u7A_Y2                  )
           );

    x74139 u7B(
               .E1 ( mcpu_mreq_n           ),
               .A1 ( { mcpu_rfsh_n, 1'b0 } ),
               .O1 ( u7B_Y1                ),
               .E2 ( u7B_Y1[2]             ),
               .A2 ( mcpu_addr[15:14]      ),
               .O2 ( u7B_Y2                )
           );

    wire mcpu_rom_cs_n_0 = u7B_Y2[0]; // $0000-$3fff
    wire mcpu_rom_cs_n_1 = u7B_Y2[1]; // $4000-$7fff
    wire mcpu_rom_cs_n_2 = u7B_Y2[2]; // $8000-$bfff
    wire mcpu_rom_cs_n_3 = u7A_Y1[0]; // $c000-$ffff

    wire wram_cs_n = u7A_Y2[0]; // wram $e000-$e7ff
    wire rram_cs_n = u7A_Y2[2]; // rram $f000-$f7ff
    wire sram_cs_n = u7A_Y2[3]; // sram $f800-$ffff

    /******** MCPU MEMORIES ********/

    wire [7:0] mcpu_rom0_q;
    wire [7:0] mcpu_rom1_q;
    wire [7:0] mcpu_rom2_q;
    wire [7:0] mcpu_rom3_q;
    wire [7:0] mcpu_wram_q;
    wire [7:0] sram_q;
    wire [7:0] rram_q;

    // 3E 3F 3H 3I 3J muxes for RRAM/SRAM address, (r|s)ad_sel_n is active (low) on blank
    wire [10:0] avr = ~rad_sel_n ? mcpu_addr[10:0] : { sh[1], xv[7:3], xsh[7:3] };
    wire [10:0] avs = ~sad_sel_n ? mcpu_addr[10:0] : { hcount[1], xv[7:3], xh[7:3] };


    dpram #(14,8) mcpu_rom0(
              .clock     ( clk_sys          ),
              .address_a ( mcpu_rom0_addr   ),
              .data_a    ( mcpu_rom_data    ),
              .q_a       ( mcpu_rom0_q      ),
              .rden_a    ( 1'b1             ),
              .wren_a    ( mcpu_rom0_wren_a )
          );

    dpram #(14,8) mcpu_rom1(
              .clock     ( clk_sys          ),
              .address_a ( mcpu_rom1_addr   ),
              .data_a    ( mcpu_rom_data    ),
              .q_a       ( mcpu_rom1_q      ),
              .rden_a    ( 1'b1             ),
              .wren_a    ( mcpu_rom1_wren_a )
          );

    dpram #(14,8) mcpu_rom2(
              .clock     ( clk_sys          ),
              .address_a ( mcpu_rom2_addr   ),
              .data_a    ( mcpu_rom_data    ),
              .q_a       ( mcpu_rom2_q      ),
              .rden_a    ( 1'b1             ),
              .wren_a    ( mcpu_rom2_wren_a )
          );

    dpram #(14,8) mcpu_rom3(
              .clock     ( clk_sys          ),
              .address_a ( mcpu_rom3_addr   ),
              .data_a    ( mcpu_rom_data    ),
              .q_a       ( mcpu_rom3_q      ),
              .rden_a    ( 1'b1             ),
              .wren_a    ( mcpu_rom3_wren_a )
          );

    dpram #(11,8) mcpu_wram(
              .clock     ( clk_sys                 ),
              .address_a ( mcpu_addr[10:0]         ),
              .data_a    ( mcpu_dout               ),
              .q_a       ( mcpu_wram_q             ),
              .rden_a    ( 1'b1                    ),
              .wren_a    ( ~wram_cs_n & ~mcpu_wr_n )
          );

    // vram bg

    dpram #(11,8) sram(
              .clock     ( clk_sys   ),
              .address_a ( avs       ),
              .data_a    ( mcpu_dout ),
              .q_a       ( sram_q    ),
              .rden_a    ( 1'b1      ),
              .wren_a    ( ~srwr_n   )
          );

    // vram fg

    dpram #(11,8) rram(
              .clock     ( clk_sys   ),
              .address_a ( avr       ),
              .data_a    ( mcpu_dout ),
              .q_a       ( rram_q    ),
              .rden_a    ( 1'b1      ),
              .wren_a    ( ~rrwr_n   )
          );

    /******** MCPU I/O & DATA BUS ********/

    wire [7:0] u6E_Y, u6D_Y;

    wire IN1 = ~u6D_Y[0];
    wire IN2 = ~u6D_Y[1];
    wire IN3 = ~u6D_Y[2];
    wire DSW = ~u6D_Y[4];
    wire SN1 = u6E_Y[0];
    wire SN2 = u6E_Y[1];
    wire SN3 = u6E_Y[2];
    wire SCR = ~u6E_Y[5];
    wire IOW = ~u6E_Y[7];

    x74138 u6E(
               .G1  ( 1'b1           ),
               .G2A ( mcpu_iorq_n    ),
               .G2B ( mcpu_wr_n      ),
               .A   ( mcpu_addr[2:0] ),
               .Y   ( u6E_Y          )
           );

    x74138 u6D(
               .G1  ( 1'b1           ),
               .G2A ( mcpu_iorq_n    ),
               .G2B ( mcpu_rd_n      ),
               .A   ( mcpu_addr[2:0] ),
               .Y   ( u6D_Y          )
           );

    reg [7:0] u2J;
    reg [7:0] u8H;

    always @(posedge clk_sys) begin
        if (~mcpu_wr_n) begin
            if (SCR)
                u2J <= mcpu_dout;
            if (IOW)
                u8H <= mcpu_dout;
        end
    end

    always @(posedge clk_sys)
        if (~mcpu_rd_n)
            mcpu_din <=
                     ~wram_cs_n ? mcpu_wram_q :
                     ~sram_cs_n ? sram_q :
                     ~rram_cs_n ? rram_q :
                     ~mcpu_rom_cs_n_0 ? mcpu_rom0_q :
                     ~mcpu_rom_cs_n_1 ? mcpu_rom1_q :
                     ~mcpu_rom_cs_n_2 ? mcpu_rom2_q :
                     ~mcpu_rom_cs_n_3 ? mcpu_rom3_q :
                     IN1 ? p1 :
                     IN2 ? p2 :
                     IN3 ? p3 :
                     DSW ? dsw :
                     8'h0;


    /******** SCROLL COUNT ********/

    wire u2I_co;
    wire [7:0] sh;

    reg oldh8, load;
    always @(posedge clk_sys) begin
        if (clk_en_514) begin
            oldh8 <= hcount[8];
            load <= ~oldh8 & hcount[8];
        end
    end

    x74161 u2H(
               .cl_n ( 1'b1       ),
               .clk  ( clk_en_514 ),
               .ld_n ( ~load      ),
               .P    ( u2J[7:4]   ),
               .ep   ( u2I_co     ),
               .et   ( u2I_co     ),
               .Q    ( sh[7:4]    )
           );

    // FG has an extra register (4L) and is one pixel late:
    // FG RAM -> 3L -> 4L -> COLOR vs BG RAM -> 3A -> COLOR
    // Could it be a problem with the decoding of one read signal that controls
    // the registers? They are coming from the PAL 315-5074.
    // My quick fix for now is +1 on scroll value.
    x74161 u2I(
               .cl_n ( 1'b1       ),
               .clk  ( clk_en_514 ),
               .ld_n ( ~load      ),
               .P    ( u2J[3:0]+1 ),
               .ep   ( 1'b1       ),
               .et   ( 1'b1       ),
               .Q    ( sh[3:0]    ),
               .co   ( u2I_co     )
           );


    // flip
    wire bflip = u8H[5];
    wire [7:0] xv  = vcount[7:0] ^ {8{bflip}};
    wire [7:3] xh  = hcount[7:3] ^ {5{bflip}};
    wire [7:2] xsh = sh[7:2]     ^ {{5{bflip}}, rhinv};

    /******** COL/CH registers ********/

    // COLors & CHaracters
    // It captures VRAM data to build tile & color addresses
    // timing signals are generated by the PAL 315-5074

    reg [7:0] r3l;
    reg [7:0] r2l;
    reg [7:0] r4l;
    reg [7:0] r3b;
    reg [7:0] r3c;

    reg prcol_set_n;
    reg prch_set_n;
    always @(posedge clk_sys) begin
        prcol_set_n <= rcol_set_n;
        prch_set_n <= rch_set_n;
        if (~prcol_set_n & rcol_set_n)
            r3l <= rram_q;
        if (~prch_set_n & rch_set_n) begin
            r2l <= rram_q;
            r4l <= r3l;
        end
        if (oldvb & ~vb) begin
            r2l <= 8'd0;
            r4l <= 8'd0;
        end
    end

    reg pscol_set_n;
    reg psch_set_n;
    always @(posedge clk_sys) begin
        pscol_set_n <= scol_set_n;
        psch_set_n <= sch_set_n;
        if (~pscol_set_n & scol_set_n)
            r3b <= sram_q;
        if (~psch_set_n & sch_set_n)
            r3c <= sram_q;
        if (oldvb & ~vb) begin
            r3b <= 8'd0;
            r3c <= 8'd0;
        end
    end

    /******** BG/FG shift registers ********/

    // shift & select high or low bits of ROM data
    // translated to verilog to avoid a lot of 74LS194 instances

    reg [3:0] r4a;
    reg [4:0] r4k;
    reg sinv;
    reg rinv;
    reg psld_n;
    reg prld_n;

    // tile flip code
    wire shinv = r3b[3] ^ bflip;
    wire rhinv = r4l[2] ^ bflip;

    // 4K & 4A for stable address/inv signals
    always @(posedge clk_sys) begin
        psld_n <= sld_n;
        prld_n <= rld_n;
        if (psld_n & ~sld_n) begin
            r4a <= r3b[7:4];
            sinv <= shinv;
        end
        if (prld_n & ~rld_n) begin
            r4k <= r4l[7:3];
            rinv <= rhinv;
        end
    end

    // bit select
    wire ss0 = sinv ? 1'b1 : ~sld_n;
    wire ss1 = sinv ? ~sld_n : 1'b1;
    wire rs0 = rinv ? 1'b1 : ~rld_n;
    wire rs1 = rinv ? ~rld_n : 1'b1;

    // extract bits from ROM data
    wire [2:0] sex = sinv ? { sra[7], srb[7], src[7] } : { sra[0], srb[0], src[0] };
    wire [1:0] rex = rinv ? { rra[3], rrb[3] } : { rra[0], rrb[0] };


    // shift registers
    reg [7:0] sra, srb, src;
    reg [3:0] rra, rrb;
    always @(posedge clk_sys) begin
        if (clk_en_514) begin

            if (ss0 & ss1) begin
                sra <= srom_dout_a;
                srb <= srom_dout_b;
                src <= srom_dout_c;
            end
            else if (~ss0 & ss1) begin
                sra <= { 1'b0, sra[7:1] };
                srb <= { 1'b0, srb[7:1] };
                src <= { 1'b0, src[7:1] };
            end
            else if (ss0 & ~ss1) begin
                sra <= { sra[6:0], 1'b0 };
                srb <= { srb[6:0], 1'b0 };
                src <= { src[6:0], 1'b0 };
            end

            if (rs0 & rs1) begin
                rra <= rrom_dout[7:4];
                rrb <= rrom_dout[3:0];
            end
            else if (~rs0 & rs1) begin
                rra <= { 1'b0, rra[3:1] };
                rrb <= { 1'b0, rrb[3:1] };
            end
            else if (rs0 & ~rs1) begin
                rra <= { rra[2:0], 1'b0 };
                rrb <= { rrb[2:0], 1'b0 };
            end

        end
    end

    /******** BG/FG color palette ********/

    wire [7:0] rc_addr = { 1'b0, r4k, rex };
    wire [7:0] sc_addr = { 1'b0, r4a, sex };

    wire [3:0] scol;
    wire [3:0] rcol;
    wire [7:0] pal_data;

    // priority & transparency
    wire rex_n = ~|rcol;
    wire sex_n = ~|scol;
    wire sel_n = (rex_n | ~sex_n | u8H[0]) & (rex_n | u8H[1]);
    wire [3:0] col = sel_n ? scol : rcol;

    dpram #(8,4) fg_color_lut(
              .clock     ( clk_sys       ),
              .address_a ( fg_color_addr ),
              .data_a    ( col_data[3:0] ),
              .q_a       ( rcol          ),
              .rden_a    ( 1'b1          ),
              .wren_a    ( fg_color_wren )
          );

    dpram #(8,4) bg_color_lut(
              .clock     ( clk_sys       ),
              .address_a ( bg_color_addr ),
              .data_a    ( col_data[3:0] ),
              .q_a       ( scol          ),
              .rden_a    ( 1'b1          ),
              .wren_a    ( bg_color_wren )
          );

    // back is a palette switch
    // the only difference between the two palettes is color 7 (2F/40)
    wire back = u8H[3];
    dpram #(5,8) palette(
              .clock     ( clk_sys  ),
              .address_a ( pal_addr ),
              .data_a    ( col_data ),
              .q_a       ( pal_data ),
              .rden_a    ( 1'b1     ),
              .wren_a    ( pal_wren )
          );

    /******** GFX ROMs ********/

    wire [13:0] rca = { r4l[1:0], r2l, xsh[2], xv[2:0] };
    wire [13:0] sca = { r3b[2:0], r3c,         xv[2:0] };

    wire [7:0]  gfx_rom1_q;
    wire [7:0]  gfx_rom2_q;
    wire [7:0]  gfx_rom3_q;
    wire [7:0]  gfx_rom4_q;
    wire [7:0]  gfx_rom5_q;
    wire [7:0]  gfx_rom6_q;
    wire [7:0]  gfx_rom7_q;
    wire [7:0]  gfx_rom8_q;

    wire [7:0] rrom_dout   = ~rca[13] ? gfx_rom1_q : gfx_rom2_q;
    wire [7:0] srom_dout_a = ~sca[13] ? gfx_rom3_q : gfx_rom4_q;
    wire [7:0] srom_dout_b = ~sca[13] ? gfx_rom5_q : gfx_rom6_q;
    wire [7:0] srom_dout_c = ~sca[13] ? gfx_rom7_q : gfx_rom8_q;

    // fg

    dpram #(13,8) gfx_rom1(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom1_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom1_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom1_wren_a )
          );

    dpram #(13,8) gfx_rom2(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom2_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom2_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom2_wren_a )
          );

    // bg

    dpram #(13,8) gfx_rom3(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom3_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom3_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom3_wren_a )
          );

    dpram #(13,8) gfx_rom4(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom4_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom4_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom4_wren_a )
          );

    dpram #(13,8) gfx_rom5(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom5_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom5_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom5_wren_a )
          );

    dpram #(13,8) gfx_rom6(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom6_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom6_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom6_wren_a )
          );

    dpram #(13,8) gfx_rom7(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom7_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom7_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom7_wren_a )
          );

    dpram #(13,8) gfx_rom8(
              .clock     ( clk_sys         ),
              .address_a ( gfx_rom8_addr   ),
              .data_a    ( gfx_rom_data    ),
              .q_a       ( gfx_rom8_q      ),
              .rden_a    ( 1'b1            ),
              .wren_a    ( gfx_rom8_wren_a )
          );


    /******** AUDIO ********/

    // /RDY are open-collector outputs on original schematic

    wire rdy1;
    wire rdy2;
    wire rdy3;
    wire rdy_n = rdy1 & rdy2 & rdy3;

    wire [13:0] mix_audio1;
    wire [13:0] mix_audio2;
    wire [13:0] mix_audio3;

    assign sound = mix_audio1 + mix_audio2 + mix_audio3;

    sn76489_audio usnd1(
                      .clk_i        ( clk_sys         ),
                      .en_clk_psg_i ( clk_en_257      ),
                      .ce_n_i       ( SN1             ),
                      .wr_n_i       ( mcpu_wr_n | SN1 ),
                      .ready_o      ( rdy1            ),
                      .data_i       ( mcpu_dout       ),
                      .mix_audio_o  ( mix_audio1      )
                  );

    sn76489_audio usnd2(
                      .clk_i        ( clk_sys         ),
                      .en_clk_psg_i ( clk_en_257      ),
                      .ce_n_i       ( SN2             ),
                      .wr_n_i       ( mcpu_wr_n | SN2 ),
                      .ready_o      ( rdy2            ),
                      .data_i       ( mcpu_dout       ),
                      .mix_audio_o  ( mix_audio2      )
                  );

    sn76489_audio usnd3(
                      .clk_i        ( clk_sys         ),
                      .en_clk_psg_i ( clk_en_257      ),
                      .ce_n_i       ( SN3             ),
                      .wr_n_i       ( mcpu_wr_n | SN3 ),
                      .ready_o      ( rdy3            ),
                      .data_i       ( mcpu_dout       ),
                      .mix_audio_o  ( mix_audio3      )
                  );


endmodule
