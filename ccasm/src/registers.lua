assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/bitUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local function assertByteTableSizeIs(byteTable, size)
    local condition = #byteTable == size;
    local message = "Expected byte table to have size " .. tostring(size) .. " but was " .. tostring(#byteTable) .. ".";
    assert(condition, message);
end

local function setRegisterByte(register)
    return function(byte)
        assertByteTableSizeIs(byte, 1);
        register.value[4] = byte[1];
    end
end

local function setRegisterWord(register)
    return function(word)
        assertByteTableSizeIs(word, 2);
        register.value[3] = word[1];
        register.value[4] = word[2];
    end
end

local function setRegisterLong(register)
    return function(longWord)
        assertByteTableSizeIs(longWord, 4);
        register.value[4] = longWord[4];
        register.value[3] = longWord[3];
        register.value[2] = longWord[2];
        register.value[1] = longWord[1];
    end
end

local function getRegisterByte(register)
    return function()
        return { register.value[4] };
    end
end

local function getRegisterWord(register)
    return function()
        return { register.value[3], register.value[4] };
    end
end

local function getRegisterLong(register)
    return function()
        return { register.value[1], register.value[2], register.value[3], register.value[4] };
    end
end

local registerMetatable = {
    __index = function(register, key)
        if key == "setByte" then
            return setRegisterByte(register);
        elseif key == "getByte" then
            return getRegisterByte(register);
        elseif key == "setWord" then
            return setRegisterWord(register);
        elseif key == "getWord" then
            return getRegisterWord(register);
        elseif key == "setLong" then
            return setRegisterLong(register);
        elseif key == "getLong" then
            return getRegisterLong(register);
        else
            return register[key];
        end
    end,
};

function clear()
    for i = 0, 7 do
        dataRegisters[i].setLong(tableUtils.zeros(registerWidthInBytes));
        addressRegisters[i].setLong(tableUtils.zeros(registerWidthInBytes));
    end
    statusRegister = 0;
end

statusRegister = 0;
STATUS_COMPARISON = 0;
STATUS_NEGATIVE = 1;
function compare(a, b)
    local diff = a - b;
    if diff == 0 then
        bitUtils.setOnAt(statusRegister, STATUS_COMPARISON);
    else
        bitUtils.setOffAt(statusRegister, STATUS_COMPARISON);
    end
    if diff < 0 then
        bitUtils.setOnAt(statusRegister, STATUS_NEGATIVE);
    else
        bitUtils.setOffAt(statusRegister, STATUS_NEGATIVE);
    end
end

registerWidthInBytes = 4;
dataRegisters = {};
addressRegisters = {};
for i = 0, 7 do
    dataRegisters[i] = {
        id = i;
        value = tableUtils.zeros(registerWidthInBytes);
    };
    addressRegisters[i] = {
        id = i;
        value = tableUtils.zeros(registerWidthInBytes);
    };
    setmetatable(dataRegisters[i], registerMetatable);
    setmetatable(addressRegisters[i], registerMetatable);
end
