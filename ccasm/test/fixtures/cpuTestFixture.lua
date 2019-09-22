assert(os.loadAPI("/ccasm/src/assembler.lua"));
assert(os.loadAPI("/ccasm/src/memory.lua"));
assert(os.loadAPI("/ccasm/src/registers.lua"));
assert(os.loadAPI("/ccasm/src/cpu.lua"));

local objectCode;
local apiEnv = {};

apiEnv.assertAddressRegisterValueIs = function(id, value)
    local actualValue = registers.addressRegisters[id].value;
    local condition = actualValue == value;
    local errorMessage = "Expected address register #" .. tostring(id) ..
            " to have value " .. tostring(value) .. " but was " ..
            tostring(actualValue) .. ".";
    assert(condition, errorMessage);

    return {
        step = apiEnv.step;
        dataRegister = apiEnv.dataRegister;
        addressRegister = apiEnv.addressRegister;
    };
end

apiEnv.assertDataRegisterValueIs = function(id, value)
    local actualValue = registers.dataRegisters[id].value;
    local condition = actualValue == value;
    local errorMessage = "Expected data register #" .. tostring(id) ..
            " to have value " .. tostring(value) .. " but was " ..
            tostring(actualValue) .. ".";
    assert(condition, errorMessage);

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

local function load()
    memory.clear();
    memory.load(objectCode.origin, objectCode.binaryOutput);
    cpu.programCounter = objectCode.origin;

    return {
        step = apiEnv.step;
    };
end

function assemble(code)
    objectCode = assembler.assemble(code);

    return {
        load = load;
    };
end