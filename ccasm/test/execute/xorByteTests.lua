assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    xorDataRegisters = function()
        fixture.assemble([[
            moveByte #hAA, d0
            moveByte #hFF, d1
            xorByte d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x55);
    end,

    xorImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveByte #hAA, d0
            xorByte #hFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x55);
    end,

    xorOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("xorByte #h1234ABCD, d0");
        end);
    end,

    xorInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("xorByte a0, d0");
            end,
            function()
                fixture.assemble("xorByte d0, #1");
            end,
            function()
                fixture.assemble([[
                    xorByte var, d0
                    var declareByte #hFF
                ]]);
            end
        );
    end,

};

return testSuite;