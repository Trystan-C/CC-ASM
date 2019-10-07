assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

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
        tableUtils.zeroPadFrontToSize(from.valueBytes, 2); -- TODO: Codify word width, so we don't have to use inline constants.
        if to.definition == operandTypes.dataRegister then
            local toRegisterId = to.valueBytes[1];
            registers.dataRegisters[toRegisterId].setWord(from.valueBytes);
        elseif to.definition == operandTypes.addressRegister then
            local toRegisterId = to.valueBytes[1];
            registers.addressRegisters[toRegisterId].setWord(from.valueBytes);
        end
    end
end
