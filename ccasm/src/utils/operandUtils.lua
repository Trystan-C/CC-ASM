assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local function registerId(operand)
    return operand.valueBytes[1];
end

function absoluteAddress(operand)
    assert(
        operand.definition == operandTypes.symbolicAddress or
        operand.definition == operandTypes.absoluteSymbolicAddress or
        operand.definition == operandTypes.absoluteAddress or
        operand.definition == operandTypes.immediateData,
        "absoluteAddress: Expected absolute or symbolic address or immediate data operand."
    );
    if operand.definition == operandTypes.symbolicAddress or operand.definition == operandTypes.absoluteSymbolicAddress then
        local offset = integer.getSignedIntegerFromBytes(operand.valueBytes);
        local symbolStartAddress = operand.valueStartAddress + offset;
        return symbolStartAddress;
    elseif operand.definition == operandTypes.absoluteAddress then
        return integer.getIntegerFromBytes(operand.valueBytes);
    elseif operand.definition == operandTypes.immediateData then
        return integer.getIntegerFromBytes(word(operand).get());
    end
end

local function byteGetter(operand)
    local getter;
    if operand.definition == operandTypes.dataRegister then
        getter = registers.dataRegisters[registerId(operand)].getByte;
    elseif operand.definition == operandTypes.addressRegister then
        getter = registers.addressRegisters[registerId(operand)].getByte;
    elseif operand.definition == operandTypes.immediateData then
        getter = function() return operand.valueBytes end
    elseif operand.definition == operandTypes.symbolicAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 1) end
    elseif operand.definition == operandTypes.absoluteSymbolicAddress then
        getter = function() return tableUtils.fitToSize(integer.getBytesForInteger(absoluteAddress(operand)), 1) end
    elseif operand.definition == operandTypes.absoluteAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 1) end
    end
    return getter;
end

local function wordGetter(operand)
    local getter;
    if operand.definition == operandTypes.dataRegister then
        getter = registers.dataRegisters[registerId(operand)].getWord;
    elseif operand.definition == operandTypes.addressRegister then
        getter = registers.addressRegisters[registerId(operand)].getWord;
    elseif operand.definition == operandTypes.immediateData then
        getter = function() return tableUtils.zeroPadFrontToSize(operand.valueBytes, 2) end
    elseif operand.definition == operandTypes.symbolicAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 2) end
    elseif operand.definition == operandTypes.absoluteSymbolicAddress then
        getter = function() return tableUtils.fitToSize(integer.getBytesForInteger(absoluteAddress(operand)), 2) end
    elseif operand.definition == operandTypes.absoluteAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 2) end
    end
    return getter;
end

local function longGetter(operand)
    local getter;
    if operand.definition == operandTypes.dataRegister then
        getter = registers.dataRegisters[registerId(operand)].getLong;
    elseif operand.definition == operandTypes.addressRegister then
        getter = registers.addressRegisters[registerId(operand)].getLong;
    elseif operand.definition == operandTypes.immediateData then
        getter = function() return tableUtils.zeroPadFrontToSize(operand.valueBytes, 4) end
    elseif operand.definition == operandTypes.symbolicAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 4) end
    elseif operand.definition == operandTypes.absoluteSymbolicAddress then
        getter = function() return tableUtils.fitToSize(integer.getBytesForInteger(absoluteAddress(operand)), 4) end
    elseif operand.definition == operandTypes.absoluteAddress then
        getter = function() return memory.readBytes(absoluteAddress(operand), 4) end
    end
    return getter;
end

local function byteSetter(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setByte;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setByte;
    elseif operand.definition == operandTypes.symbolicAddress or operand.definition == operandTypes.absoluteAddress then
        setter = function(byte) memory.writeBytes(absoluteAddress(operand), tableUtils.fitToSize(byte, 1)) end
    end
    return setter;
end

local function wordSetter(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setWord;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setWord;
    elseif operand.definition == operandTypes.symbolicAddress or operand.definition == operandTypes.absoluteAddress then
        setter = function(word) memory.writeBytes(absoluteAddress(operand), tableUtils.trimToSize(word, 2)) end
    end
    return setter;
end

local function longSetter(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setLong;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setLong;
    elseif operand.definition == operandTypes.symbolicAddress or operand.definition == operandTypes.absoluteAddress then
        setter = function(long) memory.writeBytes(absoluteAddress(operand), tableUtils.trimToSize(long, 4)) end
    end
    return setter;
end

function byte(operand)
    return {
        get = byteGetter(operand);
        set = byteSetter(operand);
    };
end

function word(operand)
    return {
        get = wordGetter(operand);
        set = wordSetter(operand);
    };
end

function long(operand)
    return {
        get = longGetter(operand);
        set = longSetter(operand);
    };
end