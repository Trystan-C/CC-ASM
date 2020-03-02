assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    divideDataRegisters = function()
        fixture.assemble([[
            moveWord #h4000, d0
            moveByte #2, d1
            divWord d1, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x2000);
    end,

    divideImmediateDataToDataRegister = function()
        fixture.assemble([[
            moveWord #h4000, d0
            divWord #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x2000);
    end,

    divisionIsSigned = function()
        fixture.assemble([[
            moveByte #1, d0
            divWord #hFFFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFFFF);
    end,

    divisionOnlyAffectsLowerWord = function()
        fixture.assemble([[
            moveLong #h40000000, d0
            divWord #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x40000000);
    end,

    divisionByZeroIsNotCompileTimeError = function()
        fixture.assemble([[
            moveByte #1, d0
            divWord #0, d0
        ]]);
    end,

    divisionByZeroIsRuntimeError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, d0
                divWord #0, d0
            ]])
                .load()
                .step(2);
        end);
    end,

    divideFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, a0
                moveByte #1, d0
                divWord a0, d0
            ]]);
        end);
    end,

    divideToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, a0
                moveByte #1, d0
                divWord d0, a0
            ]]);
        end);
    end,

    divideOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("divWord #h1234ABCD, d0");
        end);
    end,

};

return testSuite;