assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    notDataRegister = function()
        fixture.assemble("notWord d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFFFF);
    end,

    notInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("notWord a0");
            end,
            function()
                fixture.assemble("notWord #1");
            end,
            function()
                fixture.assemble([[
                    notWord var
                    var declareLong #h1234ABCD
                ]]);
            end
        );
    end,

};

return testSuite;