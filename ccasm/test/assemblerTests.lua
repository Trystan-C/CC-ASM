os.loadAPI("/ccasm/src/assembler.lua");

local objectCode = nil;
local binaryCodePtr = nil;

local function clearAssembleOutput()
    objectCode = {};
    binaryCodePtr = 1;
end

local function assemble(code)
    objectCode = assembler.assemble(code);
end

local function getNextByteFromBinaryOutput()
    local nextByte = objectCode.binaryOutput[binaryCodePtr];
    binaryCodePtr = binaryCodePtr + 1;

    if nextByte == nil then
        local tooFewBytesMessage = "Ran out of bytes. Are some data not being appended?";
        error(tooFewBytesMessage);
    end

    return nextByte;
end

local function nextInstructionShouldBe(definition)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesInstruction = nextByte == definition.byteValue;
    assert(byteMatchesInstruction, "Unexpected instruction.");
end

local function nextOperandTypeShouldBe(operandType)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandType = nextByte == operandType;
    assert(byteMatchesOperandType, "Unexpected operand type.");
end

local function nextOperandSizeInBytesShouldBe(sizeInBytes)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandSize = nextByte == sizeInBytes;
    assert(byteMatchesOperandSize, "Unexpected operand size.");
end

local function nextOperandShouldBe(operand)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperand = nextByte == operand;
    assert(byteMatchesOperand, "Unexpected operand value.");
end

local testSuite = {

    beforeEach = function()
        clearAssembleOutput();
    end,

    assembleMoveByteFromDataRegisterToDataRegister = function()
        assemble("moveByte d0, d1");
        nextInstructionShouldBe(instructions.moveByte);
        nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        nextOperandShouldBe(cpu.dataRegisters[0].id);
        nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        nextOperandSizeInBytesShouldBe(1);
        nextOperandShouldBe(cpu.dataRegisters[1].id);
    end

};

return testSuite;