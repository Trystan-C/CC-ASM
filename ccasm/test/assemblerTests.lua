os.loadAPI("/ccasm/src/assembler.lua");

local objectCode = {};
local binaryCodePtr = 1;

local function assemble(code)
    objectCode = assembler.assemble(code);
end

local function getNextByteFromBinaryOutput()
    local nextByte = objectCode.binaryOutput[binaryCodePtr];
    binaryCodePtr = binaryCodePtr + 1;

    return nextByte;
end

local function nextInstructionShouldBe(instruction)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesInstruction = nextByte == instruction;
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

    assembleMoveByteFromDataRegisterToDataRegister = function()
        assemble("moveByte d0, d1");
        nextInstructionShouldBe(instructions.moveByte);
        nextOperandTypeShouldBe(operandTypes.dataRegister.id);
        nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        nextOperandShouldBe(cpu.dataRegisters[0].id);
        nextOperandTypeShouldBe(operandTypes.dataRegister.id);
        nextOperandSizeInBytesShouldBe(1);
        nextOperandShouldBe(cpu.dataRegisters[1].id);
    end

};

return testSuite;