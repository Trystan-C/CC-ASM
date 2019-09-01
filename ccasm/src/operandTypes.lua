os.loadAPI("/ccasm/src/utils/integer.lua");
os.loadAPI("/ccasm/src/cpu.lua");

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
    };
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
    integer.assertValueIsInteger(parsedValue);

    return parsedValue;
end

immediateData.getSizeInBytes = function(token)
    return integer.getSizeInBytesForInteger(immediateData.parseValueAsInt(token));
end

immediateData.parseValueAsBytes = function(token)
    local size = immediateData.getSizeInBytes(token);
    local value = immediateData.parseValueAsInt(token);

    return integer.getBytesForInteger(size, value);
end

symbolicAddress = {
    typeByte = 3;
    pattern = "(%a[%w_]+)";
    sizeInBytes = 4;
};

symbolicAddress.parseValueAsBytes = function(token)
    local bytes = {};

    for i = 1, symbolicAddress.sizeInBytes do
        table.insert(bytes, 0);
    end

    return bytes;
end

local function throwUnrecognizedOperandTypeError(token)
    local message = "Unrecognized operand type for token: " .. tostring(token);
    error(message);
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
    elseif tokenTypeIs(symbolicAddress) then
        return "symbolicAddress";
    end

    throwUnrecognizedOperandTypeError(token);
end