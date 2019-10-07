assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");
apiLoader.loadIfNotPresent("/ccasm/src/instructions/moveByte.lua");
apiLoader.loadIfNotPresent("/ccasm/src/instructions/moveWord.lua");

local apiEnv = getfenv();
apiEnv.moveByte = moveByte;
apiEnv.moveWord = moveWord;

local function isInstructionDefinition(definition)
    return type(definition) == "table" and
            definition.byteValue ~= nil and
            definition.numOperands ~= nil;
end

byteToDefinitionMap = {};
for name, definition in pairs(getfenv()) do
    if isInstructionDefinition(definition) then
        byteToDefinitionMap[definition.byteValue] = definition;
    end
end