assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/utils/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/assemblerTestFixture.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

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
            .nextOperandShouldBe(registers.dataRegisters[0].id);
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
            .nextOperandShouldBeReferenceToSymbol("var")
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[3].id);
    end

};

return testSuite;