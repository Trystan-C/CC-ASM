function assertIsTable(tbl)
    local condition = type(tbl) == "table";
    local message = "Expected " .. tostring(tbl) .. " to be a table.";
    assert(condition, message);
end

function countKeys(tbl)
    local count = 0;
    for _, __ in pairs(tbl) do
        count = count + 1;
    end
    return count;
end

function assertTableSizesAreEqual(...)
    local tables = { ... };
    local size = nil;

    for _, tbl in ipairs(tables) do
        local tblSize = tableUtils.countKeys(tbl);
        if not size then
            size = tblSize;
        else
            local message = "Expected " .. tostring(tbl) .. " to have size " .. tostring(size) .. " but was " .. tostring(tblSize) .. ".";
            local condition = tblSize == size;
            assert(condition, message);
        end
    end
end

function deepCopy(tbl)
    local copy = {};
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = deepCopy(value);
        else
            copy[key] = value;
        end
    end
    return copy;
end

function zeros(n)
    local result = {};
    for i = 1, n do
        result[i] = 0;
    end
    return result;
end

function zeroPadFrontToSize(tbl, size)
    assertIsTable(tbl);
    while #tbl < size do
        table.insert(tbl, 1, 0);
    end
    return tbl;
end
