assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/memory.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");

byteValue = 2;
numOperands = 2;

individualOperandVerifiers = {
    sizeShouldBeFourBytes = function(operand)
        if operand.definition ~= operandTypes.symbolicAddress then
            local condition = operand.sizeInBytes <= 4;
            local errorMessage = "moveLong: Operand size " .. operand.sizeInBytes .. " >= 4.";
            assert(condition, errorMessage);
        end
    end
};

groupOperandVerifiers = {
    -- TODO
};

execute = function(from, to)
    operandUtils.long(to).set(operandUtils.long(from).get());
end
