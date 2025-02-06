`timescale 1 ps / 1 ps
module image_proc_tb();

    logic [10:0] iX_Cont, iY_Cont;
    logic [11:0] iDATA, oRed, oGreen, oBlue;
    logic [1:0] state;
    logic iDVAL, iCLK, iRST, oDVAL;
    logic err;

    logic [11:0] convolution_red;

    image_proc iDUT(.iX_Cont(iX_Cont), .iY_Cont(iY_Cont), .iDATA(iDATA), .state(state), .iDVAL(iDVAL), .iCLK(iCLK), .iRST(iRST), .oRed(oRed), .oGreen(oGreen), .oBlue(oBlue), .oDVAL(oDVAL));

    initial begin
        err = 0;
        iCLK = 0;
        @(negedge iCLK);
        $display("Reseting device!");
        iRST = 0;
        iX_Cont = 11'h000;
        iY_Cont = 11'h000;
        iDATA = $random;
        state = 2'b00;
        iDVAL = 0;
        @(negedge iCLK);
        iRST = 1;
        @(negedge iCLK);
        $display("Checking grayscale image!");
        iDVAL = 1;
        repeat(1280) @(negedge iCLK) iDATA = $random;
        if(oRed != oGreen || oGreen != oBlue) begin
            $display("ERROR: Grayscale image is not grayscale! r: %h g: %h b: %h!", oRed, oGreen, oBlue);
            err = 1;
        end
        @(negedge iCLK)
        state = 2'b01;
        repeat (1280) @(negedge iCLK) iDATA = $random;
        $display("Checking convolutions are different for horizontal and vertical image!");
        convolution_red = oRed;
        @(negedge iCLK);
        state = 2'b11;
        repeat (1280) @(negedge iCLK) iDATA = $random;
        if(oRed == convolution_red) begin
            $display("ERROR: vertical and horizontal convolutions match at %h!", oRed);
            err = 1;
        end

        if(err) begin
            $display("Errors detected! See above!");
        end else begin
            $display("YAHOO!!! All tests passed!");
        end
        $stop();



    end

    always #50 iCLK = ~iCLK;

endmodule