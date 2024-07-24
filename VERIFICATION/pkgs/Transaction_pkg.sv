package Transaction_pkg;
import shared_pkg::*;

class APB4_Transaction;
    // inputs
    // logic                           PCLK        ;
    rand logic                           PRESETn     ;
    rand logic [ADDR_WIDTH-1 : 0]        PSI_ADDR    ;
    rand logic                           PSI_WRITE   ;
    rand logic [DATA_WIDTH-1 : 0]        PSI_WDATA   ;
    `ifdef AMBA4
    rand logic [DATA_WIDTH/8 -1 : 0]     PSI_STRB    ;
    rand logic [2:0]                     PSI_PROT    ;
    `endif
         logic                           Transfer    ;
    rand logic [DATA_WIDTH-1 : 0]        PRDATA      ;
    rand logic                           PSLVERR     ;
         logic                           PREADY      ;

    // OUTPUTS
    logic [DATA_WIDTH-1 : 0]    PSO_RDATA   ;
    logic                       PSO_SLVERR  ;
    logic [ADDR_WIDTH-1 : 0]    PADDR       ;
    logic [DATA_WIDTH-1 : 0]    PWDATA      ;
    logic                       PWRITE      ;
    `ifdef AMBA4
    logic [DATA_WIDTH/8 -1 : 0] PSTRB       ;
    logic [2:0]                 PPROT       ;
    `endif
    logic [NO_SLAVES-1 : 0]     PSELx       ;
    logic                       PENABLE     ;

    rand int WaitPeriod;

    constraint RESETN {
        PRESETn dist {1:/(100-RESET_ACTIVATE), 0:/RESET_ACTIVATE};
    }
    constraint SLEVRR {
        PSLVERR dist {0:=100-PSLVERR_ACTIVATE, 1:=PSLVERR_ACTIVATE};
    }

    constraint WRITE_DATA {
        PSI_WDATA dist {MAX:=10, ZERO:=5, [1:MAX-1]:/85};
    }

    constraint READ_DATA {
        PRDATA dist {MAX:=10, ZERO:=5, [1:MAX-1]:/85};
    }

    constraint ADDRESS {
        PSI_ADDR[31:30] dist {2'b00:=25, 2'b01:=25, 2'b10:=25, 2'b11:=25}; 
    }
    `ifdef AMBA4
    constraint STRB {
        (PSI_WRITE == 0) -> PSI_STRB == 0;
    }
    `endif
    
    constraint WAIT {
        WaitPeriod >= MIN_WAIT_PEROPD;
        WaitPeriod <= MAX_WAIT_PEROPD;
    }

    function new();
    endfunction //new()
endclass //Transaction
    
endpackage