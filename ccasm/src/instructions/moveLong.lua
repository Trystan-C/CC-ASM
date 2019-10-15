assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

byteValue = 2;
numOperands = 2;

individualOperandVerifiers = {
    sizeShouldBeFourBytes = function(operand)
        if operand.definition ~= operandTypes.symbolicAddress then
            local condition = operand.sizeInBytes <= 4;
            local errorMessage = "moveLong: Operand size " .. operand.sizeInBytes .. " >= 4.";
            assert(condition, errorMessage);
        end
    end
};

groupOperandVerifiers = {
    -- TODO
};

local function getDataBytesFromOperand(operand)
    local result;
    if operand.definition == operandTypes.immediateData then
        result = tableUtils.zeroPadFrontToSize(operand.valueBytes, 4);
    elseif operand.definition == operandTypes.symbolicAddress then
        local offset = integer.getSignedIntegerFromBytes(operand.valueBytes);
        local symbolStartAddress = operand.valueStartAddress + offset;
        local symbolValue = memory.readBytes(symbolStartAddress, 4);
        result = symbolValue;
    end
    return result;
end

local function registerId(operand)
    return operand.valueBytes[1];
end

local function set(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setLong;
    elseif operand.definition == operandTypes.addressRegister then
        setter = registers.addressRegisters[registerId(operand)].setLong;
    end
    return { long = setter };
end

execute = function(from, to)
    local dataBytes = getDataBytesFromOperand(from);
    set(to).long(dataBytes);
end
