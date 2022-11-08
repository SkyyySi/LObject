local setmetatable = setmetatable
local getmetatable = getmetatable
local tostring = tostring
local tonumber = tonumber

local class = {}
local mt = {}
mt.__index = mt
setmetatable(class, mt)

do
	class.Object = {
		__init = function(self, ...) end,
		__name = "LObject Object",
	}
	class.Object.__index = class.Object
	local obj_mt = {
		__tostring = function(self)
			return "<class '"..self.__name.."'>"
		end,
	}
	obj_mt.__index = obj_mt
	setmetatable(class.Object, obj_mt)
end

do
	function class.try_lookup(obj, field)
		for k, v in pairs(obj) do
			if k == field then
				return v
			end
		end
	end

	function class.try_lookup_call(obj, field, ...)
		local fn = class.try_lookup(obj, field)
		if fn then
			return fn(...)
		end
	end

	local lookup_mt = {}
end

function mt:new(args)
	args.base = args.base or {}
	args.base.__index = args.base.__index or args.base

	local new_class = {
		__init = args.init,
		__base = args.base,
		__name = args.name,
	}

	function new_class.new(cls, ...)
		local new_self = {
			__class_meta = {}
		}

		local addr = tostring(new_self):match("table: (0x[0-9a-f]*)")
		if addr and addr ~= "" then
			new_self.__class_meta.__addr = addr

			if not args.base.__tostring then
				function args.base:__tostring()
					return "<"..new_class.__name.." object at "..new_self.__class_meta.__addr..">"
				end
			end
		end

		setmetatable(new_self, args.base)
		cls.__init(new_self, ...)
		return new_self
	end

	setmetatable(new_class, class.Object)

	args.base.__class = new_class
	return new_class
end

function mt:__call(...)
	return self:new(...)
end

return class
