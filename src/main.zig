const std = @import("std");

pub fn main() anyerror!void {
    const lst = []i32{1,2,3};

    var dup = duplicate(i32, 3, 2, lst).init();
    var iter = dup.iterator();
    while (iter.next()) |item| {
        std.debug.warn("{}\n", item);
    }
}

fn duplicate(comptime T: type, comptime len: usize, n: usize, lst: [len]T) type {
    return struct {
        const Self = @This();

        list: [len]T,

        pub fn init() Self {
            return Self{
                .list = lst,
            };
        }

        pub const Iterator = struct {
            list: [len]T,
            item: ?T,
            index: usize,
            n: usize,
            count: usize,
        
            pub fn next(it: *Iterator) ?T {
                if (it.item == null) return null;
                if (it.count <= it.n) {
                    it.count = it.count+1;
                    return it.item;
                }
                it.count = 1;
                it.index = it.index+1;
                if (it.index == len) {
                    it.item = null;
                    return null;
                }
                it.item = it.list[it.index];
                return it.item;
            }
        };

        pub fn iterator(self: *Self) Iterator {
            var item: ?T = null;
            if (len != 0) {
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