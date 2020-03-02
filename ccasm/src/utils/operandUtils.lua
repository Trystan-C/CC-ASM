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
        operand.definition == ccasm.operandTypes.symbolicAddress or
        operand.definition == ccasm.operandTypes.absoluteSymbolicAddress or
        operand.definition == ccasm.operandTypes.absoluteAddress or
        operand.definition == ccasm.operandTypes.indirectAddress or
        operand.definition == ccasm.operandTypes.immediateData,
        "absoluteAddress: Expected absolute or symbolic address or immediate data operand."
    );
    if operand.definition == ccasm.operandTypes.symbolicAddress or operand.definition == ccasm.operandTypes.absoluteSymbolicAddress then
        local offset = ccasm.integer.getSignedIntegerFromBytes(operand.valueBytes);
        local symbolStartAddress = operand.valueStartAddress + offset;
        return symbolStartAddress;
    elseif operand.definition == ccasm.operandTypes.absoluteAddress then
        return ccasm.integer.getIntegerFromBytes(operand.valueBytes);
    elseif operand.definition == ccasm.operandTypes.indirectAddress then
        return ccasm.integer.getIntegerFromBytes(ccasm.registers.addressRegisters[registerId(operand)].getWord());
    elseif operand.definition == ccasm.operandTypes.immediateData then
        return ccasm.integer.getIntegerFromBytes(word(operand).get());
    end
end

local function byteGetter(operand)
    local getter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        getter = ccasm.registers.dataRegisters[registerId(operand)].getByte;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        getter = ccasm.registers.addressRegisters[registerId(operand)].getByte;
    elseif operand.definition == ccasm.operandTypes.immediateData then
        getter = function() return operand.valueBytes end
    elseif operand.definition == ccasm.operandTypes.symbolicAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 1) end
    elseif operand.definition == ccasm.operandTypes.absoluteSymbolicAddress then
        getter = function() return ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(absoluteAddress(operand)), 1) end
    elseif operand.definition == ccasm.operandTypes.absoluteAddress or operand.definition == ccasm.operandTypes.indirectAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 1) end
    end
    return getter;
end

local function wordGetter(operand)
    local getter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        getter = ccasm.registers.dataRegisters[registerId(operand)].getWord;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        getter = ccasm.registers.addressRegisters[registerId(operand)].getWord;
    elseif operand.definition == ccasm.operandTypes.immediateData then
        getter = function() return ccasm.tableUtils.zeroPadFrontToSize(operand.valueBytes, 2) end
    elseif operand.definition == ccasm.operandTypes.symbolicAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 2) end
    elseif operand.definition == ccasm.operandTypes.absoluteSymbolicAddress then
        getter = function() return ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(absoluteAddress(operand)), 2) end
    elseif operand.definition == ccasm.operandTypes.absoluteAddress or operand.definition == ccasm.operandTypes.indirectAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 2) end
    end
    return getter;
end

local function longGetter(operand)
    local getter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        getter = ccasm.registers.dataRegisters[registerId(operand)].getLong;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        getter = ccasm.registers.addressRegisters[registerId(operand)].getLong;
    elseif operand.definition == ccasm.operandTypes.immediateData then
        getter = function() return ccasm.tableUtils.zeroPadFrontToSize(operand.valueBytes, 4) end
    elseif operand.definition == ccasm.operandTypes.symbolicAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 4) end
    elseif operand.definition == ccasm.operandTypes.absoluteSymbolicAddress then
        getter = function() return ccasm.tableUtils.fitToSize(ccasm.integer.getBytesForInteger(absoluteAddress(operand)), 4) end
    elseif operand.definition == ccasm.operandTypes.absoluteAddress or operand.definition == ccasm.operandTypes.indirectAddress then
        getter = function() return ccasm.memory.readBytes(absoluteAddress(operand), 4) end
    end
    return getter;
end

local function byteSetter(operand)
    local setter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        setter = ccasm.registers.dataRegisters[registerId(operand)].setByte;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        setter = ccasm.registers.addressRegisters[registerId(operand)].setByte;
    elseif operand.definition == ccasm.operandTypes.symbolicAddress or
           operand.definition == ccasm.operandTypes.absoluteAddress or
           operand.definition == ccasm.operandTypes.indirectAddress
    then
        setter = function(byte) ccasm.memory.writeBytes(absoluteAddress(operand), ccasm.tableUtils.fitToSize(byte, 1)) end
    end
    return setter;
end

local function wordSetter(operand)
    local setter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        setter = ccasm.registers.dataRegisters[registerId(operand)].setWord;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        setter = ccasm.registers.addressRegisters[registerId(operand)].setWord;
    elseif operand.definition == ccasm.operandTypes.symbolicAddress or
           operand.definition == ccasm.operandTypes.absoluteAddress or
           operand.definition == ccasm.operandTypes.indirectAddress
    then
        setter = function(word) ccasm.memory.writeBytes(absoluteAddress(operand), ccasm.tableUtils.trimToSize(word, 2)) end
    end
    return setter;
end

local function longSetter(operand)
    local setter;
    if operand.definition == ccasm.operandTypes.dataRegister then
        setter = ccasm.registers.dataRegisters[registerId(operand)].setLong;
    elseif operand.definition == ccasm.operandTypes.addressRegister then
        setter = ccasm.registers.addressRegisters[registerId(operand)].setLong;
    elseif operand.definition == ccasm.operandTypes.symbolicAddress or
           operand.definition == ccasm.operandTypes.absoluteAddress or
           operand.definition == ccasm.operandTypes.indirectAddress
    then
        setter = function(long) ccasm.memory.writeBytes(absoluteAddress(operand), ccasm.tableUtils.trimToSize(long, 4)) end
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