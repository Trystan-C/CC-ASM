assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");

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

    return { tonumber(registerId) };
end

addressRegister = {
    typeByte = 1,
    sizeInBytes = 1,
    pattern = "^[aA](%d)$"
};

addressRegister.parseValueAsBytes = function(token)
    local registerId = token:match(addressRegister.pattern)

    if registerId == nil then
        local errorMessage = token .. " is not an address register.";
        error(errorMessage);
    end

    return { tonumber(registerId) };
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
    sizeInBytes = 2;
};

-- Returns a zero array for use as a place-holder.
-- References to this address will be filled after the
-- entire source has been passed over.
symbolicAddress.parseValueAsBytes = function(token)
    local bytes = {};

    for _ = 1, symbolicAddress.sizeInBytes do
        table.insert(bytes, 0);
    end

    return bytes;
end

local function throwUnrecognizedOperandTypeError(token)
    local message = "Unrecognized operand type for token: " .. tostring(token);
    error(message);
end

local function throwUnrecognizedOperandTypeByteError(typeByte)
    local message = "Unrecognized operand type for byte: " .. tostring(token);
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

local typeToDefinitionMap = {};
for name, definition in pairs(getfenv()) do
    if type(definition) == "table" and type(definition.typeByte) == "number" then
        typeToDefinitionMap[definition.typeByte] = definition;
    end
end

function getDefinition(typeByte)
    if typeToDefinitionMap[typeByte] == nil then
        throwUnrecognizedOperandTypeByteError(typeByte);
    end

    return typeToDefinitionMap[typeByte];
end