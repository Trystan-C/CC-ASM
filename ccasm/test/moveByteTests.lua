os.loadAPI("/ccasm/src/assembler.lua");
os.loadAPI("/ccasm/test/utils/expect.lua");
os.loadAPI("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleMoveByteFromDataRegisterToDataRegister = function()
        fixture.assemble("moveByte d0, d1");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[0].id);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[1].id);
    end,

    assembleMoveByteFromAddressRegisterToAddressRegister = function()
        fixture.assemble("moveByte A5, a0")
        fixture.nextInstructionShouldBe(instructions.moveByte)
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister)
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
        fixture.nextOperandShouldBe(cpu.addressRegisters[5].id)
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister)
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes)
        fixture.nextOperandShouldBe(cpu.addressRegisters[0].id)
    end,

    assembleMoveByteFromDataRegisterToAddressRegister = function()
        fixture.assemble("moveByte d3, a6");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.addressRegisters[6].id);
    end,

    assembleMoveByteFromAddressRegisterToDataRegister = function()
        fixture.assemble("moveByte A3, d0");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.addressRegisters[3].id);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[0].id);
    end,

    assembleMoveByteImmediateDecimalToDataRegister = function()
        fixture.assemble("moveByte #15, D3");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.immediateData);
        fixture.nextOperandSizeInBytesShouldBe(1);
        fixture.nextOperandShouldBe(15);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end,

    assembleMoveByteImmediateHexToDataRegister = function()
        fixture.assemble("moveByte #h0F, D3");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.immediateData);
        fixture.nextOperandSizeInBytesShouldBe(1);
        fixture.nextOperandShouldBe(15);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end,

    assembleMoveByteImmediateBinaryToDataRegister = function()
        fixture.assemble("moveByte #b101, D3");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.immediateData);
        fixture.nextOperandSizeInBytesShouldBe(1);
        fixture.nextOperandShouldBe(5);
        fixture.nextOperandTypeShouldBe(operandTypes.dataRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.dataRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.dataRegisters[3].id);
    end,

    assembleMoveByteImmediateDecimalToAddressRegister = function()
        fixture.assemble("moveByte #20, a0");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.immediateData);
        fixture.nextOperandSizeInBytesShouldBe(1);
        fixture.nextOperandShouldBe(20);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.addressRegisters[0].id);
    end,

    assembleMoveByteImmediateHexToAddressRegister = function()
        fixture.assemble("moveByte #h0A, A6");
        fixture.nextInstructionShouldBe(instructions.moveByte);
        fixture.nextOperandTypeShouldBe(operandTypes.immediateData);
        fixture.nextOperandSizeInBytesShouldBe(1);
        fixture.nextOperandShouldBe(10);
        fixture.nextOperandTypeShouldBe(operandTypes.addressRegister);
        fixture.nextOperandSizeInBytesShouldBe(operandTypes.addressRegister.sizeInBytes);
        fixture.nextOperandShouldBe(cpu.addressRegisters[6].id);
    end,

    assembleMoveByteWithDecimalOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveByte #256, d5");
        end);
    end,

    assembleMoveByteWithHexOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveByte #hFFFF, A6");
        end);
    end,

    assembleMoveByteWithBinaryOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveByte #b100010001000, D4");
        end);
    end,

    assembleMoveByteImmediateFloatThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("moveByte #1.5, d3");
        end);
    end,

    assembleMoveByteFromAddressToAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                addr1 declareByte #25
                addr2 declareByte #15
                moveByte addr1, addr2
            ]]);
        end);
    end

};

return testSuite;