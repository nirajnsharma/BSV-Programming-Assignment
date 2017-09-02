// Type and some other useful definitions for the project are defined here
package GTypes;
   import GetPut     :: *;
   import Vector     :: *;

   typedef 7                              NUM_W_ROW;
   typedef 5                              NUM_W_COL;
   typedef 8                              IDataWidth;
   typedef 32                             ODataWidth;

   // Column and row counters
   typedef Bit#(TLog#(NUM_W_COL))         ColCount;
   typedef Bit#(TLog#(NUM_W_ROW))         RowCount;

   // Data-types for input and output
   typedef Bit#(IDataWidth)               IData;
   typedef Bit#(ODataWidth)               OData;

   // Data-types for a row and a column of the matrix (input)
   typedef Vector #(NUM_W_COL, IData)     IRow;
   typedef Vector #(NUM_W_ROW, IData)     ICol;

   // Data-types for an output column
   typedef Vector #(NUM_W_ROW, OData)     OCol;

   // Data-widths for the entire row of a Matrix
   typedef TMul#(NUM_W_COL, IDataWidth)	  IRowWidth;
   typedef TMul#(NUM_W_ROW, ODataWidth)	  ORowWidth;

   import "BDPI" function OutData c_mac (OData o, IData w, IData x);

   interface MatrixMulW;
      interface Put #(IRow) aIn;  // 1x5
      interface Get #(OCol) yOut; // 1x7
   endinterface

   // ================================================================
   // This function initializes the W matrix, and is used by both the TB and the
   // implementation
   function Action initialize_w (Vector#(NUM_W_COL, Reg#(ICol)) rg_ws);
      action
      ICol ws_col = newVector;
      for (Integer j=0; j<valueOf(NUM_W_COL); j=j+1) begin
	 for (Integer i=0; i<valueOf(NUM_W_ROW); i=i+1)
	    ws_col[i] = fromInteger(i+1)*fromInteger(j+1)+1;

	 rg_ws[j] <= ws_col;
      end
      endaction
   endfunction

   // ================================================================
   // This function computes the expected ouput based on the C function which
   // implements the MAC operation
   function OCol fn_computeExpected (
        Vector#(NUM_W_COL, Reg#(ICol)) rg_ws)
      , IRow dIn
   );
      let ws = readVReg (rg_ws);
      OCol expected = replicate(0);
      OData macOut = 0;

      for (Integer i=0; i<valueOf(NUM_W_ROW); i=i+1) begin
	 for (Integer j=0; j<valueOf(NUM_W_COL); j=j+1)
	    macOut = c_mac (macOut, ws[j][i], dIn[j]);
	 
	 expected[i] = macOut;
	 macOut = 0;
      end
      return (expected);
   endfunction

   // ================================================================
   // A convenience function to return the current cycle number during BSV
   // simulations

   ActionValue #(Bit #(32)) cur_cycle = actionvalue
					   Bit #(32) t <- $stime;
					   return t / 10;
				        endactionvalue;

endpackage
