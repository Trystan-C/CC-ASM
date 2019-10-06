assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

moveByte = {
    byteValue = 0;
    numOperands = 2;
    individualOperandVerifiers = {
        sizeShouldBeOneByte = function(operand)
            if operand.definition ~= operandTypes.symbolicAddress then
                local condition = operand.sizeInBytes == 1;
                local errorMessage = "moveByte: Operand size " .. operand.sizeInBytes .. " ~= 1.";
                assert(condition, errorMessage);
            end
        end
    };
    groupOperandVerifiers = {
        cannotMoveBetweenAddresses = function(operand1, operand2)
            local condition = not (operand1.definition == operandTypes.symbolicAddress and
                              operand2.definition == operandTypes.symbolicAddress);
            local errorMessage = "moveByte: Cannot move directly between direct or indirect addresses addresses.";
            assert(condition, errorMessage);
        end
    };
    execute = function(from, to)
        if from.definition == operandTypes.dataRegister then
            local fromRegisterId = from.valueBytes[1];
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setByte(
                        registers.dataRegisters[fromRegisterId].getByte()
                );
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegisters[toRegisterId].setByte(
                        registers.dataRegisters[fromRegisterId].getByte()
                );
            end
        elseif from.definition == operandTypes.addressRegister then
            local fromRegisterId = from.valueBytes[1];
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setByte(
                        registers.addressRegisters[fromRegisterId].getByte()
                );
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegisters[toRegisterId].setByte(
                        registers.addressRegisters[fromRegisterId].getByte()
                );
            end
        elseif from.definition == operandTypes.immediateData then
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setByte(from.valueBytes[1]); -- TODO: Change to just valueBytes.
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegister[toRegisterId].setByte(from.valueBytes[1]);
            end
        end
    end
};

moveWord = {
    byteValue = 1;
    numOperands = 2;
    individualOperandVerifiers = {
        sizeShouldBeTwoBytes = function(operand)
            if operand.definition ~= operandTypes.symbolicAddress then
                local condition = operand.sizeInBytes <= 2;
                local errorMessage = "moveWord: Operand size " .. operand.sizeInBytes .. " >= 2.";
                assert(condition, errorMessage);
            end
        end
    };
    groupOperandVerifiers = {
      cannotMoveBetweenAddresses = function(operand1, operand2)
            local condition = not (operand1.definition == operandTypes.symbolicAddress and
                              operand2.definition == operandTypes.symbolicAddress);
            local errorMessage = "moveWord: Cannot move directly between direct or indirect addresses addresses.";
            assert(condition, errorMessage);
        end
    };
    execute = function(from, to)
        if from.definition == operandTypes.dataRegister then
            local fromRegisterId = from.valueBytes[1];
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setWord(
                        registers.dataRegisters[fromRegisterId].getWord()
                );
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegisters[toRegisterId].setWord(
                        registers.dataRegisters[fromRegisterId].getWord()
                );
            end
        elseif from.definition == operandTypes.addressRegister then
            local fromRegisterId = from.valueBytes[1];
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setWord(
                        registers.addressRegisters[fromRegisterId].getWord()
                );
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegisters[toRegisterId].setWord(
                        registers.addressRegisters[fromRegisterId].getWord()
                );
            end
        elseif from.definition == operandTypes.immediateData then
            if to.definition == operandTypes.dataRegister then
                local toRegisterId = to.valueBytes[1];
                registers.dataRegisters[toRegisterId].setWord(from.valueBytes);
            elseif to.definition == operandTypes.addressRegister then
                local toRegisterId = to.valueBytes[1];
                registers.addressRegisters[toRegisterId].setWord(from.valueBytes);
            end
        end
    end
};

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