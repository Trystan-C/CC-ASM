assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 13;
numOperands = 2;

groupOperandVerifiers = {
    sourceCannotBeAddressRegister = function(from, to)
        assert(from.definition ~= operandTypes.addressRegister, "divWord: Source cannot be address register.");
    end,
    destinationCannotBeAddressRegister = function(from, to)
        assert(to.definition ~= operandTypes.addressRegister, "divWord: Destination cannot be address register.");
    end,
};

function execute(from, to)
    local quotient = integer.divideBytes(
        operandUtils.word(from).get(),
        operandUtils.word(to).get()
    );
    operandUtils.word(to).set(tableUtils.fitToSize(quotient, 2));
end