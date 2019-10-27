const std = @import("std");
const testing = std.testing;

const ArrayList = std.ArrayList;
const global_allocator = std.debug.global_allocator;

fn concatT(comptime T: type) type {
    return struct {
        const Self = @This();

        const Iterator = struct {
            iter1: ArrayList(T).Iterator,
            iter2: ArrayList(T).Iterator,
            end1: bool,
            end2: bool,

            pub fn next(self: *Iterator) ?T {
                var a: ?T = null;
                if (!self.end1) {
                    a = self.iter1.next();
                    if (a == null) {
                        self.end1 = true;
                        a = self.iter2.next();
                        if (a == null) {
                            self.end2 = true;
                        }
                    }
                } else if (!self.end2) {
                    a = self.iter2.next();
                    if (a == null) {
                        self.end2 = true;
                    }
                }
                return a;
            }
        };

        pub fn init() Self {
            return Self{};
        }

        pub fn iterator(self: *Self, iter1: ArrayList(T).Iterator, iter2: ArrayList(T).Iterator) Iterator {
            return Iterator{
                .iter1 = iter1,
                .iter2 = iter2,
                .end1 = false,
                .end2 = false,
            };
        }
    };
}

fn elemOf(comptime A: type) type { return std.meta.Child(A.Slice); }

fn concat(list1: var, list2: var) concatT(elemOf(@typeOf(list1))).Iterator {
    return concatT(elemOf(@typeOf(list1))).init().iterator(list1.iterator(), list2.iterator());
}

test "concat.non_empty" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    try list1.appendSlice([_]i32{1,2,3});
    try list2.appendSlice([_]i32{4,5});
    
    var iter = concat(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next().? == 5);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "concat.first_empty" {
     var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    try list1.appendSlice([_]i32{});
    try list2.appendSlice([_]i32{1,2});

    var iter = concat(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "concat.second_empty" {
    var list1 = std.ArrayList(i32).init(global_allocator);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(global_allocator);
    defer list2.deinit();

    try list1.appendSlice([_]i32{1});
    try list2.appendSlice([_]i32{});

    var iter = concat(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}