// This is the package for v01 of the VecMul block. The interface for this
// module is defined in the GTypes package

package DotProduct;
   import GetPut     :: *;
   import FIFOF      :: *;
   import Vector     :: *;

   // Project Imports
   import GTypes     :: *;

   // The module's behaviour
   (* synthesize *)
   module mkDotProduct (DotProduct);

   // This register holds the fixed weights (W)
   Reg #(MatrixRow)  rg_ws           <- mkRegU;

   // This register serves as the buffer where the input row of the A matrix
   // comes and sits, before being processed by the compute block
   // The rg_aInValid flag indicates that the data is ready for processing
   Reg #(MatrixRow)  rg_aIn          <- mkRegU;
   Reg #(Bool)       rg_aInValid     <- mkReg (False);

   // This register holds the output results
   // The rg_yOutValid flag indicates that the output is ready
   Reg #(OutData)    rg_yOut         <- mkReg (0);
   Reg #(Bool)       rg_yOutValid    <- mkReg (False);

   // This flag is used to indicate that the W vector has been initialized
   Reg #(Bool)	     rg_initialized  <- mkReg (False);

   // -----------------------------------------------------------------
   // The weights vector (fixed)
   rule initialize (!rg_initialized);
      MatrixRow  ws = replicate (0);
      for (Integer i=0; i<valueOf(NUM_COL); i=i+1)
         ws[i] = fromInteger(i)+1;
      rg_ws <= ws;
      rg_initialized <= True;
   endrule

   // *******
   // Insert rule(s) here to implement the MAC logic
   //
   // Write results into the rg_yOut register when done. Make sure that you set
   // the rg_yOutValid flag to True to indicate that the output is ready
   //
   // Remember you should clear the rg_aInValid flag to False to indicate that
   // you have completed processing, otherwise the next data can't come in



   // *******

   // -----------------------------------------------------------------
   // Interface definition - connects up the input and output buffers to the
   // interfaces. The interfaces are driven by the testbench

   // Data-in from the test bench is placed in the rg_aIn register, and the
   // rg_aInValid flag is set to True to indicate that there is valid data for
   // the compute logic
   interface Put aIn;
      method Action put (MatrixRow m) if (!rg_aInValid);
         rg_aIn <= m;
         rg_aInValid <= True;
      endmethod
   endinterface

   // Output data is driven from the rg_yOut register
   interface Get yOut;
      method ActionValue #(OutData) get if (rg_yOutValid);
         rg_yOutValid <= False;
	 rg_yOut <= 0;
	 return (rg_yOut);
      endmethod
   endinterface
   endmodule
endpackage
