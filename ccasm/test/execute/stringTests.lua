assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
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

    delcareStringWithSpaces = function()
        fixture.assemble([[
            moveWord #str, d6
            moveWord d6, a0
            moveLong #a0, d0

            addWord #4, d6
            moveWord d6, a0
            moveLong #a0, d1

            addWord #4, d6
            moveWord d6, a0
            moveLong #a0, d2

            addWord #4, d6
            moveWord d6, a0
            moveByte #a0, d3

            str declareString "Hello, world!"
        ]])
            .load()
            .step(12)
            .dataRegister(0).hasValue(0x48656C6C)
            .dataRegister(1).hasValue(0x6F2C2077)
            .dataRegister(2).hasValue(0x6F726C64)
            .dataRegister(3).hasValue(0x00000021);
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