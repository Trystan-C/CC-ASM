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
    end,

    assembleWordImmediateDecimalConstant = function()
        fixture.assemble("varName declareWord #hFF00")
            .symbolShouldExist("varName")
            .valueAtSymbolShouldBe(0xFF00);
    end,

    assembleDeclareWordConstantTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("word declareWord #hFF00AA");
        end);
    end,

    assembleLongImmediateHexConstant = function()
        fixture.assemble("long declareLong #hFFAABBCC")
            .symbolShouldExist("long")
            .valueAtSymbolShouldBe(0xFFAABBCC);
    end,

    assembleDeclareLongConstantTooLargeThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("var declareLong #AA00BB11FF");
        end);
    end,

};

return testSuite;