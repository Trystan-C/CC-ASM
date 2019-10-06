assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/test/utils/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleMoveWordFromDataRegisterToDataRegister = function()
        fixture.assemble("moveWord d5, D2");
        fixture.nextInstructionShouldBe(instructions.moveWord);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(registers.dataRegisters[5].id);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(registers.dataRegisters[2].id);
    end,

    assembleMoveWordFromAddressRegisterToAddressRegister = function()
        fixture.assemble("moveWord A0, A4");
        fixture.nextInstructionShouldBe(instructions.moveWord);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(registers.dataRegisters[0].id);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(registers.addressRegisters[4].id);
    end,

    assembleMoveWordFromDataRegisterToAddressRegister = function()
        fixture.assemble("moveWord D1, A1")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[1].id)
            .nextOperandTypeShouldBe(operandTypes.addressRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
            .nextOperandShouldBe(registers.addressRegisters[1].id);
    end,

    assembleMoveWordFromAddressRegisterToDataRegister = function()
        fixture.assemble("moveWord A6, d1")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.addressRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
            .nextOperandShouldBe(registers.addressRegisters[6].id)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[1].id);
    end,

    assembleMoveWordImmediateDecimalToDataRegister = function()
        fixture.assemble("moveWord #256, D2")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.immediateData)
            .nextOperandSizeInBytesShouldBe(2)
            .nextOperandShouldBe(256)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[2].id);
    end,

    assembleMoveWordImmediateHexToDataRegister = function()
        fixture.assemble("moveWord #h0100, d4")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.immediateData)
            .nextOperandSizeInBytesShouldBe(2)
            .nextOperandShouldBe(256)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[4].id);
    end,

    assembleMoveWordImmediateBinaryToDataRegister = function()
        fixture.assemble("moveWord #b0000000100000000, D5")
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.immediateData)
            .nextOperandSizeInBytesShouldBe(2)
            .nextOperandShouldBe(256)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[5].id);
    end,

    assembleMoveWordWithDecimalOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveWord #65537, d0");
        end);
    end,

    assembleMoveWordWithHexOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveWord #h010000, d0");
        end);
    end,

    assembleMoveWordWithBinaryOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveWord #b000000010000000000000000, d0");
        end);
    end,

    assembleMoveWordFromSymbolicAddressToDataRegister = function()
        fixture.assemble([[
            moveWord var, d0
            var declareByte #255
        ]])
            .symbolShouldExist("var")
            .valueAtSymbolShouldBe(255)
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.symbolicAddress)
            .nextOperandSizeInBytesShouldBe(operandTypes.symbolicAddress.sizeInBytes)
            .nextOperandShouldBeReferenceToSymbol("var")
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[0].id);
    end,

    assembleMoveWordFromDataRegisterToSymbolicAddress = function()
        fixture.assemble([[
            var declareByte #hA3
            moveWord D5, var
        ]])
            .symbolShouldExist("var")
            .valueAtSymbolShouldBe(0xA3)
            .offsetByBytes(1)
            .nextInstructionShouldBe(instructions.moveWord)
            .nextOperandTypeShouldBe(operandTypes.dataRegister)
            .nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes)
            .nextOperandShouldBe(registers.dataRegisters[5].id)
            .nextOperandTypeShouldBe(operandTypes.symbolicAddress)
            .nextOperandSizeInBytesShouldBe(operandTypes.symbolicAddress.sizeInBytes)
            .nextOperandShouldBeReferenceToSymbol("var");
    end,

    assembleMoveWordBetweenSymbolicAddressesThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addr1 declareByte #12
                moveWord addr1, addr2
                addr2 declareByte #24
            ]]);
        end);
    end

};

return testSuite;