assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/bitUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

--DATA REGISTER--------------------------------------------
dataRegister = {
    typeByte = 0,
    sizeInBytes = 1,
    match = function(token)
        return token:match("^[dD](%d)$");
    end,
};

dataRegister.parseValueAsBytes = function(token)
    local registerId = dataRegister.match(token);

    if registerId == nil then
        local errorMessage = token .. " is not a data register.";
        error(errorMessage);
    end

    return { tonumber(registerId) };
end

--ADDRESS REGISTER-----------------------------------------
addressRegister = {
    typeByte = 1,
    sizeInBytes = 1,
    match = function(token)
        return token:match("^[aA](%d)$");
    end,
};

addressRegister.parseValueAsBytes = function(token)
    local registerId = addressRegister.match(token);

    if registerId == nil then
        local errorMessage = token .. " is not an address register.";
        error(errorMessage);
    end

    return { tonumber(registerId) };
end

--IMMEDIATE DATA-------------------------------------------
immediateData = {
    typeByte = 2,
    match = function(token)
        return token:match("^#([hb]?)(%w+%.?%w*)$");
    end,
    formats = {
        hex = "h",
        binary = "b"
    },
};

immediateData.parseValueAsInt = function(token)
    local format, rawValue = immediateData.match(token);
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

--SYMBOLIC ADDRESS-----------------------------------------
symbolicAddress = {
    typeByte = 3,
    match = function(token)
        return token:match("^(%a[%w_]-):?$");
    end,
    sizeInBytes = 2,
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

--REGISTER RANGE-------------------------------------------
registerRange = {
    typeByte = 4;
    patterns = {
        "^([dD][0-7]%-[0-7])/([aA][0-7]%-[0-7])$",
        "^([dD][0-7]%-[0-7])/([aA][0-7])$",
        "^([dD][0-7]%-[0-7])$",
        "^([dD][0-7])$",
        "^([aA][0-7]%-[0-7])$",
        "^([aA][0-7])$",
    };
    sizeInBytes = 2;
};

registerRange.match = function(token)
    local result = {};
    for _, pattern in ipairs(registerRange.patterns) do
        result = { token:match(pattern) };
        if #result > 0 then
            break;
        end
    end
    return unpack(result);
end

registerRange.byteFromMatch = function(range)
    local interval = { range:match("([0-7])%-([0-7])") };
    if #interval == 0 then
        interval = { range:match("([0-7])") };
    end
    for i, n in ipairs(interval) do
        interval[i] = tonumber(n);
    end

    local byte = 0;
    if #interval > 1 then
        assert(interval[1] <= interval[2], "Register range (" .. range .. ") must be increasing.");
    end
    for i = interval[1], interval[2] or interval[1] do
        byte = bitUtils.setOnAt(byte, i);
    end

    return byte;
end

registerRange.registerIdsFromByte = function(byte)
    local ids = {};
    for i = 0, 7 do
        if bitUtils.getAt(byte, i) == 1 then
            table.insert(ids, i);
        end
    end
    return ids;
end

registerRange.parseValueAsBytes = function(token)
    local ranges = { registerRange.match(token) };
    local bytes = { 0, 0 };
    for _, range in ipairs(ranges) do
        if range:match("^([dD])") then
            bytes[1] = registerRange.byteFromMatch(range);
        elseif range:match("^([aA])") then
            bytes[2] = registerRange.byteFromMatch(range);
        else
            error("registerRange.parseValueAsBytes: " .. range .. " is not a data or address register range.");
        end
    end
    return bytes;
end

--OPERAND TYPE LOOKUP--------------------------------------
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
        return #{ definition.match(token) } > 0;
    end

    if tokenTypeIs(dataRegister) then
        return "dataRegister";
    elseif tokenTypeIs(addressRegister) then
        return "addressRegister";
    elseif tokenTypeIs(immediateData) then
        return "immediateData";
    elseif tokenTypeIs(symbolicAddress) then
        return "symbolicAddress";
    elseif tokenTypeIs(registerRange) then
        return "registerRange";
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