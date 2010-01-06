class Bouncer
  def initialize xvelocity, yvelocity, canvas
    @xvelocity = xvelocity
    @yvelocity = yvelocity
    @canvas = canvas
  end

  def update target
    if (Canvas.get_left(target) + @xvelocity) >= (@canvas.actual_width - target.width)  or (Canvas.get_left(target) + @xvelocity) <= 0
      @xvelocity = -@xvelocity
    end
    if (Canvas.get_top(target)  + @yvelocity) >= (@canvas.actual_height - target.height) or (Canvas.get_top(target)  + @yvelocity) <= 0
      @yvelocity = -@yvelocity
    end
    Canvas.set_top  target, Canvas.get_top(target)  + @yvelocity
    Canvas.set_left target, Canvas.get_left(target) + @xvelocity
  end
end