/// TF_Operation/TF_Output wrapper module.
module tfd.op;

import tfd.c_api;
import tfd.testing : assertStatus;

/// TF_Operation/TF_Output wrapper used in Graph.
struct Operation
{
  import mir.rc.slim_ptr : SlimRCPtr;

  import tfd.graph : GraphOwner;

  /// Raw pointer.
  TF_Output base;
  /// Graph scope containing this operation.
  SlimRCPtr!GraphOwner graph;
  alias base this;

  /// Binary operator for +.
  @trusted  Operation opBinary(string op : "+")(Operation rhs)
  {
    assert(this.graph == rhs.graph);
    scope (exit) assertStatus(this.graph.status);

    TF_OperationDescription* desc = TF_NewOperation(this.graph, "AddN", "add");
    TF_Output[2] inputs;
    inputs[0] = this.base;
    inputs[1] = rhs.base;
    TF_AddInputList(desc, inputs.ptr, 2);
    TF_Operation* op = TF_FinishOperation(desc, this.graph.status);
    assertStatus(this.graph.status);
    assert(op !is null);
    return Operation(TF_Output(op, 0), this.graph);
  }
}

