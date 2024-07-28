module testbench(APB_interface.TEST tb);

import shared_pkg::*;
import Coverage_pkg::*;
import Transaction_pkg::*;

APB4_Transaction tr = new();
APB4_Transaction cvg_tr = new();
APB4_Coverage cvg = new();

int WaitPeriod;
initial begin

    initialization                    ;
    #6                                ;
    reset(4)                          ;

    // Start First Transfer Operation
    assert(tr.randomize())            ;

    tb.Transfer    = 1                ;
    tb.PREADY      = 0                ;
    tb.PSI_ADDR    = tr.PSI_ADDR      ;
    tb.PSI_WRITE   = tr.PSI_WRITE     ;

    if (tb.PSI_WRITE) 
        tb.PSI_WDATA = tr.PSI_WDATA   ;

// AMBA4 Features
    `ifdef AMBA4
    AMBA_APB4;
    `endif

    #4                                ;
// Take Samples
    sampling                          ;

    if (!tb.PSI_WRITE)
        tb.PRDATA = tr.PRDATA         ;
    
    tb.PREADY = 1                     ;
    #2                                ;

// Take Samples
    sampling                          ;
    tb.PREADY = 0                     ;

    repeat(LOOP) begin
        randomization                 ;
        Transfer                      ;
    end

    tb.Transfer = 0                   ;
    #4                                ;
    $stop                             ;
end

task randomization;
    assert(tr.randomize())              ;
    tb.PRESETn = tr.PRESETn             ;
    WaitPeriod = tr.WaitPeriod          ;
endtask

task Transfer                          ;
    tb.PSI_ADDR  = tr.PSI_ADDR         ;
    tb.PSI_WRITE = tr.PSI_WRITE        ;
    
    `ifdef AMBA4
    AMBA_APB4;
    `endif

    if (tb.PSI_WRITE)
        tb.PSI_WDATA = tr.PSI_WDATA     ;

    #1                                  ;
    assert final (tb.PENABLE == 0)      ;
    #1                                  ;
    for (int i=1; i<WaitPeriod; ++i)
        #2                              ;

    sampling                            ;
    
    if (!tb.PSI_WRITE)
        tb.PRDATA = tr.PRDATA           ;
    
    tb.PREADY = 1                       ;
    tb.PSLVERR = tr.PSLVERR             ;
    #2                                  ;
    sampling                            ;
    tb.PREADY = 0                       ;
endtask

///////////////////////////////////////////////////////////////
//////////////////////// sampling TASK ////////////////////////
///////////////////////////////////////////////////////////////

task sampling;
cvg_tr.PRESETn    = tr.PRESETn      ;
cvg_tr.PSI_ADDR   = tr.PSI_ADDR     ;
cvg_tr.PSI_WRITE  = tr.PSI_WRITE    ;
cvg_tr.PSI_WDATA  = tr.PSI_WDATA    ;
`ifdef AMBA4
cvg_tr.PSI_STRB   = tr.PSI_STRB     ;
cvg_tr.PSI_PROT   = tr.PSI_PROT     ;
`endif
cvg_tr.Transfer   = tr.Transfer     ;
cvg_tr.PRDATA     = tr.PRDATA       ;
cvg_tr.PSLVERR    = tr.PSLVERR      ;
cvg_tr.PREADY     = tb.PREADY       ;

// OUTPUTS
cvg_tr.PSO_RDATA  = tb.PSO_RDATA       ;
cvg_tr.PSO_SLVERR = tb.PSO_SLVERR      ;
cvg_tr.PADDR      = tb.PADDR           ;
cvg_tr.PWDATA     = tb.PWDATA          ;
cvg_tr.PWRITE     = tb.PWRITE          ;
`ifdef AMBA4
cvg_tr.PSTRB      = tb.PSTRB           ;
cvg_tr.PPROT      = tb.PPROT           ;
`endif
cvg_tr.PSELx      = tb.PSELx           ;
cvg_tr.PENABLE    = tb.PENABLE         ;
    //////////////////////
    cvg.COV_sample(cvg_tr)             ;
endtask

/////////////////////////////////////////////////////////////////////
//////////////////////// initialization TASK ////////////////////////
/////////////////////////////////////////////////////////////////////

task initialization;
    tb.PRESETn    = 1;
    tb.PSI_ADDR   = 0;
    tb.PSI_WRITE  = 0;
    tb.PSI_WDATA  = 0;
    `ifdef AMBA4
    tb.PSI_STRB   = 4'b1111; 
    tb.PSI_PROT   = 3'b000;
    `endif
    tb.Transfer   = 0;
    tb.PRDATA     = 0;
    tb.PSLVERR    = 0;
    tb.PREADY     = 0;
    WaitPeriod = 4;
endtask

////////////////////////////////////////////////////////////////////
//////////////////////////// RESET TASK ////////////////////////////
////////////////////////////////////////////////////////////////////

task reset(int i);
    tb.PRESETn = 0;
    repeat(i) @(posedge tb.PCLK);
    sampling;
    tb.PRESETn = 1;
endtask

//////////////////////////////////////////////////////////////////
///////////////////////// AMPA4 features /////////////////////////
//////////////////////////////////////////////////////////////////

`ifdef AMBA4
task AMBA_APB4                         ;
    tb.PSI_PROT = tr.PSI_PROT          ;
    tb.PSI_STRB = tr.PSI_STRB          ;
endtask
`endif

endmodule