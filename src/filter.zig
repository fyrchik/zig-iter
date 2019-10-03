const std = @import("std");
const testing = std.testing;

fn filterT(comptime T: type) type {
    return struct {
        const Self = @This();

        list: []const T,
        f: fn (T) bool,

        pub fn init(list: []const T, f: fn(T) bool) Self {
            return Self{
                .list = list,
                .f = f,
            };
        }

        pub const Iterator = struct {
            list: []const T,
            filter: fn(T) bool,
            index: usize,

            pub fn next(self: *Iterator) ?T {
                if (self.list.len == 0) return null;
                while (self.index < self.list.len) {
                    const a = self.list[self.index];
                    self.index = self.index + 1;
                    if (self.filter(a)) {
                        return a;
                    }
                }
                return null;
            }
        };

        pub fn iterator(self: *Self) Iterator {
            return Iterator{
                .list = self.list,
                .filter = self.f,
                .index = 0,
            };
        }
    };
}

fn filter(list: var, f: fn (@typeOf(list).Child) bool) filterT(@typeOf(list).Child).Iterator {
    return filterT(@typeOf(list).Child).init(list, f).iterator();
}

fn isOdd(x: i32) bool { return x & 1 == 1; }

test "filter.iterator" {
    const lst = []i32{1,2,3};
    var iter = filter(lst[0..], isOdd);

    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "filter.null" {
    var iter = filter([]i32{}, isOdd);

    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "filter.all_fail" {
    const lst = []i32{2,4,6};
    var iter = filter(lst[0..], isOdd);

    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}