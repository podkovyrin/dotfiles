return {
  black = 0xff000000,
  white = 0xffffffff,
  red = 0xfffc5d7c,
  green = 0xff9ed072,
  blue = 0xff1165ba,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  magenta = 0xffb39df3,
  grey = 0xff7f8490,
  transparent = 0x00000000,

  bar = {
    bg = 0xff000000,
    border = 0xff000000,
  },
  popup = {
    bg = 0xffeaebec,
    border = 0xffb8b9ba
  },
  bg1 = 0x38ffffff,
  bg2 = 0x44ffffff,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
