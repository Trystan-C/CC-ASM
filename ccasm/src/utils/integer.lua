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
    if int < 0 then
        return 4;
    end

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

local function assertIsValidByteTable(name, bytes)
    assert(type(bytes) == "table", name .. ": Expected byte table, got " .. tostring(bytes) .. ".");
    assert(#bytes <= 4, name .. ": Expected byte table to be at most 4 bytes long, was " .. tostring(#bytes) .. ".");
end

-- TODO: Limits on integer size? Byte table can arbitrarily long.
function getIntegerFromBytes(bytes)
    assertIsValidByteTable("ccasm.integer.getIntegerFromBytes", bytes);
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

function getSignedIntegerFromBytes(bytes)
    assertIsValidByteTable("ccasm.integer.getSignedIntegerFromBytes", bytes);
    local val = getIntegerFromBytes(bytes);
    if val > 0 and bit.band(bytes[1], 0x80) ~= 0 then
        val = val - math.pow(2, 8*#bytes);
    end
    return val;
end

function addBytes(byteTable1, byteTable2)
    return getBytesForInteger(
        getSignedIntegerFromBytes(byteTable1) + getSignedIntegerFromBytes(byteTable2)
    );
end

function subtractBytes(byteTable1, byteTable2)
    return getBytesForInteger(
        getSignedIntegerFromBytes(byteTable1) - getSignedIntegerFromBytes(byteTable2)
    );
end

function multiplyBytes(byteTable1, byteTable2)
    return getBytesForInteger(
        getSignedIntegerFromBytes(byteTable1) * getSignedIntegerFromBytes(byteTable2)
    );
end

function divideBytes(byteTable1, byteTable2)
    local numerator = getSignedIntegerFromBytes(byteTable2);
    local denominator = getSignedIntegerFromBytes(byteTable1);
    if denominator == 0 then
        error("divideBytes: Illegal division by zero.");
    end
    return getBytesForInteger(math.floor(numerator / denominator));
end

function leftShiftBytes(byteTable, shiftCount)
    assertIsValidByteTable("ccasm.integer.leftShiftBytes", byteTable);
    assert(shiftCount >= 0, "ccasm.integer.leftShiftBytes: Expected shift value to be >= 0.");
    local result = { 0, 0, 0, 0 };
    for i = shiftCount + 1, #byteTable do
        result[i - shiftCount] = byteTable[i];
    end
    return result;
end

function rightShiftBytes(byteTable, shiftCount)
    assertIsValidByteTable("ccasm.integer.rightShiftBytes", byteTable);
    assert(shiftCount >= 0, "ccasm.integer.rightShiftBytes: Expected shift value to be >= 0.");
    local result = { 0, 0, 0, 0 };
    for i = 1, #byteTable - shiftCount do
        result[i + shiftCount] = byteTable[i];
    end
    return result;
end

function orBytes(byteTable1, byteTable2)
    assertIsValidByteTable("ccasm.integer.orBytes", byteTable1);
    assertIsValidByteTable("ccasm.integer.orBytes", byteTable2);
    local result = {};
    for i = 1, math.max(#byteTable1, #byteTable2) do
        result[i] = bit.bor(byteTable1[i] or 0, byteTable2[i] or 0);
    end
    return result;
end

function andBytes(byteTable1, byteTable2)
    assertIsValidByteTable("ccasm.integer.andBytes", byteTable1);
    assertIsValidByteTable("ccasm.integer.andBytes", byteTable2);
    local result = {};
    for i = 1, math.max(#byteTable1, #byteTable2) do
        result[i] = bit.band(byteTable1[i] or 0, byteTable2[i] or 0);
    end
    return result;
end

function xorBytes(byteTable1, byteTable2)
    assertIsValidByteTable("ccasm.integer.xorBytes", byteTable1);
    assertIsValidByteTable("ccasm.integer.xorBytes", byteTable2);
    local result = {};
    for i = 1, math.max(#byteTable1, #byteTable2) do
        result[i] = bit.bxor(byteTable1[i] or 0, byteTable2[i] or 0);
    end
    return result;
end

function notBytes(byteTable)
    assertIsValidByteTable("ccasm.integer.notBytes", byteTable);
    local result = {};
    for i = 1, #byteTable do
        result[i] = bit.band(0xFF, bit.bnot(byteTable[i]));
    end
    return result;
end