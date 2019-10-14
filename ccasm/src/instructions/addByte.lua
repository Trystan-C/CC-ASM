assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");

byteValue = 3;
numOperands = 2;

individualOperandVerifiers = {};
groupOperandVerifiers = {};

local function registerId(operand)
    return operand.valueBytes[1];
end

local function getDataFromOperand(operand)
    local result;
    if operand.definition == operandTypes.dataRegister then
        result = registers.dataRegisters[registerId(operand)].getByte();
    elseif operand.definition == operandTypes.addressRegister then
        result = registers.addressRegisters[registerId(operand)].getByte();
    elseif operand.definition == operandTypes.immediateData then
        result = operand.valueBytes;
    end
    return result;
end

local function set(operand)
    local setter;
    if operand.definition == operandTypes.dataRegister then
        setter = registers.dataRegisters[registerId(operand)].setByte;
    end
    return {
        byte = setter;
    };
end

function execute(from, to)
    local fromData = getDataFromOperand(from);
    local toData = getDataFromOperand(to);
    local sum = integer.addBytes(fromData, toData);
    set(to).byte(tableUtils.trimToSize(sum, 1));
end