function recursivelySerializeTable(tbl)
    local function serializeTableKey(k)
        local result = "[";
        if type(k) == "string" then
            result = result .. "\"" .. k .. "\"";
        else
            result = result .. tostring(k);
        end
        return result .. "]:";
    end

    local result = "{";
    for k, v in pairs(tbl) do
        result = result .. serializeTableKey(k);
        if type(v) == "table" then
            result = result .. recursivelySerializeTable(v);
        elseif type(v) == "string" then
            result = result .. "\"" .. v .. "\"";
        else
            result = result .. tostring(v);
        end
        result = result .. ",";
        end
    return (result:len() > 1 and result:sub(1, result:len()-1) or result) .. "}";
end

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
            local message = "Expected " .. recursivelySerializeTable(tbl) .. " to have size " .. tostring(size) .. " but was " .. tostring(tblSize) .. ".";
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

function trimToSize(tbl, size)
    assertIsTable(tbl);
    local tblSize = countKeys(tbl);
    local result = {};
    for i = 1, size do
        result[size - i + 1] = tbl[tblSize - i + 1];
    end
    return result;
end

function fitToSize(tbl, size)
    assertIsTable(tbl);
    local tblSize = countKeys(tbl);
    if tblSize > size then
        return trimToSize(tbl, size);
    elseif tblSize < size then
        return zeroPadFrontToSize(tbl, size);
    end
    return tbl;
end
