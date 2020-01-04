assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    xorDataRegisters = function()
        fixture.assemble([[
            moveWord #hAAAA, d0
            moveWord #hFFFF, d1
            xorWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0x5555);
    end,

    xorImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveWord #hAAAA, d0
            xorWord #hFFFF, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0x5555);
    end,

    xorOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("xorWord #h1234ABCD, d0");
        end);
    end,

    xorInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("xorWord a0, d0");
            end,
            function()
                fixture.assemble("xorWord d0, #1");
            end,
            function()
                fixture.assemble([[
                    xorWord var, d0
                    var declareWord #hFFFF
                ]]);
            end
        );
    end,

};

return testSuite;