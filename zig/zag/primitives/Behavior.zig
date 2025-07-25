const std = @import("std");
const config = @import("../config.zig");
const tailCall = config.tailCall;
const trace = config.trace;
const execute = @import("../execute.zig");
const SendCache = execute.SendCache;
const Context = execute.Context;
const ContextPtr = *Context;
const Code = execute.Code;
const PC = execute.PC;
const SP = execute.SP;
const compileMethod = execute.compileMethod;
const CompiledMethodPtr = execute.CompiledMethodPtr;
const Process = @import("../process.zig").Process;
const object = @import("../zobject.zig");
const Object = object.Object;
const Nil = object.Nil;
const True = object.True;
const False = object.False;
const Sym = @import("../symbol.zig").symbols;
const heap = @import("../heap.zig");

pub fn init() void {}

pub const inlines = struct {
    pub inline fn p71(self: Object, other: Object) !Object { // basicNew:
        _ = self;
        _ = other;
        //        return error.primitiveError;
        unreachable;
    }
};
pub const embedded = struct {
    const fallback = execute.fallback;
    pub fn @"new:"(pc: PC, sp: SP, process: *Process, context: ContextPtr, _: Object, _: SendCache) SP {
        sp[1] = inlines.p71(sp[1], sp[0]) catch return @call(tailCall, process.check(fallback), .{ pc, sp, process, context, undefined, undefined });
        return @call(tailCall, process.check(pc[0].prim), .{ pc + 1, sp + 1, process, context, undefined, undefined });
    }
};
pub const primitives = struct {
    pub fn p70(pc: PC, sp: SP, process: *Process, context: ContextPtr, selector: Object, cache: SendCache) SP { // basicNew
        _ = .{ pc, sp, process, context, selector, cache };
        unreachable;
    }
    pub fn p71(pc: PC, sp: SP, process: *Process, context: ContextPtr, selector: Object, cache: SendCache) SP { // basicNew:
        _ = .{ pc, sp, process, context, selector, cache };
        unreachable;
    }
};
fn testExecute(method: CompiledMethodPtr) []Object {
    var te = execute.TestExecution.new();
    te.init();
    var objs = [_]Object{};
    const result = te.run(objs[0..], method);
    std.debug.print("result = {any}\n", .{result});
    return result;
}
