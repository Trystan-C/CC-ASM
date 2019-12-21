assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");

byteValue = 4;
numOperands = 2;

individualOperandVerifiers = {
    sizeShouldBeAtMostTwoBytes = function(operand)
        assert(operand.sizeInBytes <= 2, "addWord: Operand must be 2 bytes.");
    end,
};

groupOperandVerifiers = {
    sourceMustBeDataRegisterOrImmediateData = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "addWord: source must be data register or immediate data."
        );
    end,
    destinationMustBeDataRegister = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "addWord: destination must be data register or immediate data.");
    end,
};

function execute(from, to)
    local sum = integer.addBytes(operandUtils.word(from).get(), operandUtils.word(to).get());
    operandUtils.word(to).set(tableUtils.fitToSize(sum, 2));
end