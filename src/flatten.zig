const std = @import("std");
const testing = std.testing;

fn flattenT(comptime T: type) type {
    return struct {
        const Self = @This();

        list: []const []const T,

        const Iterator = struct {
            list: []const []const T,
            outer: usize,
            inner: usize,

            fn next(self: *Iterator) ?T {
                if (self.outer == self.list.len) return null;
                if (self.inner == self.list[self.outer].len) {
                    self.inner = 1; // set it to the next element
                    self.outer = self.outer + 1;
                    while (self.outer < self.list.len and self.list[self.outer].len == 0) {
                        self.outer = self.outer + 1;
                    }
                    if (self.outer == self.list.len) return null;
                    return self.list[self.outer][0];
                }
                const a = self.list[self.outer][self.inner];
                self.inner = self.inner + 1;
                return a;
            }
        };

        fn init(list: []const []const T) Self {
            return Self{
                .list = list,
            };
        }

        fn iterator(self: *Self) Iterator {
            return Iterator{
                .list = self.list,
                .outer = 0,
                .inner = 0,
            };
        }
    };
}

fn flatten(list: var) flattenT(@typeOf(list).Child.Child).Iterator {
    const T = @typeOf(list).Child.Child;
    return flattenT(T).init(list).iterator();
}

test "flatten.non_empty" {
    const list = ([][]const i32{
        ([]i32{1,2,3})[0..],
        ([]i32{4,5})[0..],
    })[0..];
    var iter = flatten(list);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next().? == 5);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "flatten.with_empty" {
    const list = ([][]const i32{
        []i32{},
        []i32{1,2},
        []i32{},
        []i32{},
        []i32{3},
    })[0..];
    var iter = flatten(list);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "flatten.empty" {
    const list = ([][]i32{})[0..];
    var iter = flatten(list);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}