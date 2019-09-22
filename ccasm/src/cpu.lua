assert(os.loadAPI("/ccasm/src/memory.lua"));
assert(os.loadAPI("/ccasm/src/registers.lua"));
assert(os.loadAPI("/ccasm/src/instructions.lua"));

programCounter = 0;

local function throwUnsupportedInstructionError(byte)
    local message = "Unsupported instruction byte: " .. tostring(byte) .. ".";
    error(message);
end

local function readNextByte()
    local byte = memory.bytes[programCounter];
    programCounter = programCounter + 1;
    return byte;
end

local function loadInstruction()
    local byte = readNextByte();
    local definition = instructions.byteToDefinitionMap[byte];

    if definition == nil then
        throwUnsupportedInstructionError(byte);
    end

    return definition;
end

local function loadOperand()
    local typeByte = readNextByte();
    local sizeInBytes = readNextByte();
    local valueBytes = {};
    for i = 1, sizeInBytes do
        valueBytes[i] = readNextByte();
    end

    local definition = operandTypes.getDefinition(typeByte);
    return {
        definition = definition;
        sizeInBytes = sizeInBytes;
        valueBytes = valueBytes;
    };
end

local function executeInstruction(definition)
    local operands = {};
    for i = 1, definition.numOperands do
        table.insert(operands, loadOperand());
    end

    definition.execute(operands);
end

function step()
    registers.dataRegisters[1].value = 10;
    registers.dataRegisters[5].value = 10;
    registers.addressRegisters[3].value = 256;
    registers.addressRegisters[0].value = 0xFFFF;
    registers.addressRegisters[2].value = 0xFF;

    executeInstruction(loadInstruction());
end