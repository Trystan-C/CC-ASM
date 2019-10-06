assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/assembler.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/cpu.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/test/utils/expect.lua");

local objectCode;
local apiEnv = {};

apiEnv.assertAddressRegisterValueIs = function(id, value)
    expect.value(registers.addressRegisters[id].value)
            .toDeepEqual(integer.getBytesForInteger(registers.registerWidthInBytes, value));

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.assertDataRegisterValueIs = function(id, value)
    expect.value(registers.dataRegisters[id].value)
        .toDeepEqual(integer.getBytesForInteger(registers.registerWidthInBytes, value));

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
        end
    };
end

apiEnv.dataRegister = function (id)
    return {
        hasValue = function(value)
            return apiEnv.assertDataRegisterValueIs(id, value);
        end
    };
end

apiEnv.step = function(steps)
    if steps == nil then
        steps = 1;
    end

    for _ = 1, steps do
        cpu.step();
    end

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.programCounterIsAt = function(address)
    local condition = address == cpu.getProgramCounter();
    local message = "Expected program counter to be at address 0x" .. string.format("%X", address) .. " but was 0x" .. string.format("%X", cpu.getProgramCounter());
    assert(condition, message);

    return {
        step = apiEnv.step;
    };
end

local function load()
    registers.clear();
    memory.clear();
    memory.load(objectCode.origin, objectCode.binaryOutput);
    cpu.setProgramCounter(objectCode.origin);

    return {
        programCounterIsAt = apiEnv.programCounterIsAt;
        step = apiEnv.step;
    };
end

function assemble(code)
    objectCode = assembler.assemble(code);

    return {
        load = load;
    };
end