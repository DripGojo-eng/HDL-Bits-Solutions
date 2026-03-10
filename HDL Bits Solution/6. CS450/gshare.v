module top_module(
    input clk,
    input areset,

    input  predict_valid,
    input  [6:0] predict_pc,
    output predict_taken,
    output [6:0] predict_history,

    input train_valid,
    input train_taken,
    input train_mispredicted,
    input [6:0] train_history,
    input [6:0] train_pc
);

    reg [6:0] GHR;
    reg [1:0] PHT [0:127];
    integer i;
    
    wire [6:0] predict_idx = predict_pc ^ GHR;
    assign predict_history = GHR;
    assign predict_taken = PHT[predict_idx][1];
    
    wire [6:0] train_idx = train_history ^ train_pc;
    
    always @(posedge clk or posedge areset) begin
        if(areset) begin
            GHR <= 7'b0000000;
            for(i=0; i<128; i=i+1) begin
                PHT[i] <= 2'b01;
            end
        end
        else begin
            if(train_mispredicted && train_valid) begin
                GHR <= {train_history[5:0], train_taken};
            end
            else if(predict_valid) begin
                GHR <= {GHR[5:0], predict_taken};
            end
            
            if(train_valid) begin
                if(train_taken) begin
                    if(PHT[train_idx] < 2'b11) 
                        PHT[train_idx] <= PHT[train_idx] + 1;
                end 
                else begin
                    if(PHT[train_idx] > 2'b00) 
                        PHT[train_idx] <= PHT[train_idx] - 1;
                end
            end
        end
    end

endmodule
