include Microsoft::Scripting::Silverlight

def load_assembly_from_path(path)
  DynamicApplication.current.runtime.host.
  platform_adaptation_layer.
  load_assembly_from_path(path)
end

load_assembly_from_path "System.Json.dll"
require 'System.Json'

include System

module System::Json
  class JsonValue
    def method_missing(index)
      index = 'id' if index.to_s == 'photo_id'
      item = self.item(index.to_s)
      super if item.nil?
      case item.json_type
        when JsonType.string:  item.to_string.to_s.split("\"").last
        when JsonType.number:  item.to_string.to_s.to_f
        when JsonType.boolean: System::Boolean.parse(item)
        else item
      end
    end

    def inspect
      to_string.to_s
    end
  end
end
