assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

local args = { ... };
if #args ~= 2 then
    print("run <start_address> <steps>");
    return;
end

local startAddress = tonumber(args[1]);
if startAddress == nil or not integer.isInteger(startAddress) or startAddress < 0 or startAddress >= #memory.bytes then
    print("Start address must be an integer between 0 and " .. tostring(#memory.bytes) .. ".");
    return;
end

local steps = tonumber(args[2]);
if steps == nil or not integer.isInteger(steps) or steps < 0 then
    print("Steps must be an integer greater than 0.");
    return;
end

registers.setProgramCounter(startAddress);
local success, errorMessage = pcall(function()
    for i = 1, steps do
        cpu.step();
    end
end);
if not success then
    print("[RUNTIME ERROR]> " .. errorMessage);
end