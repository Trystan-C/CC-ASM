assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    xorDataRegisters = function()
        fixture.assemble([[
            moveLong #hAAAAAAAA, d0
            moveLong #hFFFFFFFF, d1
            xorLong d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x55555555);
    end,

    xorImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveLong #hAAAAAAAA, d0
            xorLong #hFFFFFFFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x55555555);
    end,

    xorOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("xorLong #h1234ABCD5678, d0");
        end);
    end,

    xorInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("xorLong a0, d0");
            end,
            function()
                fixture.assemble("xorLong d0, #1");
            end,
            function()
                fixture.assemble([[
                    xorLong var, d0
                    var declareLong #hFFFFFFFF
                ]]);
            end
        );
    end,

};

return testSuite;