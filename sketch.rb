class DrawingSurface < UserControl
  include System
  include System::Windows::Threading
  
  class << self
    attr_reader :current
  
    def create(sketch_class)
      @current = self.new
      Application.current.root_visual = @current
      @current.content = Canvas.build do
        self.background = :black
        self.loaded do |_,_|
          DrawingSurface.current.sketch = sketch_class
          DrawingSurface.current.start
        end
      end
      @current
    end
  end
  
  def initialize
    @timer = DispatcherTimer.new
    @timer.tick do |s,e|
      @each_frame_method.call if @each_frame_method
    end
    @timer.interval = TimeSpan.new(0,0,0,0,1000/30);
  end
  
  def sketch
    @sketch
  end

  def sketch=(sketch_class)
    @sketch = sketch_class.new(content)
    content.mouse_left_button_down.add @sketch.method(:mouse_pressed) if @sketch.respond_to? :mouse_pressed
    content.mouse_left_button_up.add @sketch.method(:mouse_released) if @sketch.respond_to? :mouse_released
    content.mouse_move.add @sketch.method(:mouse_dragged) if @sketch.respond_to? :mouse_dragged
    @each_frame_method = @sketch.respond_to?(:draw) ? @sketch.method(:draw) : nil
    @sketch.setup if @sketch.respond_to?(:setup)
    $sketch = @sketch
  end
  
  def start
    @timer.start
  end
end

class Sketch
  attr_reader :container

  def initialize(canvas)
    @container = canvas
  end
  
  def self.create_sketch
    DrawingSurface.create(self)
  end
  
  def dimensions
    [container.actual_width, container.actual_height]
  end
  
  def rectangle(fields = {})
    shape Rectangle, fields
  end
  
  def square(fields = {})
    box_variant_of :rectangle, fields
  end

  def ellipse(fields = {})
    shape Ellipse, fields
  end

  def circle(fields = {})
    box_variant_of :ellipse, fields
  end

private

  def box_variant_of(name, fields)
    size = fields.delete(:size)
    send(name, {:width => size, :height => size}.merge(fields))
  end

  def shape(klass, fields)
    shape = klass.new
    process_fields shape, fields
    shape
  end

  def process_fields(obj, fields)
    left, top = fields.delete(:left), fields.delete(:top)
    dotted = {}
    fields.each do |key, value|
      if key.to_s.split('.').size > 1
        dotted[key] = value
      else
        obj.send("#{key}=", value)
      end
    end
    dotted.each do |key, value|
      obj.instance_eval{ @__tmp = value }
      obj.instance_eval("self.#{key} = @__tmp; @__tmp = nil")
    end
    Canvas.set_left(obj, left) if left
    Canvas.set_top(obj, top) if top
  end

end
