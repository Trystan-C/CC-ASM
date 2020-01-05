assert(os.loadAPI("/ccasm/src/utils/apiLoader.lua"));
apiLoader.loadIfNotPresent("/ccasm/src/utils/tableUtils.lua");
apiLoader.loadIfNotPresent("/ccasm/src/utils/integer.lua");

function errorToBeThrown(func, case)
    local success = pcall(func);
    local expectationIsMet = not success;
    local errorMessage = "Expected error to be thrown";
    if case then
        errorMessage = errorMessage .. " for case " .. tostring(case);
    end
    assert(expectationIsMet, errorMessage);
end

function errorsToBeThrown(...)
    local funcs = { ... };
    for caseNum, func in ipairs(funcs) do
        errorToBeThrown(func, caseNum);
    end
end

local function assertHasKey(tbl, key)
    local condition = tbl[key] ~= nil;
    local message = "Expected table " .. tostring(tbl) .. " to have key \"" .. tostring(key) .. "\".";
    assert(condition, message);
end

local function equals(val1, val2)
    local condition = val1 == val2;
    local message = "Expected " .. tostring(val1) .. " to equal " .. tostring(val2) .. ".";
    assert(condition, message);
end

local function deepEquals(tbl1, tbl2)
    tableUtils.assertIsTable(tbl1);
    tableUtils.assertIsTable(tbl2);
    tableUtils.assertTableSizesAreEqual(tbl1, tbl2);

    for key, value in pairs(tbl1) do
        assertHasKey(tbl2, key);
        if type(value) == "table" then
            deepEquals(value, tbl2[key]);
        else
            equals(value, tbl2[key]);
        end
    end
end

function value(val1)
    return {
        toEqual = function(val2)
            return equals(val1, val2);
        end,
        toDeepEqual = function(tbl2)
            return deepEquals(val1, tbl2);
        end
    };
end
