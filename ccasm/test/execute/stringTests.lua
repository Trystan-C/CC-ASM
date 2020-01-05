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

    loadStringAbsoluteAddress = function()
        fixture.assemble([[
            origin #h1000
            moveByte #str, a0
            moveWord #str, a1
            moveLong #str, a2
            str declareString "abc"
        ]])
            .load()
            .step(3)
            .addressRegister(0).hasValue(0x18)
            .addressRegister(1).hasValue(0x1018)
            .addressRegister(2).hasValue(0x1018);
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