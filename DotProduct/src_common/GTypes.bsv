// Type and some other useful definitions for the project are defined here
package GTypes;
   import GetPut     :: *;
   import Vector     :: *;

   typedef 8                           NUM_COL;
   typedef Bit#(3)                     ColCount;
   typedef Bit#(8)                     InData;
   typedef Bit#(32)                    OutData;

   typedef Vector #(NUM_COL, InData)   MatrixRow;

   import "BDPI" function OutData c_mac (OutData o, InData w, InData x);

   interface DotProduct;
      interface Put #(MatrixRow) aIn;
      interface Get #(OutData) yOut;
   endinterface

   // ================================================================
   // This function computes the expected output based on the C function which
   // implements the MAC operation
   function OutData fn_computeExpected (Reg#(MatrixRow) rg_ws, MatrixRow dIn);
      let ws = rg_ws;
      OutData expected = 0;
      for (Integer i=0; i<valueOf(NUM_COL); i=i+1)
	 expected = c_mac (expected, ws[i], dIn[i]);
      return (expected);
   endfunction

   // ================================================================
   // A convenience function to return the current cycle number during BSV
   // simulations

   ActionValue #(Bit #(32)) cur_cycle = actionvalue
					   Bit #(32) t <- $stime;
					   return t / 10;
				        endactionvalue;

// ===============================================================
endpackage
