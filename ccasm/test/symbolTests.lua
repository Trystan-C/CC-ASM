os.loadAPI("/ccasm/test/utils/expect.lua");
os.loadAPI("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleMoveByteFromSymbolicAddress = function()
        fixture.assemble([[
            var declareByte #42
            moveByte var, d0
            ]])
            .symbolShouldExist("var")
            .valueAtSymbolShouldBe(42)
            .offsetByBytes(1)
            .nextInstructionShouldBe(instructions.moveByte)
            .nextOperandTypeShouldBe(operandTypes.symbolicAddress)
            .nextOperandSizeInBytesShouldBe(operandTypes.symbolicAddress.sizeInBytes)
            .nextOperandShouldBeReferenceToSymbol("var")
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(cpu.dataRegisters[0].id);
    end,

    assembleMoveByteFromDeferredSymbolicAddress = function()
        fixture.assemble([[
            moveByte var, D3
            var declareByte #h0A
            ]])
           .symbolShouldExist("var")
           .valueAtSymbolShouldBe(10)
           .nextInstructionShouldBe(instructions.moveByte)
           .nextOperandTypeShouldBe(operandTypes.symbolicAddress)
           .nextOperandSizeInBytesShouldBe(operandTypes.symbolicAddress.sizeInBytes)
           .nextOperandShouldBeReferenceToSymbol("var");
    end

};

return testSuite;