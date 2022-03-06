const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const target = std.zig.CrossTarget{
        .cpu_arch = .riscv64,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.baseline_rv64 },
        .os_tag = .freestanding,
        .abi = .none,
    };

    const kernel = b.addExecutable("kernel", "src/main.zig");
    kernel.addAssemblyFile("src/asm/start.s");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.setLinkerScriptPath(.{ .path = "linker.ld" });
    kernel.code_model = .medium;
    kernel.install();
    //obj.code_model = std.builtin.CodeModel.

    // const run_cmd = obj.run();
    // run_cmd.step.dependOn(b.getInstallStep());
    // if (b.args) |args| {
    //     run_cmd.addArgs(args);
    // }
    // const run_step = b.step("run", "Run the app");
    // run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);

    const qemu_command = [_][]const u8{
        "qemu-system-riscv64",
        "-machine",
        "virt",
        "-nographic",
        "-bios",
        "default",
        //"-smp",
        //"4", // CPUS
        "-kernel",
        "zig-out/bin/kernel",
        "-m",
        "128M",
        "-k",
        "fr",
        //"-serial",
        //"stdio",
        "-boot",
        "c",
        "-cpu",
        "rv64",
    };

    const qemu = b.addSystemCommand(&qemu_command);
    qemu.step.dependOn(b.default_step);
    const run_step = b.step("run", "Run the kernel with QEMU");
    run_step.dependOn(&qemu.step);
}
