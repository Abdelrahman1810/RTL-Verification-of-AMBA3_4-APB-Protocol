package shared_pkg;
    typedef enum reg [2:0] {IDLE='b001, SETUP='b010, ACCESS='b100} State;
    parameter MIN_WAIT_PEROPD   = 1                  ;
    parameter MAX_WAIT_PEROPD   = 8                  ;
    parameter RESET_ACTIVATE    = 5                  ;
    parameter PSLVERR_ACTIVATE  = 3                  ;
    parameter DATA_WIDTH        = 32                 ;
    parameter ADDR_WIDTH        = 32                 ;
    parameter NO_SLAVES         = 4                  ;
    parameter ZERO              = 0                  ;
    parameter MAX               = 2**DATA_WIDTH - 1  ;
    parameter LOOP              = 100                 ;
endpackage