os.loadAPI("/ccasm/src/assembler.lua");

local objectCode = {};
local objectCodePtr = 1;

local function assemble(code)
    objectCode = assembler.assemble(code);
end

local function nextInstructionShouldBe(instruction)
    local nextByte = objectCode[objectCodePtr];
    local byteMatchesInstruction = nextByte == instruction;
    assert(byteMatchesInstruction);
end

local testSuite = {

    assembleMoveByteFromDataRegisterToDataRegister = function()
        assemble("move.b d0, d1");
        nextInstructionShouldBe(instructions.moveByte);
        --[[nextOperandTypeShouldBe(operandTypes.dataRegister);
        nextOperandSizeInBytesShouldBe(1);
        nextOperandShouldBe(cpu.dataRegisters[0].id);
        nextOperandTypeShouldBe(operandTypes.dataRegister);
        nextOperandSizeInBytesShouldBe(1);
        nextOperandShouldBe(cpu.dataRegisters[1].id);--]]
    end

};

return testSuite;