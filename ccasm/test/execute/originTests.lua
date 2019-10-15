assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");
apiLoader.loadIfNotPresent("/ccasm/test/fixtures/cpuTestFixture.lua");

local fixture = cpuTestFixture;

local testSuite = {

    programStartsAtOrigin = function()
        fixture.assemble([[
            origin #h1000
            moveByte #15, d3
        ]])
            .load()
            .programCounterIsAt(0x1000)
            .step()
            .dataRegister(3).hasValue(15);
    end,

    originLongerThanTwoBytesThrowsError = function()
        expect.errorToBeThrown(function()
            local long = math.pow(2, 16);
            fixture.assemble("origin #" .. long);
        end);
    end,

    originAtSymbolicAddressThrowsError = function()
        expect.errorToBeThrown(function()
            fixture.assemble([[
                start declareByte 5
                origin start
            ]]);
        end);
    end

};

return testSuite;