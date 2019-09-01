assert(os.loadAPI("/ccasm/src/utils/integer.lua"));
assert(os.loadAPI("/ccasm/test/utils/expect.lua"));

local testSuite = {

    getSizeInBytesForFloatingPointValueThrowsError = function()
        expect.errorToBeThrown(function()
            integer.getSizeInBytesForInteger(2.5);
        end);
    end,

    getSizeInBytesForPositiveInteger = function()
        expect.value(integer.getSizeInBytesForInteger(255)).toEqual(1);
        expect.value(integer.getSizeInBytesForInteger(256)).toEqual(2);
        expect.value(integer.getSizeInBytesForInteger(math.pow(2, 16))).toEqual(3);
        expect.value(integer.getSizeInBytesForInteger(math.pow(2, 24) - 1)).toEqual(3);
        expect.value(integer.getSizeInBytesForInteger(math.pow(2, 24))).toEqual(4);
        expect.value(integer.getSizeInBytesForInteger(math.pow(2, 32)-1)).toEqual(4);
        expect.value(integer.getSizeInBytesForInteger(math.pow(2, 32))).toEqual(5);
    end,

    getBytesForIntegerWithSpecificSize = function()
        expect.value(integer.getBytesForInteger(4, 0)).toDeepEqual({ 0, 0, 0, 0 });
        expect.value(integer.getBytesForInteger(4, 1)).toDeepEqual({ 0, 0, 0, 1 });
        expect.value(integer.getBytesForInteger(4, 255)).toDeepEqual({ 0, 0, 0, 255 });
        expect.value(integer.getBytesForInteger(4, 0xFFFF)).toDeepEqual({ 0, 0, 255, 255 });
    end,

    getBytesForIntegerWithoutSize = function()
        expect.value(integer.getBytesForInteger(0)).toDeepEqual({ 0 });
        expect.value(integer.getBytesForInteger(256)).toDeepEqual({ 1, 0 });
        expect.value(integer.getBytesForInteger(0xFFFFFF)).toDeepEqual({ 255, 255, 255 });
    end

};

return testSuite;