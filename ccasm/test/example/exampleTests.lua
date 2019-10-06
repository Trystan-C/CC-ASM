local testSuite = {

    beforeAll = function()
        print("Before all executed.");
    end,

    beforeEach = function()
        print("Before each executed.");
    end,

    afterEach = function()
        print("After each executed.");
    end,

    afterAll = function()
        print("After all executed.");
    end,

    passingTest = function()
        assert(1 == 1);
    end,

    failingTest = function()
        error("Test failed as expected.");
    end,

    shellTest = function()
        assert(_G.shell ~= nil);
    end,

    only = {
        isolatedTest = function()
            print("'Only' sub-test-suite executed.");
        end
    };

};

return testSuite;