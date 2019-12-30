function onAt(pos)
    return bit.blshift(1, pos);
end

function getAt(int, pos)
    return bit.blogic_rshift(bit.band(int, onAt(pos)), pos);
end

function setOnAt(int, pos)
    return bit.bor(int, onAt(pos));
end

function setOffAt(int, pos)
    return bit.band(int, bit.bnot(onAt(pos)));
end