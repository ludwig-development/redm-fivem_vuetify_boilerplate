function _L(key)
    return L?[key] or DE?[key] or "Localisation missing ! Key:" .. tostring(key)
end
