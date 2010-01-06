include System::Windows
include System::Windows::Controls
include System::Windows::Shapes
include System::Windows::Media

class System::Windows::Threading::Dispatcher
  load_assembly 'System.Core'
  alias old_begin_invoke begin_invoke
  def begin_invoke(&b)
    old_begin_invoke(System::Action.new(&b))
  end
end

class System::Windows::Media::Colors
  def self.lime
    Color.from_argb 0xff, 0x00, 0xff, 0x00
  end

  def self.violet
    Color.from_argb 0xff, 0xee, 0x82, 0xee
  end
end

class Object
  def self.build(*args, &b)
    inst = new(*args)
    inst.instance_eval(&b)
    inst
  end
end

class System::Windows::Controls::Panel
  alias old_background= background=
  def background=(value)
    self.old_background=(
      if value.kind_of?(Brush)
        value
      elsif value.kind_of?(String) || value.kind_of?(Symbol)
        SolidColorBrush.new Colors.send(value)
      else
        raise "Expected String, Symbol, or Brush, got #{value.class}"
      end
    )
    background
  end
end