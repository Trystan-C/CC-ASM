function assertValueIsInteger(value)
    local isInt = type(value) == "number" and math.floor(value) == value;
    local errorMessage = "Illegal non-integer value: " .. tostring(value);
    assert(isInt, errorMessage);
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