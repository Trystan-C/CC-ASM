assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");

--VALIDATE INPUT-------------------------------------------------------------
local args = { ... };
if #args < 1 or #args > 2 then
    print("load <file.cco> <origin?>");
    return;
end

local outFilePath = shell.resolve(args[1]);
if not outFilePath:match("%.cco$") then
    print("Input file (" .. outFilePath .. ") missing .cco extension.");
    return;
end

local origin = tonumber(args[2]);
if #args == 2 and (origin == nil or origin < 0 or origin >= #memory.bytes or not integer.isInteger(origin)) then
    print("Origin must be an integer between 0 and " .. tostring(#memory.bytes) .. ".");
    return;
end

--LOAD PROGRAM------------------------------------------------------------------
local outFile = fs.open(outFilePath, "rb");
local byteCodeOrigin = { outFile.read(), outFile.read() };
if byteCodeOrigin[1] == nil or byteCodeOrigin[2] == nil then
    print("Input file size is too small (< 2 bytes).");
    outFile.close();
    return;
end

local byteCode = {};
local nextByte;
repeat
    nextByte = outFile.read();
    table.insert(byteCode, nextByte);
until nextByte == nil;
outFile.close();

local shouldOverrideOrigin = origin ~= nil;
if not shouldOverrideOrigin then
    origin = integer.getIntegerFromBytes(byteCodeOrigin);
end

memory.load(origin, byteCode);
print(string.format("%d bytes loaded at 0x%X.", #byteCode, origin));