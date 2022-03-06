const BaudRate = enum(u32) {
    Low = 38400,
    Medium = 57600,
    High = 115200,
};

pub fn Uart(base_address: usize) type {
    return struct {
        const address = base_address;

        const data_reg = @intToPtr(*volatile u8, base_address + 0);
        const div_low = @intToPtr(*volatile u8, base_address + 0);
        const div_high = @intToPtr(*volatile u8, base_address + 1);
        const int = @intToPtr(*volatile u8, base_address + 2);
        const line_control = @intToPtr(*volatile u8, base_address + 3);
        const modem_control = @intToPtr(*volatile u8, base_address + 4);
        const line_status = @intToPtr(*volatile u8, base_address + 5);
        const modem_status = @intToPtr(*volatile u8, base_address + 6);
        const scratch = @intToPtr(*volatile u8, base_address + 7);

        pub fn init(baud: BaudRate) void {
            var divisor = @intCast(u16, 115_200 / @enumToInt(baud));
            div_high.* = 0;
            line_control.* = 0x80;
            div_low.* = @intCast(u8, divisor & 0xff);
            div_high.* = @intCast(u8, (divisor >> 8));
            //line_status.* &= ~(@as(u8, 0x80));

            line_control.* = 0x03;

            int.* = 0x07;

            div_high.* = 0x01;
        }

        pub fn write_char(char: u8) void {
            while(line_status.* & (1 << 5) == 0) {}
            asm volatile ("nop" ::: "memory");
            data_reg.* = char;
        }

        pub fn write(str: []const u8) void {
            for (str) |c| {
                @This().write_char(c);
            }
        }
    };
}
