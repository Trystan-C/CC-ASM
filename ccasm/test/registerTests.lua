assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/test/assert/expect.lua");

local testSuite = {

    beforeEach = function()
        registers.clear();
    end,

    clearRegisters = function()
        for _, dataRegister in ipairs(registers.dataRegisters) do
            dataRegister.setLong({ 0x12, 0x23, 0xAB, 0xCD });
        end
        for _, addressRegister in ipairs(registers.addressRegisters) do
            addressRegister.setLong({ 0x12, 0x23, 0xAB, 0xCD });
        end
        registers.setStatusRegister(0xFF);

        registers.clear();

        for _, dataRegister in ipairs(registers.dataRegisters) do
            expect.value(dataRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
        for _, addressRegister in ipairs(registers.addressRegisters) do
            expect.value(addressRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
        expect.value(registers.getStatusRegister()).toEqual(0);
    end,

    getAndSetDataRegisterByte = function()
        local byte = { 0xFF };
        registers.dataRegisters[0].setByte(byte);
        expect.value(registers.dataRegisters[0].getByte()).toDeepEqual(byte);
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
        local byte = { 0xB2 };
        registers.addressRegisters[1].setByte(byte);
        expect.value(registers.addressRegisters[1].getByte()).toDeepEqual(byte);
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