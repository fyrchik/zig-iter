const std = @import("std");
const debug = std.debug;
const assert = std.debug.assert;
const testing = std.testing;

fn interleaveT(comptime T: type) type {
    return struct {
        const Self = @This();

        list1: []const T,
        list2: []const T,

        const Iterator = struct {
            list1: []const T,
            list2: []const T,
            _1: usize,
            _2: usize,
            fromFirst: bool,

            fn next(self: *Iterator) ?T {
                if (self.fromFirst) {
                    if (self._1 < self.list1.len) {
                        self.fromFirst = false;
                        const a = self.list1[self._1];
                        self._1 = self._1 + 1;
                        return a;
                    }
                    if (self.list2.len == self._2) return null;

                    const a = self.list2[self._2];
                    self._2 = self._2 + 1;
                    return a;
                } else if (self._2 < self.list2.len) {
                    self.fromFirst = true;
                    const a = self.list2[self._2];
                    self._2 = self._2 + 1;
                    return a;
                } else {
                    self.fromFirst = true;
                    if (self.list1.len == self._1) return null;
                    const a = self.list1[self._1];
                    self._1 = self._1 + 1;
                    return a;
                }
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
                .fromFirst = true,
            };
        }
    };
}

fn interleave(list1: var, list2: var) interleaveT(@typeOf(list1).Child).Iterator {
    const T = @typeOf(list1).Child;
    return interleaveT(T).init(list1, list2).iterator();
}

test "interleave.equal_len" {
    var list1 = ([]i32{1,3,5})[0..];
    var list2 = ([]i32{2,4,6})[0..];
    var iter = interleave(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next().? == 5);
    testing.expect(iter.next().? == 6);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "interleave.first_shorter" {
    var list1 = ([]i32{1,3})[0..];
    var list2 = ([]i32{2,4,5})[0..];
    var iter = interleave(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next().? == 5);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "interleave.first_longer" {
    var list1 = ([]i32{1,3,5})[0..];
    var list2 = ([]i32{2,4})[0..];
    var iter = interleave(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next().? == 3);
    testing.expect(iter.next().? == 4);
    testing.expect(iter.next().? == 5);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "interleave.first_empty" {
    var list1 = ([]i32{})[0..];
    var list2 = ([]i32{1,2})[0..];
    var iter = interleave(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next().? == 2);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}

test "interleave.second_empty" {
    var list1 = ([]i32{1})[0..];
    var list2 = ([]i32{})[0..];
    var iter = interleave(list1, list2);
    testing.expect(iter.next().? == 1);
    testing.expect(iter.next() == null);
    testing.expect(iter.next() == null);
}