assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");

byteValue = 7;
numOperands = 2;

groupOperandVerifiers = {
    sourceCannotBeSymbolicAddress = function(from, to)
        assert(from.definition ~= operandTypes.symbolicAddress, "subWord: Source cannot be symbolic address.");
    end,

    destinationMustBeDataRegister = function(from, to)
        assert(to.definition == operandTypes.dataRegister, "subWord: Destination must be data register.");
    end,
};

function execute(from, to)
    local fromWord = operandUtils.word(from).get();
    local toWord = operandUtils.word(to).get();
    local difference = integer.subtractBytes(toWord, fromWord);
    operandUtils.word(to).set(tableUtils.fitToSize(difference, 2));