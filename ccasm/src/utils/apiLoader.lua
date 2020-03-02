local function assertAbsoluteApiPathIsValid(absoluteApiPath)
    assert(type(absoluteApiPath) == "string", "Expected api path to be a string, was " .. tostring(absoluteApiPath));
    assert(fs.exists(absoluteApiPath), "Expected api at " .. absoluteApiPath .. " to exist.");
    assert(not fs.isDir(absoluteApiPath), "Expected api at " .. absoluteApiPath .. " to be a file.");
end

local function isApiLoaded(apiName)
    return _G.ccasm[apiName] ~= nil;
end

function loadIfNotPresent(absoluteApiPath)
    assertAbsoluteApiPathIsValid(absoluteApiPath);
    local pathHasLuaExtension = absoluteApiPath:match("%.lua$") ~= nil;
    local apiName = nil;
    if pathHasLuaExtension then
        apiName = absoluteApiPath:match(".*/(%w+)%.lua$");
    else
        apiName = absoluteApiPath:match(".*/(%w+)$");
    end

    if not isApiLoaded(apiName) then
        local success = os.loadAPI(absoluteApiPath)
        if not success then
            error("Failed to load API " .. apiName .. " at " .. absoluteApiPath);
        end
        _G.ccasm[apiName] = _G[apiName];
        _G[apiName] = nil;
    end
end