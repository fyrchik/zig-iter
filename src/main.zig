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
        n: usize,

        pub fn init(n: usize, lst: []const T) Self {
            return Self{
                .list = lst,
                .n = n,
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

        pub fn iterator(self: *Self) Iterator {
            var item: ?T = null;
            if (self.list.len != 0) {
                item = self.list[0];
            }
            return Iterator{
                .item = item,
                .list = self.list,
                .index = 0,
                .count = 0,
                .n = self.n,
            };
        }
    };
}


test "duplicate.iterator" {
    const lst = []i32{1,2,3};
    var iter = duplicate(i32)
        .init(2, lst[0..])
        .iterator();

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);

    var iter2 = duplicate(i32)
        .init(2, []const i32{})
        .iterator();
    testing.expect(iter2.next() == null);
    testing.expect(iter2.next() == null);
}