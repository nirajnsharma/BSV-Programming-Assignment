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
   DotProduct        dut            <- mkDotProduct;

   // Pseudo-random number generators. Each row of the matrix is 8*InData
   // wide. At 8-bit, this works out to 64-bits. The two LFSRs are capable of
   // generating 64-bits per cycle
   LFSR #(OutData)   dinGenL	    <- mkLFSR_32;
   LFSR #(OutData)   dinGenH        <- mkLFSR_32;

   // Flag which indicates if the LFSRs have been seeded or not
   Reg #(Bool)       rg_started     <- mkReg(False);   
   FIFOF#(MatrixRow) f_in           <- mkSizedFIFOF (16);
   FIFOF#(UInt#(32)) f_testNum      <- mkSizedFIFOF (16);

   Reg #(MatrixRow)  rg_ws          <- mkRegU;

   Reg #(UInt#(32))  rg_numTests    <- mkReg (1);

   function OutData fv_mul (InData a, InData b);
      return (extend (a) * extend (b));
   endfunction

   // Seed the LFSRs
   rule start (!rg_started);
      rg_started <= True;
      dinGenL.seed ('h55555555);
      dinGenH.seed ('hAAAAAAAA);

      // Initiatialize the weights
      MatrixRow ws = replicate(0);
      for (Integer i=0; i<valueOf(NUM_COL); i=i+1)
         ws[i] = fromInteger(i)+1;
      rg_ws <= ws;
   endrule

   // This rule runs continuously feeding data into the DUT. Each time this
   // rule rules, it feeds in one row of the matrix into the DUT
   rule putIn (rg_started);
      let dIn = {dinGenH.value, dinGenL.value};
      MatrixRow m = unpack (dIn);
      f_in.enq (m);
      f_testNum.enq (rg_numTests);
      dut.aIn.put (m);
      dinGenH.next; dinGenL.next;
      rg_numTests <= rg_numTests + 1;
   endrule

   // This rule samples the output from the DUT. Also checks the answer
   // against the expected one
   rule getOut (rg_started);
      let dIn = f_in.first; f_in.deq;
      let tNum = f_testNum.first; f_testNum.deq;

      let ws = rg_ws;
      let v_uv = zipWith (fv_mul, dIn, ws);
      let uv_sum = (foldl1 (\+ , v_uv));
      let rowOut <- dut.yOut.get;

      if (uv_sum != rowOut) begin
         $display ("(%5d)::TB::ERROR - OUTPUT MISMATCH (TEST# %0d)",
	    cur_cycle, tNum);
         $display ("       TB::DIN = ", fshow (dIn));
         $display ("       TB::EXP = %08h|DUT = %08h", uv_sum, rowOut);
         $finish;
      end

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
