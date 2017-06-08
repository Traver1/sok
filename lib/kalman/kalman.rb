class Kalman
  include Numo

  attr_accessor :ft0, :pt1, :qt0, :gt0, :xht1, :ht0, :rt0 

  def predict(ut0)
    ut0 = 0 if not ut0
    @xht0 = @ft0.dot(@xht1) + ut0
    @pt0 = @ft0.dot(@pt1).dot(@ft0.transpose)+@gt0.dot(@qt0).dot(@gt0.transpose)
    [@xht0, @pt0]
  end

  def update(zt0)
    @xht1 = @xht0 + kt0.dot(et0(zt0))
    ktht = kt0.dot(@ht0)
    @pt1 = (Int32.eye(*ktht.shape) - ktht).dot(@pt0)
    [@xht1, @pt1]
  end

  def observe(zt0, ut0=nil)
    predict(ut0)
    update(zt0)
  end

  def et0(zt0)
    zt0 - @ht0.dot(@xht0)
  end

  def st0
    @rt0 + @ht0.dot(@pt0).dot(@ht0.transpose)
  end

  def kt0
    @pt0.dot(@ht0.transpose).dot(Matrix[*st0.to_a].inv.to_a)
  end
end
