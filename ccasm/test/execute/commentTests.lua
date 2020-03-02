assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/fixtures/cpuTestFixture.lua"));
local fixture = cpuTestFixture;

local testSuite = {

    commentsAreIgnored = function()
        fixture.assemble([[
            moveLong #h12340000, d0 ;Comment without space after ;.
            moveWord #hABCD, d1 ;    Comment with space before ;.
            ; Comment on it's own line.
            ; Comment before line: addByte #1, d1
            addLong d1, d0
        ]])
            .load()
            .step(3)
            .dataRegister(0).hasValue(0x1234ABCD);
    end,

};

return testSuite;