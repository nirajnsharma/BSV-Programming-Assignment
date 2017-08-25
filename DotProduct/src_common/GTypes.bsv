// Type and some other useful definitions for the project are defined here
package GTypes;
   import GetPut     :: *;
   import Vector     :: *;

   typedef 8                           NUM_COL;
   typedef Bit#(3)                     ColCount;
   typedef Bit#(8)                     InData;
   typedef Bit#(32)                    OutData;

   typedef Vector #(NUM_COL, InData)   MatrixRow;

   interface DotProduct;
      interface Put #(MatrixRow) aIn;
      interface Get #(OutData) yOut;
   endinterface

   // ================================================================
   // A convenience function to return the current cycle number during BSV
   // simulations

   ActionValue #(Bit #(32)) cur_cycle = actionvalue
					   Bit #(32) t <- $stime;
					   return t / 10;
				        endactionvalue;

// ===============================================================
endpackage
