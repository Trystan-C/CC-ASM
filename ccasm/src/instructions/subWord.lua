assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 7;
numOperands = 2;

individualOperandVerifiers = {
    verify = function(operand)
        assert(operand.sizeInBytes <= 2, "subWord: Operand must be at most 2 bytes.");
    end,
};

groupOperandVerifiers = {
    verify = function(from, to)
        assert(
            from.definition == operandTypes.immediateData or
            from.definition == operandTypes.dataRegister,
            "subWord: Source must be immediate data or data register."
        );
        assert(to.definition == operandTypes.dataRegister, "subWord: Destination must be data register.");
    end,
};

function execute(from, to)
    local fromWord = operandUtils.word(from).get();
    local toWord = operandUtils.word(to).get();
    local difference = integer.subtractBytes(toWord, fromWord);
    operandUtils.word(to).set(tableUtils.fitToSize(difference, 2));
end