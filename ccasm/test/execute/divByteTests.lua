assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    divideDataRegisters = function()
        fixture.assemble([[
            moveByte #4, d0
            moveByte #2, d1
            divByte d1, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(2);
    end,

    divideImmediateDataToDataRegister = function()
        fixture.assemble([[
            moveByte #4, d0
            divByte #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(2);
    end,

    divisionIsSigned = function()
        fixture.assemble([[
            moveByte #1, d0
            divByte #hFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFF);
    end,

    divisionByZeroIsNotCompileTimeError = function()
        fixture.assemble([[
            moveByte #1, d0
            divByte #0, d0
        ]]);
    end,

    divisionByZeroIsRuntimeError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, d0
                divByte #0, d0
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
                divByte a0, d0
            ]]);
        end);
    end,

    divideToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, a0
                moveByte #1, d0
                divByte d0, a0
            ]]);
        end);
    end,

};

return testSuite;