assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    multiplyDataRegisters = function()
        fixture.assemble([[
            moveLong #h12340000, d0
            moveLong #2, d1
            mulLong d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x24680000);
    end,

    multiplyImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveLong #h12340000, d0
            mulLong #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x24680000);
    end,

    multiplicationIsSigned = function()
        fixture.assemble([[
            moveLong #1, d0
            mulLong #hFFFFFFFF, d0
            moveLong #hFFFFFFFF, d1
            mulLong #hFFFFFFFF, d1
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xFFFFFFFF)
            .dataRegister(1).hasValue(1);
    end,

    multiplyFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("mulLong a0, d0");
        end);
    end,

    multiplyToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("mulLong #2, A3");
        end);
    end,

    multiplyFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                mulLong var, d3
                var declareLong #h1234ABCD
            ]]);
        end);
    end,

    multiplyToSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                mulLong D6, var
                var declareLong #h1234ABCD
            ]]);
        end);
    end,

    multiplyOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, d0
                mulLong #h1234ABCD5678, d0
            ]]);
        end);
    end,

};

return testSuite;