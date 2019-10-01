const std = @import("std");
const testing = std.testing;

fn concatT(comptime T: type) type {
    return struct {
        const Self = @This();

        list1: []const T,
        list2: []const T,

        const Iterator = struct {
            list1: []const T,
            list2: []const T,
            _1: usize,
            _2: usize,

            fn next(self: *Iterator) ?T {
                if (self._1 < self.list1.len) {
                    const a = self.list1[self._1];
                    self._1 = self._1 + 1;
                    return a;
                } else if (self._2 < self.list2.len) {
                    const a = self.list2[self._2];
                    self._2 = self._2 + 1;
                    return a;
                }
                return null;
            }
        };

        fn init(list1: []const T, list2: []const T) Self {
            return Self{
                .list1 = list1,
                .list2 = list2,
            };
        }

        fn iterator(self: *Self) Iterator {
            return Iterator{
                .list1 = self.list1,
                .list2 = self.list2,
                ._1 = 0,
                ._2 = 0,
            };
        }
    };
}

fn concat(list1: var, list2: var) concatT(@typeOf(list1).Child).Iterator {
    const T = @typeOf(list1).Child;
    return concatT(T).init(list1, list2).iterator();
}

test "concat.non_empty" {
    var list1 = ([]i32{1,2,3})[0..];
    var list2 = ([]i32{4,5})[0..];
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
    var list1 = ([]i32{})[0..];
    var list2 = ([]i32{1,2})[0..];
    var iter = concat(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "concat.second_empty" {
    var list1 = ([]i32{1})[0..];
    var list2 = ([]i32{})[0..];
    var iter = concat(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}