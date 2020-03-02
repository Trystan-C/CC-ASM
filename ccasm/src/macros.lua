assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

origin = {
    numOperands = 1;
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.immediateData, "origin: Operand must be immediate data.");
        assert(operand.sizeInBytes >= 1 and operand.sizeInBytes <= 2, "origin: Operand size should be at most 2 bytes, was: " .. tostring(operand.sizeInBytes));
    end,
    assemble = function(objectCode, operands)
        objectCode.origin = ccasm.integer.getIntegerFromBytes(operands[1].valueBytes);
        return {};
    end,
};

declareByte = {
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.immediateData, "declareByte: Operand must be immediate data.");
        assert(operand.sizeInBytes == 1, "declareByte: Operand size should be 1 byte, was: " .. tostring(operand.sizeInBytes));
    end,
    assemble = function(objectCode, operands)
        return operands[1].valueBytes;
    end,
};

declareWord = {
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.immediateData, "declareWord: Operand must be immediate data.");
        assert(operand.sizeInBytes <= 2, "declareWord: Operand size should be at most 2 bytes, was: " .. tostring(operand.sizeInBytes));
    end,
    assemble = function(objectCode, operands)
        return ccasm.tableUtils.zeroPadFrontToSize(operands[1].valueBytes, 2);
    end,
};

declareLong = {
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.immediateData, "declareLong: Operand must be immediate data.");
        assert(operand.sizeInBytes <= 4, "declareLong: Operand size should be at most 4 bytes, was: " .. tostring(operand.sizeInBytes));
    end,
    assemble = function(objectCode, operands)
        return ccasm.tableUtils.zeroPadFrontToSize(operands[1].valueBytes, 4);
    end,
};

declareString = {
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == ccasm.operandTypes.stringConstant, "declareString: Operand must be a string constant.");
    end,
    assemble = function(objectCode, operands)
        return operands[1].valueBytes;
    end
};
