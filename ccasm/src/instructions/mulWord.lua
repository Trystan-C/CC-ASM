assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 10;
numOperands = 2;

individualOperandVerifiers = {
    operandMustBeTwoBytes = function(operand)
        assert(operand.sizeInBytes <= 2, "mulWord: Operand must be at most 2 bytes.");
    end,
};

groupOperandVerifiers = {
    sourceVerifier = function(from, to)
        assert(
            from.definition == operandTypes.dataRegister or
            from.definition == operandTypes.immediateData,
            "mulWord: Source must be immediate data or data register."
        );
    end,
    destinationVerifier = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "mulWord: Destination must be data register.");
    end
};

function execute(from, to)
    local product = integer.multiplyBytes(
        operandUtils.word(from).get(),
        operandUtils.word(to).get()
    );
    operandUtils.word(to).set(tableUtils.fitToSize(product, 2));
end