os.loadAPI("/ccasm/src/assembler.lua");
os.loadAPI("/ccasm/test/utils/expect.lua");
os.loadAPI("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleMoveWordFromDataRegisterToDataRegister = function()
        fixture.assemble("moveWord d5, D2");
        fixture.nextInstructionShouldBe(instructions.moveWord);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[5].id);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[2].id);
    end,

    assembleMoveWordFromAddressRegisterToAddressRegister = function()
        fixture.assemble("moveWord A0, A4");
        fixture.nextInstructionShouldBe(instructions.moveWord);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[0].id);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.addressRegisters[4].id);
    end,

    assembleMoveWordFromDataRegisterToAddressRegister = function()
        fixture.assemble("moveWord D1, A1")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(cpu.dataRegisters[1].id)
            .nextOperandTypeShouldBe(operandTypes.addressRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
            .nextOperandShouldBe(cpu.addressRegisters[1].id);
    end,

    assembleMoveWordFromAddressRegisterToDataRegister = function()
        fixture.assemble("moveWord A6, d1")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.addressRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
            .nextOperandShouldBe(cpu.addressRegisters[6].id)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(cpu.dataRegisters[1].id);
    end,

};

return testSuite;