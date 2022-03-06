const std = @import("std");
const drivers = @import("drivers/drivers.zig");
const rv64 = @import("riscv/rv64.zig");
const Config = @import("config.zig");

const uart = drivers.Debug_UART.Uart(rv64.MemoryLayout.UART0);

export fn kernel_entry() callconv(.Naked) void {
    
    uart.init(.Medium);
    uart.write("Hello, world!");
    while(true) {}
    while(true) {
        var a: u64 = 0;
        while (a < 1_000_000) {
            a += 1;
            asm volatile ("nop" ::: "memory");
        }
        uart.write_char('a');
        
        
    }
}

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
