module top();
    bit PCLK;
    initial begin
        forever
            #1 PCLK = ~PCLK;
    end
    APB_interface P_if(PCLK);

    APB_Master dut(P_if);
    testbench tb(P_if);
endmodule