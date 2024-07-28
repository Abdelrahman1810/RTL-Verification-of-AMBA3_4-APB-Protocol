package Coverage_pkg;
import shared_pkg::*;
import Transaction_pkg::*;
    
class APB4_Coverage;
    APB4_Transaction tr = new();
///////////////////////////////////////////////////////////////////////////////////
    // inputs
    // logic                           PCLK        ;
    // rand logic                           PRESETn     ;
    // rand logic [ADDR_WIDTH-1 : 0]        PSI_ADDR    ;
    // rand logic                           PSI_WRITE   ;
    // rand logic [DATA_WIDTH-1 : 0]        PSI_WDATA   ;
    // `ifdef AMBA4
    // rand logic [DATA_WIDTH/8 -1 : 0]     PSI_STRB    ;
    // rand logic [2:0]                     PSI_PROT    ;
    // `endif
    // rand logic                           Transfer    ;
    // rand logic [DATA_WIDTH-1 : 0]        PRDATA      ;
    // rand logic                           PSLVERR     ;
    // rand logic                           PREADY      ;

    // // OUTPUTS
    // logic [DATA_WIDTH-1 : 0]    PSO_RDATA   ;
    // logic                       PSO_SLVERR  ;
    // logic [ADDR_WIDTH-1 : 0]    PADDR       ;
    // logic [DATA_WIDTH-1 : 0]    PWDATA      ;
    // logic                       PWRITE      ;
    // `ifdef AMBA4
    // logic [DATA_WIDTH/8 -1 : 0] PSTRB       ;
    // logic [2:0]                 PPROT       ;
    // `endif
    // logic [NO_SLAVES-1 : 0]     PSELx       ;
    // logic                       PENABLE     ;
///////////////////////////////////////////////////////////////////////////////////
    covergroup cvg_grp;
        RESET: coverpoint tr.PRESETn;

        WRITE: coverpoint tr.PWRITE;
        
        READY: coverpoint tr.PREADY;
        
        ENABLE: coverpoint tr.PENABLE;
        
        READY_ENABLE: cross READY, ENABLE {
            option.cross_auto_bin_max = 0;
            bins ACCESSA = (binsof(READY) intersect{1} && binsof(ENABLE) intersect{1});
        }
    
        `ifdef AMBA4
            PROT: coverpoint tr.PSI_PROT;
            STRB: coverpoint tr.PSI_STRB;
        `endif
    
        SEL: coverpoint tr.PSELx {
            bins slave0 = {4'b0001};
            bins slave1 = {4'b0010};
            bins slave2 = {4'b0100};
            bins slave3 = {4'b1000};
        }
    endgroup

    function new();
        cvg_grp = new();
    endfunction //new()

    function void COV_sample(input APB4_Transaction sample_tr);
        tr = sample_tr;
        cvg_grp.sample();
    endfunction
endclass //Coverage
endpackage