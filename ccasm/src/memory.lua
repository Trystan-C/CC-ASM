assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");

local addressSize = operandTypes.symbolicAddress.sizeInBytes;
local totalMemoryInBytes = math.pow(math.pow(2, 8), addressSize);
bytes = {};

function isAddressValid(address)
    return integer.isInteger(address) and address >= 0 and address < totalMemoryInBytes;
end

function readBytes(startAddress, numBytes)
    local result = {};
    for offset = 1, numBytes do
        table.insert(result, bytes[startAddress + offset - 1]);
    end
    return result;
end

function clear()
    for i = 1, totalMemoryInBytes do
        bytes[i - 1] = 0;
    end
end

function load(startAddress, data)
    for i, byte in ipairs(data) do
        bytes[startAddress + i - 1] = byte;
    end
end

clear();
