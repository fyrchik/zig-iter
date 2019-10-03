const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;

fn productT(comptime A: type, comptime B: type) type {
    return struct {
        const Self = @This();

        list1: []const A,
        list2: []const B,

        pub fn init(list1: []const A, list2: []const B) Self {
            return Self{
                .list1 = list1,
                .list2 = list2,
            };
        }

        pub const Tuple = struct {
            _1: A,
            _2: B,
        };

        pub const Iterator = struct {
            list1: []const A,
            list2: []const B,
            _1: usize,
            _2: usize,

            pub fn next(self: *Iterator) ?Tuple {
                if (self.list1.len == 0 or self.list2.len == 0) return null;
                if (self._1 == self.list1.len) return null;
                var a = Tuple{._1 = self.list1[self._1], ._2 = self.list2[self._2]};
                self._2 = self._2 + 1;
                if (self._2 == self.list2.len) {
                    self._2 = 0;
                    self._1 = self._1 + 1;
                }
                return a;
            }
        };

        pub fn iterator(self: *Self) Iterator {
            return Iterator{
                .list1 = self.list1,
                .list2 = self.list2,
                ._1 = 0,
                ._2 = 0,
            };
        }
    };
}

fn product(list1: var, list2: var) productT(@typeOf(list1).Child, @typeOf(list2).Child).Iterator {
    return productT(@typeOf(list1).Child, @typeOf(list2).Child).init(list1, list2).iterator();
}

fn compare(comptime A: type, comptime B: type, iter: *productT(A, B).Iterator, expected: []const productT(A, B).Tuple) void {
    var i: usize = 0;
    while (i < expected.len) {
        var item = iter.next().?;
        testing.expect(expected[i]._1 == item._1);
        testing.expect(expected[i]._2 == item._2);
        i = i + 1;
    }
    testing.expect(iter.next() == null);
}

test "product.single_element" {
    const lst = []i32{1,2,3};
    const TT = productT(i32, i32).Tuple;
    
    var iter = product(lst[0..1], lst[1..2]);
    const expected: []const TT = []TT{
        TT{._1 = 1, ._2 = 2},
    };
    compare(i32, i32, &iter, expected[0..]);
}

test "product.iterator" {
    const AB = productT(i32, i8).Tuple;
    var iter = product(([]i32{1,2,3})[0..], ([]i8{-1,-2})[0..]);
    const expected = []AB{
        AB{._1 = 1, ._2 = -1}, AB{._1 = 1, ._2 = -2},
        AB{._1 = 2, ._2 = -1}, AB{._1 = 2, ._2 = -2},
        AB{._1 = 3, ._2 = -1}, AB{._1 = 3, ._2 = -2},
    };
    compare(i32, i8, &iter, expected[0..]);
}

test "product.first_empty" {
    const lst = ([]i32{1})[0..];
    var iter = product([]i32{}, lst);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "product.second_empty" {
    const lst = ([]i32{1})[0..];
    var iter = product(lst, []i32{});
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}