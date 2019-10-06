assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/utils/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/assemblerTestFixture.lua");

local fixture = assemblerTestFixture;

local testSuite = {

    assembleSingleByteImmediateDecimalConstant = function()
        fixture.assemble("varName declareByte #12")
            .symbolShouldExist("varName")
            .valueAtSymbolShouldBe(12);
    end,

    assembleDeclareByteConstantTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("myConstant declareByte #256");
        end);
    end

};

return testSuite;