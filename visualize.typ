#let bezier-cubic(length: 1cm, a, b, c, d) = {
  (a, b, c, d) = (a, b, c, d).map(item => {
    (item.at(0) * length, item.at(1) * length)
  })
  return ( (a, (0pt, 0pt), (b.at(0) - a.at(0), b.at(1) - a.at(1)) ), ( d, (c.at(0) - d.at(0), c.at(1) - d.at(1)), (0pt,0pt) ))
}
#let arc(start, end, center) = {
  let a = (start.at(0) - center.at(0), start.at(1) - center.at(1))
  let b = (end.at(0) - center.at(0), end.at(1) - center.at(1))
  let q1 = a.at(0) * a.at(0) + a.at(1) * a.at(1)
  let q2 = q1 + a.at(0) * b.at(0) + a.at(1) * b.at(1)
  let k2 = (4 / 3) * (calc.sqrt(2 * q1 * q2) - q2) / (a.at(0) * b.at(1) - a.at(1) * b.at(0))
  let c-out = (center.at(0) + a.at(0) - k2 * a.at(1), center.at(1) + a.at(1) + k2 * a.at(0))
  let c-in = (center.at(0) + b.at(0) + k2 * b.at(1), center.at(1) + b.at(1) -k2 * b.at(0))
  return (start, c-out, c-in, end)
}
#let shift(dx: 0, dy: 0, ..points) = {
  points = points.pos()
  points.map(item => {
    (item.at(0) + dx, item.at(1) + dy)
  })
}
#let float-to-length(unit: 1cm, ..points) = {
  points = points.pos()
  points.map(item => {
    (item.at(0) * unit, item.at(1) * unit)
  })
}
