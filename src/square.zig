const std = @import("std");
const debug = std.debug;
const assert = debug.assert;
const testing = std.testing;

fn squareT(comptime T: type) type {
    return struct {
        const Self = @This();

        list: []const T,

        pub fn init(list: []const T) Self {
            return Self{
                .list = list,
            };
        }

        pub const Tuple = struct {
            _1: T,
            _2: T,
        };

        pub const Iterator = struct {
            list: []const T,
            _1: usize,
            _2: usize,

            pub fn next(self: *Iterator) ?Tuple {
                if (self.list.len == 0) return null;
                if (self._1 == self.list.len) return null;
                var a = Tuple{._1 = self.list[self._1], ._2 = self.list[self._2]};
                self._2 = self._2 + 1;
                if (self._2 == self.list.len) {
                    self._2 = 0;
                    self._1 = self._1 + 1;
                }
                return a;
            }
        };

        pub fn iterator(self: *Self) Iterator {
            return Iterator{
                .list = self.list,
                ._1 = 0,
                ._2 = 0,
            };
        }
    };
}

fn square(list: var) squareT(@typeOf(list).Child).Iterator {
    return squareT(@typeOf(list).Child).init(list).iterator();
}

fn compare(comptime T: type, iter: *squareT(T).Iterator, expected: []const squareT(T).Tuple) void {
    var i: usize = 0;
    while (i < expected.len) {
        var item = iter.next().?;
        testing.expect(expected[i]._1 == item._1);
        testing.expect(expected[i]._2 == item._2);
        i = i + 1;
    }
    testing.expect(iter.next() == null);
}

test "square.iterator" {
    const lst = []i32{1,2,3};
    const TT = squareT(i32).Tuple;
    
    var iter = square(lst[0..1]);
    var expected: []const TT = []TT{
        TT{._1 = 1, ._2 = 1},
    };
    compare(i32, &iter, expected[0..]);

    iter = square(lst[0..]);
    expected = []TT{
        TT{._1 = 1, ._2 = 1}, TT{._1 = 1, ._2 = 2}, TT{._1 = 1, ._2 = 3}, 
        TT{._1 = 2, ._2 = 1}, TT{._1 = 2, ._2 = 2}, TT{._1 = 2, ._2 = 3}, 
        TT{._1 = 3, ._2 = 1}, TT{._1 = 3, ._2 = 2}, TT{._1 = 3, ._2 = 3}, 
    };
    compare(i32, &iter, expected[0..]);
}

test "square.null" {
    var iter = square([]i32{});

    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}