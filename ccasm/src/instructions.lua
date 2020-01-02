assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");
apiLoader.loadIfNotPresent("/ccasm/src/operandTypes.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/operandUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/registers.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/logger.lua");

local apiEnv = getfenv();
--MOVE------------------------------------------------------------------
apiEnv.moveByte = {
    byteValue = 0,
    numOperands = 2,
    verifyEach = function(operand)
        if operand.definition ~= operandTypes.symbolicAddress then
            local condition = operand.sizeInBytes == 1;
            local errorMessage = "moveByte: Operand size " .. operand.sizeInBytes .. " > 1.";
            assert(condition, errorMessage);
        end
    end,
    verifyAll = function(operand1, operand2)
        local condition = not (operand1.definition == operandTypes.symbolicAddress and
                        operand2.definition == operandTypes.symbolicAddress);
        local errorMessage = "moveByte: Cannot move directly between direct or indirect addresses.";
        assert(condition, errorMessage);
    end,
    execute = function(from, to)
        operandUtils.byte(to).set(operandUtils.byte(from).get());
    end,
};
apiEnv.moveWord = {
    byteValue = 1,
    numOperands = 2,
    verifyEach = function(operand)
        if operand.definition ~= operandTypes.symbolicAddress then
            local condition = operand.sizeInBytes <= 2;
            local errorMessage = "moveWord: Operand size " .. operand.sizeInBytes .. " > 2.";
            assert(condition, errorMessage);
        end
    end,
    verifyAll = function(operand1, operand2)
        local condition = not (operand1.definition == operandTypes.symbolicAddress and
                        operand2.definition == operandTypes.symbolicAddress);
        local errorMessage = "moveWord: Cannot move directly between direct or indirect addresses addresses.";
        assert(condition, errorMessage);
    end,
    execute = function(from, to)
        operandUtils.word(to).set(operandUtils.word(from).get());
    end,
};
apiEnv.moveLong = {
    byteValue = 2,
    numOperands = 2,
    verifyEach = function(operand)
        if operand.definition ~= operandTypes.symbolicAddress then
            local condition = operand.sizeInBytes <= 4;
            local errorMessage = "moveLong: Operand size " .. operand.sizeInBytes .. " > 4.";
            assert(condition, errorMessage);
        end
    end,
    verifyAll = function(from, to)
        assert(
            from.definition ~= operandTypes.symbolicAddress or
            to.definition ~= operandTypes.symbolicAddress,
            "moveLong: Cannot move directly between direct or indirect addresses."
        );
    end,
    execute = function(from, to)
        operandUtils.long(to).set(operandUtils.long(from).get());
    end,
};
--ADDITION--------------------------------------------------------------
apiEnv.addByte = {
    byteValue = 3,
    numOperands = 2,
    individualOperandVerifiers = {
        sizeShouldBeOneByte = function(operand)
            if operand.definition ~= operand.symbolicAddress then
                assert(
                    operand.sizeInBytes == 1,
                    "addByte: operand must be 1 byte"
                );
            end
        end
    },
    groupOperandVerifiers = {
        fromMustBeImmediateDataOrDataRegister = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                "addByte: source must be data register."
            );
        end,
        
        destinationMustBeDataRegister = function(from, to)
            assert(
                to.definition == operandTypes.dataRegister,
                "addByte: destination must be a data register."
            );
        end,
    },
    execute = function(from, to)
        local fromData = operandUtils.byte(from).get();
        local toData = operandUtils.byte(to).get();
        local sum = tableUtils.fitToSize(integer.addBytes(fromData, toData), 1);
        operandUtils.byte(to).set(sum);
    end,
};
apiEnv.addWord = {
    byteValue = 4,
    numOperands = 2,
    individualOperandVerifiers = {
        sizeShouldBeAtMostTwoBytes = function(operand)
            assert(operand.sizeInBytes <= 2, "addWord: Operand must be 2 bytes.");
        end,
    },
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
    },
    execute = function(from, to)
        local sum = integer.addBytes(operandUtils.word(from).get(), operandUtils.word(to).get());
        operandUtils.word(to).set(tableUtils.fitToSize(sum, 2));
    end,
};
apiEnv.addLong = {
    byteValue = 5,
    numOperands = 2,
    groupOperandVerifiers = {
        sourceMustBeImmediateDataOrDataRegister = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                "addLong: source must be immediate data or data register."
            );
        end,
        destinationMustBeDataRegister = function(from, to)
            assert(to.definition == operandTypes.dataRegister, "addLong: destination must be data register.");
        end,
    },
    execute = function(from, to)
        local sum = integer.addBytes(operandUtils.long(from).get(), operandUtils.long(to).get());
        operandUtils.long(to).set(tableUtils.trimToSize(sum, 4));
    end,
};
--SUBTRACTION-----------------------------------------------------------
apiEnv.subByte = {
    byteValue = 6,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes == 1, "subByte: Operand must be 1 byte.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "subByte: Source must be immediate data or data reigster."
            );
            assert(to.definition == operandTypes.dataRegister, "subByte: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local fromByte = operandUtils.byte(from).get();
        local toByte = operandUtils.byte(to).get();
        local difference = integer.subtractBytes(toByte, fromByte);
        operandUtils.byte(to).set(tableUtils.fitToSize(difference, 1));
    end,
};
apiEnv.subWord = {
    byteValue = 7,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes <= 2, "subWord: Operand must be at most 2 bytes.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "subWord: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "subWord: Destination must be data register.");
        end,
    },

    execute = function(from, to)
        local fromWord = operandUtils.word(from).get();
        local toWord = operandUtils.word(to).get();
        local difference = integer.subtractBytes(toWord, fromWord);
        operandUtils.word(to).set(tableUtils.fitToSize(difference, 2));
    end,
};
apiEnv.subLong = {
    byteValue = 8,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes <= 4, "subLong: Operand must be at most 4 bytes.");
        end
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "subLong: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "subLong: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local fromLong = operandUtils.long(from).get();
        local toLong = operandUtils.long(to).get();
        local difference = integer.subtractBytes(toLong, fromLong);
        operandUtils.long(to).set(tableUtils.fitToSize(difference, 4));
    end,
};
--MULTIPLICATION--------------------------------------------------------
apiEnv.mulByte = {
    byteValue = 9;
    numOperands = 2;
    individualOperandVerifiers = {
        operandMustBeOneByte = function(operand)
            assert(operand.sizeInBytes == 1, "mulByte: Operand must be one byte.");
        end,
    },
    groupOperandVerifiers = {
        sourceVerifier = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                "mulByte: Source must be data register or immediate data."
            );
        end,
        destinationVerifier = function(from, to)
            assert(to.definition == operandTypes.dataRegister, "mulByte: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local product = integer.multiplyBytes(
            operandUtils.byte(from).get(),
            operandUtils.byte(to).get()
        );
        operandUtils.byte(to).set(tableUtils.fitToSize(product, 1));
    end,
};
apiEnv.mulWord = {
    byteValue = 10,
    numOperands = 2,
    individualOperandVerifiers = {
        operandMustBeTwoBytes = function(operand)
            assert(operand.sizeInBytes <= 2, "mulWord: Operand must be at most 2 bytes.");
        end,
    },
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
    },
    execute = function(from, to)
        local product = integer.multiplyBytes(
            operandUtils.word(from).get(),
            operandUtils.word(to).get()
        );
        operandUtils.word(to).set(tableUtils.fitToSize(product, 2));
    end,
};
apiEnv.mulLong = {
    byteValue = 11,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes <= 4, "mulLong: Operand must be at most 4 bytes.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.dataRegister or
                from.definition == operandTypes.immediateData,
                "mulLong: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "mulLong: Destination must be data register.");
        end
    },
    execute = function(from, to)
        local product = integer.multiplyBytes(
            operandUtils.long(from).get(),
            operandUtils.long(to).get()
        );
        operandUtils.long(to).set(tableUtils.fitToSize(product, 4));
    end,
};
--DIVISION-------------------------------------------------
apiEnv.divByte = {
    byteValue = 12,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes == 1, "divByte: Operand must be 1 byte.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "divByte: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "divByte: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local quotient = integer.divideBytes(
            operandUtils.byte(from).get(),
            operandUtils.byte(to).get()
        );
        operandUtils.byte(to).set(tableUtils.fitToSize(quotient, 1));
    end,
};
apiEnv.divWord = {
    byteValue = 13,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes <= 2, "divWord: Operand must be at most 2 bytes.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "divWord: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "divWord: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local quotient = integer.divideBytes(
            operandUtils.word(from).get(),
            operandUtils.word(to).get()
        );
        operandUtils.word(to).set(tableUtils.fitToSize(quotient, 2));
    end,
};
apiEnv.divLong = {
    byteValue = 14,
    numOperands = 2,
    individualOperandVerifiers = {
        verify = function(operand)
            assert(operand.sizeInBytes <= 4, "divLong: Operand must be at most 4 bytes.");
        end,
    },
    groupOperandVerifiers = {
        verify = function(from, to)
            assert(
                from.definition == operandTypes.immediateData or
                from.definition == operandTypes.dataRegister,
                "divLong: Source must be immediate data or data register."
            );
            assert(to.definition == operandTypes.dataRegister, "divLong: Destination must be data register.");
        end,
    },
    execute = function(from, to)
        local quotient = integer.divideBytes(
            operandUtils.long(from).get(),
            operandUtils.long(to).get()
        );
        operandUtils.long(to).set(tableUtils.fitToSize(quotient, 4));
    end,
};
--COMPARISON------------------------------------------------------------
apiEnv.cmpByte = {
    byteValue = 15,
    numOperands = 2,
    verifyEach = function(operand)
        assert(operand.sizeInBytes == 1, "cmpByte: Operand must be 1 byte.");
    end,
    verifyAll = function(operand1, operand2)
        assert(
            operand1.definition == operandTypes.dataRegister or
            operand1.definition == operandTypes.immediateData,
            "cmpByte: Left operand must be immediate data or data register."
        );
        assert(
            operand2.definition == operandTypes.immediateData or
            operand2.definition == operandTypes.dataRegister,
            "cmpByte: Right operand must be immediate data or data register."
        );
    end,
    execute = function(left, right)
        registers.compare(
            integer.getSignedIntegerFromBytes(operandUtils.byte(left).get()),
            integer.getSignedIntegerFromBytes(operandUtils.byte(right).get())
        );
    end,
};
apiEnv.cmpWord = {
    byteValue = 16,
    numOperands = 2,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "cmpWord: Operand must be at most 2 bytes.");
    end,
    verifyAll = function(left, right)
        assert(
            left.definition == operandTypes.immediateData or
            left.definition == operandTypes.dataRegister,
            "cmpWord: Left operand must be immediate data or data register."
        );
        assert(
            right.definition == operandTypes.immediateData or
            right.definition == operandTypes.dataRegister,
            "cmpWord: Right operand must be immediate data or data register."
        );
    end,
    execute = function(left, right)
        registers.compare(
            integer.getSignedIntegerFromBytes(operandUtils.word(left).get()),
            integer.getSignedIntegerFromBytes(operandUtils.word(right).get())
        );
    end,
};
apiEnv.cmpLong = {
    byteValue = 17,
    numOperands = 2,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 4, "cmpLong: Operand must be at most 4 bytes.");
    end,
    verifyAll = function(left, right)
        assert(
            left.definition == operandTypes.immediateData or
            left.definition == operandTypes.dataRegister,
            "cmpLong: Left operand must be immediate data or data register."
        );
        assert(
            right.definition == operandTypes.immediateData or
            right.definition == operandTypes.dataRegister,
            "cmpLong: Right operand must be immediate data or data register."
        );
    end,
    execute = function(left, right)
        registers.compare(
            integer.getSignedIntegerFromBytes(operandUtils.long(left).get()),
            integer.getSignedIntegerFromBytes(operandUtils.long(right).get())
        );
    end,
};
--BRANCHING-------------------------------------------------------------
apiEnv.beq = {
    byteValue = 18,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "beq: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "beq: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bne = {
    byteValue = 19,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bne: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bne: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.blt = {
    byteValue = 20,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "blt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 and 
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.ble = {
    byteValue = 21,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "blt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "ble: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 or
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 1 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bgt = {
    byteValue = 22,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bgt: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bgt: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 0 and
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
apiEnv.bge = {
    byteValue = 23,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.sizeInBytes <= 2, "bge: Operand must be at most 2 bytes.");
        assert(
            operand.definition == operandTypes.symbolicAddress or
            operand.definition == operandTypes.immediateData,
            "bge: Operand must be a symbolic address or immediate data."
        );
    end,
    execute = function(operand)
        if bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_COMPARISON) == 1 or
        bitUtils.getAt(registers.getStatusRegister(), registers.STATUS_NEGATIVE) == 0 then
            registers.setProgramCounter(operandUtils.absoluteAddress(operand));
        end
    end,
};
--SUBROUTINES----------------------------------------------
apiEnv.bsr = {
    byteValue = 24,
    numOperands = 1,
    verifyEach = function(operand)
        assert(operand.definition == operandTypes.symbolicAddress, "bsr: Operand must be symbolic address.");
    end,
    execute = function(operand)
        -- Program counter will be at the next instruction, since cpu will read the instruction and operand before executing.
        registers.pushStack(integer.getBytesForInteger(2, registers.getProgramCounter()));
        registers.setProgramCounter(operandUtils.absoluteAddress(operand));
    end,
};
apiEnv.ret = {
    byteValue = 25,
    numOperands = 0,
    execute = function()
        registers.setProgramCounter(integer.getIntegerFromBytes(registers.popStackWord()));
    end,
};
-----------------------------------------------------------
--DEFINITION MAP-------------------------------------------
local function isInstructionDefinition(definition)
    return type(definition) == "table" and
            definition.byteValue ~= nil and
            definition.numOperands ~= nil;
end

local function throwInstructionRedefinitionError(byteValue)
    local message = "Instruction byte value " .. tostring(byteValue) .. " cannot be shared.";
    error(message);
end

local byteToDefinitionMap = {};
for name, definition in pairs(getfenv()) do
    if isInstructionDefinition(definition) then
        if byteToDefinitionMap[definition.byteValue] ~= nil then
            throwInstructionRedefinitionError(definition.byteValue);
        else
            byteToDefinitionMap[definition.byteValue] = definition;
        end
    end
end

function definitionFromByte(instructionByte)
    return byteToDefinitionMap[instructionByte];
end