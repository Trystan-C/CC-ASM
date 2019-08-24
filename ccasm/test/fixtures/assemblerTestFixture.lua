os.loadAPI("/ccasm/src/assembler.lua");

local apiEnv = getfenv();
local objectCode = nil;
local binaryCodePtr = nil;

local function getNextByteFromBinaryOutput()
    local nextByte = objectCode.binaryOutput[binaryCodePtr];
    binaryCodePtr = binaryCodePtr + 1;

    if nextByte == nil then
        local tooFewBytesMessage = "Ran out of bytes. Are some data not being appended?";
        error(tooFewBytesMessage);
    end

    return nextByte;
end

function nextOperandShouldBe(operand)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperand = nextByte == operand;
    assert(byteMatchesOperand, "Unexpected operand value.");

    return {
        nextInstructionShouldBe = apiEnv.nextInstructionShouldBe;
        nextOperandTypeShouldBe = apiEnv.nextOperandTypeShouldBe;
    };
end

function nextOperandSizeInBytesShouldBe(sizeInBytes)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandSize = nextByte == sizeInBytes;
    assert(byteMatchesOperandSize, "Unexpected operand size.");

    return {
        nextOperandShouldBe = nextOperandShouldBe;
    };
end

function nextOperandTypeShouldBe(operandTypeDefinition)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesOperandType = nextByte == operandTypeDefinition.typeByte;
    local errorMessage = "Unexpected operand type: " .. tostring(operandType);
    assert(byteMatchesOperandType, errorMessage);

    return {
        nextOperandSizeInBytesShouldBe = nextOperandSizeInBytesShouldBe;
    };
end

function nextInstructionShouldBe(instructionDefinition)
    local nextByte = getNextByteFromBinaryOutput();
    local byteMatchesInstruction = nextByte == instructionDefinition.byteValue;
    assert(byteMatchesInstruction, "Unexpected instruction.");

    return {
        nextOperandTypeShouldBe = nextOperandTypeShouldBe;
    };
end

local function clearAssembleOutput()
    objectCode = {};
    binaryCodePtr = 1;
end

function assemble(code)
    clearAssembleOutput();
    objectCode = assembler.assemble(code);

    return {
        nextInstructionShouldBe = nextInstructionShouldBe;
    };
end
