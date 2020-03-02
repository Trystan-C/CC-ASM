assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
assert(os.loadAPI("/ccasm/test/assert/expect.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/assembler.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/bitUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local objectCode;
local apiEnv = {};

apiEnv.printProgramCounter = function()
    ccasm.logger.info("PROGRAM_COUNTER=%%", ccasm.registers.getProgramCounter());
    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
        statusRegister = apiEnv.statusRegister;
    };
end

apiEnv.statusRegister = function()
    local next = {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
        statusRegister = apiEnv.statusRegister;
    };
    local function errorMessage(name, expected, actual)
        return name .. ": Expected " .. expected .. " but was " .. actual .. ".";
    end
    return {
        printValue = function()
            ccasm.logger.info("STATUS_REGISTER=%%", ccasm.registers.statusRegister);
            return next;
        end,
        comparisonFlagIs = function(value)
            local actual = ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_COMPARISON);
            assert(actual == value, errorMessage("comparisonFlag", value, actual));
            return next;
        end,
        negativeFlagIs = function(value)
            local actual = ccasm.bitUtils.getAt(ccasm.registers.getStatusRegister(), ccasm.registers.STATUS_NEGATIVE);
            assert(actual == value, errorMessage("negativeFlag", value, actual));
            return next;
        end,
    };
end

apiEnv.assertAddressRegisterValueIs = function(id, value)
    expect.value(ccasm.registers.addressRegisters[id].value)
            .toDeepEqual(ccasm.integer.getBytesForInteger(ccasm.registers.registerWidthInBytes, value));

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.assertDataRegisterValueIs = function(id, value)
    expect.value(ccasm.registers.dataRegisters[id].value)
        .toDeepEqual(ccasm.integer.getBytesForInteger(ccasm.registers.registerWidthInBytes, value));

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.printAddressRegisterValue = function(id)
    ccasm.logger.info("ADDRESS_REGISTER[%%]=%%", id, ccasm.registers.addressRegisters[id].value);

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.printDataRegisterValue = function(id)
    ccasm.logger.info("DATA_REGISTER[%%]=%%", id, ccasm.registers.dataRegisters[id].value);

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.addressRegister = function(id)
    return {
        hasValue = function(value)
            return apiEnv.assertAddressRegisterValueIs(id, value);
        end,
        printValue = function(value)
            return apiEnv.printAddressRegisterValue(id);
        end,
    };
end

apiEnv.dataRegister = function (id)
    return {
        hasValue = function(value)
            return apiEnv.assertDataRegisterValueIs(id, value);
        end,
        printValue = function()
            return apiEnv.printDataRegisterValue(id);
        end,
    };
end

apiEnv.step = function(steps)
    if steps == nil then
        steps = 1;
    end

    for _ = 1, steps do
        ccasm.cpu.step();
    end

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
        statusRegister = apiEnv.statusRegister;
        printProgramCounter = apiEnv.printProgramCounter;
    };
end

apiEnv.programCounterIsAt = function(address)
    local condition = address == ccasm.registers.getProgramCounter();
    local message = "Expected program counter to be at address 0x" .. string.format("%X", address) .. " but was 0x" .. string.format("%X", ccasm.registers.getProgramCounter());
    assert(condition, message);

    return {
        step = apiEnv.step;
    };
end

local function load()
    ccasm.registers.clear();
    ccasm.memory.clear();
    ccasm.memory.load(objectCode.origin, objectCode.binaryOutput);
    ccasm.registers.setProgramCounter(objectCode.origin);

    return {
        programCounterIsAt = apiEnv.programCounterIsAt;
        printProgramCounter = apiEnv.printProgramCounter;
        step = apiEnv.step;
    };
end

local function logBinary()
    ccasm.logger.info("[bindump]\nsize=%%\nbytes=%%", #objectCode.binaryOutput, objectCode.binaryOutput);

    return {
        load = load;
    };
end

function assemble(code)
    objectCode = ccasm.assembler.assemble(code);

    return {
        load = load;
        logBinary = logBinary;
    };
end