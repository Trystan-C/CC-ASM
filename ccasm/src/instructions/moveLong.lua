assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

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
        elseif to.definition == operandTypes.addressRegister then
            local toRegisterId = to.valueBytes[1];
            tableUtils.zeroPadFrontToSize(from.valueBytes, registers.registerWidthInBytes);
            registers.addressRegisters[toRegisterId].setLong(from.valueBytes);
        end
    elseif from.definition == operandTypes.symbolicAddress then
        -- from.valueBytes contains the relative address in the objectCode binary output.
        -- Start of data is going to be at programOrigin + relativeAddress. Do we have access to this?
        -- Maybe instead set relative address bytes in operand when object code is loaded into memory.
    end
end
