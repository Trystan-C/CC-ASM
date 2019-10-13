assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/instructions.lua");

local programCounter = 0;

function getProgramCounter()
    return programCounter;
end

function setProgramCounter(address)
    if memory.isAddressValid(address) then
        programCounter = address;
    else
        error("Expected program counter to be a valid address, was " .. tostring(address));
    end
end

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
    local operandValueStartAddress = programCounter;
    local valueBytes = {};
    for i = 1, sizeInBytes do
        valueBytes[i] = readNextByte();
    end

    local definition = operandTypes.getDefinition(typeByte);
    return {
        definition = definition;
        sizeInBytes = sizeInBytes;
        valueBytes = valueBytes;
        valueStartAddress = operandValueStartAddress;
    };
end

local function executeInstruction(definition)
    local operands = {};
    for i = 1, definition.numOperands do
        table.insert(operands, loadOperand());
    end

    definition.execute(unpack(operands));
end

function step()
    executeInstruction(loadInstruction());
end