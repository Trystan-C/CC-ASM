assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

local args = { ... };
if #args ~= 1 then
    print("run <start_address>");
    return;
end

local startAddress = tonumber(args[1]);
if startAddress == nil or not ccasm.integer.isInteger(startAddress) or startAddress < 0 or startAddress >= #ccasm.memory.bytes then
    print("Start address must be an integer between 0 and " .. tostring(#ccasm.memory.bytes) .. ".");
    return;
end

local function writeKeyValueToMemory(key)
    local bytes = ccasm.integer.getBytesForInteger(1, key);
    ccasm.memory.writeBytes(0x0200, bytes);
end

ccasm.registers.setProgramCounter(startAddress);
local function tick()
    local loopEventType = "CCASM_LOOP";
    os.queueEvent(loopEventType);
    local eventArgs = { os.pullEvent() };
    if eventArgs[1] == "key_up" then
        writeKeyValueToMemory(string.byte(' '));
    elseif eventArgs[1] == "key" then
        writeKeyValueToMemory(keys.getName(eventArgs[2]):byte());
    elseif eventArgs[1] == loopEventType then
        ccasm.cpu.step();
    end
end

while true do
    local success, errorMessage = pcall(tick);
    if not success then
        print("[RUNTIME ERROR]> " .. errorMessage);
        break;
    end
end