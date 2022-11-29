local BLIPS = nil

BLIPS = {
    Add = function(self)
        
    end,
    Remove = function(self)
        
    end,
    RemoveAll = function(self)
        
    end,
    SetWayPoint = function(self)
        
    end,
    Disable = function(self)
        
    end,
    Enable = function(self)
        
    end,
    ShortData = function(self, data)
        for resource, data in pairs(data) do
            if not BLIPS.Data[resource] then BLIPS.Data[resource] = {} end
            for category, data in pairs(data) do
                if not BLIPS.Data[resource][category] then BLIPS.Data[resource][category] = {} end
                for id, data in pairs(data) do
                    if not BLIPS.Data[resource][category][id] then
                        BLIPS.Data[resource][category][id] = data
                    end
                end
            end
        end
    end,
    Data = {}
}

-- Handlers
AddEventHandler('esx:onPlayerLogout', BLIPS.RemoveAll)

-- Events
RegisterNetEvent('esx_blips:Collector', function(data)
    BLIPS:ShortData(data)
end)

RegisterNetEvent('esx_blips:RemoveAll', BLIPS.RemoveAll)

RegisterCommand('print', function (source, args, raw)
    print(json.encode(BLIPS.Data,{indent=true}))
end, false)

function ParsingTable_cl(node)
    --  print('inside')
      local cache, stack, output = {},{},{}
      local depth = 1
      local output_str = "{\n"
  
          while true do
              local size = 0
              for k,v in pairs(node) do
                  size = size + 1
              end
  
              local cur_index = 1
              for k,v in pairs(node) do
                  if (cache[node] == nil) or (cur_index >= cache[node]) then
  
                      if (string.find(output_str,"}",output_str:len())) then
                          output_str = output_str .. ",\n"
                      elseif not (string.find(output_str,"\n",output_str:len())) then
                          output_str = output_str .. "\n"
                      end
  
                      -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                      table.insert(output,output_str)
                      output_str = ""
  
                      local key
                      if (type(k) == "number" or type(k) == "boolean") then
                          key = "^2["..tostring(k).."]"
                      else
                          key = "^2['"..tostring(k).."']"
                      end
  
                      if (type(v) == "number" or type(v) == "boolean") then
                          output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                      elseif (type(v) == "table") then
                          output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                          table.insert(stack,node)
                          table.insert(stack,v)
                          cache[node] = cur_index+1
                          break
                      else
                          output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                      end
  
                      if (cur_index == size) then
                          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "^2}"
                      else
                          output_str = output_str .. ","
                      end
                  else
                  -- close the table
                      if (cur_index == size) then
                          output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "^2}"
                      end
                  end
  
                  cur_index = cur_index + 1
              end
  
              if (size == 0) then
                  output_str = ''..output_str .. "\n" .. string.rep('\t',depth-1) .. "^2}"
              end
  
              if (#stack > 0) then
                  node = stack[#stack]
                  stack[#stack] = nil
                  depth = cache[node] == nil and depth + 1 or depth - 1
              else
                  break
              end
          end
      -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
      table.insert(output,output_str)
      output_str = table.concat(output)
      
      print(string.format("^5[Script %s is parsing a table to console]", GetCurrentResourceName()))
      print(string.format("\n ^2 Table = %s ", output_str))
      print('\n ^5===============================================================')
end