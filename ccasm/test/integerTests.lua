assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");

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

    getBytesForIntegerWithSizeSmallerThanInteger = function()
        expect.value(integer.getBytesForInteger(2, 0xAABBFFEE)).toDeepEqual({ 0xFF, 0xEE });
    end,

    getBytesForNegativeInteger = function()
        expect.value(integer.getBytesForInteger(2, -1)).toDeepEqual({ 0xFF, 0xFF });
    end,

    getBytesForIntegerWithoutSize = function()
        expect.value(integer.getBytesForInteger(0)).toDeepEqual({ 0 });
        expect.value(integer.getBytesForInteger(256)).toDeepEqual({ 1, 0 });
        expect.value(integer.getBytesForInteger(0xFFFFFF)).toDeepEqual({ 255, 255, 255 });
    end,

    getIntegerFromBytes = function()
        expect.value(integer.getIntegerFromBytes({})).toEqual(0);
        expect.value(integer.getIntegerFromBytes({ 5 })).toEqual(5);
        expect.value(integer.getIntegerFromBytes({ 0xFF, 0xFF })).toEqual(math.pow(2, 16) - 1);
        expect.value(integer.getIntegerFromBytes({ 1, 0, 0 })).toEqual(math.pow(2, 16));
        expect.value(integer.getIntegerFromBytes({ 0xA3, 0xB5, 0xC2, 3 })).toEqual(2746597891);
    end,

    getSignedIntegerFromBytes = function()
        expect.value(integer.getSignedIntegerFromBytes({ 0xFF })).toEqual(-1);
        expect.value(integer.getSignedIntegerFromBytes({ 0xFF, 0xFF })).toEqual(-1);
        expect.value(integer.getSignedIntegerFromBytes({ 0x80 })).toEqual(-128);
        expect.value(integer.getSignedIntegerFromBytes({ 0x7F })).toEqual(127);
    end,

    getIntegerFromBytesWithTooManyBytesThrowsError = function()
        expect.errorToBeThrown(function()
            integer.getIntegerFromBytes({ 1, 2, 3, 4, 5});
        end);
    end,

    addBytes = function()
        expect.value(integer.addBytes({ 1 }, { 1 })).toDeepEqual({ 2 });
        expect.value(integer.addBytes({ 0xFF }, { 0xFF })).toDeepEqual({ 1, 0xFE });
    end,

};

return testSuite;