assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 11;
numOperands = 2;

groupOperandVerifiers = {
    sourceCannotBeAddressRegister = function(from, to)
        assert(from.definition ~= operandTypes.addressRegister, "mulLong: Source cannot be address register.");
    end,
    destinationCannotBeAddressRegister = function(from, to)
        assert(to.definition ~= operandTypes.addressRegister, "mulLong: Destination cannot be address register.");
    end
};

function execute(from, to)
    local product = integer.multiplyBytes(
        operandUtils.long(from).get(),
        operandUtils.long(to).get()
    );
    operandUtils.long(to).set(tableUtils.fitToSize(product, 4));
end