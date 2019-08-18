os.loadAPI("/ccasm/src/assembler.lua");
os.loadAPI("/ccasm/test/fixtures/assemblerTestFixture.lua");

local testSuite = {

    assembleMoveByteFromDataRegisterToDataRegister = function()
        assemblerTestFixture.assemble("moveByte d0, d1");
        assemblerTestFixture.nextInstructionShouldBe(instructions.moveByte);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        assemblerTestFixture.nextOperandShouldBe(cpu.dataRegisters[0].id);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        assemblerTestFixture.nextOperandShouldBe(cpu.dataRegisters[1].id);
    end,

    assembleMoveByteFromAddressRegisterToAddressRegister = function()
        assemblerTestFixture.assemble("moveByte A5, a0")
        assemblerTestFixture.nextInstructionShouldBe(instructions.moveByte)
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.addressRegister.typeByte)
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
        assemblerTestFixture.nextOperandShouldBe(cpu.addressRegisters[5].id)
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.addressRegister.typeByte)
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
        assemblerTestFixture.nextOperandShouldBe(cpu.addressRegisters[0].id)
    end,

    assembleMoveByteImmediateDecimalToDataRegister = function()
        assemblerTestFixture.assemble("moveByte #15, D3");
        assemblerTestFixture.nextInstructionShouldBe(instructions.moveByte);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.immediateData.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(1);
        assemblerTestFixture.nextOperandShouldBe(15);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        assemblerTestFixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end,

    assembleMoveByteImmediateHexToDataRegister = function()
        assemblerTestFixture.assemble("moveByte #h0F, D3");
        assemblerTestFixture.nextInstructionShouldBe(instructions.moveByte);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.immediateData.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(1);
        assemblerTestFixture.nextOperandShouldBe(15);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        assemblerTestFixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end,

    assembleMoveByteImmediateBinaryToDataRegister = function()
        assemblerTestFixture.assemble("moveByte #b101, D3");
        assemblerTestFixture.nextInstructionShouldBe(instructions.moveByte);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.immediateData.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(1);
        assemblerTestFixture.nextOperandShouldBe(5);
        assemblerTestFixture.nextOperandTypeShouldBe(operandTypes.dataRegister.typeByte);
        assemblerTestFixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        assemblerTestFixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end

};

return testSuite;