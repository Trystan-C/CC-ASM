assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    orDataRegisters = function()
        fixture.assemble([[
            moveByte #hA0, d0
            moveByte #h0B, d1
            orByte d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAB);
    end,

    orImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveByte #h77, d0
            orByte #hAA, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFF);
    end,

    orDataRegisterAndImmediateDataThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orByte d0, #1");
        end);
    end,

    orOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orByte #h1234, d0");
        end);
    end,

    orInvalidOperandTypeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orByte a0, d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("orByte d0, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                orByte var, d0
                var declareByte #hFF
            ]]);
        end);
    end,

};

return testSuite;