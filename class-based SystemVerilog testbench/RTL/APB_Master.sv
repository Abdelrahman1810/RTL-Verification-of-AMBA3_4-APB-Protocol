`define disabled disable iff(!dut.PRESETn || dut.PSLVERR)
module APB_Master (APB_interface.DUT dut);
import shared_pkg::*;
State NextState, CurrentState;

//**************************************************************//
//////////////////////// Next State Logic ////////////////////////
//**************************************************************//
    always @(*) begin
        case (CurrentState)
            IDLE: begin
                if (dut.Transfer) begin
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
                if (dut.PSLVERR) begin
                    NextState <= IDLE;
                end 
                else begin
                    if (dut.PREADY & dut.Transfer) begin
                        NextState <= SETUP;
                    end 
                    else if (dut.PREADY & !dut.Transfer) begin
                        NextState <= IDLE;
                    end
                    else begin
                        NextState <= ACCESS;
                    end
                end
            end
        endcase
    end

//**********************************************************//
//////////////////////// State Memory ////////////////////////
//**********************************************************//
    always @(posedge dut.PCLK or negedge dut.PRESETn) begin
        if (!dut.PRESETn) begin
            CurrentState <= IDLE;
        end else begin
            CurrentState <= NextState;
        end
    end

//**********************************************************//
//////////////////////// output Logic ////////////////////////
//**********************************************************//
    always @(posedge dut.PCLK or negedge dut.PRESETn) begin
        if (!dut.PRESETn) begin
            dut.PENABLE    <= 0;
            dut.PADDR      <= 0; 
            dut.PWRITE     <= 0;
            dut.PSO_RDATA  <= 0;
            dut.PSO_SLVERR <= 0;
            dut.PWDATA     <= 0;
            `ifdef AMBA4
            dut.PSTRB      <= 0;
            dut.PPROT      <= 0;
            `endif
        end
        else if (NextState == SETUP) begin
            dut.PENABLE <= 0;
            dut.PADDR   <= dut.PSI_ADDR; 
            dut.PWRITE  <= dut.PSI_WRITE;
            if (dut.PSI_WRITE == 1) begin // WRITE
                dut.PWDATA <= dut.PSI_WDATA;
                `ifdef AMBA4
                dut.PSTRB <= dut.PSI_STRB;
                `endif
            end else if (dut.PSI_WRITE == 0) begin // READ 
                `ifdef AMBA4
                dut.PSTRB <= 'b0;
                `endif
            end
        end
        else if (NextState == ACCESS) begin
            dut.PENABLE = 1;
            `ifdef AMBA4
            dut.PPROT <= dut.PSI_PROT;
            `endif
            if (dut.PREADY == 1) begin
                if (dut.PSI_WRITE == 0) begin
                    dut.PSO_RDATA <= dut.PRDATA;
                end
                dut.PSO_SLVERR <= dut.PSLVERR;
            end
        end
        else begin
            dut.PENABLE <= 0;
        end
    end

//**********************************************************//
////////////////////// ADDRESS Decoding //////////////////////
//**********************************************************//

    always @(posedge dut.PCLK or negedge dut.PRESETn) begin
        if (!dut.PRESETn) begin
            dut.PSELx <= 'b0;
        end
        else if (NextState == IDLE) begin
            dut.PSELx <= 'b0;
        end
        else begin
            case (dut.PSI_ADDR[31:30])
                'b00: dut.PSELx <= 4'b0001;
                'b01: dut.PSELx <= 4'b0010;
                'b10: dut.PSELx <= 4'b0100;
                'b11: dut.PSELx <= 4'b1000;
                default: begin
                   dut.PSELx <= 'b0;
                end
            endcase
        end
    end

//***************************************************//
////////////////////// Assertion //////////////////////
//***************************************************//
`ifdef ASSERTION_COVERAGE

    always_comb begin
        if (dut.PRESETn == 0) begin
            RST_PENABLE    :assert final (dut.PENABLE    == 0)  ;
            
            RST_PADDR      :assert final (dut.PADDR      == 0)  ; 
            
            RST_PWRITE     :assert final (dut.PWRITE     == 0)  ;
            
            RST_PSO_RDATA  :assert final (dut.PSO_RDATA  == 0)  ;
            
            RST_PSO_SLVERR :assert final (dut.PSO_SLVERR == 0)  ;
            
            RST_PWDATA     :assert final (dut.PWDATA     == 0)  ;
            
            RST_PSELx      :assert final (dut.PSELx      == 0)  ;
        end
    end
    
    NextState_pslv :assert property (@(posedge dut.PCLK) (dut.PSLVERR)&&($past(NextState) == ACCESS) |-> (NextState == IDLE));
    
    selx           :assert property (@(posedge dut.PCLK) `disabled (dut.PSI_ADDR!=0) |=> ($countones(dut.PSELx) == 1));
    
    ASSERT_ENABLE  :assert property (@(posedge dut.PCLK) (NextState == ACCESS) |=> (dut.PENABLE == 1));
    
    ADDRESS        :assert property (@(posedge dut.PCLK) `disabled (NextState == SETUP) |=> (dut.PADDR == dut.PSI_ADDR));
    
    WRITE          :assert property (@(posedge dut.PCLK) `disabled (NextState == SETUP) |=> (dut.PWRITE == dut.PSI_WRITE));
    
    WRITE_DATA     :assert property (@(posedge dut.PCLK) `disabled (NextState == SETUP)&&(dut.PWRITE) |=> (dut.PWDATA == dut.PSI_WDATA));
    
    READ_DATA      :assert property (@(posedge dut.PCLK) `disabled (NextState == ACCESS)&&(dut.PWRITE==0) |->##[1:$] (dut.PSO_RDATA == dut.PRDATA));
    
    SLVERR         :assert property (@(posedge dut.PCLK) (dut.PREADY) |-> (dut.PSO_SLVERR == dut.PSLVERR));

`ifdef AMBA4
   
   READ_STRB :assert property (@(posedge dut.PCLK) `disabled (dut.PWRITE == 0) |-> (dut.PSTRB == 0));
   
   STRB      :assert property (@(posedge dut.PCLK) `disabled (NextState == SETUP)&&(dut.PWRITE) |-> (dut.PSTRB == dut.PSI_STRB));
   
   PROT      :assert property (@(posedge dut.PCLK) `disabled (NextState == ACCESS) |=> (dut.PPROT == dut.PSI_PROT));
    always_comb begin
        if (dut.PRESETn == 0) begin
           RESET_STRB:assert final (dut.PSTRB == 0);
           RESET_PROT:assert final (dut.PPROT == 0);
        end
    end
`endif

//**************************************************//
////////////////////// Coverage //////////////////////
//**************************************************//
    always_comb begin
        if (dut.PRESETn == 0) begin
            RST_PENABLE_cover     :cover final (dut.PENABLE    == 0)  ;
            
            RST_PADDR_cover       :cover final (dut.PADDR      == 0)  ; 
            
            RST_PWRITE_cover      :cover final (dut.PWRITE     == 0)  ;
            
            RST_PSO_RDATA_cover   :cover final (dut.PSO_RDATA  == 0)  ;
            
            RST_PSO_SLVERR_cover  :cover final (dut.PSO_SLVERR == 0)  ;
            
            RST_PWDATA_cover      :cover final (dut.PWDATA     == 0)  ;
            
            RST_PSELx_cover       :cover final (dut.PSELx      == 0)  ;
        end
    end
    
    NextState_pslv_cover  :cover property (@(posedge dut.PCLK) (dut.PSLVERR)&&($past(NextState) == ACCESS) |-> (NextState == IDLE));
    
    selx_cover            :cover property (@(posedge dut.PCLK) disable iff(!dut.PRESETn || dut.PSLVERR) (dut.PSI_ADDR!=0) |=> ($countones(dut.PSELx) == 1));
    
    ASSERT_ENABLE_cover   :cover property (@(posedge dut.PCLK) (NextState == ACCESS) |=> (dut.PENABLE == 1));
    
    ADDRESS_cover         :cover property (@(posedge dut.PCLK) (NextState == SETUP) |=> (dut.PADDR == dut.PSI_ADDR));
    
    WRITE_cover           :cover property (@(posedge dut.PCLK) (NextState == SETUP) |=> (dut.PWRITE == dut.PSI_WRITE));
    
    WRITE_DATA_cover      :cover property (@(posedge dut.PCLK) (NextState == SETUP)&&(dut.PWRITE) |=> (dut.PWDATA == dut.PSI_WDATA));
    
    READ_DATA_cover       :cover property (@(posedge dut.PCLK) (NextState == ACCESS)&&(dut.PWRITE) |=> (dut.PSO_RDATA == dut.PRDATA));
    
    SLVERR_cover          :cover property (@(posedge dut.PCLK) (dut.PREADY) |-> (dut.PSO_SLVERR == dut.PSLVERR));

`ifdef AMBA4
   
   READ_STRB_cover  :cover property (@(posedge dut.PCLK) (dut.PWRITE == 0) |-> (dut.PSTRB == 0));
   
   STRB_cover       :cover property (@(posedge dut.PCLK) (NextState == SETUP)&&(dut.PWRITE) |-> (dut.PSTRB == dut.PSI_STRB));
   
   PROT_cover       :cover property (@(posedge dut.PCLK) (NextState == ACCESS) |-> (dut.PPROT == dut.PSI_PROT));
    always_comb begin
        if (dut.PRESETn == 0) begin
           RESET_STRB_cover :cover final (dut.PSTRB == 0);
           RESET_PROT_cover :cover final (dut.PPROT == 0);
        end
    end
`endif
`endif
endmodule