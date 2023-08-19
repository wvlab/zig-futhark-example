const std = @import("std");
const c = @cImport({
    @cInclude("wow.h");
});

pub fn main() !void {
    const meh: [4]i32 = .{ 4, 5, 7, 9 };
    var fres: i32 = undefined;

    const fcfg = c.futhark_context_config_new();
    const fctx = c.futhark_context_new(fcfg);
    defer _ = c.futhark_context_config_free(fcfg);
    defer _ = c.futhark_context_free(fctx);

    const farr = c.futhark_new_i32_1d(fctx, &meh, meh.len);
    defer _ = c.futhark_free_i32_1d(fctx, farr);

    _ = c.futhark_entry_fact_sum(fctx, &fres, farr);
    _ = c.futhark_context_sync(fctx);

    std.debug.print("{}\n", .{fres});
}
