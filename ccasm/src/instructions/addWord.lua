assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");

byteValue = 4;
numOperands = 2;

individualOperandVerifiers = {};
groupOperandVerifiers = {};

function execute(from, to)
    local sum = integer.addBytes(operandUtils.word(from).get(), operandUtils.word(to).get());
    operandUtils.word(to).set(tableUtils.fitToSize(sum, 2));
end