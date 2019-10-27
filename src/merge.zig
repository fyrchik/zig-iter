const std = @import("std");
const debug = std.debug;
const testing = std.testing;

const ArrayList = std.ArrayList;
const global_allocator = debug.global_allocator;

fn mergeT(comptime T: type) type {
    return struct {
        const Self = @This();
        const LT = fn (T, T) bool;

        fn init() Self {
            return Self{};
        }

        pub const Iterator = struct {
            list1: ArrayList(T).Iterator,
            list2: ArrayList(T).Iterator,
            less: LT,
            elem1: ?T,
            elem2: ?T,
            first: bool,

            pub fn reset(self: *Iterator) void {
                self.list1.reset();
                self.list2.reset();
                self.elem1 = null;
                self.elem2 = null;
                self.first = true;
            }

            pub fn next(self: *Iterator) ?T {
                if (self.first) {
                    self.first = false;
                    self.elem1 = self.list1.next();
                    self.elem2 = self.list2.next();
                }
                    
                var a: ?T = null;
                if ((self.elem1 == null) and (self.elem2 == null)) {
                    return null;
                } else if (self.elem1 == null) {
                    a = self.elem2;
                    self.elem2 = self.list2.next();
                } else if (self.elem2 == null) {
                    a = self.elem1;
                    self.elem1 = self.list1.next();
                } else if (self.less(self.elem1.?, self.elem2.?)) {
                    a = self.elem1;
                    self.elem1 = self.list1.next();
                } else {
                    a = self.elem2;
                    self.elem2 = self.list2.next();
                }
                return a;
            }
        };

        pub fn iterator(self: *Self, l1: ArrayList(T), l2: ArrayList(T), less: LT) Iterator {
            var iter1 = l1.iterator();
            var iter2 = l2.iterator();
            return Iterator{
                .list1 = iter1,
                .list2 = iter2,
                .less = less,
                .elem1 = null,
                .elem2 = null,
                .first = true,
            };
        }
    };
}

fn elemOf(comptime t: type) type { return std.meta.Child(t.Slice); }

fn merge(list1: var, list2: var, less: fn (elemOf(@typeOf(list1)), elemOf(@typeOf(list2))) bool) mergeT(elemOf(@typeOf(list1))).Iterator {
    return mergeT(elemOf(@typeOf(list1))).init().iterator(list1, list2, less);
}

fn lt(a: i32, b: i32) bool { return a < b; }

test "merge.iterator" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();
    
    try list1.append(1);
    try list1.append(2);
    try list1.append(3);
    try list2.append(2);
    try list2.append(6);
    try list2.append(7);
    
    var iter = merge(list1, list2, lt);

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 6);
    testing.expect(iter.next().? == 7);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "merge.first_null" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    try list2.append(1);
    try list2.append(2);

    var iter = merge(list1, list2, lt);

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "merge.second_null" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    try list1.append(1);
    try list1.append(2);

    var iter = merge(list1, list2, lt);

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "merge.both_null" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    var iter = merge(list1, list2, lt);

    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "merge.reset" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();
    
    try list1.append(1);
    try list1.append(3);
    try list2.append(2);
    try list2.append(4);
    
    var iter = merge(list1, list2, lt);

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next() == null);
    
    iter.reset();
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    
    iter.reset();
    testing.expect(iter.next().? == 1);
}