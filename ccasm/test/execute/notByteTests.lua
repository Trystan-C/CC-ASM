assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    notDataRegister = function()
        fixture.assemble("notByte d0")
            .load()
            .step()
            .dataRegister(0).hasValue(0xFF);
    end,

    notInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("notByte a0");
            end,
            function()
                fixture.assemble("notByte #1");
            end,
            function()
                fixture.assemble([[
                    notByte var
                    var declareLong #h1234ABCD
                ]]);
            end
        );
    end,

};

return testSuite;