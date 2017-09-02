package Tb;
   // Default imports
   import FIFOF      :: *;
   import Vector     :: *;
   import LFSR       :: *;
   import GetPut     :: *;

   // Project imports
   import GTypes     :: *; // Common type definitions here
   import DotProduct :: *; // The DUT is implemented here

   // Test bench module (top-level, therefore Empty interface)
   (* synthesize *)
   module mkTb (Empty);

   // Instantiate the design-under-test
   DotProduct        dut            <- mkMatrixMulW;

   // Pseudo-random number generators. Each row of the matrix is 8*InData
   // wide. At 8-bit, this works out to 64-bits. The two LFSRs are capable of
   // generating 64-bits per cycle
   LFSR #(OData)     dinGenL	    <- mkLFSR_32;
   LFSR #(OData)     dinGenH        <- mkLFSR_32;

   // Flag which indicates if the LFSRs have been seeded or not
   Reg #(Bool)       rg_started     <- mkReg(False);   
   FIFOF#(IRow)      f_in           <- mkSizedFIFOF (16);
   FIFOF#(UInt#(32)) f_testNum      <- mkSizedFIFOF (16);

   Vector #(  NUM_W_COL
            , Reg #(ICol)
	   )         rg_ws          <- mkRegU;

   Reg #(UInt#(32))  rg_numTests    <- mkReg (1);

   function OutData fv_mul (InData a, InData b);
      return (extend (a) * extend (b));
   endfunction

   Bool debug = False;

   // Seed the LFSRs
   rule start (!rg_started);
      rg_started <= True;
      dinGenL.seed ('h12345678);
      dinGenH.seed ('h9ABCDEF0);

      // Initiatialize the weights
      initialize_w (rg_ws);
   endrule

   // This rule runs continuously feeding data into the DUT. Each time this
   // rule runs, it feeds in one row of A into the DUT
   rule putIn (rg_started);
      // Generate random data to feed the DUT, and update the LFSRs
      let randomIn = {dinGenH.value, dinGenL.value};
      dinGenH.next; dinGenL.next;

      // Format the data into a row of the matrix
      Bit# (IRowWidth) dIn = truncate (randomIn);
      IRow m = unpack (dIn);

      // Record the data sent in to compute expected output
      f_in.enq (m);

      // Record the test-number, also increment for next test
      f_testNum.enq (rg_numTests);
      rg_numTests <= rg_numTests + 1;

      // Feed the data into the DUT
      dut.aIn.put (m);

      if (debug) $display ("(%5d)::TB::putIn::Test# %0d::",
	 cur_cycle, rg_numTests, fshow (m));
   endrule

   // This rule samples the output from the DUT. Also checks the answer
   // against the expected one
   rule getOut (rg_started);
      // Retreive the data sent to the DUT along with the test number
      let dIn = f_in.first; f_in.deq;
      let tNum = f_testNum.first; f_testNum.deq;

      // Compute expected value using the C routine
      let expected = fn_computeExpected (rg_ws, dIn);

      // Get the computed value from the hardware
      let dutOut <- dut.yOut.get;

      // Compare ...
      // Look for mismatches in each entry of the output
      Bool mismatchFound = False;
      for (Integer i=0; i<valueOf(NUM_W_ROW); i=i+1) begin
	 mismatchFound = mismatchFound || (expected[i] != dutOut[i]);

      // Mismatch
      if (mismatchFound) begin
         $display ("(%5d)::TB::ERROR - OUTPUT MISMATCH (TEST# %0d)",
	    cur_cycle, tNum);
         $display ("       TB::A = ", fshow (dIn));
         $display ("       TB::EXP = ", fshow (golden));
	 $display ("       TB::DUT = ", fshow (dutOut));
         $finish;
      end

      // No mismatch found
      else begin
	 if ((rg_numTests % 100000) == 0) begin
	    $display ("(%5d)::TB::%d tests passed. Ending test...",
	       cur_cycle, rg_numTests); 
	    $finish;
	 end
      end
   endrule

   endmodule
endpackage
