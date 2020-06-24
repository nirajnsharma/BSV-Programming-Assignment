package SequenceDetect;

// This is the skeletal code for an iterative sequence detector.
// Blanks which you need to fill are marked usually with /* */
// comments with a question in between.

// ---------------------------------------------------------------
// Library imports     
import GetPut :: *;
// ---------------------------------------------------------------

// ---------------------------------------------------------------
// Interface type definition
// The system will "put" input data values into the detector, and
// "get" responses from the detector as results. Observe that no
// low-level control signals have been declared with respect to
// the interface.

interface SequenceDetect;
   interface Put# (/* What is the input data type? */) iData;
   interface Get# (Bit #(32)) oResult;
endinterface : SequenceDetect

// ---------------------------------------------------------------
// Module definition

module mkSeqDet (SequenceDetect);
   // ------------------------------------------------------------
   // Submodules
   // The only submodules you require in this model are registers.
   // Instantiate all the registers you will need. I have added
   // the first one as an example

   // rg_busy is a register which holds a Bool value and is reset
   // to False
   Reg #(Bool) rg_busy <- mkReg (False);

   /* What other submodules do you require in this module? */

   // ------------------------------------------------------------
   // Rules -- define your rule(s) here. Before writing the rule
   // you need to answer the following questions:
   //
   // 1. Under what condition will the rule execute -- this
   // becomes the explicit or outer condition of the rule
   //
   // 2. What all actions will you do under that conditon? These
   // will be become statements inside the rule body. Refer to
   // Lec2 on how to write to registers.
   //
   // 3. Are some of the actions guarded by conditions inside the
   // rule? These become ifs guarding the actions

   rule detectSequence (/* condition? */);
      /* Actions? */
   endrule : detectSequence

   // ------------------------------------------------------------
   // Interface definition
   // The last bit of code relates to defining what each method in
   // your interface does. If a method is of type Action or
   // ActionValue, writing the internals of a method is like
   // writing a rule. You need to answer the same questions. Only
   // for ActionValue methods, in addition, there will be a value
   // returned like you would do in a function. There is a third
   // type of method called value methods. These just return value
   // and do not have any side-effects.
   // ------------------------------------------------------------

   interface Put iData;
      method Action put
         (/* Type of data? */ d) if (/* when can this method be called? */);
         /* Actions? */
      endmethod : put
   endinterface

   interface Get oResult;
      method ActionValue #(Bit #(32)) get ()
         if (/* when can this method be called? */);
         /* Actions? */
      endmethod : get
   endinterface

endmodule : mkSeqDet
// ------------------------------------------------------------

endpackage : SequenceDetect
