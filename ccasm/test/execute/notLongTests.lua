assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    notDataRegister = function()
        fixture.assemble("notLong d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFFFFFF);
    end,

    notInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("notLong a0");
            end,
            function()
                fixture.assemble("notLong #1");
            end,
            function()
                fixture.assemble([[
                    notLong var
                    var declareLong #h1234ABCD
                ]]);
            end
        );
    end,

};

return testSuite;