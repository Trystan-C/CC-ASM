local function assertFormatIsValid(format)
    assert(type(format) == "string", "Log formats must be valid strings.");
end

local function getCharacterArray(str)
    local chars = {};
    for char in str:gmatch(".") do
        table.insert(chars, char);
    end
    return chars;
end

local function serializeTableKey(k)
    local result = "[";
    if type(k) == "string" then
        result = result .. "\"" .. k .. "\"";
    else
        result = result .. tostring(k);
    end
    return result .. "]:";
end

local function recursivelySerializeTable(tbl)
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

local function serializeObject(object)
    if type(object) == "table" then
        return recursivelySerializeTable(object);
    else
        return tostring(object);
    end
end

local function formatMessage(format, objects)
    assertFormatIsValid(format);
    local message = "";
    local objectIndex = 1;
    local chars = getCharacterArray(format);
    local i = 1;
    while i <= #chars do
        if chars[i] == "%" and i < #chars and chars[i + 1] == "%" then
            if objectIndex <= #objects then
                message = message .. serializeObject(objects[objectIndex]);
                objectIndex = objectIndex + 1;
            end
            i = i + 1;
        else
            message = message .. chars[i];
        end
        i = i + 1;
    end
    return message:len() > 0 and message or format;
end

function info(format, ...)
    local message = formatMessage("[INFO]> " .. format, { ... });
    print(message);
end