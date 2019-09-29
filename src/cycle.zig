const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;

fn cycleT(comptime T: type) type {
    return struct {
        const Self = @This();

        list: []const T,

        pub fn init(list: []const T) Self {
            return Self{
                .list = list,
            };
        }

        pub const Iterator = struct {
            list: []const T,
            index: usize,

            pub fn next(self: *Iterator) ?T {
                if (self.list.len == 0) return null;
                var a = self.list[self.index];
                self.index = (self.index + 1) % self.list.len;
                return a;
            }
        };

        pub fn iterator(self: *Self) Iterator {
            return Iterator{
                .list = self.list,
                .index = 0,
            };
        }
    };
}

fn cycle(list: var) cycleT(@typeOf(list).Child).Iterator {
    return cycleT(@typeOf(list).Child).init(list).iterator();
}

test "cycle.iterator" {
    const lst = []i32{1,2,3};
    
    var iter = cycle(lst[0..1]);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 1);

    iter = cycle(lst[0..]);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 1);
}

test "cycle.null" {
    var iter = cycle([]i32{});

    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}