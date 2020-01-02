assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");
local fixture = cpuTestFixture;

local testSuite = {

    branchToSubroutineExecutesAndReturns = function()
        fixture.assemble([[
            bsr my_subroutine
            moveByte #h0C, d0
            my_subroutine:
            moveLong #hABCD1234, d0
            ret
        ]])
            .load()
            .step(4)
            .dataRegister(0).hasValue(0xABCD120C);
    end,

    branchToAbsoluteAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble("bsr #h1234");
        end);
    end,

};

return testSuite;