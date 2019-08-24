assert(os.loadAPI("/ccasm/src/cpu.lua"));

local function assertValueIsInteger(value)
    local isInt = type(value) == "number" and math.floor(value) == value;
    local errorMessage = "Illegal non-integer value: " .. tostring(value);
    assert(isInt, errorMessage);
end

local function getSizeInBytesForInteger(int)
    assertValueIsInteger(int);
    local power = 8;

    while math.pow(2, power) - 1 < int do
        power = power + 8;
    end

    return power / 8;
end

-- NOTE: Big-endian order, e.g., 0x54 -> [1] = 00000101, [2] = 00000100
local function getBytesForInteger(sizeInBytes, int)
    local bytes = {};

    -- Capture bytes in little-endian order.
    for i = 1, sizeInBytes do
        bytes[i] = bit.band(int, 0xFF);
        bit.blogic_rshift(int, 8);
    end

    -- Reverse the order of the capture bytes.
    for i = 1, sizeInBytes do
        local tmp = bytes[i];
        bytes[i] = bytes[sizeInBytes-i+1];
        bytes[sizeInBytes-i+1] = tmp;
    end

    return bytes;
end

invalidType = {};

dataRegister = {
    typeByte = 0,
    sizeInBytes = 1,
    pattern = "[dD](%d)"
};

dataRegister.parseValueAsBytes = function(token)
    local registerId = token:match(dataRegister.pattern);

    if registerId == nil then
        local errorMessage = token .. " is not a data register.";
        error(errorMessage);
    end

    return { cpu.dataRegisters[tonumber(registerId)].id };
end

addressRegister = {
    typeByte = 1,
    sizeInBytes = 1,
    pattern = "[aA](%d)"
};

addressRegister.parseValueAsBytes = function(token)
    local registerId = token:match(addressRegister.pattern)

    if registerId == nil then
        local errorMessage = token .. " is not an address register.";
        error(errorMessage);
    end

    return { cpu.addressRegisters[tonumber(registerId)].id };
end

immediateData = {
    typeByte = 2,
    pattern = "#([hb]?)(%w+%.?%w*)",
    formats = {
        hex = "h",
        binary = "b"
    }
};

immediateData.parseValueAsInt = function(token)
    local format, rawValue = token:match(immediateData.pattern);
    local base = 10;

    if format == immediateData.formats.binary then
        base = 2;
    elseif format == immediateData.formats.hex then
        base = 16;
    end

    local parsedValue = tonumber(rawValue, base);
    assertValueIsInteger(parsedValue);

    return parsedValue;
end

immediateData.getSizeInBytes = function(token)
    return getSizeInBytesForInteger(immediateData.parseValueAsInt(token));
end

immediateData.parseValueAsBytes = function(token)
    local size = immediateData.getSizeInBytes(token);
    local value = immediateData.parseValueAsInt(token);

    return getBytesForInteger(size, value);
end

function getType(token)
    local function tokenTypeIs(definition)
        return #{ token:match(definition.pattern) } > 0;
    end

    if tokenTypeIs(dataRegister) then
        return "dataRegister";
    elseif tokenTypeIs(addressRegister) then
        return "addressRegister";
    elseif tokenTypeIs(immediateData) then
        return "immediateData";
    end
end