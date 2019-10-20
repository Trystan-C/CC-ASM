assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

local function registerId(operand)
    return operand.valueBytes[1];
end

local function byteGetter(operand)
    local getter;
    if operand.definition == operandTypes.dataRegister then
        getter = registers.dataRegisters[registerId(operand)].getByte;
    elseif operand.definition == operandTypes.addressRegister then
        getter = registers.addressRegisters[registerId(operand)].getByte;
    elseif operand.definition == operandTypes.immediateData then
        getter = function() return operand.valueBytes end
    end
    return getter;
end

local function byteSetter(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setByte;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setByte;
    end
    return setter;
end

function byte(operand)
    return {
        get = byteGetter(operand);
        set = byteSetter(operand);
    };
end