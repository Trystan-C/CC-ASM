assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    orDataRegisters = function()
        fixture.assemble([[
            moveLong #hAAAA0000, d0
            moveLong #h0000BBBB, d1
            orLong d0, d1
        ]])
            .load()
            .step(3)
            .dataRegister(1).hasValue(0xAAAABBBB);
    end,

    orImmediateDataAndDataRegister = function()
        fixture.assemble([[
            moveLong #h77777777, d0
            orLong #hAAAAAAAA, d0
        ]])
            .load()
            .step(2)
            .dataRegister(0).hasValue(0xFFFFFFFF);
    end,

    orDataRegisterAndImmediateDataThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orLong d0, #1");
        end);
    end,

    orOperandTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orLong #h1234ABCD5678, d0");
        end);
    end,

    orInvalidOperandTypeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("orLong a0, d0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble("orLong d0, a0");
        end);
        expect.errorToBeThrown(function()
            fixture.assemble([[
                orLong var, d0
                var declareLong #hFFFFFFFF
            ]]);
        end);
    end,

};

return testSuite;