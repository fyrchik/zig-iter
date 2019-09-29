const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;

pub fn main() anyerror!void {
    std.debug.warn("main");
}

fn duplicate(comptime T: type) type {
    return struct {
        const Self = @This();

        list: []const T,

        pub fn init(list: []T) Self {
            return Self{
                .list = list,
            };
        }

        pub const Iterator = struct {
            list: []const T,
            item: ?T,
            index: usize,
            n: usize,
            count: usize,
        
            pub fn next(it: *Iterator) ?T {
                if (it.item == null) return null;
                if (it.count < it.n) {
                    it.count = it.count+1;
                    return it.item;
                }
                it.count = 1;
                it.index = it.index+1;
                if (it.index == it.list.len) {
                    it.item = null;
                    return null;
                }
                if (it.index < it.list.len) {
                    it.item = it.list[it.index];
                    return it.item;
                }
                unreachable;
            }
        };

        pub fn iterator(self: *Self, n: usize) Iterator {
            var item: ?T = null;
            if (self.list.len != 0 and n != 0) {
                item = self.list[0];
            }
            return Iterator{
                .item = item,
                .list = self.list,
                .index = 0,
                .count = 0,
                .n = n,
            };
        }
    };
}


test "duplicate.iterator" {
    var lst = []i32{1,2,3};
    var kek: []i32 = lst[0..];
    var list = duplicate(i32).init(kek);

    var iter0 = list.iterator(0);
    testing.expect(iter0.next() == null);
    testing.expect(iter0.next() == null);

    var iter1 = list.iterator(1);
    testing.expect(iter1.next().? == 1);
    testing.expect(iter1.next().? == 2);
    testing.expect(iter1.next().? == 3);
    testing.expect(iter1.next() == null);
    testing.expect(iter1.next() == null);

    var iter2 = list.iterator(2);
    testing.expect(iter2.next().? == 1);
    testing.expect(iter2.next().? == 1);
    testing.expect(iter2.next().? == 2);
    testing.expect(iter2.next().? == 2);
    testing.expect(iter2.next().? == 3);
    testing.expect(iter2.next().? == 3);
    testing.expect(iter2.next() == null);
    testing.expect(iter2.next() == null);
}

test "duplicate.null" {
    var iter = duplicate(i32).init([]i32{}).iterator(3);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}