assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 9;
numOperands = 2;

groupOperandVerifiers = {
    sourceCannotBeAddressRegister = function(from, to)
        assert(from.definition ~= operandTypes.addressRegister, "mulByte: Source cannot be address register.");
    end,
    destinationCannotBeAddressRegister = function(from, to)
        assert(to.definition ~= operandTypes.addressRegister, "mulByte: Destination cannot be address register.");
    end
};

function execute(from, to)
    local product = integer.multiplyBytes(
        operandUtils.byte(from).get(),
        operandUtils.byte(to).get()
    );
    operandUtils.byte(to).set(tableUtils.fitToSize(product, 1));
end