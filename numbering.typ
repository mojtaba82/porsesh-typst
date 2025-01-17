#let _base(a, b) = {
  let r
  let result = ()
  while a >= b {
    result.push(calc.rem(a,b))
    a = calc.div-euclid(a,b)
  }
  result.push(a)
  return result.rev()
}
#let __numbering(symbols, number) = {
  let len = symbols.len()
  let a = number
  let b
  let result = ""
  while number > 0 {
    a = int((number - 1) / len)
    b = calc.rem(number - 1, len)
    result = symbols.at(b) + result
    number = a
  }
  result
}
#let alphabet-fa = (
  str.from-unicode(1570), str.from-unicode(1576),
  str.from-unicode(1662), str.from-unicode(1578),
  str.from-unicode(1579), str.from-unicode(1580),
  str.from-unicode(1670), str.from-unicode(1581),
  str.from-unicode(1582), str.from-unicode(1583),
  str.from-unicode(1584), str.from-unicode(1585),
  str.from-unicode(1586), str.from-unicode(1688),
  str.from-unicode(1587), str.from-unicode(1588),
  str.from-unicode(1589), str.from-unicode(1590),
  str.from-unicode(1591), str.from-unicode(1592),
  str.from-unicode(1593), str.from-unicode(1594),
  str.from-unicode(1601), str.from-unicode(1602),
  str.from-unicode(1705), str.from-unicode(1711),
  str.from-unicode(1604), str.from-unicode(1605),
  str.from-unicode(1606), str.from-unicode(1608),
  str.from-unicode(1607), str.from-unicode(1740)
)
#__numbering(alphabet-fa,33)