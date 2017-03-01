local json = require( "json" )
local M = {}
M.filename = "userdefault.json"

-- internal use
local function saveData( tabel )
   local path = system.pathForFile( M.filename, system.DocumentsDirectory )
   local file = io.open(path, "w")
   if ( file ) then
      print( "saveData: " )
      local jsonSaveGame = json.encode(tabel)
      file:write( jsonSaveGame )
      io.close( file )
      return true
   else
      print( "Error: could not read ", M.filename, "." )
      return false
   end
end

-- Internal use
local function readData( user_default_key,  default_value)
   local path = system.pathForFile( M.filename, system.DocumentsDirectory )
   local contents = ""
   local file = io.open( path, "r" )
   print( "readData path : " .. path )
   if ( file ) then
      -- Read all contents of file into a string
      local contents = file:read( "*a" )
      print( "contents readData: " .. contents )
      if (contents) then
         local jsonRead = json.decode(contents)
         if (jsonRead == nil) then
            print( "Value is nil" )
            io.close(file)
            local tabel = {user_default_key = default_value}
            saveData(tabel)
         else
            jsonRead[user_default_key] = default_value
            io.close( file )
            saveData(jsonRead)
         end
      end
   else
      print( "readData key: " ..user_default_key )
      local jsonRead = {user_default_key = default_value}
      saveData(jsonRead)
   end
end


-- User call this method to save value for particular key
function M.save(user_default_key, value)
	readData(user_default_key, value)
end

-- user call this method to find value for particular key and user also provide default value
-- if there is no value for corresponding key it will return default value
function M.load(user_default_key, default_value)
   local path = system.pathForFile( M.filename, system.DocumentsDirectory )
   local contents = ""
   local file = io.open( path, "r" )
   print( "path : " .. path )
   if ( file ) then
      -- Read all contents of file into a string
      local contents = file:read( "*a" )
      -- print( "contents : " .. contents )
      if (contents) then
      	local jsonRead = json.decode(contents)
      	if (jsonRead == nil) then
      		print( "Value is nil" )
      		io.close(file)
      		M.save(user_default_key, default_value)
      		return default_value
      	end
     	   local value = jsonRead[user_default_key]
         if (value == nil) then
            print( "Value is nil" )
            io.close(file)
            M.save(user_default_key, default_value)
            return default_value
         end
        	print( value )
      	io.close( file )
      	return value
      else
         io.close( file )
         M.save(user_default_key, default_value)
         return default_value
      end
      return nil
   else
      print( "load key:" ..user_default_key )
      M.save(user_default_key, default_value)
      return default_value
   end
   return nil
end

return M
