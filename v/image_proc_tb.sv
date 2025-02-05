module image_proc_tb();

    logic [10:0] iX_Cont, iY_Cont;
    logic [11:0] iDATA, oRed, oGreen, oBlue;
    logic [1:0] state;
    logic iDVAL, iCLK, iRST, oDVAL;

    image_proc(.iX_Cont(iX_Cont), .iY_Cont(iY_Cont), .iDATA(iDATA), .state(state), .iDVAL(iDVAL), .iCLK(iCLK), .iRST(iRST), .oRed(oRed), .oGreen(oGreen), .oBlue(oBlue), .oDVAL(oDVAL));

endmodule