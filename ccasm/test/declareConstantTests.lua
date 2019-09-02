os.loadAPI("/ccasm/src/assembler.lua");
os.loadAPI("/ccasm/test/utils/expect.lua");
os.loadAPI("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleSingleByteImmediateDecimalConstant = function()
        fixture.assemble("varName declareByte #12")
            .symbolShouldExist("varName")
            .valueAtSymbolShouldBe(12);
    end,

    assembleDeclareByteConstantTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("myConstant declareByte #256");
        end);
    end,

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
    end,

};

return testSuite;