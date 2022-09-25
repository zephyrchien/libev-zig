const std = @import("std");
const assert = std.debug.assert;
const Type = std.builtin.Type;


const helper = struct {
    const e = error{BadType};

    fn extract(
        comptime input: type,
        comptime id: std.meta.Tag(Type),
        comptime T: type) e!T {
        return switch(@typeInfo(input)) {
            id => |x| x,
            else => e.BadType,
        };
    }

    fn ckeckString(comptime input: anytype) e!void {
        const ptr = try extract(@TypeOf(input), .Pointer, Type.Pointer);
        if (!ptr.is_const) return e.BadType;

        const arr = try extract(ptr.child, .Array, Type.Array);
        if (arr.len == 0) return e.BadType;

        const byte = try extract(arr.child, .Int, Type.Int);
        if (byte.bits != 8) return e.BadType;
        if (byte.signedness != .unsigned) return e.BadType;
    }

    fn checkInt(comptime input: type) e!void {
        _ = try extract(input, .Int, Type.Int);
    }
};

fn makeSet(comptime input: anytype, comptime T: type) type {
    const bits = @bitSizeOf(T);
    const N = std.math.min(input.len + 1, bits);
    const PADD = bits - input.len;
    assert(input.len <= bits);

    // bitwise field
    var fields: [N]Type.StructField = undefined;

    for (input) |data, idx| {
        const name = switch(@typeInfo(@TypeOf(data))) {
            .Pointer =>  blk:{
                helper.ckeckString(data)
                catch @compileError("not string: " ++ @typeName(@TypeOf(data)));
                break :blk data;
            },
            .Struct  => blk:{
                helper.ckeckString(data[0])
                catch @compileError("not string: " ++ @typeName(@TypeOf(data[0])));
                break :blk data[0];
            },
            else     =>  @compileError("bad type: " ++ @typeName(@TypeOf(data))),
        };

        fields[idx] = .{
            .name = name,
            .field_type = bool,
            .default_value = &false,
            .is_comptime = false,
            .alignment = 0,
        };
    }

    // padding
    if (PADD > 0) {
        fields[N - 1] = .{
            .name = "_padd",
            .field_type = @Type(.{
                .Int = .{
                    .bits = PADD,
                    .signedness = .unsigned,
                },
            }),
            .default_value = &0,
            .is_comptime = false,
            .alignment = 0,
        } ;
    }

    return @Type(.{
        .Struct = .{
            .layout = .Packed,
            .fields = &fields,
            .decls = &[_]Type.Declaration{},
            .is_tuple = false,
        },
    });
}

fn makeTable(comptime input: anytype, comptime T:type) type {
    const bits = @bitSizeOf(T);
    const N = input.len;
    assert(input.len <= bits);

    // static field
    var fields: [N]Type.StructField = undefined;

    for (input) |data, idx| {
        var name: []const u8 = undefined;
        var value: comptime_int = undefined;
        switch(@typeInfo(@TypeOf(data))) {
            .Pointer  =>  {
                helper.ckeckString(data)
                catch @compileError("not string: " ++ @typeName(@TypeOf(data)));
                name = data; value = 1 << idx; 
            },
            .Struct =>  |s| {
                helper.ckeckString(data[0])
                catch @compileError("not string: " ++ @typeName(@TypeOf(data[0])));
                if (s.fields.len == 1) {
                name = data[0]; value = 1 << idx;
            } else if (s.fields.len == 2) {
                name = data[0]; value = data[1]; 
            }},
            else    =>  @compileError("bad type: " ++ @typeName(@TypeOf(data))),
        }

        fields[idx] = .{
            .name = name,
            .field_type = T,
            .default_value = &value,
            .is_comptime = true,
            .alignment = 0,
        };
    }

    return @Type(.{
        .Struct = .{
            .layout = .Auto,
            .fields = &fields,
            .decls = &[_]Type.Declaration{},
            .is_tuple = false,
        },
    });
}

pub fn make(comptime input: anytype, comptime T:type) type {
    helper.checkInt(T)
    catch @compileError("not int: " ++ @typeName(T));
    return struct {
        pub const set_t = makeSet(input, T);
        pub const table_t = makeTable(input, T);
        pub const Table = table_t{};

        pub fn into_int(set: set_t) T {
            var hint: T = 0;

            inline for (std.meta.fields(table_t)) |field| {
                const name = field.name;
                const value = @field(Table, name);
                if (@field(set, name)) { hint |= value; }
            }

            return hint;
        }

        pub fn from_int(hint: T) set_t {
            var set = set_t{};

            inline for (std.meta.fields(table_t)) |field| {
                const name = field.name;
                const value = @field(Table, name);
                @field(set, name) = (hint & value != 0);
            }

            return set;
        }
    };
}

test "bitset1" {
    const rgb = make(.{ "red", "green", "blue" }, u32);

    const Set = rgb.set_t;
    const RGB = rgb.Table;
    const from = rgb.from_int;
    const into = rgb.into_int;

    // test
    const eql = std.meta.eql;
    const expect = std.testing.expect;

    try expect(@sizeOf(Set) == 4);
    try expect(@bitSizeOf(Set) == 32);

    try expect(RGB.red == 0b001);
    try expect(RGB.green == 0b010);
    try expect(RGB.blue == 0b100);

    const set0 = Set{};
    const set1 = Set{.red = true};
    const set2 = Set{.green = true};
    const set3 = Set{.red = true, .green = true};
    const set4 = Set{.red = true, .green = true, .blue = true};

    try expect(comptime into(set0) == 0);
    try expect(comptime into(set1) == 0b001);
    try expect(comptime into(set2) == 0b010);
    try expect(comptime into(set3) == 0b011);
    try expect(comptime into(set4) == 0b111);

    try expect(eql(set0, comptime from(into(set0))));
    try expect(eql(set1, comptime from(into(set1))));
    try expect(eql(set2, comptime from(into(set2))));
    try expect(eql(set3, comptime from(into(set3))));
    try expect(eql(set4, comptime from(into(set4))));
}

test "bitset2" {
    const rgb = make(.{
        .{"red"}, .{"green"}, .{"blue"}
    }, u32);

    const Set = rgb.set_t;
    const RGB = rgb.Table;
    const from = rgb.from_int;
    const into = rgb.into_int;

    // test
    const eql = std.meta.eql;
    const expect = std.testing.expect;

    try expect(@sizeOf(Set) == 4);
    try expect(@bitSizeOf(Set) == 32);

    try expect(RGB.red == 0b001);
    try expect(RGB.green == 0b010);
    try expect(RGB.blue == 0b100);

    const set0 = Set{};
    const set1 = Set{.red = true};
    const set2 = Set{.green = true};
    const set3 = Set{.red = true, .green = true};
    const set4 = Set{.red = true, .green = true, .blue = true};

    try expect(comptime into(set0) == 0);
    try expect(comptime into(set1) == 0b001);
    try expect(comptime into(set2) == 0b010);
    try expect(comptime into(set3) == 0b011);
    try expect(comptime into(set4) == 0b111);

    try expect(eql(set0, comptime from(into(set0))));
    try expect(eql(set1, comptime from(into(set1))));
    try expect(eql(set2, comptime from(into(set2))));
    try expect(eql(set3, comptime from(into(set3))));
    try expect(eql(set4, comptime from(into(set4))));
}

test "bitset3" {
    const R = 0x001; const G = 0x010; const B = 0x100;
    const rgb = make(.{
        .{"red", R}, .{"green", G}, .{"blue", B}
    }, u32);

    const Set = rgb.set_t;
    const RGB = rgb.Table;
    const from = rgb.from_int;
    const into = rgb.into_int;

    // test
    const eql = std.meta.eql;
    const expect = std.testing.expect;

    try expect(@sizeOf(Set) == 4);
    try expect(@bitSizeOf(Set) == 32);

    try expect(RGB.red == R);
    try expect(RGB.green == G);
    try expect(RGB.blue == B);

    const set0 = Set{};
    const set1 = Set{.red = true};
    const set2 = Set{.green = true};
    const set3 = Set{.red = true, .green = true};
    const set4 = Set{.red = true, .green = true, .blue = true};

    try expect(comptime into(set0) == 0);
    try expect(comptime into(set1) == R);
    try expect(comptime into(set2) == G);
    try expect(comptime into(set3) == R|G);
    try expect(comptime into(set4) == R|G|B);

    try expect(eql(set0, comptime from(into(set0))));
    try expect(eql(set1, comptime from(into(set1))));
    try expect(eql(set2, comptime from(into(set2))));
    try expect(eql(set3, comptime from(into(set3))));
    try expect(eql(set4, comptime from(into(set4))));
}
