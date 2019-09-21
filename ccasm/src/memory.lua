assert(os.loadAPI("/ccasm/src/operandTypes.lua"));

bytes = {};

function clear()
    local addressSize = operandTypes.symbolicAddress.sizeInBytes;
    local numBytes = math.pow(math.pow(2, 8), addressSize);

    for i = 1, numBytes do
        bytes[i - 1] = 0;
    end
end

function load(startAddress, data)
    for i, byte in ipairs(data) do
        bytes[startAddress + i - 1] = byte;
    end
end

clear();
