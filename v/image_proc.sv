`default_nettype none
module image_proc(  oRed,
                    oGreen,
                    oBlue,
                    oDVAL,
                    iX_Cont,
                    iY_Cont,
                    iDATA,
                    iDVAL,
                    iCLK,
                    iRST,
                    state
                );

input wire  [10:0]	iX_Cont;
input wire	[10:0]	iY_Cont;
input wire	[11:0]	iDATA;
input wire  [1:0]   state;
input wire			iDVAL;
input wire			iCLK;
input wire			iRST;
output wire	[11:0]	oRed;
output wire	[11:0]	oGreen;
output wire	[11:0]	oBlue;
output wire			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;
reg		[11:0]	mCCD_R;
reg		[11:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg     [13:0]  avg_data;
reg				mDVAL;

// Grayscale values
wire    [11:0]  gDATA_0;
wire    [11:0]  gDATA_1;
wire    [11:0]  gDATA_2;
reg     [11:0]  gDATA_0_1;
reg     [11:0]  gDATA_0_2;
reg     [11:0]  gDATA_1_1;
reg     [11:0]  gDATA_1_2;
reg     [11:0]  gDATA_2_1;
reg     [11:0]  gDATA_2_2;
reg     [11:0]  convolution;
reg     [11:0]  abs_val;

assign	oRed	=	state[0] ? abs_val : mCCD_R[11:0];
assign	oGreen	=	state[0] ? abs_val : mCCD_R[11:0];
assign	oBlue	=	state[0] ? abs_val : mCCD_R[11:0];
assign	oDVAL	=	mDVAL;

Line_Buffer1 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

Grayscale_Buffer    u1  (   .clken(mDVAL),
                            .clock(iCLK),
                            .shiftin(mCCD_R),
                            .taps0x(gDATA_1),
                            .taps1x(gDATA_0)
                        );

Grayscale_Buffer    u2  (   .clken(mDVAL),
                            .clock(iCLK),
                            .shiftin(gDATA_1),
                            .taps0x(), // Intentionally left blank
                            .taps1x(gDATA_2)
                        );

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		mDVAL	<=	0;
        avg_data <= 0;

        gDATA_0_2 <= 0;
        gDATA_0_1 <= 0;
        gDATA_1_2 <= 0;
        gDATA_1_1 <= 0;
        gDATA_2_2 <= 0;
        gDATA_2_1 <= 0;
        convolution <= 0;
        abs_val <= 0;
	end
	else
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
        avg_data    <=  mDATA_0+mDATAd_0+mDATA_1+mDATAd_1;

        gDATA_0_2 <= gDATA_0_1;
        gDATA_0_1 <= gDATA_0;
        gDATA_1_2 <= gDATA_1_1;
        gDATA_1_1 <= gDATA_1;
        gDATA_2_2 <= gDATA_2_1;
        gDATA_2_1 <= gDATA_2;
        // Calc convolution
        if(state[1]) // 1 == horizontal edge
            convolution = (~gDATA_0+1) + {(~gDATA_0_1+1), 1'b0} + (~gDATA_0_2+1) + gDATA_2 + {gDATA_2_1, 1'b0} + gDATA_2_2;
        else
            convolution = (~gDATA_0+1) + gDATA_0_2 + {(~gDATA_1+1), 1'b0} + {gDATA_1_2, 1'b0} + (~gDATA_2+1) + gDATA_2_2;
        abs_val <= convolution[11] ? ~convolution + 1 : convolution;
		if({iY_Cont[0],iX_Cont[0]}==2'b10)
		begin
			mCCD_R	<=	avg_data[13:2];
			mCCD_G	<=	avg_data[13:2];
			mCCD_B	<=	avg_data[13:2];
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)
		begin
			mCCD_R	<=	avg_data[13:2];
			mCCD_G	<=	avg_data[13:2];
			mCCD_B	<=	avg_data[13:2];
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)
		begin
			mCCD_R	<=	avg_data[13:2];
			mCCD_G	<=	avg_data[13:2];
			mCCD_B	<=	avg_data[13:2];
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)
		begin
			mCCD_R	<=	avg_data[13:2];
			mCCD_G	<=	avg_data[13:2];
			mCCD_B	<=	avg_data[13:2];
		end
	end
end

endmodule
`default_nettype wire