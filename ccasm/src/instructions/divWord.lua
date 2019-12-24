assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 13;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes <= 2, "divWord: Operand must be at most 2 bytes.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "divWord: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "divWord: Destination must be data register.");
    end,
};

function execute(from, to)
    local quotient = integer.divideBytes(
        operandUtils.word(from).get(),
        operandUtils.word(to).get()
    );
    operandUtils.word(to).set(tableUtils.fitToSize(quotient, 2));
end