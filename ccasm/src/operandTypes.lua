assert(os.loadAPI("/ccasm/src/cpu.lua"));

invalidType = {};

dataRegister = {
    typeByte = 0,
    sizeInBytes = 1,
    pattern = "[dD](%d)"
};

dataRegister.parseValueAsBytes = function(token)
    local registerId = token:match(dataRegister.pattern);

    if registerId == nil then
        local errorMessage = token .. " is not a data register.";
        error(errorMessage);
    end

    return { cpu.dataRegisters[tonumber(registerId)].id };
end

function getType(token)
    local function tokenTypeIs(definition)
        return token:match(definition.pattern) ~= nil;
    end

    if tokenTypeIs(dataRegister) then
        return "dataRegister";
    end
end