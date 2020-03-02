assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    divideDataRegisters = function()
        fixture.assemble([[
            moveLong #h40000000, d0
            moveByte #2, d1
            divLong d1, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x20000000);
    end,

    divideImmediateDataToDataRegister = function()
        fixture.assemble([[
            moveLong #h40000000, d0
            divLong #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x20000000);
    end,

    divisionIsSigned = function()
        fixture.assemble([[
            moveByte #1, d0
            divLong #hFFFFFFFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFFFFFFFF);
    end,

    divisionByZeroIsNotCompileTimeError = function()
        fixture.assemble([[
            moveByte #1, d0
            divLong #0, d0
        ]]);
    end,

    divisionByZeroIsRuntimeError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, d0
                divLong #0, d0
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
                divLong a0, d0
            ]]);
        end);
    end,

    divideToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, a0
                moveByte #1, d0
                divLong d0, a0
            ]]);
        end);
    end,

    divideOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("divLong #h1234ABCD5678, d0");
        end);
    end,

};

return testSuite;