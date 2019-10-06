assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/test/utils/expect.lua");

local testSuite = {

    beforeEach = function()
        registers.clear();
    end,

    clearRegisters = function()
        registers.clear();
        for _, dataRegister in ipairs(registers.dataRegisters) do
            expect.value(dataRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
        for _, addressRegister in ipairs(registers.addressRegisters) do
            expect.value(addressRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
    end,

    getAndSetDataRegisterByte = function()
        registers.dataRegisters[0].setByte(0xFF);
        expect.value(registers.dataRegisters[0].getByte()).toEqual(0xFF);
    end,

    getAndSetDataRegisterWord  = function()
        local word = { 0xA3, 25 };
        registers.dataRegisters[2].setWord(word);
        expect.value(registers.dataRegisters[2].getWord()).toDeepEqual(word);
    end,

    getAndSetDataRegisterLong = function()
        local long = { 0xb1, 0xa5, 255, 0x32 };
        registers.dataRegisters[3].setLong(long);
        expect.value(registers.dataRegisters[3].getLong()).toDeepEqual(long);
    end,

    getAndSetAddressRegisterByte = function()
        registers.addressRegisters[1].setByte(0xB2);
        expect.value(registers.addressRegisters[1].getByte()).toEqual(0xB2);
    end,

    getAndSetAddressRegisterWord  = function()
        local word = { 0xF0, 0x12 };
        registers.addressRegisters[2].setWord(word);
        expect.value(registers.addressRegisters[2].getWord()).toDeepEqual(word);
    end,

    getAndSetAddressRegisterLong = function()
        local long = { 0xb1, 0xa5, 255, 0x32 };
        registers.addressRegisters[3].setLong(long);
        expect.value(registers.addressRegisters[3].getLong()).toDeepEqual(long);
    end,

};

return testSuite;