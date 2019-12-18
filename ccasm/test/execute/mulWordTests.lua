assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    multiplyDataRegisters = function()
        fixture.assemble([[
            moveWord #h1234, d0
            moveWord #2, d1
            mulWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x2468);
    end,

    multiplyImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveWord #h1234, d0
            mulWord #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x2468);
    end,

    multiplicationIsSigned = function()
        fixture.assemble([[
            moveWord #1, d0
            mulWord #hFFFF, d0
            moveWord #hFFFF, d1
            mulWord #hFFFF, d1
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xFFFF)
            .dataRegister(1).hasValue(1);
    end,

    multiplyFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #h1234, a0
                moveWord #1, d0
                mulWord a0, d0
            ]]);
        end);
    end,

    multiplyToAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveWord #1, d0
                moveWord #2, a0
                mulWord d0, a0
            ]]);
        end);
    end,

};

return testSuite;