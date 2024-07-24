interface APB_interface(input bit PCLK);
import shared_pkg::*;
`ifdef AMBA4
    logic [DATA_WIDTH/8 -1 : 0]  PSI_STRB       ; 
    logic [2:0]                  PSI_PROT       ; 
    logic [DATA_WIDTH/8 -1 : 0] PSTRB           ;
    logic [2:0]                 PPROT           ;
`endif 
// PSI => Previous System IN
// PSO => Previous System OUT
// Global Sinals
    logic PRESETn                               ;  
// logic Master FROM Previous system
    logic [ADDR_WIDTH-1 : 0]     PSI_ADDR       ;
    logic                        PSI_WRITE      ;
    logic [DATA_WIDTH-1 : 0]     PSI_WDATA      ;
    logic                        Transfer       ;
// logic Master FROM Slave
    logic [DATA_WIDTH-1 : 0]     PRDATA         ;
    logic                        PSLVERR        ;
    logic                        PREADY         ;

// output Master TO Previous system
    logic [DATA_WIDTH-1 : 0]    PSO_RDATA       ;
    logic                       PSO_SLVERR      ;
// output Master TO Slave
    logic [ADDR_WIDTH-1 : 0]    PADDR           ;
    logic [DATA_WIDTH-1 : 0]    PWDATA          ;
    logic                       PWRITE          ;
    logic [NO_SLAVES-1 : 0]     PSELx           ;
    logic                       PENABLE         ;

    modport DUT (
        input       PCLK        ,
        input       PRESETn     ,  
        `ifdef AMBA4
            input   PSI_STRB    , 
            input   PSI_PROT    , 
            output  PSTRB       ,
            output  PPROT       ,
        `endif 
        input      PSI_ADDR     ,
        input      PSI_WRITE    ,
        input      PSI_WDATA    ,
        input      Transfer     ,
        input      PRDATA       ,
        input      PSLVERR      ,
        input      PREADY       ,
        output     PSO_RDATA    ,
        output     PSO_SLVERR   ,
        output     PADDR        ,
        output     PWDATA       ,
        output     PWRITE       ,
        output     PSELx        ,
        output     PENABLE    
    );

    modport TEST (
        input       PCLK       ,
        output     PRESETn     ,  
        `ifdef AMBA4
            output PSI_STRB    , 
            output PSI_PROT    , 
            input  PSTRB       ,
            input  PPROT       ,
        `endif 
        output    PSI_ADDR     ,
        output    PSI_WRITE    ,
        output    PSI_WDATA    ,
        output    Transfer     ,
        output    PRDATA       ,
        output    PSLVERR      ,
        output    PREADY       ,
        input     PSO_RDATA    ,
        input     PSO_SLVERR   ,
        input     PADDR        ,
        input     PWDATA       ,
        input     PWRITE       ,
        input     PSELx        ,
        input     PENABLE    
    );

endinterface