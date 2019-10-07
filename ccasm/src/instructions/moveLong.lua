assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
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
    if from.definition == operandTypes.immediateData then
        if to.definition == operandTypes.dataRegister then
            local toRegisterId = to.valueBytes[1];
            tableUtils.zeroPadFrontToSize(from.valueBytes, registers.registerWidthInBytes);
            registers.dataRegisters[toRegisterId].setLong(from.valueBytes);
        end
    end
end
