const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;
const zag = @import("../zag.zig");
const config = zag.config;
const tailCall = config.tailCall;
const trace = config.trace;
const checkEqual = zag.utilities.checkEqual;
const object = zag.object;
const Object = object.Object;
const ClassIndex = object.ClassIndex;
const Nil = object.Nil;
const True = object.True;
const False = object.False;
//const class = @import("class.zig");
const symbol = zag.symbol;
const Sym = symbol.symbols;
const phi32 = zag.utilities.inversePhi(u32);
const execute = zag.execute;
const empty = &[0]Object{};
const PC = execute.PC;
const SP = execute.SP;
const Execution = execute.Execution;
const Process = zag.Process;
const Context = zag.Context;
const Extra = execute.Extra;
const Result = execute.Result;
const CompiledMethod = execute.CompiledMethod;
const stringOf = zag.heap.CompileTimeString;
const tf = zag.threadedFn.Enum;
const llvm = @import("llvm-build-module");
const LLVMtype = llvm.types;
const builtin = @import("builtin");
pub const isTestMode = builtin.is_test;
pub const moduleName = "llvm";
pub const llvmString = stringOf("llvm").init().obj();
const allocator = std.heap.page_allocator;

const LLVMAttributeRef = LLVMtype.LLVMAttributeRef;
const LLVMBasicBlockRef = LLVMtype.LLVMBasicBlockRef;
const LLVMBool = LLVMtype.LLVMBool;
const LLVMBuilderRef = LLVMtype.LLVMBuilderRef;
const LLVMComdatRef = LLVMtype.LLVMComdatRef;
const LLVMContextRef = LLVMtype.LLVMContextRef;
const LLVMDIBuilderRef = LLVMtype.LLVMDIBuilderRef;
const LLVMDiagnosticInfoRef = LLVMtype.LLVMDiagnosticInfoRef;
const LLVMJITEventListenerRef = LLVMtype.LLVMJITEventListenerRef;
const LLVMMemoryBufferRef = LLVMtype.LLVMMemoryBufferRef;
const LLVMMetadataRef = LLVMtype.LLVMMetadataRef;
const LLVMModuleFlagEntry = LLVMtype.LLVMModuleFlagEntry;
const LLVMModuleProviderRef = LLVMtype.LLVMModuleProviderRef;
const LLVMModuleRef = LLVMtype.LLVMModuleRef;
const LLVMNamedMDNodeRef = LLVMtype.LLVMNamedMDNodeRef;
const LLVMPassManagerRef = LLVMtype.LLVMPassManagerRef;
const LLVMPassRegistryRef = LLVMtype.LLVMPassRegistryRef;
const LLVMTypeRef = LLVMtype.LLVMTypeRef;
const LLVMUseRef = LLVMtype.LLVMUseRef;
const LLVMValueMetadataEntry = LLVMtype.LLVMValueMetadataEntry;
const LLVMValueRef = LLVMtype.LLVMValueRef;
const llvmClass = @intFromEnum(object.ClassIndex.LLVM);

// Execution of tests: call `zig build test -Dllvm
// JITDriver (future)     =>  Traverses through each threaded word in a compiled method's code array and
//                            sends the word as a message to the JITDispatcher.
// JITDispatcher (future) => Contains logic that orchastrates which primitives to send to the
//                           JITPrimitiveGEnerator class. Defined on the Smalltalk side.
//                           Contains sp, driver, and gen instance variables.
// JITPrimitiveGenerator  => Contains direct LLVM primitive calls.
//                           Contains builder, module and context instance variables.

pub fn main() void {}
fn Converter(T: type) type {
    const tag = switch (T) {
        LLVMAttributeRef => 1,
        LLVMBasicBlockRef => 2,
        LLVMBool => 3,
        LLVMBuilderRef => 4,
        LLVMComdatRef => 5,
        LLVMContextRef => 6,
        LLVMDIBuilderRef => 7,
        LLVMDiagnosticInfoRef => 8,
        LLVMJITEventListenerRef => 9,
        LLVMMemoryBufferRef => 10,
        LLVMMetadataRef => 11,
        LLVMModuleFlagEntry => 12,
        LLVMModuleProviderRef => 13,
        LLVMModuleRef => 14,
        LLVMNamedMDNodeRef => 15,
        LLVMPassManagerRef => 16,
        LLVMPassRegistryRef => 17,
        LLVMTypeRef => 18,
        LLVMUseRef => 19,
        LLVMValueMetadataEntry => 20,
        LLVMValueRef => 21,
        JITPrimitiveGeneratorRef => 255,
        else => @compileError("Converter needs extansion for type: " ++ @typeName(T)),
    };
    return struct {
        fn asObject(llvmPtr: T) Object {
            return Object.Special.objectFrom(llvmClass, tag, @ptrCast(llvmPtr));
        }
        fn asLLVM(tagObject: Object) !T {
            const spec = tagObject.rawSpecial();
            if (spec.imm == llvmClass) { // TODO: Double check bit logic
                if (spec.tag == tag)
                    return @ptrCast(spec.ptr());
            }
            return error.InvalidTag;
        }
        fn getTag() u8 {
            return tag; // TODO: ensure 'T: type' is bounded to u8
        }
    };
}

const AttributeRef = Converter(LLVMAttributeRef);
const BasicBlockRef = Converter(LLVMBasicBlockRef);
const Bool = Converter(LLVMBool);
const BuilderRef = Converter(LLVMBuilderRef);
const ComdatRef = Converter(LLVMComdatRef);
const ContextRef = Converter(LLVMContextRef);
const DIBuilderRef = Converter(LLVMDIBuilderRef);
const DiagnosticInfoRef = Converter(LLVMDiagnosticInfoRef);
const JITEventListenerRef = Converter(LLVMJITEventListenerRef);
const MemoryBufferRef = Converter(LLVMMemoryBufferRef);
const MetadataRef = Converter(LLVMMetadataRef);
const ModuleFlagEntry = Converter(LLVMModuleFlagEntry);
const ModuleProviderRef = Converter(LLVMModuleProviderRef);
const ModuleRef = Converter(LLVMModuleRef);
const NamedMDNodeRef = Converter(LLVMNamedMDNodeRef);
const PassManagerRef = Converter(LLVMPassManagerRef);
const PassRegistryRef = Converter(LLVMPassRegistryRef);
const TypeRef = Converter(LLVMTypeRef);
const UseRef = Converter(LLVMUseRef);
const ValueMetadataEntry = Converter(LLVMValueMetadataEntry);
const ValueRef = Converter(LLVMValueRef);
const PrimitiveGeneratorRef = Converter(JITPrimitiveGeneratorRef);
const JITPrimitiveGeneratorRef = *JITPrimitiveGenerator;
const JITPrimitiveGenerator = struct {
    module: LLVMModuleRef,
    context: LLVMContextRef,
    builder: LLVMBuilderRef,
};

pub const initNativeTarget = if (config.notZag) struct {} else struct {
    pub const number = 900;
    pub fn primitive(_: PC, sp: SP, process: *Process, context: *Context, _: Extra) Result {
        // TODO: future might need a fallback case if native target is incorrect
        llvm.target.initNativeTarget();
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, sp, process, context, undefined });
    }
    test "initNativeTarget" {
        _ = Execution.initTest("llvm init target", .{
            tf.inlinePrimitive, 900,
        });
    }
};

pub const makeJITPrimitiveGenerator = if (config.notZag) struct {} else struct {
    pub const number = 901;
    pub fn primitive(_: PC, sp: SP, process: *Process, context: *Context, _: Extra) Result {
        // TODO: Ensure the LLVM-C API calls don't fail - implement call to Extra.primitiveFailed if so (?)
        // The fields of the generator must be not be null
        const memory = allocator.alloc(JITPrimitiveGenerator, 1) catch unreachable;
        const primitiveGenerator: JITPrimitiveGeneratorRef = @ptrCast(memory);
        primitiveGenerator.context = llvm.core.LLVMContextCreate();
        primitiveGenerator.module = llvm.core.LLVMModuleCreateWithNameInContext("jit_module", primitiveGenerator.context);
        primitiveGenerator.builder = llvm.core.LLVMCreateBuilderInContext(primitiveGenerator.context);
        const new_sp = sp.push(PrimitiveGeneratorRef.asObject(primitiveGenerator));
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, new_sp, process, context, undefined });
    }
    test "makeJITPrimitiveGenerator" {
        // TODO: Couple primitive 900 here
        var exe = Execution.initTest("llvm primitiveGenerator", .{
            // tf.inlinePrimitive, 900,
            tf.inlinePrimitive, 901,
        });
        try exe.execute(&[_]Object{}); // initial stack
        const result = exe.stack()[0];
        const spec = result.rawSpecial();
        try expectEqual(llvmClass, spec.imm);
        try expectEqual(PrimitiveGeneratorRef.getTag(), spec.tag);
        const llvmObj = try PrimitiveGeneratorRef.asLLVM(result);
        try expect(llvmObj.module != null);
        try expect(llvmObj.context != null);
        try expect(llvmObj.builder != null);
    }
};

pub const @"createThreadedSig:methodName" = if (config.objectEncoding != .zag) struct {} else struct {};

pub const freeJITResources = if (config.objectEncoding != .zag) struct {} else struct {
    pub const number = 454;
    pub fn primitive(pc: PC, sp: SP, process: *Process, context: *Context, extra: Extra) Result {
        // TODO: Free allocator, LLVM JIT instance, module
        // context and builder become invalid after being passed to the JIT instance
        _ = .{ pc, sp, process, context, extra };
        @panic("not implemented");
    }
};

pub const @"register:plus:asName:" = if (config.objectEncoding != .zag) struct {} else struct {
    pub fn primitive(pc: PC, sp: SP, process: *Process, context: *Context, extra: Extra) Result {
        if (isTestMode) return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        const self = sp.at(4);
        const jitPrimitiveGenerate: JITPrimitiveGeneratorRef = PrimitiveGeneratorRef.asLLVM(self);
        const builder = BuilderRef.asLLVM(jitPrimitiveGenerate.module) catch return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        const registerToModify = ValueRef.asLLVM(sp.third) catch return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        const offset = sp.next.to(i64);
        const name = sp.top.arrayAsSlice(u8) catch return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        const newSp = sp.unreserve(3);
        const module = ModuleRef.asLLVM(jitPrimitiveGenerate.context) catch return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        const tagObjectTy = llvm.core.LLVMGetTypeByName(module, "TagObject");
        sp.top = ValueRef.asObject(singleIndexGEP(@ptrCast(builder), tagObjectTy, registerToModify, offset, name));
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, newSp, process, context, undefined });
    }
};

pub const newLabel = struct {
    pub fn primitive(pc: PC, sp: SP, process: *Process, context: *Context, extra: Extra) Result {
        if (isTestMode) return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, sp, process, context, undefined });
    }
};

pub const @"literalToRegister:" = if (config.objectEncoding != .zag) struct {} else struct {
    pub fn primitive(pc: PC, sp: SP, process: *Process, context: *Context, extra: Extra) Result {
        // const valueToPush = sp.top;
        if (isTestMode) return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, sp, process, context, undefined });
    }
};

pub const @"add:to:" = if (config.objectEncoding != .zag) struct {} else struct {
    pub fn primitive(pc: PC, sp: SP, process: *Process, context: *Context, extra: Extra) Result {
        if (isTestMode) return @call(tailCall, Extra.primitiveFailed, .{ pc, sp, process, context, extra });
        return @call(tailCall, process.check(context.npc.f), .{ context.tpc, sp, process, context, undefined });
    }
};

inline fn singleIndexGEP(builder: LLVMBuilderRef, elementType: LLVMTypeRef, base: LLVMValueRef, offset: i64, name: []const u8) LLVMValueRef {
    // singleIndex - for pointer and integer offsets
    const offset_bits: u64 = @bitCast(offset);
    const signExtend = offset < 0;
    const idx = [_]LLVMValueRef{llvm.type.LLVMConstInt(elementType, offset_bits, @intFromBool(signExtend))};
    const idx_ptr: [*c]llvm.types.LLVMValueRef = @constCast(@ptrCast(&idx[0]));
    return llvm.core.LLVMBuildGEP2(builder, elementType, base, idx_ptr, 1, @ptrCast(name));
}

// ------ OLD TESTS -------
// test "simple llvm" {
//     std.debug.print("Test: simple llvm\n", .{});
//     const expectEqual = std.testing.expectEqual;
//     Process.resetForTest();
//     const pl = if (true) &p.pushLiteral else llvmPLCM;
//     var method = compileMethod(Sym.yourself, 0, 0, .testClass, .{
//         pl,                    0,
//         &p.returnTopNoContext,
//     });
//     var te = Execution.new();
//     te.init(null);
//     var objs = [_]Object{ Nil, True };
//     const result = te.run(objs[0..], &method);
//     try expectEqual(result.len, 3);
//     try expectEqual(result[0], Object.from(0));
//     try expectEqual(result[1], Nil);
//     try expectEqual(result[2], True);
// }
// test "llvm external" {
//     std.debug.print("Test: llvm external\n", .{});
//     const expectEqual = std.testing.expectEqual;
//     Process.resetForTest();
//     const pl = if (true) &p.pushLiteral else llvmPLCM;
//     var method = compileMethod(Sym.yourself, 1, 0, .testClass, .{
//         &p.pushContext,   "^",
//         ":label1",        &p.pushLiteral,
//         42,               &p.popLocal,
//         0,                &p.pushLocal,
//         0,                pl,
//         0,                &p.pushLiteral,
//         true,             &p.classCase,
//         ClassIndex.False, "label3",
//         &p.branch,        "label2",
//         ":label3",        &p.pushLocal,
//         0,                ":label4",
//         &p.returnTop,     ":label2",
//         pl,               0,
//         &p.branch,        "label4",
//     });
//     method.resolve();
//     const debugging = false;
//     if (debugging) {
//         @setRuntimeSafety(false);
//         for (&method.code, 0..) |*tv, idx|
//             trace("\nt[{}]=0x{x:0>8}: 0x{x:0>16}", .{ idx, @intFromPtr(tv), tv.object.rawU() });
//     }
//     var objs = [_]Object{ Nil, Nil, Nil };
//     var te = Execution.new();
//     te.init(null);
//     const result = te.run(objs[0..], &method);
//     try expectEqual(result.len, 1);
//     try expectEqual(result[0], Object.from(0));
// }
