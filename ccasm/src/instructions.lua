assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local apiEnv = getfenv();
for _, fileName in pairs(fs.list("/ccasm/src/instructions")) do
    apiLoader.loadIfNotPresent("/ccasm/src/instructions/" .. fileName);
    local instructionName = fileName:match("^(.+)%.lua$");
    apiEnv[instructionName] = _G[instructionName];
end

local function isInstructionDefinition(definition)
    return type(definition) == "table" and
            definition.byteValue ~= nil and
            definition.numOperands ~= nil;
end

byteToDefinitionMap = {};

local function throwInstructionRedefinitionError(byteValue)
    local message = "Instruction byte value " .. tostring(byteValue) .. " cannot be shared.";
    error(message);
end

for name, definition in pairs(getfenv()) do
    if isInstructionDefinition(definition) then
        if byteToDefinitionMap[definition.byteValue] ~= nil then
            throwInstructionRedefinitionError(definition.byteValue);
        else
            byteToDefinitionMap[definition.byteValue] = definition;
        end
    end
end