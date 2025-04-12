local function sort_by_natural(nodes)
  local function sorter(left, right)
    if left.name == "." then
      return true
    end
    if right.name == "." then
      return false
    end
    if left.type ~= "directory" and right.type == "directory" then
      return false
    end
    if left.type == "directory" and right.type ~= "directory" then
      return true
    end

    local lname = left.name:lower()
    local rname = right.name:lower()
    if lname == rname then
      return false
    end

    for i = 1, math.max(#lname, #rname) do
      local l, r = lname:sub(i, -1), rname:sub(i, -1)
      local lnum = tonumber(l:match "^[0-9]+")
      local rnum = tonumber(r:match "^[0-9]+")
      if lnum and rnum and lnum ~= rnum then
        return lnum < rnum
      end
      if l:sub(1, 1) ~= r:sub(1, 1) then
        return l < r
      end
    end
  end
  table.sort(nodes, sorter)
end

return {
  sort_by = sort_by_natural,
  renderer = {
    root_folder_label = ":t",
  },
  filters = {
    custom = { "^.git$" },
  },
}
