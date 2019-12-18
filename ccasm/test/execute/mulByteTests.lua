assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    multiplyDataRegisters = function()
        fixture.assemble([[
            moveByte #1, d0
            moveByte #2, d1
            mulByte d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(2);
    end,

    multiplyImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveByte #2, d0
            mulByte #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(4);
    end,

    multiplicationIsSigned = function()
        fixture.assemble([[
            moveByte #1, d0
            mulByte #hFF, d0
            moveByte #hFF, d1
            mulByte #hFF, d1
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xFF)
            .dataRegister(1).hasValue(1);
    end,

    multiplyToAddressRegisterThrowsError  = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                mulByte #1, A3
            ]]);
        end);
    end,

    multiplyFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #1, a5
                moveByte #2, d0
                mulByte a5, d0
            ]]);
        end);
    end,

    multiplyOnlyAffectsLowerByte = function()
        fixture.assemble([[
            moveWord #h1200, D5
            mulByte #2, d5
        ]])
            .load()
            .step(2)
            .dataRegister(5).hasValue(0x1200);
    end,

};

return testSuite;