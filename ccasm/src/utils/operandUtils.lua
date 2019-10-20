assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

local function registerId(operand)
    return operand.valueBytes[1];
end

local function absoluteAddress(operand)
    local offset = integer.getSignedIntegerFromBytes(operand.valueBytes);
    local symbolStartAddress = operand.valueStartAddress + offset;
    return symbolStartAddress;
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
    end
    return getter;
end

local function byteSetter(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setByte;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setByte;
    elseif operand.definition == operandTypes.symbolicAddress then
        setter = function(byte)
            memory.writeBytes(absoluteAddress(operand), tableUtils.trimToSize(byte, 1));
        end
    end
    return setter;
end

function byte(operand)
    return {
        get = byteGetter(operand);
        set = byteSetter(operand);
    };
end