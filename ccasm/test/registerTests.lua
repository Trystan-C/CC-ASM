assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
assert(os.loadAPI("/ccasm/test/assert/expect.lua"));

local testSuite = {

    beforeEach = function()
        ccasm.registers.clear();
    end,

    clearRegisters = function()
        for _, dataRegister in ipairs(ccasm.registers.dataRegisters) do
            dataRegister.setLong({ 0x12, 0x23, 0xAB, 0xCD });
        end
        for _, addressRegister in ipairs(ccasm.registers.addressRegisters) do
            addressRegister.setLong({ 0x12, 0x23, 0xAB, 0xCD });
        end
        ccasm.registers.setStatusRegister(0xFF);

        ccasm.registers.clear();

        for _, dataRegister in ipairs(ccasm.registers.dataRegisters) do
            expect.value(dataRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
        for _, addressRegister in ipairs(ccasm.registers.addressRegisters) do
            expect.value(addressRegister.value).toDeepEqual({ 0, 0, 0, 0 });
        end
        expect.value(ccasm.registers.getStatusRegister()).toEqual(0);
    end,

    getAndSetDataRegisterByte = function()
        local byte = { 0xFF };
        ccasm.registers.dataRegisters[0].setByte(byte);
        expect.value(ccasm.registers.dataRegisters[0].getByte()).toDeepEqual(byte);
    end,

    getAndSetDataRegisterWord  = function()
        local word = { 0xA3, 25 };
        ccasm.registers.dataRegisters[2].setWord(word);
        expect.value(ccasm.registers.dataRegisters[2].getWord()).toDeepEqual(word);
    end,

    getAndSetDataRegisterLong = function()
        local long = { 0xb1, 0xa5, 255, 0x32 };
        ccasm.registers.dataRegisters[3].setLong(long);
        expect.value(ccasm.registers.dataRegisters[3].getLong()).toDeepEqual(long);
    end,

    getAndSetAddressRegisterByte = function()
        local byte = { 0xB2 };
        ccasm.registers.addressRegisters[1].setByte(byte);
        expect.value(ccasm.registers.addressRegisters[1].getByte()).toDeepEqual(byte);
    end,

    getAndSetAddressRegisterWord  = function()
        local word = { 0xF0, 0x12 };
        ccasm.registers.addressRegisters[2].setWord(word);
        expect.value(ccasm.registers.addressRegisters[2].getWord()).toDeepEqual(word);
    end,

    getAndSetAddressRegisterLong = function()
        local long = { 0xb1, 0xa5, 255, 0x32 };
        ccasm.registers.addressRegisters[3].setLong(long);
        expect.value(ccasm.registers.addressRegisters[3].getLong()).toDeepEqual(long);
    end,

    popAtStackBaseThrowsError = function()
        expect.errorToBeThrown(function()
            ccasm.registers.popStackByte();
        end);

        ccasm.registers.clear();
        expect.errorToBeThrown(function()
            ccasm.registers.popStackWord();
        end);
        
        ccasm.registers.clear();
        expect.errorToBeThrown(function()
            ccasm.registers.popStackLong();
        end);
    end,

    pushOverStackLimitThrowsError = function()
        local bytes = {};
        for i = 1, ccasm.registers.STACK_SIZE_IN_BYTES do
            table.insert(bytes, 0);
        end
        ccasm.registers.pushStack(bytes);
        expect.errorToBeThrown(function()
            ccasm.registers.pushStack({ 0 });
        end);
    end,

    stack = function()
        ccasm.registers.pushStack({ 0x12 });
        ccasm.registers.pushStack({ 0x12, 0x34 });
        ccasm.registers.pushStack({ 0x12, 0x34, 0xAB, 0xCD });
        expect.value(ccasm.registers.popStackLong()).toDeepEqual({ 0x12, 0x34, 0xAB, 0xCD });
        expect.value(ccasm.registers.popStackWord()).toDeepEqual({ 0x12, 0x34 });
        expect.value(ccasm.registers.popStackByte()).toDeepEqual({ 0x12 });
    end,

};

return testSuite;