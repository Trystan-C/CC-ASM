assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 14;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes <= 4, "divLong: Operand must be at most 4 bytes.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "divLong: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "divLong: Destination must be data register.");
    end,
};

function execute(from, to)
    local quotient = integer.divideBytes(
        operandUtils.long(from).get(),
        operandUtils.long(to).get()
    );
    operandUtils.long(to).set(tableUtils.fitToSize(quotient, 4));
end