assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/assert/expect.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    subByteFromDataRegister = function()
        fixture.assemble([[
            moveByte #25, d0
            subByte #10, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(15);
    end,

    subByteCanOverflow = function()
        fixture.assemble([[
            moveByte #1, d0
            subByte #2, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFF);
    end,

    subByteFromAddressRegisterThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #32, a3
                subByte #22, a3
            ]]);
        end);
    end,

    subByteAtSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                moveByte #10, d0
                subByte x, d0
                x declareByte #5
            ]]);
        end);
    end,

    subByteFromSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                subByte #15, x
                x declareByte #20
            ]]);
        end);
    end,

    subByteAffectsOnlyLowerByte = function()
        fixture.assemble([[
            moveWord #h1200, d0
            subByte #1, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x12FF);
    end,

    subByteOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("subByte #h1234, d0");
        end);
    end,

};

return testSuite;