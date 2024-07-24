module APB_Master #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter NO_SLAVES  = 4
) (
`ifdef AMBA4
      input [DATA_WIDTH/8 -1 : 0]  PSI_STRB  , 
      input [2:0]                  PSI_PROT  , 
      output reg [DATA_WIDTH/8 -1 : 0] PSTRB ,
      output reg [2:0]                 PPROT ,
`endif 
// PSI => Previous System IN
// PSO => Previous System OUT
// Global Sinals
    input PCLK                                  ,
    input PRESETn                               ,  
// input Master FROM Previous system
    input [ADDR_WIDTH-1 : 0]     PSI_ADDR       ,
    input                        PSI_WRITE      ,
    input [DATA_WIDTH-1 : 0]     PSI_WDATA      ,
    input                        Transfer       ,
// input Master FROM Slave
    input [DATA_WIDTH-1 : 0]     PRDATA         ,
    input                        PSLVERR        ,
    input                        PREADY         ,

// output Master TO Previous system
    output reg [DATA_WIDTH-1 : 0]    PSO_RDATA  ,
    output reg                       PSO_SLVERR ,
// output Master TO Slave
    output reg [ADDR_WIDTH-1 : 0]    PADDR      ,
    output reg [DATA_WIDTH-1 : 0]    PWDATA     ,
    output reg                       PWRITE     ,
    output reg [NO_SLAVES-1 : 0]     PSELx      ,
    output reg                       PENABLE    
);
    reg [2:0] NextState, CurrentState;
    // Decleration of States
    // OneHot
    localparam [2:0] IDLE   = 3'b001;
    localparam [2:0] SETUP  = 3'b010;
    localparam [2:0] ACCESS = 3'b100;

// Next State Logic
    always @(*) begin
        case (CurrentState)
            IDLE: begin
                if (Transfer) begin
                    NextState <= SETUP;
                end
                else begin
                    NextState <= IDLE;
                end
            end
            SETUP: begin
                NextState <= ACCESS;
            end
            ACCESS: begin
                if (PSLVERR) begin
                    NextState <= IDLE;
                end 
                else begin
                    if (PREADY & Transfer) begin
                        NextState <= SETUP;
                    end 
                    else if (PREADY & !Transfer) begin
                        NextState <= IDLE;
                    end
                    else begin
                        NextState <= ACCESS;
                    end
                end
            end
        endcase
    end

// State Memory
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            CurrentState <= IDLE;
        end else begin
            CurrentState <= NextState;
        end
    end

    
// output Logic
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PENABLE    <= 0;
            PADDR      <= 0; 
            PWRITE     <= 0;
            PSO_RDATA  <= 0;
            PSO_SLVERR <= 0;
            PWDATA     <= 0;
            `ifdef AMBA4
            PSTRB      <= 0;
            PPROT      <= 0;
            `endif
        end
        else if (NextState == SETUP) begin
            PENABLE <= 0;
            PADDR   <= PSI_ADDR; 
            PWRITE  <= PSI_WRITE;
            if (PSI_WRITE == 1) begin // WRITE
                PWDATA <= PSI_WDATA;
                `ifdef AMBA4
                PSTRB <= PSI_STRB;
                `endif
            end else if (PSI_WRITE == 0) begin // READ 
                `ifdef AMBA4
                PSTRB <= 'b0;
                `endif
            end
        end
        else if (NextState == ACCESS) begin
            PENABLE = 1;
            `ifdef AMBA4
            PPROT <= PSI_PROT;
            `endif
            if (PREADY == 1) begin
                if (PSI_WRITE == 0) begin
                    PSO_RDATA <= PRDATA;
                end
                PSO_SLVERR <= PSLVERR;
            end
        end
        else begin
            PENABLE <= 0;
        end
    end

// ADDRESS Decoding
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PSELx <= 'b0;
        end
        else if (NextState == IDLE) begin
            PSELx <= 'b0;
        end
        else begin
            case (PSI_ADDR[31:30])
                'b00: PSELx <= 4'b0001;
                'b01: PSELx <= 4'b0010;
                'b10: PSELx <= 4'b0100;
                'b11: PSELx <= 4'b1000;
                default: begin
                   PSELx <= 'b0;
                end
            endcase
        end
    end
endmodule