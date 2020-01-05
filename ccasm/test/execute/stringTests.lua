assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    declareString = function()
        fixture.assemble([[
            moveLong str, d0
            str declareString "abc"
        ]])
            .load()
            .step()
            .dataRegister(0).hasValue(0x61626300);
    end,

    declareInvalidOperandThrowsError = function()
        expect.errorsToBeThrown(
            function()
                fixture.assemble("str declareString #h1234ABCD");
            end,
            function()
                fixture.assemble("str declareString 'str'");
            end
        );
    end,

};

return testSuite;