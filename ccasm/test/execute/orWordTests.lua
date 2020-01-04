assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    orDataRegisters = function()
        fixture.assemble([[
            moveWord #hAA00, d0
            moveWord #h00BB, d1
            orWord d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAABB);
    end,

    orImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveWord #h7777, d0
            orWord #hAAAA, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFFFF);
    end,

    orDataRegisterAndImmediateDataThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orWord d0, #1");
        end);
    end,

    orOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orWord #h1234ABCD, d0");
        end);
    end,

    orInvalidOperandTypeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orWord a0, d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("orWord d0, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                orWord var, d0
                var declareWord #hFF
            ]]);
        end);
    end,

};

return testSuite;