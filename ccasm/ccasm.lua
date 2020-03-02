local srcRoot = "/ccasm/src";
local blacklist = {
    demos = true,
    debug = true,
    run = true,
    assemble = true,
    load = true,
    apiLoader = true,
};

local function getFileNameWithoutExtension(absoluteFilePath)
    return absoluteFilePath:match(".*/(%w+)%.lua$") or absoluteFilePath:match(".*/(%w+)$");
end

local function loadDirectory(absolutePath)
    local files = fs.list(absolutePath);
    for _, fileName in pairs(files) do
        local absoluteFilePath = absolutePath .. '/' .. fileName;
        local nameWithoutExtension = getFileNameWithoutExtension(absoluteFilePath);
        if not blacklist[nameWithoutExtension] then
            if fs.isDir(absoluteFilePath) then
                loadDirectory(absoluteFilePath);
            else
                apiLoader.loadIfNotPresent(absoluteFilePath);
            end
        end
    end
end

_G.ccasm = {};
assert(os.loadAPI(srcRoot .. "/utils/apiLoader.lua"));
print("Loading new CCASM instance...");
loadDirectory(srcRoot);
print("Done.");