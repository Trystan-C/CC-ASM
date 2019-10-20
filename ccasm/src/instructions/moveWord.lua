assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");

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
    operandUtils.word(to).set(operandUtils.word(from).get());
end
