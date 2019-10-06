local function assertValueIsInRangeInclusive(int, interval)
    local lowerBound, upperBound = unpack(interval);
    local message = "Expected " .. tostring(int) .. " to be in range [" .. lowerBound .. ", " .. upperBound .. "].";
    local isInBounds = int >= lowerBound and int <= upperBound;
    assert(isInBounds, message);
end

function isInteger(value)
    return type(value) == "number" and math.floor(value) == value;
end

function assertValueIsInteger(value)
    local errorMessage = "Illegal non-integer value: " .. tostring(value);
    assert(isInteger(value), errorMessage);
end

function assertValueIsByte(value)
    assertValueIsInteger(value);
    assertValueIsInRangeInclusive(value, { 0, 255 });
end

function getSizeInBytesForInteger(int)
    assertValueIsInteger(int);
    local power = 8;

    while math.pow(2, power) - 1 < int do
        power = power + 8;
    end

    return power / 8;
end

function getBytesForInteger(sizeInBytes, int)
    -- Make-shift overload, so we  don't have to change the
    -- way this is already being called.
    if int == nil then
        int = sizeInBytes;
        sizeInBytes = getSizeInBytesForInteger(int);
    end

    local bytes = {};

    -- Capture bytes in little-endian order.
    for i = 1, sizeInBytes do
        bytes[i] = bit.band(int, 0xFF);
        int = bit.blogic_rshift(int, 8);
    end

    local reversedBytes = {};
    for i = sizeInBytes, 1, -1 do
        table.insert(reversedBytes, bytes[i]);
    end

    return reversedBytes;
end

local function intToBin(int)
    local binary = "";
    while int > 0 do
        local r = int % 2;
        int = int / 2;
        binary = r .. binary;
    end
    return binary;
end

-- TODO: Limits on integer size? Byte table can arbitrarily long.
function getIntegerFromBytes(bytes)
    assert(type(bytes) == "table", "Expected byte table, got " .. tostring(bytes) .. ".");
    assert(#bytes <= 4, "Expected byte table to be at most 4 bytes long, was " .. tostring(#bytes) .. ".");
    local val = 0;
    local i, bitShift = #bytes, 0;
    while i >= 1 do
        local byte = bytes[i];
        assertValueIsByte(byte);
        byte = bit.blshift(bytes[i], bitShift);
        val = bit.bor(val, byte);
        bitShift = bitShift + 8;
        i = i - 1;
    end
    return val;
end